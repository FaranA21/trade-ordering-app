import 'package:equatable/equatable.dart';

enum StockLevel { inStock, low, out }

class Product extends Equatable {
  const Product({
    required this.id,
    required this.sku,
    required this.name,
    required this.category,
    required this.packSize,
    required this.unit,
    required this.tradePrice,
    required this.vatRate,
    required this.stock,
    required this.available,
    this.imageUrl,
    this.photoCredit,
    this.photoCreditUrl,
  });

  final String id;
  final String sku;
  final String name;
  final String category;
  final String packSize;
  final String unit;

  /// List trade price, GBP, ex VAT. Each customer may get a discount on top.
  final double tradePrice;
  final double vatRate;
  final int stock;

  /// Hidden from the buyer app when false (set in admin).
  final bool available;

  /// Unsplash photo (hotlinked, as Unsplash requires). Null = use the local asset.
  final String? imageUrl;

  /// "Photo by X on Unsplash", shown on the product page.
  final String? photoCredit;
  final String? photoCreditUrl;

  static const int lowStockLimit = 10;

  StockLevel get stockLevel {
    if (stock <= 0) return StockLevel.out;
    if (stock < lowStockLimit) return StockLevel.low;
    return StockLevel.inStock;
  }

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as String,
        sku: json['sku'] as String,
        name: json['name'] as String,
        category: json['category'] as String,
        packSize: json['packSize'] as String,
        unit: json['unit'] as String,
        tradePrice: (json['tradePrice'] as num).toDouble(),
        vatRate: (json['vatRate'] as num).toDouble(),
        stock: json['stock'] as int,
        available: json['available'] as bool? ?? true,
        imageUrl: json['imageUrl'] as String?,
        photoCredit: json['photoCredit'] as String?,
        photoCreditUrl: json['photoCreditUrl'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'sku': sku,
        'name': name,
        'category': category,
        'packSize': packSize,
        'unit': unit,
        'tradePrice': tradePrice,
        'vatRate': vatRate,
        'stock': stock,
        'available': available,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (photoCredit != null) 'photoCredit': photoCredit,
        if (photoCreditUrl != null) 'photoCreditUrl': photoCreditUrl,
      };

  Product copyWith({double? tradePrice, int? stock, bool? available}) => Product(
        id: id,
        sku: sku,
        name: name,
        category: category,
        packSize: packSize,
        unit: unit,
        tradePrice: tradePrice ?? this.tradePrice,
        vatRate: vatRate,
        stock: stock ?? this.stock,
        available: available ?? this.available,
        imageUrl: imageUrl,
        photoCredit: photoCredit,
        photoCreditUrl: photoCreditUrl,
      );

  @override
  List<Object?> get props => [id, tradePrice, stock, available];
}
