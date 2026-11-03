import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:merchant_demo/core/constants/app_config.dart';
import 'package:merchant_demo/data/datasources/trade_datasource.dart';
import 'package:merchant_demo/data/models/app_session.dart';
import 'package:merchant_demo/data/models/cart_line.dart';
import 'package:merchant_demo/data/models/customer.dart';
import 'package:merchant_demo/data/models/order.dart';
import 'package:merchant_demo/data/models/order_item.dart';
import 'package:merchant_demo/data/models/order_status.dart';
import 'package:merchant_demo/data/models/product.dart';

/// Firebase Auth + Cloud Firestore.
///
/// Collections (created by tool/seed/seed.js):
///   products/{productId}     the catalogue
///   customers/{uid}          one per trade account; the doc id is the buyer's Firebase uid
///   orders/{autoId}          customerId = the buyer's uid
///   admins/{uid}             branch staff; existence = admin rights
///   meta/counters            { lastOrderNo } for HM-xxxxx order numbers
///
/// firestore.rules makes sure a buyer can only read their own account and orders.
class FirestoreDatasource implements TradeDatasource {
  FirestoreDatasource({FirebaseAuth? auth, FirebaseFirestore? db})
      : _auth = auth ?? FirebaseAuth.instance,
        _db = db ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _products => _db.collection('products');
  CollectionReference<Map<String, dynamic>> get _customers => _db.collection('customers');
  CollectionReference<Map<String, dynamic>> get _orders => _db.collection('orders');
  DocumentReference<Map<String, dynamic>> get _counters => _db.doc('meta/counters');

  // ------------------------------------------------------------ auth

  @override
  Future<AppSession?> currentSession() async {
    // On web the signed-in user is restored asynchronously; wait for it once.
    final user = _auth.currentUser ?? await _auth.authStateChanges().first;
    if (user == null) return null;
    return _sessionFor(user);
  }

  /// Works out the role: an admins/{uid} doc means staff, a customers/{uid} doc means buyer.
  Future<AppSession?> _sessionFor(User user) async {
    final admin = await _db.doc('admins/${user.uid}').get();
    if (admin.exists) return AppSession(uid: user.uid, role: UserRole.admin);
    final customer = await _customers.doc(user.uid).get();
    if (customer.exists) return AppSession(uid: user.uid, role: UserRole.buyer, customerId: user.uid);
    return null;
  }

  @override
  Future<AppSession?> signInBuyer(String accountNo, String password) async {
    final session = await _signIn(AppConfig.emailForAccount(accountNo), password);
    if (session == null || session.role != UserRole.buyer) {
      await _auth.signOut();
      return null;
    }
    return session;
  }

  @override
  Future<AppSession?> signInAdmin(String email, String password) async {
    final session = await _signIn(email.trim(), password);
    if (session == null || !session.isAdmin) {
      await _auth.signOut();
      return null;
    }
    return session;
  }

  Future<AppSession?> _signIn(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password.trim());
      final user = cred.user;
      return user == null ? null : _sessionFor(user);
    } on FirebaseAuthException {
      return null;
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  // ------------------------------------------------------------ reads

  @override
  Stream<List<Product>> watchProducts() => _products
      .snapshots()
      .map((s) => s.docs.map((d) => Product.fromJson({...d.data(), 'id': d.id})).toList()
        ..sort((a, b) => a.id.compareTo(b.id)));

  @override
  Stream<List<Customer>> watchCustomers(AppSession session) {
    if (session.isAdmin) {
      return _customers.snapshots().map((s) => s.docs.map(_customerFrom).toList());
    }
    return _customers.doc(session.customerId).snapshots().map((d) => d.exists ? [_customerFrom(d)] : <Customer>[]);
  }

  @override
  Stream<List<TradeOrder>> watchOrders(AppSession session) {
    // Buyers may only query their own orders (the rules check this).
    final Query<Map<String, dynamic>> query =
        session.isAdmin ? _orders : _orders.where('customerId', isEqualTo: session.customerId);
    return query.snapshots().map((s) => s.docs.map(_orderFrom).toList());
  }

  static Customer _customerFrom(DocumentSnapshot<Map<String, dynamic>> d) =>
      Customer.fromJson({...d.data()!, 'id': d.id});

  static TradeOrder _orderFrom(DocumentSnapshot<Map<String, dynamic>> d) {
    final data = {...d.data()!, 'id': d.id};
    final placed = data['placedAt'];
    data['placedAt'] = placed is Timestamp ? placed.toDate().toIso8601String() : '$placed';
    return TradeOrder.fromJson(data);
  }

  // ------------------------------------------------------------ writes

  @override
  Future<void> updateProduct(String productId, {double? tradePrice, bool? available}) => _products.doc(productId).update({
        if (tradePrice != null) 'tradePrice': tradePrice,
        if (available != null) 'available': available,
      });

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) =>
      _orders.doc(orderId).update({'status': status.key});

  @override
  Future<TradeOrder> placeOrder({
    required Customer customer,
    required List<CartLine> lines,
    required Fulfilment fulfilment,
    required String poReference,
  }) {
    return _db.runTransaction<TradeOrder>((tx) async {
      // All reads first (a Firestore transaction rule).
      final counter = await tx.get(_counters);
      final customerSnap = await tx.get(_customers.doc(customer.id));
      final productSnaps = <DocumentSnapshot<Map<String, dynamic>>>[];
      for (final l in lines) {
        productSnaps.add(await tx.get(_products.doc(l.product.id)));
      }

      final nextNo = ((counter.data()?['lastOrderNo'] as num?)?.toInt() ?? 20000) + 1;
      final ref = _orders.doc();
      final order = TradeOrder(
        id: ref.id,
        orderNo: 'HM-$nextNo',
        customerId: customer.id,
        customerName: customer.companyName,
        placedAt: DateTime.now(),
        status: OrderStatus.placed,
        fulfilment: fulfilment,
        poReference: poReference.trim(),
        deliveryAddress: customer.address,
        items: [
          for (final l in lines)
            OrderItem(
              productId: l.product.id,
              name: l.product.name,
              packSize: l.product.packSize,
              qty: l.qty,
              unitPrice: l.unitPrice,
            ),
        ],
      );

      final data = order.toJson()..remove('id');
      data['placedAt'] = Timestamp.fromDate(order.placedAt);
      tx.set(ref, data);
      tx.update(_counters, {'lastOrderNo': nextNo});

      for (var i = 0; i < lines.length; i++) {
        final stock = (productSnaps[i].data()?['stock'] as num?)?.toInt() ?? 0;
        final next = (stock - lines[i].qty).clamp(0, stock);
        if (next < stock) tx.update(productSnaps[i].reference, {'stock': next});
      }

      final balance = (customerSnap.data()?['balance'] as num?)?.toDouble() ?? 0;
      tx.update(customerSnap.reference, {'balance': ((balance + order.total) * 100).roundToDouble() / 100});
      return order;
    });
  }
}
