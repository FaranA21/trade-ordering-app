enum OrderStatus {
  placed('placed', 'Placed'),
  packed('packed', 'Packed'),
  outForDelivery('outForDelivery', 'Out for delivery'),
  delivered('delivered', 'Delivered');

  const OrderStatus(this.key, this.label);

  /// Value stored in JSON.
  final String key;

  /// Text shown to people.
  final String label;

  static OrderStatus fromKey(String key) =>
      OrderStatus.values.firstWhere((s) => s.key == key, orElse: () => OrderStatus.placed);

  /// The next stage, or null when already delivered.
  OrderStatus? get next {
    final i = OrderStatus.values.indexOf(this);
    return i < OrderStatus.values.length - 1 ? OrderStatus.values[i + 1] : null;
  }
}

enum Fulfilment {
  delivery('delivery', 'Delivery to site'),
  collection('collection', 'Collect from branch');

  const Fulfilment(this.key, this.label);
  final String key;
  final String label;

  static Fulfilment fromKey(String key) =>
      Fulfilment.values.firstWhere((f) => f.key == key, orElse: () => Fulfilment.delivery);
}
