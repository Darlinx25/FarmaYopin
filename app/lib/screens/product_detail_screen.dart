import 'package:flutter/material.dart';

import '../models/product.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  void _increment() => setState(() => _quantity++);
  void _decrement() {
    if (_quantity > 1) setState(() => _quantity--);
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return LayoutBuilder(
      builder: (context, constraints) {
        final height =
            constraints.maxHeight < 400 ? 400.0 : constraints.maxHeight;
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
                      _buildHeader(context),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildImage(),
                              _buildInfo(product),
                            ],
                          ),
                        ),
                      ),
                      _buildAddToCart(product),
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: ShapeDecoration(
                color: const Color(0xFFFAFAF9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Color(0xFF1E47EB),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Detalle de Producto',
            style: TextStyle(
              color: Color(0xFF1E47EB),
              fontSize: 20,
              fontFamily: 'Work Sans',
              fontWeight: FontWeight.w700,
              letterSpacing: -0.40,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      width: double.infinity,
      height: 220,
      color: const Color(0xFFD6E9F9),
      child: const Icon(
        Icons.medication,
        color: Color(0xFF1E47EB),
        size: 64,
      ),
    );
  }

  Widget _buildInfo(Product product) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            style: const TextStyle(
              color: Color(0xFF1E47EB),
              fontSize: 34,
              fontFamily: 'Work Sans',
              fontWeight: FontWeight.w700,
              letterSpacing: -0.68,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '\$${product.price.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Color(0xFFF28E2A),
              fontSize: 22,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 1,
            color: const Color(0xFFE5E7EB),
          ),
          const SizedBox(height: 20),
          if (product.description.isNotEmpty) ...[
            const Text(
              'Descripción',
              style: TextStyle(
                color: Color(0xFF1E47EB),
                fontSize: 13,
                fontFamily: 'Work Sans',
                fontWeight: FontWeight.w400,
                letterSpacing: -0.26,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              product.description,
              style: const TextStyle(
                color: Color(0xFF4B5563),
                fontSize: 13,
                fontFamily: 'Work Sans',
                fontWeight: FontWeight.w400,
                letterSpacing: -0.26,
              ),
            ),
            const SizedBox(height: 20),
          ],
          Row(
            children: [
              Expanded(child: _buildStatusCard(product)),
              const SizedBox(width: 12),
              Expanded(child: _buildQuantityCard()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(Product product) {
    final available = product.stock > 0;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estado',
            style: TextStyle(
              color: Color(0xFF4B5563),
              fontSize: 11,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            available ? 'Disponible' : 'Agotado',
            style: TextStyle(
              color:
                  available ? const Color(0xFF10B981) : const Color(0xFFEF4444),
              fontSize: 15,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            '(${product.stock} unidades)',
            style: const TextStyle(
              color: Color(0xFF4B5563),
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cantidad',
            style: TextStyle(
              color: Color(0xFF4B5563),
              fontSize: 11,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _decrement,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFE5E7EB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Icon(Icons.remove,
                      size: 14, color: Color(0xFF4B5563)),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '$_quantity',
                style: const TextStyle(
                  color: Color(0xFF1E47EB),
                  fontSize: 15,
                  fontFamily: 'Work Sans',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: _increment,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFE5E7EB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child:
                      const Icon(Icons.add, size: 14, color: Color(0xFF4B5563)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddToCart(Product product) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      child: Column(
        children: [
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
              onPressed: product.stock > 0 ? () => _addToCart(product) : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_bag, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    product.stock > 0 ? 'Agregar al Carrito' : 'Sin Stock',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
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
          const SizedBox(height: 12),
          Container(
            width: 139,
            height: 5,
            decoration: ShapeDecoration(
              color: const Color(0xFF1E47EB),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addToCart(Product product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} x$_quantity agregado al carrito'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
