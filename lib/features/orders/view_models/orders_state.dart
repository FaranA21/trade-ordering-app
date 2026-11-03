import 'package:equatable/equatable.dart';

import 'package:merchant_demo/data/models/order.dart';

class OrdersState extends Equatable {
  const OrdersState({this.orders = const []});

  /// The signed-in customer's orders, newest first.
  final List<TradeOrder> orders;

  TradeOrder? byId(String id) {
    for (final o in orders) {
      if (o.id == id) return o;
    }
    return null;
  }

  @override
  List<Object?> get props => [orders];
}
