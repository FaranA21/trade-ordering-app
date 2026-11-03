import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:merchant_demo/data/models/order.dart';
import 'package:merchant_demo/data/models/order_status.dart';
import 'package:merchant_demo/data/repositories/trade_repository.dart';
import 'package:merchant_demo/features/admin/orders/view_models/admin_orders_state.dart';

class AdminOrdersViewModel extends Cubit<AdminOrdersState> {
  AdminOrdersViewModel(this._repo) : super(const AdminOrdersState()) {
    // New orders from the buyer app appear here straight away.
    _sub = _repo.changes.where((c) => c == RepoChange.orders).listen((_) => _reload());
    _reload();
  }

  final TradeRepository _repo;
  late final StreamSubscription<RepoChange> _sub;

  void _reload() => emit(state.copyWith(orders: _repo.getAllOrders()));

  void setFilter(OrderStatus? status) =>
      emit(status == null ? state.copyWith(clearFilter: true) : state.copyWith(filter: status));

  void search(String query) => emit(state.copyWith(query: query));

  /// Moves the order to the next status: Placed > Packed > Out for delivery > Delivered.
  /// A delivered order goes back to Placed, so the demo can be shown again.
  void advance(TradeOrder order) {
    final next = order.status.next ?? OrderStatus.placed;
    _repo.updateOrderStatus(order.id, next);
  }

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}
