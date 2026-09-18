import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/card.dart';
import '../services/card_service.dart';

class AddCardScreen extends StatefulWidget {
  final CardModel? initial;

  const AddCardScreen({super.key, this.initial});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _numberController = TextEditingController();
  final _holderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _saveDefault = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      _numberController.text = _group(initial.number);
      _holderController.text = initial.holder;
      _expiryController.text = initial.expiry;
      _saveDefault = true;
    }
  }

  String _group(String digits) {
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  @override
  void dispose() {
    _numberController.dispose();
    _holderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  String _digits(TextEditingController controller) =>
      controller.text.replaceAll(RegExp(r'\D'), '');

  String get _groupedNumber {
    final digits = _digits(_numberController);
    final slots = List<String>.filled(16, '•');
    for (var i = 0; i < digits.length && i < 16; i++) {
      slots[i] = digits[i];
    }
    final buffer = StringBuffer();
    for (var i = 0; i < slots.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write('  ');
      buffer.write(slots[i]);
    }
    return buffer.toString();
  }

  String get _formattedExpiry {
    final text = _expiryController.text;
    if (text.isEmpty) return 'MM/AA';
    final digits = _digits(_expiryController);
    return digits.length > 2 ? '${digits.substring(0, 2)}/${digits.substring(2)}' : text;
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? const Color(0xFFEF4444) : const Color(0xFFF28E2A),
      ),
    );
  }

  Future<void> _confirm() async {
    final number = _digits(_numberController);
    final holder = _holderController.text.trim();
    final expiry = _formattedExpiry;
    final cvv = _digits(_cvvController);

    if (number.length != 16) {
      _showMessage('Ingresá un número de tarjeta válido (16 dígitos)',
          isError: true);
      return;
    }
    if (holder.isEmpty) {
      _showMessage('Ingresá el nombre del titular', isError: true);
      return;
    }
    final expiryMatch = RegExp(r'^(\d{2})/(\d{2})$').firstMatch(expiry);
    if (expiryMatch == null) {
      _showMessage('Ingresá una fecha de vencimiento válida (MM/AA)',
          isError: true);
      return;
    }
    final month = int.parse(expiryMatch.group(1)!);
    if (month < 1 || month > 12) {
      _showMessage('Ingresá un mes válido', isError: true);
      return;
    }
    if (cvv.length < 3) {
      _showMessage('Ingresá un CVV válido', isError: true);
      return;
    }

    var card = CardModel(
      userId: CardService.instance.userId ?? 0,
      holder: holder,
      number: number,
      expiry: '${expiryMatch.group(1)!}/${expiryMatch.group(2)!}',
      last4: number.substring(number.length - 4),
    );
    if (_saveDefault) {
      card = await CardService.instance.saveAsDefault(card);
    }
    if (!mounted) return;
    Navigator.of(context).pop(card);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = max(constraints.maxHeight, 760.0);
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
                              spacing: 16,
                              children: [
                                _buildCardPreview(),
                                _label('Número de Tarjeta'),
                                _field(
                                  controller: _numberController,
                                  hint: '0000 0000 0000 0000',
                                  keyboardType: TextInputType.number,
                                  formatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(16),
                                    _NumberGroupFormatter(),
                                  ],
                                ),
                                _label('Nombre del Titular'),
                                _field(
                                  controller: _holderController,
                                  hint: 'Como aparece en la tarjeta',
                                  textCapitalization:
                                      TextCapitalization.words,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        spacing: 6,
                                        children: [
                                          _label('Fecha de Vencimiento'),
                                          _field(
                                            controller: _expiryController,
                                            hint: 'MM/AA',
                                            keyboardType:
                                                TextInputType.datetime,
                                            formatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                              LengthLimitingTextInputFormatter(
                                                  4),
                                              _ExpiryFormatter(),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        spacing: 6,
                                        children: [
                                          _label('CVV'),
                                          _field(
                                            controller: _cvvController,
                                            hint: '123',
                                            obscure: true,
                                            keyboardType: TextInputType.number,
                                            formatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                              LengthLimitingTextInputFormatter(
                                                  4),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                _buildSaveDefault(),
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
              'Añadir Tarjeta',
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

  Widget _buildCardPreview() {
    return Container(
      width: double.infinity,
      height: 176,
      padding: const EdgeInsets.all(20),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        gradient: const LinearGradient(
          begin: Alignment(0.00, 0.00),
          end: Alignment(1.00, 1.00),
          colors: [Color(0xFF1F48EC), Color(0xFF0D2EAD)],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                Icons.contactless_rounded,
                color: Colors.white70,
                size: 24,
              ),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
            _groupedNumber,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'Work Sans',
              fontWeight: FontWeight.w700,
              letterSpacing: 0.36,
            ),
          ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(
                    'TITULAR',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.63),
                      fontSize: 9,
                      fontFamily: 'Work Sans',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    _holderController.text.isEmpty
                        ? 'NOMBRE COMPLETO'
                        : _holderController.text.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontFamily: 'Work Sans',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: 2,
                children: [
                  Text(
                    'VENCE',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.63),
                      fontSize: 9,
                      fontFamily: 'Work Sans',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    _formattedExpiry,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontFamily: 'Work Sans',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF4B5563),
        fontSize: 13,
        fontFamily: 'Work Sans',
        fontWeight: FontWeight.w400,
        letterSpacing: -0.26,
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    bool obscure = false,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? formatters,
  }) {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscure,
        textCapitalization: textCapitalization,
        inputFormatters: formatters,
        style: const TextStyle(
          color: Color(0xFF4B5563),
          fontSize: 13,
          fontFamily: 'Work Sans',
        ),
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 13,
            fontFamily: 'Work Sans',
            fontWeight: FontWeight.w400,
            letterSpacing: -0.26,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: Color(0xFFF28E2A), width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveDefault() {
    return GestureDetector(
      onTap: () => setState(() => _saveDefault = !_saveDefault),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _saveDefault ? Icons.check_box : Icons.check_box_outline_blank,
            color: const Color(0xFFF28E2A),
            size: 22,
          ),
          const SizedBox(width: 6),
          const Text(
            'Guardar como predeterminada',
            style: TextStyle(
              color: Color(0xFF4B5563),
              fontSize: 13,
              fontFamily: 'Work Sans',
              fontWeight: FontWeight.w400,
              letterSpacing: -0.26,
            ),
          ),
        ],
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
                  Icon(Icons.lock_outline, color: Colors.white, size: 18),
                  Text(
                    'Confirmar Tarjeta',
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

class _NumberGroupFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final trimmed = digits.length > 4 ? digits.substring(0, 4) : digits;
    final text = trimmed.length > 2
        ? '${trimmed.substring(0, 2)}/${trimmed.substring(2)}'
        : trimmed;
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}