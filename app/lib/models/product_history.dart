class ProductHistoryItem {
  final DateTime date;
  final int quantity;
  final String client;
  final String product;
  final double amount;

  ProductHistoryItem({
    required this.date,
    required this.quantity,
    required this.client,
    required this.product,
    required this.amount,
  });

  factory ProductHistoryItem.fromJson(Map<String, dynamic> json) {
    return ProductHistoryItem(
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      quantity: json['quantity'] ?? 0,
      client: json['client'] ?? '',
      product: json['product'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
    );
  }
}