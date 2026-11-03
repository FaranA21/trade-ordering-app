import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:merchant_demo/core/constants/app_config.dart';
import 'package:merchant_demo/data/repositories/trade_repository.dart';
import 'package:merchant_demo/features/auth/view_models/auth_state.dart';

class AuthViewModel extends Cubit<AuthState> {
  AuthViewModel(this._repo) : super(const AuthState()) {
    _fromSession();
    // Keep the buyer's balance fresh after each order, and follow sign-out.
    _sub = _repo.changes
        .where((c) => c == RepoChange.customers || c == RepoChange.session)
        .listen((_) => _fromSession());
  }

  final TradeRepository _repo;
  late final StreamSubscription<RepoChange> _sub;

  /// Rebuilds the state from the repository's session (also restores a
  /// sign-in kept by Firebase after a page refresh).
  void _fromSession() {
    if (state.loading) return;
    final s = _repo.session;
    if (s == null) {
      if (state.signedIn || state.isAdmin) emit(const AuthState());
      return;
    }
    if (s.isAdmin) {
      emit(const AuthState(isAdmin: true));
    } else {
      final customer = _repo.getCustomer(s.customerId!);
      if (customer != null) emit(AuthState(customer: customer));
    }
  }

  Future<void> signIn(String accountNo, String password) async {
    emit(const AuthState(loading: true));
    try {
      final customer = await _repo.signInBuyer(accountNo, password);
      emit(customer == null
          ? const AuthState(error: 'Account number or password is wrong. Try TA-4102 and ${AppConfig.demoPassword}.')
          : AuthState(customer: customer));
    } catch (_) {
      emit(const AuthState(error: 'Could not reach the server. Check your connection and try again.'));
    }
  }

  Future<void> signInAdmin(String email, String password) async {
    emit(const AuthState(loading: true));
    try {
      final ok = await _repo.signInAdmin(email, password);
      emit(ok ? const AuthState(isAdmin: true) : const AuthState(error: 'Email or password is wrong, or this is not a staff account.'));
    } catch (_) {
      emit(const AuthState(error: 'Could not reach the server. Check your connection and try again.'));
    }
  }

  Future<void> signOut() async {
    await _repo.signOut();
    emit(const AuthState());
  }

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}
