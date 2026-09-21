import 'package:flutter/material.dart';

import '../../api/api_client.dart';
import '../../models/product.dart';
import '../../services/catalog_service.dart';
import '../profile_screen.dart';
import 'admin_product_form_screen.dart';
import 'admin_product_history_screen.dart';
import 'admin_product_view_screen.dart';

class AdminProductListScreen extends StatefulWidget {
  const AdminProductListScreen({super.key});

  @override
  State<AdminProductListScreen> createState() => _AdminProductListScreenState();
}

class _AdminProductListScreenState extends State<AdminProductListScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final catalog = CatalogService.instance;
      if (catalog.products.isEmpty && !catalog.isLoading) {
        catalog.load();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  List<Product> _filteredProducts(List<Product> products) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return products;
    return products.where((p) {
      final name = p.name.toLowerCase();
      final description = p.description.toLowerCase();
      return name.contains(q) || description.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CatalogService.instance,
      builder: (context, _) {
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
                          _buildSearch(),
                          Expanded(child: _buildContent()),
                          _buildBottomNav(),
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Productos',
            style: TextStyle(
              color: Color(0xFF1E47EB),
              fontSize: 20,
              fontFamily: 'Work Sans',
              fontWeight: FontWeight.w700,
              letterSpacing: -0.40,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            tooltip: 'Agregar producto',
            onPressed: () => _go(const AdminProductFormScreen()),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFF28E2A),
              fixedSize: const Size(40, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        onChanged: (value) => setState(() => _query = value),
        style: const TextStyle(
          color: Color(0xFF4B5563),
          fontSize: 13,
          fontFamily: 'Work Sans',
        ),
        decoration: InputDecoration(
          hintText: 'Buscar producto...',
          hintStyle: const TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 13,
            fontFamily: 'Work Sans',
            fontWeight: FontWeight.w400,
            letterSpacing: -0.26,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.zero,
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFF9CA3AF),
            size: 18,
          ),
          suffixIcon: _query.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: Color(0xFF9CA3AF),
                    size: 18,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                )
              : null,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFF28E2A), width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final catalog = CatalogService.instance;

    if (catalog.isLoading && catalog.products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (catalog.error != null && catalog.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: Color(0xFF9CA3AF)),
            const SizedBox(height: 12),
            Text(
              catalog.error!,
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
              onPressed: () => CatalogService.instance.reload(),
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

    final products = _filteredProducts(catalog.products);

    if (products.isEmpty) {
      return Center(
        child: Text(
          catalog.products.isEmpty
              ? 'No hay productos'
              : 'Sin resultados para "$_query"',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF4B5563),
            fontSize: 14,
            fontFamily: 'Work Sans',
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: products.map(_productCard).toList(),
          ),
        ),
      ),
    );
  }

  Widget _productCard(Product product) {
    final inStock = product.stock > 0;
    final String status;
    final Color statusColor;
    if (!product.available) {
      status = 'No disponible';
      statusColor = const Color(0xFF4B5563);
    } else if (inStock) {
      status = 'Disponible';
      statusColor = const Color(0xFF10B981);
    } else {
      status = 'Agotado';
      statusColor = const Color(0xFFEF4444);
    }
    return GestureDetector(
      onTap: () => _go(AdminProductViewScreen(product: product)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color: const Color(0xFFD6E9F9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: product.imageUrl.isEmpty
                  ? const Icon(
                      Icons.medication,
                      color: Color(0xFF1E47EB),
                      size: 28,
                    )
                  : Image.network(
                      ApiClient.resolveImageUrl(product.imageUrl),
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
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
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
                    _formatMoney(product.price),
                    style: const TextStyle(
                      color: Color(0xFFF28E2A),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF9CA3AF),
              size: 22,
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
              icon: Icons.inventory_2_outlined,
              label: 'Productos',
              active: true,
              onTap: () {},
            ),
          ),
          Expanded(
            child: _navItem(
              icon: Icons.history,
              label: 'Historial',
              active: false,
              onTap: () => _go(const AdminProductHistoryScreen()),
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
}