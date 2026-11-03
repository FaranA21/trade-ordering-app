import 'package:equatable/equatable.dart';

import 'package:merchant_demo/data/models/order.dart';
import 'package:merchant_demo/data/models/order_status.dart';
import 'package:merchant_demo/data/models/product.dart';

class DayValue extends Equatable {
  const DayValue(this.day, this.valueExVat);

  final DateTime day;
  final double valueExVat;

  @override
  List<Object?> get props => [day, valueExVat];
}

class DashboardState extends Equatable {
  const DashboardState({
    this.ordersToday = 0,
    this.toPackToday = 0,
    this.valueTodayExVat = 0,
    this.valueTodayIncVat = 0,
    this.openOrders = 0,
    this.outOfStock = 0,
    this.lowStock = 0,
    this.byDay = const [],
    this.statusCounts = const {},
    this.waiting = const [],
    this.lowStockProducts = const [],
    this.recent = const [],
  });

  final int ordersToday;

  /// Orders placed today that are not packed yet.
  final int toPackToday;
  final double valueTodayExVat;
  final double valueTodayIncVat;

  /// Not yet delivered or collected.
  final int openOrders;
  final int outOfStock;
  final int lowStock;

  /// Order value per day for the last 8 days that had orders, oldest first.
  final List<DayValue> byDay;
  final Map<OrderStatus, int> statusCounts;

  /// All orders still at Placed: the packing list.
  final List<TradeOrder> waiting;
  final List<Product> lowStockProducts;
  final List<TradeOrder> recent;

  bool get busiestDayIsToday {
    if (byDay.isEmpty) return false;
    final best = byDay.reduce((a, b) => a.valueExVat >= b.valueExVat ? a : b);
    final now = DateTime.now();
    return best.day.year == now.year && best.day.month == now.month && best.day.day == now.day;
  }

  @override
  List<Object?> get props => [
        ordersToday,
        toPackToday,
        valueTodayExVat,
        valueTodayIncVat,
        openOrders,
        outOfStock,
        lowStock,
        byDay,
        statusCounts,
        waiting,
        lowStockProducts,
        recent,
      ];
}
