import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../models/cart_item.dart';
import '../models/payment_method.dart';
import '../services/cart_service.dart';
import '../services/catalog_service.dart';
import 'payment_options_screen.dart';
import 'payment_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String _money(double value) {
    final fixed = value.toStringAsFixed(2);
    final parts = fixed.split('.');
    final intPart = parts[0];
    final buffer = StringBuffer();
    for (var i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buffer.write(',');
      buffer.write(intPart[i]);
    }
    return '\$${buffer.toString()}.${parts[1]}';
  }

  Future<void> _goToPayment() async {
    if (CartService.instance.isEmpty) return;
    final navigator = Navigator.of(context);
    final selection = await navigator.push<PaymentSelection>(
      MaterialPageRoute(builder: (_) => const PaymentOptionsScreen()),
    );
    if (selection == null || !mounted) return;
    await navigator.push(
      MaterialPageRoute(
        builder: (_) => PaymentScreen(selection: selection),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CartService.instance,
      builder: (context, _) {
        final items = CartService.instance.items;
        final total = CartService.instance.total;

        return LayoutBuilder(
          builder: (context, constraints) {
            final height = constraints.maxHeight;
            return Scaffold(
              backgroundColor: const Color(0xFFFAFAF9),
              body: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Container(
                      width: double.infinity,
                      height: height,
                      clipBehavior: Clip.antiAlias,
                      decoration: const ShapeDecoration(
                        color: Color(0xFFFAFAF9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(40)),
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildHeader(),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  spacing: 12,
                                  children: [
                                    if (items.isEmpty)
                                      const Padding(
                                        padding: EdgeInsets.only(top: 80),
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.shopping_cart_outlined,
                                              size: 56,
                                              color: Color(0xFF9CA3AF),
                                            ),
                                            SizedBox(height: 12),
                                            Text(
                                              'Tu carrito está vacío',
                                              style: TextStyle(
                                                color: Color(0xFF4B5563),
                                                fontSize: 14,
                                                fontFamily: 'Work Sans',
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    else
                                      ...items.map(_cartItem),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          _buildFooter(total: total, enabled: items.isNotEmpty),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Volver',
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 4),
          const Flexible(
            child: Text(
              'Mi Carrito',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Color(0xFF1E47EB),
                fontSize: 20,
                fontFamily: 'Work Sans',
                fontWeight: FontWeight.w700,
                letterSpacing: -0.40,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cartItem(CartItem item) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: const Color(0xFFD6E9F9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: item.imageUrl.isEmpty
                ? const Icon(
                    Icons.medication,
                    color: Color(0xFF1E47EB),
                    size: 28,
                  )
                : Image.network(
                    ApiClient.resolveImageUrl(item.imageUrl),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(
                      Icons.medication,
                      color: Color(0xFF1E47EB),
                      size: 28,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF1E47EB),
                    fontSize: 13,
                    fontFamily: 'Work Sans',
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.26,
                  ),
                ),
                Text(
                  _money(item.price),
                  style: const TextStyle(
                    color: Color(0xFFF28E2A),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: ShapeDecoration(
                        color: const Color(0xFFFAFAF9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 16),
                            visualDensity: VisualDensity.compact,
                            color: const Color(0xFF1E47EB),
                            onPressed: () => _decrease(item),
                          ),
                          Text(
                            '${item.quantity}',
                            style: const TextStyle(
                              color: Color(0xFF1E47EB),
                              fontSize: 13,
                              fontFamily: 'Work Sans',
                              fontWeight: FontWeight.w400,
                              letterSpacing: -0.26,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 16),
                            visualDensity: VisualDensity.compact,
                            color: const Color(0xFF1E47EB),
                            onPressed: () => _increase(item),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      color: const Color(0xFFEF4444),
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Quitar',
                      onPressed: () => CartService.instance.remove(
                        item.productId,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _increase(CartItem item) {
    int? max;
    for (final p in CatalogService.instance.products) {
      if (p.id == item.productId) {
        max = p.stock;
        break;
      }
    }
    if (max != null && item.quantity >= max) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stock insuficiente')),
      );
      return;
    }
    CartService.instance.updateQuantity(item.productId, item.quantity + 1);
  }

  void _decrease(CartItem item) {
    if (item.quantity <= 1) {
      CartService.instance.remove(item.productId);
    } else {
      CartService.instance.updateQuantity(item.productId, item.quantity - 1);
    }
  }

  Widget _buildFooter({required double total, required bool enabled}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total a Pagar',
                style: TextStyle(
                  color: Color(0xFF1E47EB),
                  fontSize: 20,
                  fontFamily: 'Work Sans',
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.40,
                ),
              ),
              Flexible(
                child: Text(
                  _money(total),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFF28E2A),
                    fontSize: 20,
                    fontFamily: 'Work Sans',
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.40,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFF28E2A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: enabled ? _goToPayment : null,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  Icon(Icons.payment, color: Colors.white, size: 18),
                  Text(
                    'Pagar',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontFamily: 'Work Sans',
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.26,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}