import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:merchant_demo/core/routes/app_router.dart';
import 'package:merchant_demo/core/theme/app_colors.dart';
import 'package:merchant_demo/core/theme/app_decor.dart';
import 'package:merchant_demo/core/utils/formatters.dart';
import 'package:merchant_demo/core/widgets/product_image.dart';
import 'package:merchant_demo/core/widgets/status_badge.dart';
import 'package:merchant_demo/data/models/order.dart';
import 'package:merchant_demo/data/models/order_status.dart';
import 'package:merchant_demo/data/models/product.dart';
import 'package:merchant_demo/features/orders/view_models/orders_state.dart';
import 'package:merchant_demo/features/orders/view_models/orders_view_model.dart';

class OrdersView extends StatefulWidget {
  const OrdersView({super.key});

  @override
  State<OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<OrdersView> {
  bool _showActive = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<OrdersViewModel, OrdersState>(
          builder: (context, state) {
            final active = state.orders.where((o) => o.isActive).toList();
            final past = state.orders.where((o) => !o.isActive).toList();
            final shown = _showActive ? active : past;
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 22, 16, 24),
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text('Orders', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.6)),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: AppDecor.card(radius: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _Tab(
                          label: 'Active (${active.length})',
                          selected: _showActive,
                          onTap: () => setState(() => _showActive = true),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: _Tab(
                          label: 'Past (${past.length})',
                          selected: !_showActive,
                          onTap: () => setState(() => _showActive = false),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                if (shown.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: Text(
                      _showActive ? 'No orders on the way. Your next one will show here.' : 'No past orders yet.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                for (final order in shown) ...[
                  _OrderCard(order: order),
                  const SizedBox(height: 12),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          backgroundColor: selected ? AppColors.ink : Colors.transparent,
          foregroundColor: selected ? Colors.white : AppColors.textMuted,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
        child: Text(label),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final TradeOrder order;

  @override
  Widget build(BuildContext context) {
    final vm = context.read<OrdersViewModel>();
    final step = OrderStatus.values.indexOf(order.status);
    final done = order.status == OrderStatus.delivered;
    final thumbs = order.items.take(3).map((i) => vm.productFor(i.productId)).whereType<Product>().toList();

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: AppDecor.card(radius: 22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => context.push(Routes.order(order.id)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(order.orderNo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                          Text('${Fmt.dayShort(order.placedAt)}, ${order.fulfilment.key}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                    StatusBadge(status: order.status, label: order.statusLabel),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    SizedBox(
                      height: 40,
                      width: thumbs.isEmpty ? 0 : 40.0 + (thumbs.length - 1) * 30,
                      child: Stack(
                        children: [
                          for (var i = 0; i < thumbs.length; i++)
                            Positioned(
                              left: i * 30.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: ProductImage(
                                  product: thumbs[i],
                                  width: 36,
                                  height: 36,
                                  radius: 10,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(Fmt.gbp(order.total),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                        Text('${order.itemCount} items, inc VAT',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    for (var i = 0; i < 4; i++)
                      Expanded(
                        child: Container(
                          height: 5,
                          margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: i <= step
                                ? (done ? AppColors.stockIn : AppColors.highlight)
                                : const Color(0xFFE3E8EF),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
