import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:merchant_demo/data/models/cart_line.dart';
import 'package:merchant_demo/data/models/customer.dart';
import 'package:merchant_demo/data/models/order.dart';
import 'package:merchant_demo/data/models/order_status.dart';
import 'package:merchant_demo/data/models/product.dart';
import 'package:merchant_demo/data/repositories/trade_repository.dart';
import 'package:merchant_demo/features/cart/view_models/cart_state.dart';

class CartViewModel extends Cubit<CartState> {
  CartViewModel(this._repo) : super(const CartState());

  final TradeRepository _repo;

  /// Adds to whatever is already in the cart for this product.
  void add(Product product, int qty, Customer customer) {
    if (qty <= 0) return;
    final lines = List<CartLine>.of(state.lines);
    final i = lines.indexWhere((l) => l.product.id == product.id);
    if (i == -1) {
      lines.add(CartLine(product: product, qty: qty, unitPrice: _repo.priceFor(product, customer)));
    } else {
      lines[i] = lines[i].copyWith(qty: lines[i].qty + qty);
    }
    emit(state.copyWith(lines: lines, clearPlaced: true));
  }

  void setQty(String productId, int qty) {
    final lines = List<CartLine>.of(state.lines);
    final i = lines.indexWhere((l) => l.product.id == productId);
    if (i == -1) return;
    if (qty <= 0) {
      lines.removeAt(i);
    } else {
      lines[i] = lines[i].copyWith(qty: qty);
    }
    emit(state.copyWith(lines: lines));
  }

  void remove(String productId) => setQty(productId, 0);

  /// One tap: fills the cart with a past order at today's prices.
  /// Hidden or out-of-stock products are skipped; returns how many were skipped.
  int reorder(TradeOrder order, Customer customer) {
    final lines = <CartLine>[];
    var skipped = 0;
    for (final item in order.items) {
      final product = _repo.getProduct(item.productId);
      if (product == null || !product.available || product.stock <= 0) {
        skipped++;
        continue;
      }
      lines.add(CartLine(product: product, qty: item.qty, unitPrice: _repo.priceFor(product, customer)));
    }
    emit(CartState(lines: lines, fulfilment: order.fulfilment));
    return skipped;
  }

  void setFulfilment(Fulfilment f) => emit(state.copyWith(fulfilment: f));

  void setPoReference(String po) => emit(state.copyWith(poReference: po));

  Future<void> placeOrder(Customer customer) async {
    if (state.isEmpty || state.placing) return;
    emit(state.copyWith(placing: true, clearError: true));
    try {
      final order = await _repo.placeOrder(
        customer: customer,
        lines: state.lines,
        fulfilment: state.fulfilment,
        poReference: state.poReference,
      );
      emit(CartState(placedOrder: order));
    } catch (_) {
      emit(state.copyWith(placing: false, error: 'The order did not go through. Check your connection and try again.'));
    }
  }

  void clear() => emit(const CartState());
}
