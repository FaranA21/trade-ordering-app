import 'package:flutter/material.dart';

import 'package:merchant_demo/data/models/order_status.dart';
import 'package:merchant_demo/core/theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status, this.label});

  final OrderStatus status;

  /// Overrides the status text, e.g. "Collected" for collection orders.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = AppColors.statusColors(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Text(
        label ?? status.label,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w800),
      ),
    );
  }
}
