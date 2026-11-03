import 'package:flutter/material.dart';

import 'package:merchant_demo/core/constants/brand_config.dart';
import 'package:merchant_demo/data/models/order_status.dart';

class AppColors {
  AppColors._();

  static const Color ink = BrandConfig.ink;
  static const Color inkRaised = BrandConfig.inkRaised;
  static const Color primary = BrandConfig.primary;
  static const Color highlight = BrandConfig.highlight;

  static const Color ground = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE3E8EF);
  static const Color divider = Color(0xFFEEF2F6);
  static const Color inputBorder = Color(0xFFDCE3EB);
  static const Color tile = Color(0xFFE9EDF2);

  static const Color textMain = Color(0xFF0B1F33);
  static const Color textBody = Color(0xFF33475B);
  static const Color textMuted = Color(0xFF5B6B7C);
  static const Color textOnInk = Color(0xFFF5F7FA);
  static const Color textOnInkMuted = Color(0xFFC8D3E0);

  static const Color stockIn = Color(0xFF15803D);
  static const Color stockLow = Color(0xFFB45309);
  static const Color stockOut = Color(0xFFB42318);

  /// Background and text colour for each order status badge.
  static (Color, Color) statusColors(OrderStatus status) {
    switch (status) {
      case OrderStatus.placed:
        return (const Color(0xFFEEF0F2), const Color(0xFF33475B));
      case OrderStatus.packed:
        return (const Color(0xFFE3ECF7), const Color(0xFF1E4E8C));
      case OrderStatus.outForDelivery:
        return (const Color(0xFFFEF3DC), const Color(0xFF92400E));
      case OrderStatus.delivered:
        return (const Color(0xFFE3F4EA), const Color(0xFF15803D));
    }
  }
}
