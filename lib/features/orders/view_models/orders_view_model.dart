import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:merchant_demo/data/models/product.dart';
import 'package:merchant_demo/data/repositories/trade_repository.dart';
import 'package:merchant_demo/features/orders/view_models/orders_state.dart';

class OrdersViewModel extends Cubit<OrdersState> {
  OrdersViewModel(this._repo) : super(const OrdersState()) {
    // Status changes made in the admin panel appear here straight away.
    _sub = _repo.changes
        .where((c) => c == RepoChange.orders || c == RepoChange.session)
        .listen((_) => _reload());
    _reload();
  }

  final TradeRepository _repo;
  late final StreamSubscription<RepoChange> _sub;
  /// The signed-in buyer, taken from the session so a restored sign-in works too.
  String? get _customerId => _repo.session?.customerId;

  /// Kept for the sign-in screen; the data now follows the session by itself.
  void load([String? _]) => _reload();

  void _reload() {
    final id = _customerId;
    emit(OrdersState(orders: id == null ? const [] : _repo.getOrdersFor(id)));
  }

  /// Used for item photos in order cards.
  Product? productFor(String productId) => _repo.getProduct(productId);

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}
