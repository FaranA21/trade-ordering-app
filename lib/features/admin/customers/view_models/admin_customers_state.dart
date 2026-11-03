import 'package:equatable/equatable.dart';

import 'package:merchant_demo/data/models/customer.dart';

class CustomerSummary extends Equatable {
  const CustomerSummary({required this.customer, required this.orderCount, this.lastOrderAt});

  final Customer customer;
  final int orderCount;
  final DateTime? lastOrderAt;

  @override
  List<Object?> get props => [customer, orderCount, lastOrderAt];
}

class AdminCustomersState extends Equatable {
  const AdminCustomersState({this.customers = const []});

  final List<CustomerSummary> customers;

  double get totalOwed => customers.fold(0.0, (s, c) => s + c.customer.balance);

  @override
  List<Object?> get props => [customers];
}
