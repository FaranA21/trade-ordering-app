import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:merchant_demo/core/constants/brand_config.dart';
import 'package:merchant_demo/core/routes/app_router.dart';
import 'package:merchant_demo/core/theme/app_colors.dart';
import 'package:merchant_demo/core/theme/app_decor.dart';
import 'package:merchant_demo/core/utils/formatters.dart';
import 'package:merchant_demo/core/widgets/product_image.dart';
import 'package:merchant_demo/data/models/order.dart';
import 'package:merchant_demo/data/models/order_status.dart';
import 'package:merchant_demo/features/auth/view_models/auth_view_model.dart';
import 'package:merchant_demo/features/cart/view_models/cart_view_model.dart';
import 'package:merchant_demo/features/orders/view_models/orders_state.dart';
import 'package:merchant_demo/features/orders/view_models/orders_view_model.dart';
import 'package:merchant_demo/features/orders/widgets/status_timeline.dart';

class OrderDetailView extends StatelessWidget {
  const OrderDetailView({super.key, required this.orderId});

  final String orderId;

  static String _headline(TradeOrder o) {
    final collect = o.fulfilment == Fulfilment.collection;
    switch (o.status) {
      case OrderStatus.placed:
        return 'Order placed';
      case OrderStatus.packed:
        return 'Packed and ready';
      case OrderStatus.outForDelivery:
        return collect ? 'Ready to collect' : 'On the van';
      case OrderStatus.delivered:
        return collect ? 'Collected' : 'Delivered';
    }
  }

  static String _note(TradeOrder o) {
    final collect = o.fulfilment == Fulfilment.collection;
    final site = o.deliveryAddress.split(',').first;
    switch (o.status) {
      case OrderStatus.placed:
        return 'We have your order and will pack it shortly.';
      case OrderStatus.packed:
        return collect ? 'Packed. We will tell you when it is at the counter.' : 'Packed and waiting for the van.';
      case OrderStatus.outForDelivery:
        return collect ? 'Waiting for you at the trade counter.' : 'The driver is on the way to $site.';
      case OrderStatus.delivered:
        return collect ? 'Collected from the branch.' : 'Delivered to $site.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final customer = context.watch<AuthViewModel>().state.customer;

    // Rebuilds when the branch changes the status in the admin panel.
    return BlocBuilder<OrdersViewModel, OrdersState>(
      builder: (context, state) {
        final order = state.byId(orderId);
        if (order == null || customer == null) {
          // A just-placed order can take a moment to arrive from the server.
          return Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Loading your order', style: TextStyle(color: AppColors.textMuted)),
                ],
              ),
            ),
          );
        }
        final vm = context.read<OrdersViewModel>();
        final step = OrderStatus.values.indexOf(order.status);
        final collect = order.fulfilment == Fulfilment.collection;

        return Scaffold(
          body: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(20, MediaQuery.paddingOf(context).top + 16, 20, 22),
                decoration: const BoxDecoration(
                  color: AppColors.ink,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton.filled(
                          tooltip: 'Back',
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.inkRaised,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(44, 44),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () => context.canPop() ? context.pop() : context.go(Routes.orders),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Order ${order.orderNo}',
                                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white)),
                            Text('Placed ${Fmt.dayTime(order.placedAt)}',
                                style: const TextStyle(fontSize: 12, color: AppColors.textOnInkMuted)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(order.status == OrderStatus.delivered ? 'Complete' : 'Step ${step + 1} of 4',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.highlight)),
                    const SizedBox(height: 4),
                    Text(_headline(order),
                        style: const TextStyle(
                            fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.6, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(_note(order), style: const TextStyle(fontSize: 13, color: AppColors.textOnInkMuted)),
                    const SizedBox(height: 18),
                    StatusTimeline(order: order),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: AppDecor.card(),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3DC),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Icon(collect ? Icons.storefront_outlined : Icons.local_shipping_outlined,
                                color: const Color(0xFF92400E), size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(collect ? 'Collect from the branch' : 'Delivery, 7am to 12pm',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                                Text(collect ? BrandConfig.branchAddress : order.deliveryAddress,
                                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                      decoration: AppDecor.card(),
                      child: Column(
                        children: [
                          for (final item in order.items)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  if (vm.productFor(item.productId) case final p?)
                                    ProductImage(product: p, width: 44, height: 44, radius: 12)
                                  else
                                    const SizedBox(width: 44, height: 44),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                                        Text('${item.qty} x ${Fmt.gbp(item.unitPrice)}',
                                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                      ],
                                    ),
                                  ),
                                  Text(Fmt.gbp(item.lineTotal),
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                                ],
                              ),
                            ),
                          const Divider(height: 16),
                          _Row(left: 'VAT 20%', right: Fmt.gbp(order.vat), muted: true),
                          if (order.poReference.isNotEmpty)
                            _Row(left: 'PO reference', right: order.poReference, muted: true),
                          _Row(left: 'Total on account', right: Fmt.gbp(order.total), bold: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Status updates here as soon as the branch changes it.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: AppDecor.bottomBar(),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.highlight,
                    foregroundColor: AppColors.ink,
                    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                  onPressed: () {
                    final skipped = context.read<CartViewModel>().reorder(order, customer);
                    if (skipped > 0) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('$skipped item${skipped == 1 ? ' is' : 's are'} out of stock and left out.'),
                      ));
                    }
                    context.push(Routes.cart);
                  },
                  child: const Text('Order this again'),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.left, required this.right, this.bold = false, this.muted = false});

  final String left;
  final String right;
  final bool bold;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: bold ? 17 : 13,
      fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
      color: muted ? AppColors.textMuted : AppColors.textMain,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [Expanded(child: Text(left, style: style)), Text(right, style: style)]),
    );
  }
}
