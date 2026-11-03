import 'package:flutter/material.dart';

import 'package:merchant_demo/core/constants/brand_config.dart';
import 'package:merchant_demo/core/theme/app_colors.dart';
import 'package:merchant_demo/core/theme/app_theme.dart';

/// The square initials logo. Swap for Image.asset when personalising for a lead.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 44});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.highlight,
        borderRadius: BorderRadius.circular(size * 0.23),
      ),
      child: Text(BrandConfig.initials, style: AppTheme.price(size: size * 0.45, color: AppColors.ink)),
    );
  }
}
