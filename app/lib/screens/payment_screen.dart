import 'dart:math';

import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../api/auth_storage.dart';
import '../models/cart_item.dart';
import '../models/payment_method.dart';
import '../models/purchase.dart';
import '../services/cart_service.dart';
import '../services/purchase_service.dart';
import 'payment_options_screen.dart';

class PaymentScreen extends StatefulWidget {
  final PaymentSelection selection;

  const PaymentScreen({super.key, required this.selection});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late PaymentSelection _selection;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _selection = widget.selection;
  }

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

  Future<void> _changeMethod() async {
    final sel = await Navigator.of(context).push<PaymentSelection>(
      MaterialPageRoute(builder: (_) => const PaymentOptionsScreen()),
    );
    if (sel == null || !mounted) return;
    setState(() => _selection = sel);
  }

  Future<void> _confirmPayment() async {
    if (_checking) return;

    setState(() => _checking = true);
    try {
      final items = CartService.instance.items;
      final response = await ApiClient.post(
        '/api/cart/checkout',
        body: {
          'items': items
              .map(
                (i) => {'product_id': i.productId, 'quantity': i.quantity},
              )
              .toList(),
          'payment_method':
              _selection.method == PaymentMethod.card ? 'card' : 'cash',
          'card_last4':
              _selection.method == PaymentMethod.card
                  ? _selection.card?.last4 ?? ''
                  : '',
        },
      );
      final userId = await AuthStorage.getUserId();
      final total = items.fold(0.0, (sum, i) => sum + i.subtotal);
      if (userId != null && response is Map<String, dynamic>) {
        final purchase = Purchase(
          id: response['sale_id'] as int? ?? DateTime.now().millisecondsSinceEpoch,
          total: (response['total'] as num?)?.toDouble() ?? total,
          paymentMethod:
              _selection.method == PaymentMethod.card ? 'card' : 'cash',
          cardLast4: _selection.method == PaymentMethod.card
              ? _selection.card?.last4 ?? ''
              : '',
          date: DateTime.now(),
          items: items
              .map(
                (i) => PurchaseItem(
                  productId: i.productId,
                  name: i.name,
                  quantity: i.quantity,
                  unitPrice: i.price,
                  imageUrl: i.imageUrl,
                ),
              )
              .toList(),
        );
        try {
          await PurchaseService.instance.savePurchase(userId, purchase);
        } catch (_) {}
      }
      await CartService.instance.clear();

      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);
      navigator.popUntil((route) => route.isFirst);
      messenger.showSnackBar(
        const SnackBar(content: Text('Compra realizada con éxito')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo procesar la compra'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
    } finally {
      if (mounted) setState(() => _checking = false);
    }
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
            final height = max(constraints.maxHeight, 780.0);
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
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  spacing: 16,
                                  children: [
                                    const Text(
                                      'Productos en tu pedido',
                                      style: TextStyle(
                                        color: Color(0xFF1E47EB),
                                        fontSize: 20,
                                        fontFamily: 'Work Sans',
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.40,
                                      ),
                                    ),
                                    ...items.map(_productItem),
                                    _buildMethod(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          _buildFooter(total: total),
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
              'Resumen de Pago',
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

  Widget _productItem(CartItem item) {
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
            width: 50,
            height: 50,
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: const Color(0xFFD6E9F9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: item.imageUrl.isNotEmpty
                ? Image.network(
                    ApiClient.resolveImageUrl(item.imageUrl),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const _MedicationThumb(),
                  )
                : const _MedicationThumb(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  '${item.name} x${item.quantity}',
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
                  _money(item.subtotal),
                  style: const TextStyle(
                    color: Color(0xFFF28E2A),
                    fontSize: 13,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String get _methodLabel {
    if (_selection.method == PaymentMethod.card) {
      return _selection.card?.summary ?? 'Tarjeta de Crédito/Débito';
    }
    return 'Pago en Efectivo';
  }

  Widget _buildMethod() {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Método de Pago',
                style: TextStyle(
                  color: Color(0xFF1E47EB),
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
              GestureDetector(
                onTap: _changeMethod,
                child: const Text(
                  'Cambiar',
                  style: TextStyle(
                    color: Color(0xFFF28E2A),
                    fontSize: 13,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          Row(
            spacing: 10,
            children: [
              Icon(
                _selection.method == PaymentMethod.card
                    ? Icons.credit_card
                    : Icons.payments_rounded,
                color: const Color(0xFF1E47EB),
                size: 22,
              ),
              Text(
                _methodLabel,
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
        ],
      ),
    );
  }

  Widget _buildFooter({required double total}) {
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
          _totalRow('Subtotal', _money(total), color: const Color(0xFF4B5563)),
          _totalRow('Envío', 'Gratis', color: const Color(0xFF10B981)),
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFE5E7EB)),
              ),
            ),
          ),
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
              onPressed: _checking ? null : _confirmPayment,
              child: _checking
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 8,
                      children: [
                        Icon(Icons.payment, color: Colors.white, size: 18),
                        Text(
                          'Confirmar Pago',
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
          Center(
            child: Container(
              width: 139,
              height: 5,
              decoration: ShapeDecoration(
                color: const Color(0xFF1E47EB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _totalRow(String label, String value, {required Color color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF4B5563),
            fontSize: 13,
            fontFamily: 'Work Sans',
            fontWeight: FontWeight.w400,
            letterSpacing: -0.26,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontFamily: 'Work Sans',
            fontWeight: FontWeight.w400,
            letterSpacing: -0.26,
          ),
        ),
      ],
    );
  }
}

class _MedicationThumb extends StatelessWidget {
  const _MedicationThumb();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.medication,
      color: Color(0xFF1E47EB),
      size: 26,
    );
  }
}