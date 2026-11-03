import 'package:flutter/material.dart';

import 'package:merchant_demo/core/theme/app_colors.dart';

/// Card and panel styles from the v2 design: white, rounded, soft navy shadow.
class AppDecor {
  AppDecor._();

  static BoxDecoration card({double radius = 20, Color color = AppColors.surface}) => BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(color: AppColors.ink.withValues(alpha: 0.07), blurRadius: 18, offset: const Offset(0, 6)),
        ],
      );

  /// Navy panel with a stronger shadow (hero cards, totals).
  static BoxDecoration navy({double radius = 22}) => BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(color: AppColors.ink.withValues(alpha: 0.25), blurRadius: 30, offset: const Offset(0, 14)),
        ],
      );

  /// White bar fixed to the bottom of a screen.
  static BoxDecoration bottomBar() => BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(color: AppColors.ink.withValues(alpha: 0.08), blurRadius: 24, offset: const Offset(0, -8)),
        ],
      );
}
