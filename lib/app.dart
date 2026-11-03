import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:merchant_demo/core/constants/brand_config.dart';
import 'package:merchant_demo/core/routes/app_router.dart';
import 'package:merchant_demo/core/theme/app_theme.dart';
import 'package:merchant_demo/data/repositories/trade_repository.dart';
import 'package:merchant_demo/features/admin/customers/view_models/admin_customers_view_model.dart';
import 'package:merchant_demo/features/admin/dashboard/view_models/dashboard_view_model.dart';
import 'package:merchant_demo/features/admin/orders/view_models/admin_orders_view_model.dart';
import 'package:merchant_demo/features/admin/products/view_models/admin_products_view_model.dart';
import 'package:merchant_demo/features/auth/view_models/auth_view_model.dart';
import 'package:merchant_demo/features/cart/view_models/cart_view_model.dart';
import 'package:merchant_demo/features/catalogue/view_models/catalogue_view_model.dart';
import 'package:merchant_demo/features/orders/view_models/orders_view_model.dart';

class MerchantDemoApp extends StatefulWidget {
  const MerchantDemoApp({super.key, required this.repository});

  final TradeRepository repository;

  @override
  State<MerchantDemoApp> createState() => _MerchantDemoAppState();
}

class _MerchantDemoAppState extends State<MerchantDemoApp> {
  late final AuthViewModel _auth = AuthViewModel(widget.repository);
  late final GoRouter _router = AppRouter.create(_auth);

  @override
  void dispose() {
    _router.dispose();
    _auth.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: widget.repository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _auth),
          BlocProvider(create: (_) => CatalogueViewModel(widget.repository)),
          BlocProvider(create: (_) => CartViewModel(widget.repository)),
          BlocProvider(create: (_) => OrdersViewModel(widget.repository)),
          // Admin view models. Created on first use.
          BlocProvider(create: (_) => DashboardViewModel(widget.repository)),
          BlocProvider(create: (_) => AdminOrdersViewModel(widget.repository)),
          BlocProvider(create: (_) => AdminProductsViewModel(widget.repository)),
          BlocProvider(create: (_) => AdminCustomersViewModel(widget.repository)),
        ],
        child: MaterialApp.router(
          title: kIsWeb ? '${BrandConfig.companyName} Admin' : '${BrandConfig.companyName} Trade',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          routerConfig: _router,
        ),
      ),
    );
  }
}
