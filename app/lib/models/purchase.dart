class Purchase {
  final int id;
  final double total;
  final DateTime date;
  final List<PurchaseItem> items;

  Purchase({
    required this.id,
    required this.total,
    required this.date,
    required this.items,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['id'],
      total: (json['total'] ?? 0).toDouble(),
      date: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      items: (json['items'] as List? ?? [])
          .map((e) => PurchaseItem.fromJson(e))
          .toList(),
    );
  }
}

class PurchaseItem {
  final int productId;
  final String name;
  final int quantity;
  final double unitPrice;

  PurchaseItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });

  factory PurchaseItem.fromJson(Map<String, dynamic> json) {
    return PurchaseItem(
      productId: json['product_id'],
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unit_price'] ?? 0).toDouble(),
    );
  }
}