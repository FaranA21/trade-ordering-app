import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:merchant_demo/data/datasources/trade_datasource.dart';
import 'package:merchant_demo/data/models/app_session.dart';
import 'package:merchant_demo/data/models/cart_line.dart';
import 'package:merchant_demo/data/models/customer.dart';
import 'package:merchant_demo/data/models/order.dart';
import 'package:merchant_demo/data/models/order_status.dart';
import 'package:merchant_demo/data/models/product.dart';

/// What changed, so view models only reload what they need.
enum RepoChange { products, orders, customers, session }

/// Single source of truth for the app (the Model layer in MVVM).
///
/// After sign-in it listens to live lists from the datasource (Firestore or
/// local JSON) and keeps the latest copy in memory, so view models can read
/// synchronously. Every update from the datasource is announced on [changes].
class TradeRepository {
  TradeRepository(this._ds);

  final TradeDatasource _ds;

  List<Product> _products = const [];
  List<Customer> _customers = const [];
  List<TradeOrder> _orders = const [];
  AppSession? _session;
  final List<StreamSubscription<dynamic>> _subs = [];

  final StreamController<RepoChange> _changes = StreamController<RepoChange>.broadcast();

  /// Buyer app and admin listen to this. With Firebase, a status change made
  /// on another device arrives here within a second or so.
  Stream<RepoChange> get changes => _changes.stream;

  AppSession? get session => _session;

  /// Restores a previous sign-in (Firebase keeps it per browser tab).
  Future<void> init() async {
    final s = await _ds.currentSession();
    if (s != null) await _startSession(s);
  }

  // ---------------------------------------------------------------- session

  /// Returns the customer, or null when the details are wrong.
  Future<Customer?> signInBuyer(String accountNo, String password) async {
    final s = await _ds.signInBuyer(accountNo, password);
    if (s == null) return null;
    await _startSession(s);
    return getCustomer(s.customerId!);
  }

  Future<bool> signInAdmin(String email, String password) async {
    final s = await _ds.signInAdmin(email, password);
    if (s == null) return false;
    await _startSession(s);
    return true;
  }

  Future<void> signOut() async {
    await _stopSession();
    await _ds.signOut();
  }

  Future<void> _startSession(AppSession s) async {
    await _stopSession();
    _session = s;
    final ready = <Future<void>>[
      _listen<Product>(_ds.watchProducts(), (v) => _products = v, RepoChange.products),
      _listen<Customer>(_ds.watchCustomers(s), (v) => _customers = v, RepoChange.customers),
      _listen<TradeOrder>(_ds.watchOrders(s), (v) => _orders = v, RepoChange.orders),
    ];
    // Wait for the first snapshot of each list so screens open with data.
    await Future.wait(ready);
    _emit(RepoChange.session);
  }

  /// Subscribes to a live list. The returned future completes on the first
  /// value (or on an error, so a permissions problem cannot hang the app).
  Future<void> _listen<T>(Stream<List<T>> stream, void Function(List<T>) store, RepoChange change) {
    final first = Completer<void>();
    _subs.add(stream.listen(
      (items) {
        store(List.unmodifiable(items));
        _emit(change);
        if (!first.isCompleted) first.complete();
      },
      onError: (Object e) {
        debugPrint('TradeRepository: $change stream error: $e');
        if (!first.isCompleted) first.complete();
      },
    ));
    return first.future;
  }

  Future<void> _stopSession() async {
    for (final s in _subs) {
      await s.cancel();
    }
    _subs.clear();
    _products = const [];
    _customers = const [];
    _orders = const [];
    _session = null;
    _emit(RepoChange.session);
  }

  void _emit(RepoChange c) {
    if (!_changes.isClosed) _changes.add(c);
  }

  // --------------------------------------------------------------- products

  List<Product> getProducts({bool includeHidden = false}) =>
      includeHidden ? _products : _products.where((p) => p.available).toList();

  List<String> getCategories() {
    final seen = <String>[];
    for (final p in _products) {
      if (!seen.contains(p.category)) seen.add(p.category);
    }
    return seen;
  }

  Product? getProduct(String id) {
    for (final p in _products) {
      if (p.id == id) return p;
    }
    return null;
  }

  /// This customer's price, ex VAT, rounded to the penny.
  double priceFor(Product product, Customer customer) =>
      (product.tradePrice * (1 - customer.discountPct / 100) * 100).roundToDouble() / 100;

  Future<void> updateProduct(String id, {double? tradePrice, bool? available}) =>
      _ds.updateProduct(id, tradePrice: tradePrice, available: available);

  // -------------------------------------------------------------- customers

  List<Customer> getCustomers() => _customers;

  Customer? getCustomer(String id) {
    for (final c in _customers) {
      if (c.id == id) return c;
    }
    return null;
  }

  // ----------------------------------------------------------------- orders

  /// Orders this session can see, newest first.
  List<TradeOrder> getAllOrders() => List.of(_orders)..sort((a, b) => b.placedAt.compareTo(a.placedAt));

  List<TradeOrder> getOrdersFor(String customerId) =>
      getAllOrders().where((o) => o.customerId == customerId).toList();

  TradeOrder? getLastOrderFor(String customerId) {
    final list = getOrdersFor(customerId);
    return list.isEmpty ? null : list.first;
  }

  TradeOrder? getOrder(String id) {
    for (final o in _orders) {
      if (o.id == id) return o;
    }
    return null;
  }

  int countOrdersFor(String customerId) => _orders.where((o) => o.customerId == customerId).length;

  Future<TradeOrder> placeOrder({
    required Customer customer,
    required List<CartLine> lines,
    required Fulfilment fulfilment,
    String poReference = '',
  }) =>
      _ds.placeOrder(customer: customer, lines: lines, fulfilment: fulfilment, poReference: poReference);

  Future<void> updateOrderStatus(String orderId, OrderStatus status) => _ds.updateOrderStatus(orderId, status);

  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    _changes.close();
  }
}
