import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:merchant_demo/core/constants/brand_config.dart';
import 'package:merchant_demo/core/routes/app_router.dart';
import 'package:merchant_demo/core/theme/app_colors.dart';
import 'package:merchant_demo/core/theme/app_decor.dart';
import 'package:merchant_demo/core/utils/formatters.dart';
import 'package:merchant_demo/core/widgets/product_image.dart';
import 'package:merchant_demo/core/widgets/qty_stepper.dart';
import 'package:merchant_demo/data/models/cart_line.dart';
import 'package:merchant_demo/data/models/customer.dart';
import 'package:merchant_demo/data/models/order_status.dart';
import 'package:merchant_demo/features/auth/view_models/auth_view_model.dart';
import 'package:merchant_demo/features/cart/view_models/cart_state.dart';
import 'package:merchant_demo/features/cart/view_models/cart_view_model.dart';

/// Cart and checkout on one screen. Payment is "on account" only.
class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    final customer = context.watch<AuthViewModel>().state.customer;
    if (customer == null) return const SizedBox.shrink();

    return BlocConsumer<CartViewModel, CartState>(
      listenWhen: (a, b) =>
          (a.placedOrder == null && b.placedOrder != null) || (b.error != null && a.error != b.error),
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
          return;
        }
        context.pushReplacement(Routes.order(state.placedOrder!.id));
      },
      builder: (context, cart) {
        final overLimit = cart.total > customer.creditAvailable;
        return Scaffold(
          appBar: AppBar(
            leading: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: _BackButton(onPressed: () => context.canPop() ? context.pop() : context.go(Routes.shop)),
            ),
            leadingWidth: 60,
            title: const Text('Your order'),
            actions: [
              if (!cart.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: Text('${cart.count} items',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                  ),
                ),
            ],
          ),
          body: cart.isEmpty
              ? const _EmptyCart()
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  children: [
                    for (final line in cart.lines) ...[
                      _LineCard(line: line),
                      const SizedBox(height: 12),
                    ],
                    _FulfilmentPicker(cart: cart, customer: customer),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      decoration: AppDecor.card(),
                      child: TextFormField(
                        initialValue: cart.poReference,
                        onChanged: context.read<CartViewModel>().setPoReference,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        decoration: const InputDecoration(
                          labelText: 'PO reference (optional)',
                          hintText: 'e.g. PO-4471',
                          fillColor: AppColors.surface,
                          contentPadding: EdgeInsets.zero,
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SummaryCard(cart: cart, customer: customer, overLimit: overLimit),
                  ],
                ),
          bottomNavigationBar: cart.isEmpty
              ? null
              : Container(
                  decoration: AppDecor.bottomBar(),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.highlight,
                          foregroundColor: AppColors.ink,
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                        onPressed: cart.placing || overLimit
                            ? null
                            : () => context.read<CartViewModel>().placeOrder(customer),
                        child: cart.placing
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.ink),
                              )
                            : const Text('Place order on account'),
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 44,
        height: 44,
        decoration: AppDecor.card(radius: 14),
        child: IconButton(
          tooltip: 'Back',
          onPressed: onPressed,
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textMain),
        ),
      ),
    );
  }
}

class _LineCard extends StatelessWidget {
  const _LineCard({required this.line});

  final CartLine line;

  @override
  Widget build(BuildContext context) {
    final vm = context.read<CartViewModel>();
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: AppDecor.card(),
      child: Row(
        children: [
          ProductImage(product: line.product, width: 72, height: 72),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(line.product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, height: 1.3, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text('${Fmt.gbp(line.unitPrice)} each',
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    QtyStepper(
                      compact: true,
                      qty: line.qty,
                      min: 0,
                      max: line.product.stock,
                      onChanged: (q) => vm.setQty(line.product.id, q),
                    ),
                    const Spacer(),
                    Text(Fmt.gbp(line.lineTotal), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FulfilmentPicker extends StatelessWidget {
  const _FulfilmentPicker({required this.cart, required this.customer});

  final CartState cart;
  final Customer customer;

  @override
  Widget build(BuildContext context) {
    final delivery = cart.fulfilment == Fulfilment.delivery;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: AppDecor.card(),
          child: Row(
            children: [
              for (final f in Fulfilment.values)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: f == Fulfilment.delivery ? 6 : 0),
                    child: SizedBox(
                      height: 46,
                      child: TextButton(
                        onPressed: () => context.read<CartViewModel>().setFulfilment(f),
                        style: TextButton.styleFrom(
                          backgroundColor: cart.fulfilment == f ? AppColors.ink : Colors.transparent,
                          foregroundColor: cart.fulfilment == f ? Colors.white : AppColors.textMuted,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                        ),
                        child: Text(f.label),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 6, right: 8),
              child: Icon(Icons.place_outlined, size: 18, color: AppColors.textMuted),
            ),
            Expanded(
              child: Text(
                delivery
                    ? 'To ${customer.address}. Next working day, 7am to 12pm.'
                    : 'From ${BrandConfig.branchAddress}. Ready 2 hours after you order.',
                style: const TextStyle(fontSize: 13, height: 1.5, color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.cart, required this.customer, required this.overLimit});

  final CartState cart;
  final Customer customer;
  final bool overLimit;

  @override
  Widget build(BuildContext context) {
    const muted = TextStyle(fontSize: 14, color: AppColors.textOnInkMuted);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppDecor.navy(),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: AppColors.highlight, borderRadius: BorderRadius.circular(11)),
                child: const Icon(Icons.receipt_long_outlined, size: 18, color: AppColors.ink),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Pay on account',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                    Text(
                      overLimit
                          ? 'Over your credit limit. Remove some items or call the branch.'
                          : '${customer.paymentTerms}, ${Fmt.gbp(customer.creditAvailable)} credit left',
                      style: TextStyle(
                        fontSize: 12,
                        color: overLimit ? const Color(0xFFFFB4A8) : AppColors.textOnInkMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppColors.inkRaised, height: 1),
          ),
          Row(children: [const Expanded(child: Text('Subtotal', style: muted)), Text(Fmt.gbp(cart.subtotal), style: muted)]),
          const SizedBox(height: 6),
          Row(children: [const Expanded(child: Text('VAT 20%', style: muted)), Text(Fmt.gbp(cart.vat), style: muted)]),
          const SizedBox(height: 8),
          Row(
            children: [
              const Expanded(
                child: Text('Total', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
              Text(Fmt.gbp(cart.total),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shopping_cart_outlined, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 12),
            const Text('Your order is empty.', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text('Add products, or reorder your last order from the Shop tab.',
                textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 20),
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(180, 50)),
              onPressed: () => context.go(Routes.shop),
              child: const Text('Go to shop'),
            ),
          ],
        ),
      ),
    );
  }
}
