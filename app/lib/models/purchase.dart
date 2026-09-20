class Purchase {
  final int id;
  final double total;
  final String paymentMethod;
  final String cardLast4;
  final DateTime date;
  final List<PurchaseItem> items;

  Purchase({
    required this.id,
    required this.total,
    required this.paymentMethod,
    required this.cardLast4,
    required this.date,
    required this.items,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['id'],
      total: (json['total'] ?? 0).toDouble(),
      paymentMethod: json['payment_method'] ?? 'cash',
      cardLast4: json['card_last4'] ?? '',
      date: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      items: (json['items'] as List? ?? [])
          .map((e) => PurchaseItem.fromJson(e))
          .toList(),
    );
  }

  factory Purchase.fromMap(Map<String, Object?> map, List<PurchaseItem> items) {
    return Purchase(
      id: map['id'] as int,
      total: (map['total'] as num?)?.toDouble() ?? 0,
      paymentMethod: map['payment_method'] as String? ?? 'cash',
      cardLast4: map['card_last4'] as String? ?? '',
      date:
          DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
      items: items,
    );
  }

  Map<String, Object?> toInsertMap() {
    return {
      'id': id,
      'total': total,
      'payment_method': paymentMethod,
      'card_last4': cardLast4,
      'created_at': date.toIso8601String(),
    };
  }
}

class PurchaseItem {
  final int productId;
  final String name;
  final int quantity;
  final double unitPrice;
  final String imageUrl;

  PurchaseItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.imageUrl,
  });

  double get subtotal => unitPrice * quantity;

  factory PurchaseItem.fromJson(Map<String, dynamic> json) {
    return PurchaseItem(
      productId: json['product_id'],
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unit_price'] ?? 0).toDouble(),
      imageUrl: json['image_url'] ?? '',
    );
  }

  factory PurchaseItem.fromMap(Map<String, Object?> map) {
    return PurchaseItem(
      productId: map['product_id'] as int,
      name: map['name'] as String? ?? '',
      quantity: map['quantity'] as int? ?? 0,
      unitPrice: (map['unit_price'] as num?)?.toDouble() ?? 0,
      imageUrl: map['image_url'] as String? ?? '',
    );
  }

  Map<String, Object?> toInsertMap(int purchaseId, int userId) {
    return {
      'purchase_id': purchaseId,
      'user_id': userId,
      'product_id': productId,
      'name': name,
      'quantity': quantity,
      'unit_price': unitPrice,
      'image_url': imageUrl,
    };
  }
}