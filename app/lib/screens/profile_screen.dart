import 'dart:math';

import 'package:flutter/material.dart';

import '../api/auth_storage.dart';
import '../services/cart_service.dart';
import '../services/catalog_service.dart';
import 'cart_screen.dart';
import 'login_screen.dart';
import 'purchase_history_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = '';
  String _email = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final name = await AuthStorage.getName();
    final email = await AuthStorage.getEmail();
    if (!mounted) return;
    setState(() {
      _name = name ?? '';
      _email = email ?? '';
    });
  }

  Future<void> _logout() async {
    await CartService.instance.reset();
    await CatalogService.instance.reset();
    await AuthStorage.clear();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _go(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
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
                      Expanded(
                        child: SingleChildScrollView(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 48,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 40,
                                children: [
                                  _buildUserCard(),
                                  _logoutButton(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
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
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 56,
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
              'Perfil',
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

  Widget _buildUserCard() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 20,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: ShapeDecoration(
              color: const Color(0xFFD6E9F9),
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Color(0xFF1E47EB), width: 2),
                borderRadius: BorderRadius.circular(48),
              ),
            ),
            child: const Icon(
              Icons.person,
              color: Color(0xFF1E47EB),
              size: 44,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 6,
            children: [
              Text(
                _name.isEmpty ? 'Sin nombre' : _name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF1E47EB),
                  fontSize: 20,
                  fontFamily: 'Work Sans',
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.40,
                ),
              ),
              Text(
                _email.isEmpty ? 'Sin email' : _email,
                textAlign: TextAlign.center,
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

  Widget _logoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFF28E2A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: _logout,
        child: const Text(
          'Cerrar Sesión',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontFamily: 'Work Sans',
            fontWeight: FontWeight.w400,
            letterSpacing: -0.26,
          ),
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
              onTap: () => Navigator.of(context).pop(),
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
              active: false,
              onTap: () => _go(const PurchasesScreen()),
            ),
          ),
          Expanded(
            child: _navItem(
              icon: Icons.person,
              label: 'Perfil',
              active: true,
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}