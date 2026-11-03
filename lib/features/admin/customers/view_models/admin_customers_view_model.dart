import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:merchant_demo/data/repositories/trade_repository.dart';
import 'package:merchant_demo/features/admin/customers/view_models/admin_customers_state.dart';

class AdminCustomersViewModel extends Cubit<AdminCustomersState> {
  AdminCustomersViewModel(this._repo) : super(const AdminCustomersState()) {
    // Balances and order counts change when a buyer places an order.
    _sub = _repo.changes.where((c) => c != RepoChange.products).listen((_) => _reload());
    _reload();
  }

  final TradeRepository _repo;
  late final StreamSubscription<RepoChange> _sub;

  void _reload() {
    final list = _repo.getCustomers().map((c) {
      final last = _repo.getLastOrderFor(c.id);
      return CustomerSummary(customer: c, orderCount: _repo.countOrdersFor(c.id), lastOrderAt: last?.placedAt);
    }).toList()
      ..sort((a, b) => b.customer.balance.compareTo(a.customer.balance));
    emit(AdminCustomersState(customers: list));
  }

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}
