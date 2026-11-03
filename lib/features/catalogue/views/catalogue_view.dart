import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:merchant_demo/core/routes/app_router.dart';
import 'package:merchant_demo/core/theme/app_colors.dart';
import 'package:merchant_demo/core/theme/app_decor.dart';
import 'package:merchant_demo/core/widgets/order_bar.dart';
import 'package:merchant_demo/data/models/customer.dart';
import 'package:merchant_demo/data/models/product.dart';
import 'package:merchant_demo/features/auth/view_models/auth_view_model.dart';
import 'package:merchant_demo/features/cart/view_models/cart_state.dart';
import 'package:merchant_demo/features/cart/view_models/cart_view_model.dart';
import 'package:merchant_demo/features/catalogue/view_models/catalogue_state.dart';
import 'package:merchant_demo/features/catalogue/view_models/catalogue_view_model.dart';
import 'package:merchant_demo/features/catalogue/widgets/category_tile.dart';
import 'package:merchant_demo/features/catalogue/widgets/product_grid_card.dart';
import 'package:merchant_demo/features/catalogue/widgets/reorder_hero_card.dart';

class CatalogueView extends StatelessWidget {
  const CatalogueView({super.key});

  static String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 18) return 'Good afternoon';
    return 'Good evening';
  }

  /// "Cement & Aggregates" -> "Cement"
  static String _shortCategory(String c) => c.split(RegExp(r'\s|&')).first;

  void _reorder(BuildContext context, CatalogueState state, Customer customer) {
    final order = state.lastOrder;
    if (order == null) return;
    final skipped = context.read<CartViewModel>().reorder(order, customer);
    if (skipped > 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$skipped item${skipped == 1 ? ' is' : 's are'} out of stock and left out.'),
      ));
    }
    context.push(Routes.cart);
  }

  void _quickAdd(BuildContext context, Product product, Customer customer) {
    context.read<CartViewModel>().add(product, 1, customer);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('Added 1 x ${product.name}'),
        duration: const Duration(seconds: 2),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final customer = context.watch<AuthViewModel>().state.customer;
    if (customer == null) return const SizedBox.shrink();
    final vm = context.read<CatalogueViewModel>();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            BlocBuilder<CatalogueViewModel, CatalogueState>(
              builder: (context, state) {
                final products = state.visible;
                final showHero = state.lastOrder != null && state.query.isEmpty;
                return CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      sliver: SliverToBoxAdapter(
                        child: _Header(
                          greeting: '${_greeting()}, ${customer.contactName.split(' ').first}',
                          customer: customer,
                          onSearch: vm.search,
                        ),
                      ),
                    ),
                    if (showHero)
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                        sliver: SliverToBoxAdapter(
                          child: ReorderHeroCard(
                            order: state.lastOrder!,
                            onReorder: () => _reorder(context, state, customer),
                          ),
                        ),
                      ),
                    const SliverPadding(
                      padding: EdgeInsets.fromLTRB(20, 22, 20, 10),
                      sliver: SliverToBoxAdapter(
                        child: Text('Categories', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 100,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: state.categories.length + 1,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, i) {
                            if (i == 0) {
                              return CategoryTile(
                                label: 'All',
                                selected: state.category == CatalogueState.allCategories,
                                onTap: () => vm.selectCategory(CatalogueState.allCategories),
                              );
                            }
                            final c = state.categories[i - 1];
                            final sample = state.products.where((p) => p.category == c);
                            return CategoryTile(
                              label: _shortCategory(c),
                              sample: sample.isEmpty ? null : sample.first,
                              selected: state.category == c,
                              onTap: () => vm.selectCategory(c),
                            );
                          },
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                state.category == CatalogueState.allCategories ? 'All products' : state.category,
                                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                              ),
                            ),
                            const Text('Prices ex VAT', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                    ),
                    if (products.isEmpty)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: Text('No products match. Try another word or category.',
                              textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted)),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
                        sliver: SliverGrid.builder(
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 220,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            mainAxisExtent: 250,
                          ),
                          itemCount: products.length,
                          itemBuilder: (context, i) {
                            final p = products[i];
                            return ProductGridCard(
                              product: p,
                              price: vm.priceFor(p),
                              onTap: () => context.push(Routes.product(p.id)),
                              onQuickAdd:
                                  p.stockLevel == StockLevel.out ? null : () => _quickAdd(context, p, customer),
                            );
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 14,
              child: BlocBuilder<CartViewModel, CartState>(
                builder: (context, cart) => cart.isEmpty
                    ? const SizedBox.shrink()
                    : OrderBar(count: cart.count, total: cart.total, onTap: () => context.push(Routes.cart)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.greeting, required this.customer, required this.onSearch});

  final String greeting;
  final Customer customer;
  final ValueChanged<String> onSearch;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(greeting,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textMuted)),
                  const SizedBox(height: 2),
                  Text(customer.companyName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.4)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: AppDecor.card(radius: 10),
              child: Text(customer.accountNo,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.ink)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: AppDecor.card(radius: 16),
          child: TextField(
            onChanged: onSearch,
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              hintText: 'Search products or SKU',
              prefixIcon: Icon(Icons.search, color: Color(0xFF8293A5)),
              fillColor: AppColors.surface,
            ),
          ),
        ),
      ],
    );
  }
}
