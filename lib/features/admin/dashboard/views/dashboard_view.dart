import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:merchant_demo/core/routes/app_router.dart';
import 'package:merchant_demo/core/theme/app_colors.dart';
import 'package:merchant_demo/core/theme/app_decor.dart';
import 'package:merchant_demo/core/utils/formatters.dart';
import 'package:merchant_demo/core/widgets/product_image.dart';
import 'package:merchant_demo/core/widgets/status_badge.dart';
import 'package:merchant_demo/data/models/order_status.dart';
import 'package:merchant_demo/features/admin/dashboard/view_models/dashboard_state.dart';
import 'package:merchant_demo/features/admin/dashboard/view_models/dashboard_view_model.dart';
import 'package:merchant_demo/features/admin/dashboard/widgets/order_value_chart.dart';
import 'package:merchant_demo/features/admin/shell/widgets/admin_page.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  static const _statusColors = {
    OrderStatus.placed: Color(0xFF8293A5),
    OrderStatus.packed: Color(0xFF3B6EA5),
    OrderStatus.outForDelivery: AppColors.highlight,
    OrderStatus.delivered: AppColors.ink,
  };

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardViewModel, DashboardState>(
      builder: (context, s) {
        final toPack = s.waiting.length;
        return AdminPage(
          title: toPack == 0 ? 'Nothing waiting to be packed.' : '$toPack order${toPack == 1 ? '' : 's'} to pack.',
          subtitle: Fmt.longDay(DateTime.now()),
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(0, 46), padding: const EdgeInsets.symmetric(horizontal: 20)),
              onPressed: () => context.go(Routes.adminOrdersWithStatus(OrderStatus.placed.key)),
              child: const Text('Open packing list'),
            ),
          ],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LayoutBuilder(
                builder: (context, c) {
                  final cols = c.maxWidth > 900 ? 4 : (c.maxWidth > 520 ? 2 : 1);
                  final w = (c.maxWidth - (cols - 1) * 16) / cols;
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      SizedBox(
                        width: w,
                        child: _StatTile(
                          label: 'Value today, ex VAT',
                          value: Fmt.gbp(s.valueTodayExVat),
                          sub: s.busiestDayIsToday ? 'Busiest day this period' : '${Fmt.gbp(s.valueTodayIncVat)} inc VAT',
                          navy: true,
                        ),
                      ),
                      SizedBox(
                        width: w,
                        child: _StatTile(
                          label: 'Orders today',
                          value: '${s.ordersToday}',
                          sub: '${s.toPackToday} to pack, ${s.ordersToday - s.toPackToday} further along',
                        ),
                      ),
                      SizedBox(
                        width: w,
                        child: _StatTile(label: 'Open orders', value: '${s.openOrders}', sub: 'Not yet delivered'),
                      ),
                      SizedBox(
                        width: w,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: () => context.go(Routes.adminProducts),
                          child: _StatTile(
                            label: 'Stock to check',
                            value: '${s.outOfStock + s.lowStock}',
                            sub: '${s.outOfStock} out of stock, ${s.lowStock} low',
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, c) {
                  final chart = _Panel(
                    title: 'Order value by day',
                    trailing: 'ex VAT, last ${s.byDay.length} order days',
                    child: SizedBox(height: 230, child: OrderValueChart(days: s.byDay)),
                  );
                  final side = _Panel(
                    title: 'Where orders are now',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: SizedBox(
                            height: 14,
                            child: Row(
                              children: [
                                for (final st in OrderStatus.values)
                                  if ((s.statusCounts[st] ?? 0) > 0)
                                    Expanded(flex: s.statusCounts[st]!, child: Container(color: _statusColors[st])),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        for (final st in OrderStatus.values)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(color: _statusColors[st], shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 10),
                                Expanded(child: Text(st.label, style: const TextStyle(fontWeight: FontWeight.w600))),
                                Text('${s.statusCounts[st] ?? 0}', style: const TextStyle(fontWeight: FontWeight.w800)),
                              ],
                            ),
                          ),
                        if (s.lowStockProducts.isNotEmpty) ...[
                          const Divider(height: 24),
                          const Text('Running low', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 8),
                          for (final p in s.lowStockProducts)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                children: [
                                  ProductImage(product: p, width: 40, height: 40, radius: 10),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(p.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                                        Text(p.stock == 0 ? 'Out of stock' : '${p.stock} left',
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: p.stock == 0 ? AppColors.stockOut : AppColors.stockLow)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ],
                    ),
                  );
                  if (c.maxWidth < 900) {
                    return Column(children: [chart, const SizedBox(height: 16), side]);
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: chart),
                      const SizedBox(width: 16),
                      Expanded(flex: 2, child: side),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              _Panel(
                title: 'Latest orders',
                child: Column(
                  children: [
                    for (final o in s.recent)
                      InkWell(
                        onTap: () => context.go(Routes.adminOrders),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              _Initials(text: Fmt.initials(o.customerName)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(o.customerName, style: const TextStyle(fontWeight: FontWeight.w700)),
                                    Text('${o.orderNo}, ${Fmt.when(o.placedAt)}',
                                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                  ],
                                ),
                              ),
                              Text(Fmt.gbp(o.total), style: const TextStyle(fontWeight: FontWeight.w800)),
                              const SizedBox(width: 12),
                              StatusBadge(status: o.status, label: o.statusLabel),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value, required this.sub, this.navy = false});

  final String label;
  final String value;
  final String sub;
  final bool navy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: navy ? AppDecor.navy() : AppDecor.card(radius: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600, color: navy ? AppColors.textOnInkMuted : AppColors.textMuted)),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value,
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                    color: navy ? Colors.white : AppColors.textMain)),
          ),
          const SizedBox(height: 4),
          Text(sub,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: navy ? AppColors.highlight : AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child, this.trailing});

  final String title;
  final String? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: AppDecor.card(radius: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800))),
              if (trailing != null)
                Text(trailing!,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _Initials extends StatelessWidget {
  const _Initials({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: const Color(0xFFE8EEF5), borderRadius: BorderRadius.circular(11)),
      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.ink)),
    );
  }
}
