import 'package:equatable/equatable.dart';

import 'package:merchant_demo/data/models/customer.dart';

class AuthState extends Equatable {
  const AuthState({this.customer, this.isAdmin = false, this.loading = false, this.error});

  /// Set when a buyer is signed in.
  final Customer? customer;

  /// True when branch staff are signed in to the admin panel.
  final bool isAdmin;
  final bool loading;
  final String? error;

  bool get signedIn => customer != null;

  @override
  List<Object?> get props => [customer, isAdmin, loading, error];
}
