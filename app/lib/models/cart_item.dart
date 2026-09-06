import 'product.dart';

class CartItem {
  final int productId;
  final String name;
  final double price;
  int quantity;
  final String imageUrl;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });

  factory CartItem.fromProduct(Product product, int quantity) {
    return CartItem(
      productId: product.id,
      name: product.name,
      price: product.price,
      quantity: quantity,
      imageUrl: product.imageUrl,
    );
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['product_id'] ?? json['id'],
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
      imageUrl: json['image_url'] ?? '',
    );
  }

  double get subtotal => price * quantity;
}