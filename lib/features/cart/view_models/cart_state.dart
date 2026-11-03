import 'package:equatable/equatable.dart';

import 'package:merchant_demo/data/models/cart_line.dart';
import 'package:merchant_demo/data/models/order.dart';
import 'package:merchant_demo/data/models/order_status.dart';

class CartState extends Equatable {
  const CartState({
    this.lines = const [],
    this.fulfilment = Fulfilment.delivery,
    this.poReference = '',
    this.placing = false,
    this.placedOrder,
    this.error,
  });

  final List<CartLine> lines;
  final Fulfilment fulfilment;
  final String poReference;
  final bool placing;

  /// Set once an order goes through, so the screen can open its status page.
  final TradeOrder? placedOrder;

  /// Shown once when placing the order fails.
  final String? error;

  int get count => lines.fold(0, (sum, l) => sum + l.qty);
  bool get isEmpty => lines.isEmpty;
  double get subtotal => _round(lines.fold(0.0, (sum, l) => sum + l.lineTotal));
  double get vat => _round(subtotal * TradeOrder.vatRate);
  double get total => _round(subtotal + vat);

  int qtyOf(String productId) {
    for (final l in lines) {
      if (l.product.id == productId) return l.qty;
    }
    return 0;
  }

  CartState copyWith({
    List<CartLine>? lines,
    Fulfilment? fulfilment,
    String? poReference,
    bool? placing,
    TradeOrder? placedOrder,
    bool clearPlaced = false,
    String? error,
    bool clearError = false,
  }) =>
      CartState(
        lines: lines ?? this.lines,
        fulfilment: fulfilment ?? this.fulfilment,
        poReference: poReference ?? this.poReference,
        placing: placing ?? this.placing,
        placedOrder: clearPlaced ? null : (placedOrder ?? this.placedOrder),
        error: clearError ? null : (error ?? this.error),
      );

  static double _round(double v) => (v * 100).roundToDouble() / 100;

  @override
  List<Object?> get props => [lines, fulfilment, poReference, placing, placedOrder, error];
}
