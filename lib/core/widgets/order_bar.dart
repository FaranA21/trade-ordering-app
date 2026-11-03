import 'package:flutter/material.dart';

import 'package:merchant_demo/core/theme/app_colors.dart';
import 'package:merchant_demo/core/utils/formatters.dart';

/// Floating navy bar: "3 items in your order, £173.44 inc VAT" + View order.
class OrderBar extends StatelessWidget {
  const OrderBar({super.key, required this.count, required this.total, required this.onTap});

  final int count;
  final double total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.ink,
      borderRadius: BorderRadius.circular(18),
      elevation: 10,
      shadowColor: AppColors.ink.withValues(alpha: 0.5),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 8, 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$count item${count == 1 ? '' : 's'} in your order',
                        style: const TextStyle(fontSize: 12, color: AppColors.textOnInkMuted)),
                    Text('${Fmt.gbp(total)} inc VAT',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white)),
                  ],
                ),
              ),
              Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(color: AppColors.highlight, borderRadius: BorderRadius.circular(13)),
                child: const Text('View order',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.ink)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
