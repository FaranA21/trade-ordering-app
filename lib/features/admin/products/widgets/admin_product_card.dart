import 'package:flutter/material.dart';

import 'package:merchant_demo/core/theme/app_colors.dart';
import 'package:merchant_demo/core/theme/app_decor.dart';
import 'package:merchant_demo/core/widgets/product_image.dart';
import 'package:merchant_demo/data/models/product.dart';

/// Product card with an editable price and a show-in-app switch.
class AdminProductCard extends StatefulWidget {
  const AdminProductCard({
    super.key,
    required this.product,
    required this.onSavePrice,
    required this.onAvailableChanged,
  });

  final Product product;

  /// Returns false when the text is not a valid price.
  final bool Function(String text) onSavePrice;
  final ValueChanged<bool> onAvailableChanged;

  @override
  State<AdminProductCard> createState() => _AdminProductCardState();
}

class _AdminProductCardState extends State<AdminProductCard> {
  late final TextEditingController _price = TextEditingController(text: _format(widget.product.tradePrice));
  final FocusNode _focus = FocusNode();

  static String _format(double v) => v.toStringAsFixed(2);

  @override
  void initState() {
    super.initState();
    // Save when the field loses focus, as well as on Enter.
    _focus.addListener(() {
      if (!_focus.hasFocus) _save();
    });
  }

  @override
  void didUpdateWidget(covariant AdminProductCard old) {
    super.didUpdateWidget(old);
    if (!_focus.hasFocus && old.product.tradePrice != widget.product.tradePrice) {
      _price.text = _format(widget.product.tradePrice);
    }
  }

  @override
  void dispose() {
    _price.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _save() {
    if (_price.text == _format(widget.product.tradePrice)) return;
    final ok = widget.onSavePrice(_price.text);
    final messenger = ScaffoldMessenger.of(context);
    if (ok) {
      messenger.showSnackBar(SnackBar(content: Text('Price saved for ${widget.product.name}.')));
    } else {
      _price.text = _format(widget.product.tradePrice);
      messenger.showSnackBar(const SnackBar(content: Text('Enter a price like 12.50.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final (stockText, bg, fg) = switch (p.stockLevel) {
      StockLevel.out => ('Out of stock', const Color(0xFFFDE4E1), AppColors.stockOut),
      StockLevel.low => ('${p.stock} left', const Color(0xFFFEF3DC), AppColors.stockLow),
      StockLevel.inStock => ('${p.stock} in stock', const Color(0xFFE3F4EA), AppColors.stockIn),
    };

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: AppDecor.card(radius: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              Opacity(
                opacity: p.available ? 1 : 0.45,
                child: ProductImage(product: p, height: 130, width: double.infinity, radius: 16),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: _Badge(text: p.sku, bg: Colors.white.withValues(alpha: 0.94), fg: AppColors.ink),
              ),
              Positioned(bottom: 10, left: 10, child: _Badge(text: stockText, bg: bg, fg: fg)),
              if (!p.available)
                const Positioned(
                  bottom: 10,
                  right: 10,
                  child: _Badge(text: 'Hidden', bg: AppColors.ink, fg: Colors.white),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(p.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, height: 1.3, fontWeight: FontWeight.w700)),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 0, 6, 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Trade price ex VAT',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _price,
                        focusNode: _focus,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _focus.unfocus(),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                        decoration: const InputDecoration(
                          isDense: true,
                          prefixText: '£ ',
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  children: [
                    const Text('In app',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                    Switch(
                      value: p.available,
                      activeTrackColor: AppColors.ink,
                      thumbColor: const WidgetStatePropertyAll(Colors.white),
                      onChanged: widget.onAvailableChanged,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.bg, required this.fg});

  final String text;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: fg)),
    );
  }
}
