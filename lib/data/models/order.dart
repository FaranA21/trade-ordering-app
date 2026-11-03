import 'package:equatable/equatable.dart';

import 'package:merchant_demo/data/models/order_item.dart';
import 'package:merchant_demo/data/models/order_status.dart';

/// Named TradeOrder so it does not clash with other "Order" classes in packages.
class TradeOrder extends Equatable {
  const TradeOrder({
    required this.id,
    required this.orderNo,
    required this.customerId,
    required this.customerName,
    required this.placedAt,
    required this.status,
    required this.fulfilment,
    required this.poReference,
    required this.deliveryAddress,
    required this.items,
  });

  final String id;
  final String orderNo;
  final String customerId;
  final String customerName;
  final DateTime placedAt;
  final OrderStatus status;
  final Fulfilment fulfilment;
  final String poReference;
  final String deliveryAddress;
  final List<OrderItem> items;

  static const double vatRate = 0.2;

  /// Status text that fits how the order is fulfilled.
  String get statusLabel {
    if (fulfilment == Fulfilment.collection) {
      if (status == OrderStatus.outForDelivery) return 'Ready to collect';
      if (status == OrderStatus.delivered) return 'Collected';
    }
    return status.label;
  }

  bool get isActive => status != OrderStatus.delivered;

  double get subtotal => _round(items.fold(0.0, (sum, i) => sum + i.lineTotal));
  double get vat => _round(subtotal * vatRate);
  double get total => _round(subtotal + vat);
  int get itemCount => items.fold(0, (sum, i) => sum + i.qty);

  factory TradeOrder.fromJson(Map<String, dynamic> json) => TradeOrder(
        id: json['id'] as String,
        orderNo: json['orderNo'] as String,
        customerId: json['customerId'] as String,
        customerName: json['customerName'] as String,
        placedAt: DateTime.parse(json['placedAt'] as String),
        status: OrderStatus.fromKey(json['status'] as String),
        fulfilment: Fulfilment.fromKey(json['fulfilment'] as String),
        poReference: json['poReference'] as String? ?? '',
        deliveryAddress: json['deliveryAddress'] as String? ?? '',
        items: (json['items'] as List)
            .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'orderNo': orderNo,
        'customerId': customerId,
        'customerName': customerName,
        'placedAt': placedAt.toIso8601String(),
        'status': status.key,
        'fulfilment': fulfilment.key,
        'poReference': poReference,
        'deliveryAddress': deliveryAddress,
        'paymentMethod': 'account',
        'items': items.map((i) => i.toJson()).toList(),
        'subtotal': subtotal,
        'vat': vat,
        'total': total,
      };

  TradeOrder copyWith({OrderStatus? status}) => TradeOrder(
        id: id,
        orderNo: orderNo,
        customerId: customerId,
        customerName: customerName,
        placedAt: placedAt,
        status: status ?? this.status,
        fulfilment: fulfilment,
        poReference: poReference,
        deliveryAddress: deliveryAddress,
        items: items,
      );

  /// Same order with its date moved (used to keep the demo data current).
  TradeOrder shifted(Duration by) => TradeOrder(
        id: id,
        orderNo: orderNo,
        customerId: customerId,
        customerName: customerName,
        placedAt: placedAt.add(by),
        status: status,
        fulfilment: fulfilment,
        poReference: poReference,
        deliveryAddress: deliveryAddress,
        items: items,
      );

  static double _round(double v) => (v * 100).roundToDouble() / 100;

  @override
  List<Object?> get props => [id, status];
}
