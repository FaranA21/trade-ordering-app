import 'package:equatable/equatable.dart';

import 'package:merchant_demo/data/models/order.dart';
import 'package:merchant_demo/data/models/product.dart';

class CatalogueState extends Equatable {
  const CatalogueState({
    this.products = const [],
    this.categories = const [],
    this.category = allCategories,
    this.query = '',
    this.lastOrder,
  });

  static const String allCategories = 'All';

  final List<Product> products;
  final List<String> categories;
  final String category;
  final String query;
  final TradeOrder? lastOrder;

  List<Product> get visible {
    final q = query.trim().toLowerCase();
    return products.where((p) {
      final inCategory = category == allCategories || p.category == category;
      final matches = q.isEmpty || p.name.toLowerCase().contains(q) || p.sku.toLowerCase().contains(q);
      return inCategory && matches;
    }).toList();
  }

  CatalogueState copyWith({
    List<Product>? products,
    List<String>? categories,
    String? category,
    String? query,
    TradeOrder? lastOrder,
  }) =>
      CatalogueState(
        products: products ?? this.products,
        categories: categories ?? this.categories,
        category: category ?? this.category,
        query: query ?? this.query,
        lastOrder: lastOrder ?? this.lastOrder,
      );

  @override
  List<Object?> get props => [products, categories, category, query, lastOrder];
}
