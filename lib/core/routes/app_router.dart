import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:merchant_demo/features/account/views/account_view.dart';
import 'package:merchant_demo/features/shell/views/buyer_shell_view.dart';
import 'package:merchant_demo/features/cart/views/cart_view.dart';
import 'package:merchant_demo/features/catalogue/views/catalogue_view.dart';
import 'package:merchant_demo/features/auth/views/admin_login_view.dart';
import 'package:merchant_demo/features/auth/views/login_view.dart';
import 'package:merchant_demo/features/orders/views/order_detail_view.dart';
import 'package:merchant_demo/features/orders/views/orders_view.dart';
import 'package:merchant_demo/features/catalogue/views/product_detail_view.dart';
import 'package:merchant_demo/features/auth/view_models/auth_view_model.dart';
import 'package:merchant_demo/features/admin/customers/views/admin_customers_view.dart';
import 'package:merchant_demo/features/admin/dashboard/views/dashboard_view.dart';
import 'package:merchant_demo/features/admin/orders/views/admin_orders_view.dart';
import 'package:merchant_demo/features/admin/products/views/admin_products_view.dart';
import 'package:merchant_demo/features/admin/shell/views/admin_shell_view.dart';

class Routes {
  Routes._();

  static const login = '/';
  static const shop = '/shop';
  static String product(String id) => '/shop/product/$id';
  static const cart = '/cart';
  static const orders = '/orders';
  static String order(String id) => '/orders/$id';
  static const account = '/account';
  static const admin = '/admin';
  static const adminLogin = '/admin/login';
  static const adminOrders = '/admin/orders';
  static const adminProducts = '/admin/products';
  static const adminCustomers = '/admin/customers';

  /// Orders filtered to one status, e.g. the packing list (placed).
  static String adminOrdersWithStatus(String statusKey) => '/admin/orders?status=$statusKey';
}

class AppRouter {
  AppRouter._();

  static final _rootKey = GlobalKey<NavigatorState>();

  static GoRouter create(AuthViewModel auth) {
    return GoRouter(
      navigatorKey: _rootKey,
      initialLocation: Routes.login,
      refreshListenable: _StreamListenable(auth.stream),
      redirect: (context, state) {
        final path = state.matchedLocation;
        final a = auth.state;

        // Admin panel: staff only.
        if (path.startsWith(Routes.admin)) {
          if (path == Routes.adminLogin) return a.isAdmin ? Routes.admin : null;
          return a.isAdmin ? null : Routes.adminLogin;
        }

        // Buyer app: a signed-in trade customer only.
        if (!a.signedIn && path != Routes.login) return Routes.login;
        if (a.signedIn && path == Routes.login) return Routes.shop;
        return null;
      },
      routes: [
        GoRoute(path: Routes.login, builder: (_, __) => const LoginView()),

        // Tabs with the bottom bar: Shop, Orders, Account.
        StatefulShellRoute.indexedStack(
          builder: (_, __, shell) => BuyerShellView(shell: shell),
          branches: [
            StatefulShellBranch(routes: [
              GoRoute(path: Routes.shop, builder: (_, __) => const CatalogueView()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: Routes.orders, builder: (_, __) => const OrdersView()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: Routes.account, builder: (_, __) => const AccountView()),
            ]),
          ],
        ),

        // Full-screen pages, no bottom bar.
        GoRoute(
          path: '/shop/product/:id',
          parentNavigatorKey: _rootKey,
          builder: (_, state) => ProductDetailView(productId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: Routes.cart,
          parentNavigatorKey: _rootKey,
          builder: (_, __) => const CartView(),
        ),
        GoRoute(
          path: '/orders/:id',
          parentNavigatorKey: _rootKey,
          builder: (_, state) => OrderDetailView(orderId: state.pathParameters['id']!),
        ),

        GoRoute(path: Routes.adminLogin, builder: (_, __) => const AdminLoginView()),

        // Admin panel: side menu on wide screens, drawer on narrow ones.
        ShellRoute(
          builder: (_, state, child) => AdminShellView(location: state.uri.path, child: child),
          routes: [
            GoRoute(
              path: Routes.admin,
              pageBuilder: (_, __) => const NoTransitionPage(child: DashboardView()),
            ),
            GoRoute(
              path: Routes.adminOrders,
              pageBuilder: (_, state) => NoTransitionPage(
                key: ValueKey(state.uri.toString()),
                child: AdminOrdersView(
                  key: ValueKey(state.uri.toString()),
                  initialStatus: state.uri.queryParameters['status'],
                ),
              ),
            ),
            GoRoute(
              path: Routes.adminProducts,
              pageBuilder: (_, __) => const NoTransitionPage(child: AdminProductsView()),
            ),
            GoRoute(
              path: Routes.adminCustomers,
              pageBuilder: (_, __) => const NoTransitionPage(child: AdminCustomersView()),
            ),
          ],
        ),
      ],
    );
  }
}

/// Lets go_router re-run its redirect when the auth cubit emits.
class _StreamListenable extends ChangeNotifier {
  _StreamListenable(Stream<dynamic> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
