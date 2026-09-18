import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../api/api_client.dart';
import '../../models/product.dart';
import '../../models/product_history.dart';

class AdminProductHistoryScreen extends StatefulWidget {
  final Product? product;

  const AdminProductHistoryScreen({super.key, this.product});

  @override
  State<AdminProductHistoryScreen> createState() =>
      _AdminProductHistoryScreenState();
}

class _AdminProductHistoryScreenState extends State<AdminProductHistoryScreen> {
  List<ProductHistoryItem> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final product = widget.product;
      final data = product == null
          ? await ApiClient.get('/api/history')
          : await ApiClient.get('/api/products/${product.id}/history');
      final list = (data['data'] as List<dynamic>? ?? [])
          .map((e) => ProductHistoryItem.fromJson(e as Map<String, dynamic>))
          .toList();
      if (!mounted) return;
      setState(() => _items = list);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
      _items = [];
    } catch (e, s) {
      debugPrint('[HISTORIAL] error inesperado: $e\n$s');
      if (!mounted) return;
      setState(() {
        _error = 'No se pudo conectar con el servidor';
        _items = [];
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool get _isProductMode => widget.product != null;

  String _formatMoney(double value) {
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

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  String _quantityLabel(int quantity) {
    return quantity == 1 ? '1 unidad' : '$quantity unidades';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = max(constraints.maxHeight, 700.0);
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
                      Expanded(child: _buildContent()),
                      _buildHomeBar(),
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
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Volver',
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Expanded(
            child: Text(
              'Historial de Compras',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF1E47EB),
                fontSize: 20,
                fontFamily: 'Work Sans',
                fontWeight: FontWeight.w700,
                letterSpacing: -0.40,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: Color(0xFF9CA3AF)),
            const SizedBox(height: 12),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF4B5563),
                fontSize: 13,
                fontFamily: 'Work Sans',
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFF28E2A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _load,
              child: const Text(
                'Reintentar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontFamily: 'Work Sans',
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _isProductMode
                ? 'Sin historial para este producto'
                : 'No hay ventas registradas',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF4B5563),
              fontSize: 14,
              fontFamily: 'Work Sans',
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isProductMode) _buildProductBanner(),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 12,
                  children: _items.map(_buildCard).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductBanner() {
    final product = widget.product!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(color: Color(0xFFD6E9F9)),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: product.imageUrl.isEmpty
                ? const Icon(
                    Icons.medication,
                    color: Color(0xFF1E47EB),
                    size: 20,
                  )
                : Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.medication,
                      color: Color(0xFF1E47EB),
                      size: 20,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    color: Color(0xFF1E47EB),
                    fontSize: 13,
                    fontFamily: 'Work Sans',
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.26,
                  ),
                ),
                Text(
                  'Precio actual: ${_formatMoney(product.price)}',
                  style: const TextStyle(
                    color: Color(0xFF4B5563),
                    fontSize: 11,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(ProductHistoryItem item) {
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          if (!_isProductMode && item.product.isNotEmpty)
            Text(
              item.product,
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
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _formatDate(item.date),
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 11,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _formatMoney(item.amount),
                style: const TextStyle(
                  color: Color(0xFFF28E2A),
                  fontSize: 13,
                  fontFamily: 'Work Sans',
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.26,
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.person,
                      color: Color(0xFF1E47EB),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        item.client,
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
                    ),
                  ],
                ),
              ),
              Text(
                'Cant: ${_quantityLabel(item.quantity)}',
                style: const TextStyle(
                  color: Color(0xFF4B5563),
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHomeBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
}