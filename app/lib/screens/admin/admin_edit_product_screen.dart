import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../api/api_client.dart';
import '../../models/product.dart';
import '../../services/catalog_service.dart';

class AdminEditProductScreen extends StatefulWidget {
  final Product product;

  const AdminEditProductScreen({super.key, required this.product});

  @override
  State<AdminEditProductScreen> createState() => _AdminEditProductScreenState();
}

class _AdminEditProductScreenState extends State<AdminEditProductScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;

  late bool _disponible;
  XFile? _image;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _nameController = TextEditingController(text: product.name);
    _descriptionController = TextEditingController(text: product.description);
    _priceController = TextEditingController(
      text: product.price.toStringAsFixed(2).replaceAll('.00', ''),
    );
    _stockController = TextEditingController(text: '${product.stock}');
    _disponible = product.available;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
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

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
    );
    if (picked == null) return;
    if (!mounted) return;
    setState(() => _image = picked);
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final price = double.tryParse(_priceController.text.trim());
    final stock = int.tryParse(_stockController.text.trim());

    if (name.isEmpty) {
      _showMessage('Ingresá el nombre del medicamento', isError: true);
      return;
    }
    if (price == null || price <= 0) {
      _showMessage('Ingresá un precio válido (mayor a 0)', isError: true);
      return;
    }
    if (stock == null || stock < 0) {
      _showMessage('Ingresá un stock válido', isError: true);
      return;
    }

    setState(() => _loading = true);
    try {
      debugPrint('[ADMIN-PRODUCT] actualizando producto: ${widget.product.id}');
      String imageUrl = widget.product.imageUrl;
      if (_image != null) {
        imageUrl = await ApiClient.uploadImage(_image!);
      }
      await ApiClient.put(
        '/api/products/${widget.product.id}',
        body: {
          'name': name,
          'description': description,
          'price': price,
          'stock': stock,
          'image_url': imageUrl,
          'available': _disponible,
        },
      );
      debugPrint('[ADMIN-PRODUCT] actualizado OK');
      await CatalogService.instance.reload();
      if (!mounted) return;
      _showMessage('Producto actualizado');
      Navigator.of(context)..pop()..pop();
    } on ApiException catch (e) {
      debugPrint('[ADMIN-PRODUCT] ApiException: ${e.message}');
      _showMessage(e.message, isError: true);
    } catch (e, s) {
      debugPrint('[ADMIN-PRODUCT] error inesperado: $e\n$s');
      _showMessage('No se pudo conectar con el servidor', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
                              spacing: 16,
                              children: [
                                _buildImagePicker(),
                                _label('Nombre del Medicamento'),
                                _field(
                                  controller: _nameController,
                                  hint: 'Ej: Paracetamol 500mg',
                                ),
                                _label('Descripción'),
                                _field(
                                  controller: _descriptionController,
                                  hint:
                                      'Ej: Analgésico y antipirético para el alivio del dolor',
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
                                          _label('Precio (\$)'),
                                          _field(
                                            controller: _priceController,
                                            hint: 'Ej: 450',
                                            keyboardType:
                                                const TextInputType.numberWithOptions(
                                                    decimal: true),
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
                                          _label('Stock Actual'),
                                          _field(
                                            controller: _stockController,
                                            hint: 'Ej: 100',
                                            keyboardType:
                                                TextInputType.number,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                _buildDisponible(),
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
              'Editar Producto',
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

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 130,
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Color(0xFFF28E2A), width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _buildImageContent(),
      ),
    );
  }

  Widget _buildImageContent() {
    if (_image != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.file(File(_image!.path), fit: BoxFit.cover),
          Positioned(
            right: 8,
            bottom: 8,
            child: _imagePill(),
          ),
        ],
      );
    }
    if (widget.product.imageUrl.isNotEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            ApiClient.resolveImageUrl(widget.product.imageUrl),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.medication,
              color: Color(0xFF1E47EB),
              size: 40,
            ),
          ),
          Positioned(
            right: 8,
            bottom: 8,
            child: _imagePill(),
          ),
        ],
      );
    }
    return const Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 8,
      children: [
        Icon(
          Icons.cloud_upload_outlined,
          color: Color(0xFFF28E2A),
          size: 32,
        ),
        Text(
          'Subir imagen del medicamento',
          style: TextStyle(
            color: Color(0xFFF28E2A),
            fontSize: 13,
            fontFamily: 'Work Sans',
            fontWeight: FontWeight.w400,
            letterSpacing: -0.26,
          ),
        ),
      ],
    );
  }

  Widget _imagePill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: ShapeDecoration(
        color: Colors.black.withValues(alpha: 0.50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.photo_camera_outlined, color: Colors.white, size: 14),
          SizedBox(width: 4),
          Text(
            'Cambiar Imagen',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontFamily: 'Work Sans',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisponible() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => setState(() => _disponible = !_disponible),
          child: Icon(
            _disponible ? Icons.check_box : Icons.check_box_outline_blank,
            color: const Color(0xFFF28E2A),
            size: 22,
          ),
        ),
        const SizedBox(width: 6),
        const Text(
          'Disponible',
          style: TextStyle(
            color: Color(0xFF4B5563),
            fontSize: 13,
            fontFamily: 'Work Sans',
            fontWeight: FontWeight.w400,
            letterSpacing: -0.26,
          ),
        ),
      ],
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
  }) {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          color: Color(0xFF4B5563),
          fontSize: 13,
          fontFamily: 'Work Sans',
        ),
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
              onPressed: _loading ? null : _save,
              child: _loading
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
                        Icon(Icons.save_outlined, color: Colors.white, size: 18),
                        Text(
                          'Guardar Cambios',
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