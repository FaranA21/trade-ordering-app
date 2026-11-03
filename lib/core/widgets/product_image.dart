import 'package:flutter/material.dart';

import 'package:merchant_demo/core/theme/app_colors.dart';
import 'package:merchant_demo/data/models/product.dart';

/// Product photo. Order of preference:
/// 1. Unsplash URL from products.json (hotlinked, as Unsplash's terms require)
/// 2. Local file assets/images/products/`<productId>`.jpg
/// 3. A category icon
class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.product,
    this.width,
    this.height,
    this.radius = 14,
  });

  final Product product;
  final double? width;
  final double? height;
  final double radius;

  static String assetFor(String productId) => 'assets/images/products/$productId.jpg';

  static IconData iconFor(String category) {
    final c = category.toLowerCase();
    if (c.contains('timber')) return Icons.view_week_outlined;
    if (c.contains('cement')) return Icons.layers_outlined;
    if (c.contains('plumb')) return Icons.plumbing;
    if (c.contains('electr')) return Icons.electrical_services;
    if (c.contains('fix')) return Icons.hardware_outlined;
    if (c.contains('insul')) return Icons.roofing;
    return Icons.inventory_2_outlined;
  }

  Widget _fallback() => Container(
        width: width,
        height: height,
        color: AppColors.tile,
        alignment: Alignment.center,
        child: Icon(iconFor(product.category), color: AppColors.primary, size: 32),
      );

  @override
  Widget build(BuildContext context) {
    final url = product.imageUrl;
    final Widget image = url != null
        ? Image.network(
            url,
            width: width,
            height: height,
            fit: BoxFit.cover,
            loadingBuilder: (_, child, progress) => progress == null
                ? child
                : Container(width: width, height: height, color: AppColors.tile),
            errorBuilder: (_, __, ___) => _fallback(),
          )
        : Image.asset(
            assetFor(product.id),
            width: width,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _fallback(),
          );
    return ClipRRect(borderRadius: BorderRadius.circular(radius), child: image);
  }
}
