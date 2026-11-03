import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:merchant_demo/data/models/product.dart';
import 'package:merchant_demo/data/repositories/trade_repository.dart';
import 'package:merchant_demo/features/catalogue/view_models/catalogue_state.dart';

class CatalogueViewModel extends Cubit<CatalogueState> {
  CatalogueViewModel(this._repo) : super(const CatalogueState()) {
    _sub = _repo.changes.listen((_) => _reload());
    _reload();
  }

  final TradeRepository _repo;
  late final StreamSubscription<RepoChange> _sub;
  /// The signed-in buyer, taken from the session so a restored sign-in works too.
  String? get _customerId => _repo.session?.customerId;

  /// Kept for the sign-in screen; the data now follows the session by itself.
  void load([String? _]) => _reload();

  void _reload() {
    final id = _customerId;
    emit(CatalogueState(
      products: _repo.getProducts(),
      categories: _repo.getCategories(),
      category: state.category,
      query: state.query,
      lastOrder: id == null ? null : _repo.getLastOrderFor(id),
    ));
  }

  /// The signed-in customer's price, ex VAT.
  double priceFor(Product product) {
    final id = _customerId;
    final customer = id == null ? null : _repo.getCustomer(id);
    return customer == null ? product.tradePrice : _repo.priceFor(product, customer);
  }

  Product? productById(String id) => _repo.getProduct(id);

  void selectCategory(String category) => emit(state.copyWith(category: category));

  void search(String query) => emit(state.copyWith(query: query));

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}
