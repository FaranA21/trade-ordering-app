import 'package:equatable/equatable.dart';

import 'package:merchant_demo/data/models/order.dart';
import 'package:merchant_demo/data/models/order_status.dart';

class AdminOrdersState extends Equatable {
  const AdminOrdersState({this.orders = const [], this.filter, this.query = ''});

  /// All orders, newest first.
  final List<TradeOrder> orders;

  /// Null means all statuses.
  final OrderStatus? filter;
  final String query;

  List<TradeOrder> get visible {
    final q = query.trim().toLowerCase();
    return orders.where((o) {
      final statusOk = filter == null || o.status == filter;
      final queryOk = q.isEmpty || o.orderNo.toLowerCase().contains(q) || o.customerName.toLowerCase().contains(q);
      return statusOk && queryOk;
    }).toList();
  }

  int countOf(OrderStatus? status) =>
      status == null ? orders.length : orders.where((o) => o.status == status).length;

  AdminOrdersState copyWith({List<TradeOrder>? orders, OrderStatus? filter, bool clearFilter = false, String? query}) =>
      AdminOrdersState(
        orders: orders ?? this.orders,
        filter: clearFilter ? null : (filter ?? this.filter),
        query: query ?? this.query,
      );

  @override
  List<Object?> get props => [orders, filter, query];
}
