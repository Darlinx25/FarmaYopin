import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../api/api_client.dart';
import '../models/purchase.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'purchase_detail_screen.dart';

class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({super.key});

  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> {
  List<Purchase> _purchases = [];
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
      final data = await ApiClient.get('/api/purchases');
      final list = (data['data'] as List<dynamic>? ?? [])
          .map((e) => Purchase.fromJson(e as Map<String, dynamic>))
          .toList();
      if (!mounted) return;
      setState(() => _purchases = list);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _purchases = [];
      });
    } catch (e, s) {
      debugPrint('[COMPRAS] error inesperado: $e\n$s');
      if (!mounted) return;
      setState(() {
        _error = 'No se pudo conectar con el servidor';
        _purchases = [];
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _go(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

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

  String _itemsSummary(Purchase purchase) {
    if (purchase.items.isEmpty) return 'Sin productos';
    return purchase.items
        .map((item) => '${item.quantity}x ${item.name}')
        .join(', ');
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
                      _buildBottomNav(),
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: const Row(
        children: [
          Text(
            'Mis Compras',
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

    if (_purchases.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No hay compras todavía',
            textAlign: TextAlign.center,
            style: TextStyle(
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
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: _purchases.map(_buildCard).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(Purchase purchase) {
    return GestureDetector(
      onTap: () => _go(PurchaseDetailScreen(purchase: purchase)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                const Text(
                  'Medicamentos',
                  style: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 11,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _itemsSummary(purchase),
                  style: const TextStyle(
                    color: Color(0xFF4B5563),
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
                Text(
                  _formatDate(purchase.date),
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(
                        color: Color(0xFF4B5563),
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatMoney(purchase.total),
                      style: const TextStyle(
                        color: Color(0xFF1E47EB),
                        fontSize: 13,
                        fontFamily: 'Work Sans',
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.26,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    final color = active ? const Color(0xFFF28E2A) : const Color(0xFF4B5563);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 2,
        children: [
          Icon(icon, color: color, size: 22),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontFamily: 'Inter',
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      width: double.infinity,
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _navItem(
              icon: Icons.storefront,
              label: 'Catálogo',
              active: false,
              onTap: () => Navigator.of(context)
                  .popUntil((route) => route.isFirst),
            ),
          ),
          Expanded(
            child: _navItem(
              icon: Icons.shopping_cart_outlined,
              label: 'Carrito',
              active: false,
              onTap: () => _go(const CartScreen()),
            ),
          ),
          Expanded(
            child: _navItem(
              icon: Icons.receipt_long_outlined,
              label: 'Mis Compras',
              active: true,
              onTap: () {},
            ),
          ),
          Expanded(
            child: _navItem(
              icon: Icons.person_outline,
              label: 'Perfil',
              active: false,
              onTap: () => _go(const ProfileScreen()),
            ),
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