import 'package:flutter/material.dart';

import '../api/auth_storage.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _name = '';
  String _role = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final name = await AuthStorage.getName();
    final role = await AuthStorage.getRole();
    if (!mounted) return;
    setState(() {
      _name = name ?? '';
      _role = role ?? 'client';
    });
  }

  Future<void> _logout() async {
    await AuthStorage.clear();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = _role == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('FarmaYopin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: _logout,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFFF28E2A),
              child: Icon(Icons.person, color: Colors.white, size: 44),
            ),
            const SizedBox(height: 16),
            Text(
              _name.isEmpty ? 'Bienvenido' : _name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              isAdmin ? 'Administrador' : 'Cliente',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontFamily: 'Work Sans',
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Aquí irán tus pantallas del menú',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}