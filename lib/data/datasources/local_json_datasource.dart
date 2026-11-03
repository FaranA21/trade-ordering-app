import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import 'package:merchant_demo/core/constants/app_config.dart';
import 'package:merchant_demo/data/datasources/trade_datasource.dart';
import 'package:merchant_demo/data/models/app_session.dart';
import 'package:merchant_demo/data/models/cart_line.dart';
import 'package:merchant_demo/data/models/customer.dart';
import 'package:merchant_demo/data/models/order.dart';
import 'package:merchant_demo/data/models/order_item.dart';
import 'package:merchant_demo/data/models/order_status.dart';
import 'package:merchant_demo/data/models/product.dart';

/// Offline fallback: the JSON in assets/data, kept in memory while the app runs.
/// Run with --dart-define=USE_FIREBASE=false to use it.
class LocalJsonDatasource implements TradeDatasource {
  final _products = _Store<Product>();
  final _customers = _Store<Customer>();
  final _orders = _Store<TradeOrder>();
  bool _loaded = false;
  AppSession? _session;

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    _products.set((await _loadList('assets/data/products.json')).map(Product.fromJson).toList());
    _customers.set((await _loadList('assets/data/customers.json')).map(Customer.fromJson).toList());
    _orders.set(_shiftToToday((await _loadList('assets/data/orders.json')).map(TradeOrder.fromJson).toList()));
    _loaded = true;
  }

  Future<List<Map<String, dynamic>>> _loadList(String path) async {
    final raw = await rootBundle.loadString(path);
    return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  }

  /// The dummy orders were written for 3 Nov 2026. Move the dates forward so
  /// the newest order day is always today, otherwise the dashboard goes stale.
  static List<TradeOrder> _shiftToToday(List<TradeOrder> orders) {
    if (orders.isEmpty) return orders;
    final newest = orders.map((o) => o.placedAt).reduce((a, b) => a.isAfter(b) ? a : b);
    final now = DateTime.now();
    final days = DateTime(now.year, now.month, now.day)
        .difference(DateTime(newest.year, newest.month, newest.day))
        .inDays;
    if (days <= 0) return orders;
    return orders.map((o) => o.shifted(Duration(days: days))).toList();
  }

  // ------------------------------------------------------------ auth

  @override
  Future<AppSession?> currentSession() async => _session;

  @override
  Future<AppSession?> signInBuyer(String accountNo, String password) async {
    await _ensureLoaded();
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (password.trim() != AppConfig.demoPassword) return null;
    for (final c in _customers.items) {
      if (c.accountNo.toUpperCase() == accountNo.trim().toUpperCase()) {
        return _session = AppSession(uid: c.id, role: UserRole.buyer, customerId: c.id);
      }
    }
    return null;
  }

  @override
  Future<AppSession?> signInAdmin(String email, String password) async {
    await _ensureLoaded();
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (email.trim().toLowerCase() != AppConfig.adminEmail || password.trim() != AppConfig.demoPassword) return null;
    return _session = const AppSession(uid: 'admin', role: UserRole.admin);
  }

  @override
  Future<void> signOut() async => _session = null;

  // ------------------------------------------------------------ reads

  @override
  Stream<List<Product>> watchProducts() async* {
    await _ensureLoaded();
    yield* _products.watch();
  }

  @override
  Stream<List<Customer>> watchCustomers(AppSession session) async* {
    await _ensureLoaded();
    yield* _customers.watch().map((all) => session.isAdmin ? all : all.where((c) => c.id == session.customerId).toList());
  }

  @override
  Stream<List<TradeOrder>> watchOrders(AppSession session) async* {
    await _ensureLoaded();
    yield* _orders
        .watch()
        .map((all) => session.isAdmin ? all : all.where((o) => o.customerId == session.customerId).toList());
  }

  // ------------------------------------------------------------ writes

  @override
  Future<void> updateProduct(String productId, {double? tradePrice, bool? available}) async {
    _products.update((p) => p.id == productId ? p.copyWith(tradePrice: tradePrice, available: available) : p);
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    _orders.update((o) => o.id == orderId ? o.copyWith(status: status) : o);
  }

  @override
  Future<TradeOrder> placeOrder({
    required Customer customer,
    required List<CartLine> lines,
    required Fulfilment fulfilment,
    required String poReference,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final nextNo = _orders.items
            .map((o) => int.tryParse(o.orderNo.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0)
            .fold<int>(0, (a, b) => a > b ? a : b) +
        1;
    final order = TradeOrder(
      id: 'o${DateTime.now().microsecondsSinceEpoch}',
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
    final qty = {for (final l in lines) l.product.id: l.qty};
    _products.update((p) => qty.containsKey(p.id) ? p.copyWith(stock: (p.stock - qty[p.id]!).clamp(0, 1 << 30)) : p);
    _customers.update((c) => c.id == customer.id ? c.copyWith(balance: _round(c.balance + order.total)) : c);
    _orders.set([..._orders.items, order]);
    return order;
  }

  static double _round(double v) => (v * 100).roundToDouble() / 100;
}

/// A list plus a stream that replays the current list to each new listener.
class _Store<T> {
  List<T> items = const [];
  final _controller = StreamController<List<T>>.broadcast();

  void set(List<T> next) {
    items = List.unmodifiable(next);
    _controller.add(items);
  }

  void update(T Function(T) change) => set(items.map(change).toList());

  Stream<List<T>> watch() => Stream.multi((listener) {
        listener.add(items);
        final sub = _controller.stream.listen(listener.add);
        listener.onCancel = sub.cancel;
      });
}
