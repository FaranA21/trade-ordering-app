import 'package:flutter/material.dart';

import 'package:merchant_demo/core/theme/app_colors.dart';
import 'package:merchant_demo/core/theme/app_theme.dart';

class QtyStepper extends StatelessWidget {
  const QtyStepper({
    super.key,
    required this.qty,
    required this.onChanged,
    this.min = 1,
    this.max = 999,
    this.compact = false,
  });

  final int qty;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 40.0 : 48.0;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.inputBorder),
        borderRadius: BorderRadius.circular(12),
        color: AppColors.surface,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: IconButton(
              tooltip: 'Decrease quantity',
              icon: const Icon(Icons.remove, size: 20),
              onPressed: qty > min ? () => onChanged(qty - 1) : null,
            ),
          ),
          SizedBox(
            width: compact ? 32 : 40,
            child: Text('$qty', textAlign: TextAlign.center, style: AppTheme.price(size: compact ? 18 : 22)),
          ),
          SizedBox(
            width: size,
            height: size,
            child: IconButton(
              tooltip: 'Increase quantity',
              icon: const Icon(Icons.add, size: 20),
              onPressed: qty < max ? () => onChanged(qty + 1) : null,
            ),
          ),
        ],
      ),
    );
  }
}
