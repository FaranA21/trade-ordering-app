import 'package:equatable/equatable.dart';

import 'package:merchant_demo/data/models/product.dart';

class CartLine extends Equatable {
  const CartLine({required this.product, required this.qty, required this.unitPrice});

  final Product product;
  final int qty;

  /// This customer's price, ex VAT.
  final double unitPrice;

  double get lineTotal => (unitPrice * qty * 100).roundToDouble() / 100;

  CartLine copyWith({int? qty}) =>
      CartLine(product: product, qty: qty ?? this.qty, unitPrice: unitPrice);

  @override
  List<Object?> get props => [product.id, qty, unitPrice];
}
