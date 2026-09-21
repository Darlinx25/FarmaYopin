import 'package:flutter/material.dart';

import '../models/card.dart';
import '../models/payment_method.dart';
import '../services/card_service.dart';
import 'add_card_screen.dart';

class PaymentOptionsScreen extends StatefulWidget {
  const PaymentOptionsScreen({super.key});

  @override
  State<PaymentOptionsScreen> createState() => _PaymentOptionsScreenState();
}

class _PaymentOptionsScreenState extends State<PaymentOptionsScreen> {
  PaymentMethod _selected = PaymentMethod.cash;
  CardModel? _card;

  @override
  void initState() {
    super.initState();
    _card = CardService.instance.defaultCard;
  }

  Future<void> _openAddCard() async {
    final card = await Navigator.of(context).push<CardModel>(
      MaterialPageRoute(
        builder: (_) => AddCardScreen(initial: _card),
      ),
    );
    if (card == null || !mounted) return;
    setState(() {
      _card = card;
      _selected = PaymentMethod.card;
    });
  }

  Future<void> _selectCard() async {
    if (_card != null) {
      setState(() => _selected = PaymentMethod.card);
      return;
    }
    await _openAddCard();
  }

  Future<void> _confirm() async {
    if (_selected == PaymentMethod.cash) {
      Navigator.of(context).pop(
        const PaymentSelection(method: PaymentMethod.cash),
      );
      return;
    }
    if (_card == null) {
      await _openAddCard();
      if (!mounted || _card == null) return;
      _finishCard();
      return;
    }
    _finishCard();
  }

  void _finishCard() {
    Navigator.of(context).pop(
      PaymentSelection(method: PaymentMethod.card, card: _card),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 12,
                              children: [
                                _buildOption(
                                  selected: _selected == PaymentMethod.card,
                                  icon: Icons.credit_card,
                                  title: 'Tarjeta de Crédito/Débito',
                                  subtitle: _card != null
                                      ? '${_card!.maskedLabel} (Predeterminada)'
                                      : 'Agrega tu tarjeta para pagar',
                                  onTap: _selectCard,
                                  onSubtitleTap:
                                      _card != null ? _openAddCard : null,
                                ),
                                _buildOption(
                                  selected: _selected == PaymentMethod.cash,
                                  icon: Icons.payments_rounded,
                                  title: 'Pago en Efectivo',
                                  subtitle: 'Paga al recibir tu pedido',
                                  onTap: () => setState(
                                    () => _selected = PaymentMethod.cash,
                                  ),
                                ),
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
              'Método de Pago',
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

  Widget _buildOption({
    required bool selected,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    VoidCallback? onSubtitleTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: selected ? 2 : 1,
              color: selected
                  ? const Color(0xFFF28E2A)
                  : const Color(0xFFE5E7EB),
            ),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 12,
          children: [
            Icon(icon, color: const Color(0xFF1E47EB), size: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF1E47EB),
                      fontSize: 15,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  GestureDetector(
                    onTap: onSubtitleTap,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            subtitle,
                            style: TextStyle(
                              color: onSubtitleTap != null
                                  ? const Color(0xFFF28E2A)
                                  : const Color(0xFF4B5563),
                              fontSize: 12,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        if (onSubtitleTap != null) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.chevron_right,
                            size: 14,
                            color: Color(0xFFF28E2A),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 18,
              height: 18,
              decoration: ShapeDecoration(
                color: selected
                    ? const Color(0xFFF28E2A)
                    : Colors.transparent,
                shape: OvalBorder(
                  side: BorderSide(
                    width: selected ? 1 : 2,
                    color: selected
                        ? const Color(0xFFF28E2A)
                        : const Color(0xFFE5E7EB),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
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
              onPressed: _confirm,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  Icon(Icons.check_circle_outline,
                      color: Colors.white, size: 18),
                  Text(
                    'Confirmar Método',
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
}