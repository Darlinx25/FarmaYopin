import 'dart:math';

import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _Item {
  final String name;
  final double price;
  int qty;

  _Item(this.name, this.price, this.qty);
}

class _CartScreenState extends State<CartScreen> {
  final _items = [
    _Item('Ibuprofeno 400mg', 450, 2),
    _Item('Amoxicilina 500mg', 1200, 1),
  ];

  double get _total =>
      _items.fold(0, (sum, item) => sum + (item.price * item.qty));

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

  void _incQty(_Item item, int delta) {
    setState(() {
      item.qty = max(1, item.qty + delta);
    });
  }

  void _remove(_Item item) {
    setState(() => _items.remove(item));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = max(constraints.maxHeight, 720.0);
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
                                if (_items.isEmpty)
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
                                  ..._items.map(_cartItem),
                              ],
                            ),
                          ),
                        ),
                      ),
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            ),
          ),
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

  Widget _cartItem(_Item item) {
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
            decoration: ShapeDecoration(
              color: const Color(0xFFD6E9F9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Icon(
              Icons.medication,
              color: Color(0xFF1E47EB),
              size: 28,
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
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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
                            onPressed: () => _incQty(item, -1),
                          ),
                          Text(
                            '${item.qty}',
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
                            onPressed: () => _incQty(item, 1),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      color: const Color(0xFFEF4444),
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Quitar',
                      onPressed: () => _remove(item),
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

  Widget _buildFooter() {
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
                  _money(_total),
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
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Completando la compra (próximamente)'),
                  ),
                );
              },
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