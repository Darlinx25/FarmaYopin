import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../api/auth_storage.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: const _LoginBody(),
          ),
        ),
      ),
    );
  }
}

class _LoginBody extends StatefulWidget {
  const _LoginBody();

  @override
  State<_LoginBody> createState() => _LoginBodyState();
}

class _LoginBodyState extends State<_LoginBody> {
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

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Ingresá tu email y contraseña', isError: true);
      return;
    }

    setState(() => _loading = true);
    try {
      final data = await ApiClient.post(
        '/login',
        body: {'email': email, 'password': password},
        withAuth: false,
      );

      final user = data['user'] as Map<String, dynamic>;
      await AuthStorage.saveSession(
        token: data['token'] as String,
        userId: user['id'],
        name: user['name'],
        email: user['email'],
        role: user['role'],
      );

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } on ApiException catch (e) {
      _showMessage(e.message, isError: true);
    } catch (_) {
      _showMessage('No se pudo conectar con el servidor', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 700),
          child: Container(
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: const Color(0xFFFAFAF9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        '10:47',
                        style: TextStyle(
                          color: Color(0xFF1E47EB),
                          fontSize: 14,
                          fontFamily: 'Work Sans',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 8,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            clipBehavior: Clip.antiAlias,
                            decoration: const BoxDecoration(),
                            child: const Stack(),
                          ),
                          Container(
                            width: 20,
                            height: 20,
                            clipBehavior: Clip.antiAlias,
                            decoration: const BoxDecoration(),
                            child: const Stack(),
                          ),
                          Container(
                            width: 28,
                            height: 20,
                            clipBehavior: Clip.antiAlias,
                            decoration: const BoxDecoration(),
                            child: const Stack(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 40, left: 24, right: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 40,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
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
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: const BoxDecoration(),
                                    child: const Stack(),
                                  ),
                                ],
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
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 16,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 6,
                                children: [
                                  const SizedBox(
                                    width: 354,
                                    child: Text(
                                      'Correo Electrónico',
                                      style: TextStyle(
                                        color: Color(0xFF4B5563),
                                        fontSize: 13,
                                        fontFamily: 'Work Sans',
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: -0.26,
                                      ),
                                    ),
                                  ),
                                  TextField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      hintText: 'tucorreo@ejemplo.com',
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
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 6,
                                children: [
                                  const SizedBox(
                                    width: 354,
                                    child: Text(
                                      'Contraseña',
                                      style: TextStyle(
                                        color: Color(0xFF4B5563),
                                        fontSize: 13,
                                        fontFamily: 'Work Sans',
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: -0.26,
                                      ),
                                    ),
                                  ),
                                  TextField(
                                    controller: _passwordController,
                                    obscureText: _obscure,
                                    decoration: InputDecoration(
                                      hintText: '••••••••',
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
                                      suffixIcon: IconButton(
                                        icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                                        onPressed: () => setState(() => _obscure = !_obscure),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
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
                                        const SnackBar(content: Text('Recuperación de contraseña próximamente')),
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
                            ),
                          ],
                        ),
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
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 91,
                  child: Stack(
                    children: [
                      const Positioned(
                        left: 130.50,
                        top: 0,
                        child: Text(
                          '¿No tenés una cuenta?',
                          style: TextStyle(
                            color: Color(0xFF4B5563),
                            fontSize: 13,
                            fontFamily: 'Work Sans',
                            fontWeight: FontWeight.w400,
                            letterSpacing: -0.26,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 160.50,
                        top: 23,
                        child: GestureDetector(
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
                      ),
                      Positioned(
                        left: 0,
                        top: 303,
                        child: SizedBox(
                          width: 402,
                          height: 25,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 131.50,
                                top: 12,
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
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}