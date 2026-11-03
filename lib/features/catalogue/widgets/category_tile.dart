import 'package:flutter/material.dart';

import 'package:merchant_demo/core/theme/app_colors.dart';
import 'package:merchant_demo/core/widgets/product_image.dart';
import 'package:merchant_demo/data/models/product.dart';

/// Square photo tile with a label under it. The photo is the first product
/// in the category; "All" shows a navy tile instead.
class CategoryTile extends StatelessWidget {
  const CategoryTile({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.sample,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Product? sample;

  @override
  Widget build(BuildContext context) {
    final tile = sample == null
        ? Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.grid_view_rounded, color: AppColors.highlight),
          )
        : ProductImage(product: sample!, width: 64, height: 64, radius: 20);

    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: 72,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(23),
                  border: Border.all(color: selected ? AppColors.highlight : Colors.transparent, width: 3),
                ),
                child: tile,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected ? AppColors.textMain : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
