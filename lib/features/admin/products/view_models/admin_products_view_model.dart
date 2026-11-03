import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:merchant_demo/data/models/product.dart';
import 'package:merchant_demo/data/repositories/trade_repository.dart';
import 'package:merchant_demo/features/admin/products/view_models/admin_products_state.dart';

class AdminProductsViewModel extends Cubit<AdminProductsState> {
  AdminProductsViewModel(this._repo) : super(const AdminProductsState()) {
    _sub = _repo.changes.where((c) => c == RepoChange.products).listen((_) => _reload());
    _reload();
  }

  final TradeRepository _repo;
  late final StreamSubscription<RepoChange> _sub;

  void _reload() => emit(state.copyWith(products: _repo.getProducts(includeHidden: true)));

  void search(String query) => emit(state.copyWith(query: query));

  /// Saves a new list price (GBP, ex VAT). Returns false if the text is not a valid price.
  bool setPrice(Product product, String text) {
    final value = double.tryParse(text.replaceAll('£', '').replaceAll(',', '').trim());
    if (value == null || value <= 0) return false;
    _repo.updateProduct(product.id, tradePrice: (value * 100).roundToDouble() / 100);
    return true;
  }

  /// Shows or hides the product in the buyer app.
  void setAvailable(Product product, bool available) => _repo.updateProduct(product.id, available: available);

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}
