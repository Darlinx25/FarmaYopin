import 'dart:math';

import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../api/auth_storage.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _remember = false;
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : const Color(0xFFF28E2A),
      ),
    );
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    debugPrint('[LOGIN] tap: email=$email, pass=${password.isEmpty ? 'vacio' : '***'}');

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Ingresá tu email y contraseña', isError: true);
      return;
    }

    setState(() => _loading = true);
    try {
      debugPrint('[LOGIN] llamando a la API...');
      final data = await ApiClient.post(
        '/login',
        body: {'email': email, 'password': password},
        withAuth: false,
      );
      debugPrint('[LOGIN] respuesta OK: $data');

      final user = data['user'] as Map<String, dynamic>;
      await AuthStorage.saveSession(
        token: data['token'] as String,
        userId: user['id'],
        name: user['name'],
        email: user['email'],
        role: user['role'],
      );
      debugPrint('[LOGIN] sesión guardada, navegando a HomeScreen');

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } on ApiException catch (e) {
      debugPrint('[LOGIN] ApiException: ${e.message}');
      _showMessage(e.message, isError: true);
    } catch (e, s) {
      debugPrint('[LOGIN] error inesperado: $e\n$s');
      _showMessage('No se pudo conectar con el servidor', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = max(constraints.maxHeight, 800.0);
        return Scaffold(
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
                      _statusBar(),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 32,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 32,
                                children: [
                                  _logoBlock(),
                                  _fieldsBlock(),
                                  _loginButton(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      _bottomLinks(),
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

  Widget _statusBar() {
    return Container(
      width: double.infinity,
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '10:47',
            style: TextStyle(
              color: Color(0xFF1E47EB),
              fontSize: 14,
              fontFamily: 'Work Sans',
              fontWeight: FontWeight.w600,
            ),
          ),
          Spacer(),
          Icon(Icons.signal_cellular_alt, color: Color(0xFF1E47EB), size: 18),
          SizedBox(width: 8),
          Icon(Icons.wifi, color: Color(0xFF1E47EB), size: 18),
          SizedBox(width: 8),
          Icon(Icons.battery_full, color: Color(0xFF1E47EB), size: 18),
        ],
      ),
    );
  }

  Widget _logoBlock() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 12,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: ShapeDecoration(
              color: const Color(0xFFF28E2A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Icon(
              Icons.local_pharmacy,
              color: Colors.white,
              size: 36,
            ),
          ),
          const Text(
            'FarmaYopin',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFF28E2A),
              fontSize: 34,
              fontFamily: 'Work Sans',
              fontWeight: FontWeight.w700,
              letterSpacing: -0.68,
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldsBlock() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          const Text(
            'Correo Electrónico',
            style: TextStyle(
              color: Color(0xFF4B5563),
              fontSize: 13,
              fontFamily: 'Work Sans',
              fontWeight: FontWeight.w400,
              letterSpacing: -0.26,
            ),
          ),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: _fieldDecoration('tucorreo@ejemplo.com'),
          ),
          const Text(
            'Contraseña',
            style: TextStyle(
              color: Color(0xFF4B5563),
              fontSize: 13,
              fontFamily: 'Work Sans',
              fontWeight: FontWeight.w400,
              letterSpacing: -0.26,
            ),
          ),
          TextField(
            controller: _passwordController,
            obscureText: _obscure,
            decoration: _fieldDecoration('••••••••').copyWith(
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 6,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 6,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _remember = !_remember),
                    child: Icon(
                      _remember
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color: const Color(0xFFF28E2A),
                      size: 22,
                    ),
                  ),
                  const Text(
                    'Recordarme',
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
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Recuperación de contraseña próximamente'),
                    ),
                  );
                },
                child: const Text(
                  '¿Olvidaste tu contraseña?',
                  style: TextStyle(
                    color: Color(0xFFF28E2A),
                    fontSize: 13,
                    fontFamily: 'Work Sans',
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.26,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
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
        borderSide: const BorderSide(color: Color(0xFFF28E2A), width: 1.5),
      ),
    );
  }

  Widget _loginButton() {
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
        onPressed: _loading ? null : _login,
        child: _loading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Iniciar Sesión',
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

  Widget _bottomLinks() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          const Text(
            '¿No tenés una cuenta?',
            style: TextStyle(
              color: Color(0xFF4B5563),
              fontSize: 13,
              fontFamily: 'Work Sans',
              fontWeight: FontWeight.w400,
              letterSpacing: -0.26,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RegisterScreen()),
              );
            },
            child: const Text(
              'Crear Cuenta',
              style: TextStyle(
                color: Color(0xFFF28E2A),
                fontSize: 13,
                fontFamily: 'Work Sans',
                fontWeight: FontWeight.w400,
                letterSpacing: -0.26,
              ),
            ),
          ),
        ],
      ),
    );
  }
}