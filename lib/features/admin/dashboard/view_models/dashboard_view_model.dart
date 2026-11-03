import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:merchant_demo/data/models/order_status.dart';
import 'package:merchant_demo/data/models/product.dart';
import 'package:merchant_demo/data/repositories/trade_repository.dart';
import 'package:merchant_demo/features/admin/dashboard/view_models/dashboard_state.dart';

class DashboardViewModel extends Cubit<DashboardState> {
  DashboardViewModel(this._repo) : super(const DashboardState()) {
    _sub = _repo.changes.listen((_) => load());
    load();
  }

  final TradeRepository _repo;
  late final StreamSubscription<RepoChange> _sub;

  static DateTime _dayOf(DateTime d) => DateTime(d.year, d.month, d.day);
  static double _round(double v) => (v * 100).roundToDouble() / 100;

  void load() {
    final orders = _repo.getAllOrders();
    final products = _repo.getProducts(includeHidden: true);
    final today = _dayOf(DateTime.now());

    final todays = orders.where((o) => _dayOf(o.placedAt) == today).toList();

    // Group order value by day, keep the last 8 days that had orders.
    final perDay = <DateTime, double>{};
    for (final o in orders) {
      final d = _dayOf(o.placedAt);
      perDay[d] = (perDay[d] ?? 0) + o.subtotal;
    }
    final days = perDay.keys.toList()..sort();
    final last8 = days.length > 8 ? days.sublist(days.length - 8) : days;

    final counts = {for (final s in OrderStatus.values) s: orders.where((o) => o.status == s).length};
    final lowOrOut = products.where((p) => p.stockLevel != StockLevel.inStock).toList()
      ..sort((a, b) => a.stock.compareTo(b.stock));

    emit(DashboardState(
      ordersToday: todays.length,
      toPackToday: todays.where((o) => o.status == OrderStatus.placed).length,
      valueTodayExVat: _round(todays.fold(0.0, (s, o) => s + o.subtotal)),
      valueTodayIncVat: _round(todays.fold(0.0, (s, o) => s + o.total)),
      openOrders: orders.where((o) => o.isActive).length,
      outOfStock: products.where((p) => p.stockLevel == StockLevel.out).length,
      lowStock: products.where((p) => p.stockLevel == StockLevel.low).length,
      byDay: [for (final d in last8) DayValue(d, _round(perDay[d]!))],
      statusCounts: counts,
      waiting: orders.where((o) => o.status == OrderStatus.placed).toList(),
      lowStockProducts: lowOrOut.take(4).toList(),
      recent: orders.take(6).toList(),
    ));
  }

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}
