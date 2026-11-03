import 'package:equatable/equatable.dart';

import 'package:merchant_demo/data/models/product.dart';

class AdminProductsState extends Equatable {
  const AdminProductsState({this.products = const [], this.query = ''});

  /// Every product, including ones hidden from the buyer app.
  final List<Product> products;
  final String query;

  List<Product> get visible {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return products;
    return products.where((p) => p.name.toLowerCase().contains(q) || p.sku.toLowerCase().contains(q)).toList();
  }

  int get outOfStock => products.where((p) => p.stockLevel == StockLevel.out).length;
  int get lowStock => products.where((p) => p.stockLevel == StockLevel.low).length;

  AdminProductsState copyWith({List<Product>? products, String? query}) =>
      AdminProductsState(products: products ?? this.products, query: query ?? this.query);

  @override
  List<Object?> get props => [products, query];
}
