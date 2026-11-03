import 'package:equatable/equatable.dart';

class OrderItem extends Equatable {
  const OrderItem({
    required this.productId,
    required this.name,
    required this.packSize,
    required this.qty,
    required this.unitPrice,
  });

  final String productId;
  final String name;
  final String packSize;
  final int qty;

  /// Price this customer paid per unit, ex VAT.
  final double unitPrice;

  double get lineTotal => _round(unitPrice * qty);

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        productId: json['productId'] as String,
        name: json['name'] as String,
        packSize: json['packSize'] as String,
        qty: json['qty'] as int,
        unitPrice: (json['unitPrice'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'name': name,
        'packSize': packSize,
        'qty': qty,
        'unitPrice': unitPrice,
        'lineTotal': lineTotal,
      };

  static double _round(double v) => (v * 100).roundToDouble() / 100;

  @override
  List<Object?> get props => [productId, qty, unitPrice];
}
