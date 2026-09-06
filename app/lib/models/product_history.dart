class ProductHistoryItem {
  final DateTime date;
  final int quantity;
  final String client;

  ProductHistoryItem({
    required this.date,
    required this.quantity,
    required this.client,
  });

  factory ProductHistoryItem.fromJson(Map<String, dynamic> json) {
    return ProductHistoryItem(
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      quantity: json['quantity'] ?? 0,
      client: json['client'] ?? '',
    );
  }
}