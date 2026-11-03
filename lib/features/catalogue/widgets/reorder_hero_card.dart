import 'package:flutter/material.dart';

import 'package:merchant_demo/core/constants/brand_config.dart';
import 'package:merchant_demo/core/theme/app_colors.dart';
import 'package:merchant_demo/core/utils/formatters.dart';
import 'package:merchant_demo/data/models/order.dart';

/// Navy card over a yard photo: "Your last order" with the one-tap Reorder.
class ReorderHeroCard extends StatelessWidget {
  const ReorderHeroCard({super.key, required this.order, required this.onReorder});

  final TradeOrder order;
  final VoidCallback onReorder;

  String _summary() {
    final names = order.items.take(3).map((i) => '${i.qty} x ${_short(i.name)}').join(', ');
    final more = order.items.length > 3 ? ', +${order.items.length - 3} more' : '';
    return '$names$more';
  }

  /// "C24 Treated Timber 47x100mm 4.8m" -> "C24 Treated Timber"
  static String _short(String name) => name.split(' ').take(3).join(' ');

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(image: AssetImage(BrandConfig.loginHero), fit: BoxFit.cover),
        boxShadow: [
          BoxShadow(color: AppColors.ink.withValues(alpha: 0.25), blurRadius: 30, offset: const Offset(0, 14)),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              AppColors.ink.withValues(alpha: 0.97),
              AppColors.ink.withValues(alpha: 0.88),
              AppColors.ink.withValues(alpha: 0.35),
            ],
            stops: const [0, 0.55, 1],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your last order, ${Fmt.dayShort(order.placedAt)}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.highlight)),
            const SizedBox(height: 8),
            const SizedBox(
              width: 230,
              child: Text('Same again?',
                  style: TextStyle(
                      fontSize: 22, height: 1.2, fontWeight: FontWeight.w800, letterSpacing: -0.4, color: Colors.white)),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 240,
              child: Text(_summary(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: AppColors.textOnInkMuted)),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 44),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                backgroundColor: AppColors.highlight,
                foregroundColor: AppColors.ink,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
              onPressed: onReorder,
              icon: const Icon(Icons.replay_rounded, size: 18),
              label: Text('Reorder ${Fmt.gbp(order.total)}'),
            ),
          ],
        ),
      ),
    );
  }
}
