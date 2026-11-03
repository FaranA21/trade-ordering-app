import 'package:flutter/material.dart';

import 'package:merchant_demo/core/theme/app_colors.dart';
import 'package:merchant_demo/core/theme/app_decor.dart';
import 'package:merchant_demo/core/utils/formatters.dart';
import 'package:merchant_demo/core/widgets/product_image.dart';
import 'package:merchant_demo/data/models/product.dart';

/// Product card for the 2-column grid: photo, SKU, name, stock, price and "+".
class ProductGridCard extends StatelessWidget {
  const ProductGridCard({
    super.key,
    required this.product,
    required this.price,
    required this.onTap,
    required this.onQuickAdd,
  });

  final Product product;

  /// This customer's price, ex VAT.
  final double price;
  final VoidCallback onTap;

  /// Adds one to the order. Null when out of stock.
  final VoidCallback? onQuickAdd;

  @override
  Widget build(BuildContext context) {
    final (stockText, stockColor) = switch (product.stockLevel) {
      StockLevel.out => ('Out of stock', AppColors.stockOut),
      StockLevel.low => ('Only ${product.stock} left', AppColors.stockLow),
      StockLevel.inStock => ('In stock', AppColors.stockIn),
    };

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: AppDecor.card(),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ProductImage(product: product, height: 112, width: double.infinity, radius: 14),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(product.sku,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.ink)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, height: 1.3, fontWeight: FontWeight.w700),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(stockText,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: stockColor)),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(Fmt.gbp(price),
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                      ),
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: IconButton.filled(
                          tooltip: 'Add one to your order',
                          padding: EdgeInsets.zero,
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.ink,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: AppColors.tile,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                          ),
                          onPressed: onQuickAdd,
                          icon: const Icon(Icons.add, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
