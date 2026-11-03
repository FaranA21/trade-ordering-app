import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:merchant_demo/core/routes/app_router.dart';
import 'package:merchant_demo/core/theme/app_colors.dart';
import 'package:merchant_demo/core/theme/app_decor.dart';
import 'package:merchant_demo/core/utils/formatters.dart';
import 'package:merchant_demo/core/widgets/product_image.dart';
import 'package:merchant_demo/core/widgets/qty_stepper.dart';
import 'package:merchant_demo/data/models/product.dart';
import 'package:merchant_demo/features/auth/view_models/auth_view_model.dart';
import 'package:merchant_demo/features/cart/view_models/cart_view_model.dart';
import 'package:merchant_demo/features/catalogue/view_models/catalogue_view_model.dart';
import 'package:merchant_demo/features/orders/view_models/orders_view_model.dart';

class ProductDetailView extends StatefulWidget {
  const ProductDetailView({super.key, required this.productId});

  final String productId;

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  int? _qty;

  /// Quantity this customer ordered last time, if any.
  int? _lastQty() {
    for (final order in context.read<OrdersViewModel>().state.orders) {
      for (final item in order.items) {
        if (item.productId == widget.productId) return item.qty;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final customer = context.watch<AuthViewModel>().state.customer;
    final vm = context.watch<CatalogueViewModel>();
    final product = vm.productById(widget.productId);

    if (customer == null || product == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('This product is no longer available.')));
    }

    final price = vm.priceFor(product);
    final lastQty = _lastQty();
    final out = product.stockLevel == StockLevel.out;
    final maxQty = out ? 1 : product.stock;
    final qty = (_qty ?? lastQty ?? 1).clamp(1, maxQty);
    final quick = <int>{1, 5, 10, 20}.where((n) => n <= maxQty).toList();

    final (stockText, stockBg, stockFg) = switch (product.stockLevel) {
      StockLevel.out => ('Out of stock', const Color(0xFFFDE4E1), AppColors.stockOut),
      StockLevel.low => ('Only ${product.stock} left', const Color(0xFFFEF3DC), AppColors.stockLow),
      StockLevel.inStock => ('${product.stock} in stock', const Color(0xFFE3F4EA), AppColors.stockIn),
    };

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Stack(
            children: [
              ProductImage(product: product, height: 340, width: double.infinity, radius: 0),
              Positioned(
                top: MediaQuery.paddingOf(context).top + 12,
                left: 16,
                child: IconButton.filled(
                  tooltip: 'Back',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.94),
                    foregroundColor: AppColors.textMain,
                    minimumSize: const Size(44, 44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => context.canPop() ? context.pop() : context.go(Routes.shop),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                ),
              ),
            ],
          ),
          Transform.translate(
            offset: const Offset(0, -28),
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              decoration: const BoxDecoration(
                color: AppColors.ground,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    children: [
                      _Chip(text: product.sku, bg: const Color(0xFFE8EEF5), fg: AppColors.ink),
                      _Chip(text: stockText, bg: stockBg, fg: stockFg),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(product.name,
                      style: const TextStyle(fontSize: 24, height: 1.22, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                  const SizedBox(height: 6),
                  Text('Sold as: ${product.packSize}',
                      style: const TextStyle(fontSize: 14, color: AppColors.textMuted)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _InfoTile(label: 'Your price', value: Fmt.gbp(price))),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _InfoTile(
                          label: 'List price',
                          value: Fmt.gbp(product.tradePrice),
                          struck: price < product.tradePrice,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: _InfoTile(label: 'Last time', value: lastQty == null ? 'New' : '$lastQty')),
                    ],
                  ),
                  if (!out) ...[
                    const SizedBox(height: 18),
                    const Text('Quick quantity', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        for (final n in quick)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: _QuickButton(
                                label: '$n',
                                selected: qty == n,
                                onTap: () => setState(() => _qty = n),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                  if (product.photoCredit != null) ...[
                    const SizedBox(height: 18),
                    Text(product.photoCredit!, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: AppDecor.bottomBar(),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Row(
              children: [
                QtyStepper(qty: qty, max: maxQty, onChanged: (q) => setState(() => _qty = q)),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: out
                        ? null
                        : () {
                            final router = GoRouter.of(context);
                            context.read<CartViewModel>().add(product, qty, customer);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Added $qty to your order.'),
                              action: SnackBarAction(label: 'View', onPressed: () => router.push(Routes.cart)),
                            ));
                            context.pop();
                          },
                    child: Text(out ? 'Out of stock' : 'Add ${Fmt.gbp(price * qty)}'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text, required this.bg, required this.fg});

  final String text;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: fg)),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value, this.struck = false});

  final String label;
  final String value;
  final bool struck;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppDecor.card(radius: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: struck ? const Color(0xFF8293A5) : AppColors.textMain,
                decoration: struck ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickButton extends StatelessWidget {
  const _QuickButton({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          backgroundColor: selected ? AppColors.highlight : AppColors.surface,
          foregroundColor: AppColors.textMain,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: selected ? AppColors.highlight : const Color(0xFFDCE3EB)),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
        child: Text(label),
      ),
    );
  }
}
