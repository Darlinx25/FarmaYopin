import 'dart:math';

import 'package:flutter/material.dart';

import '../api/api_client.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
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

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (name.isEmpty || lastName.isEmpty || email.isEmpty || password.isEmpty) {
      _showMessage('Completá todos los campos', isError: true);
      return;
    }
    if (password.length < 6) {
      _showMessage('La contraseña debe tener al menos 6 caracteres', isError: true);
      return;
    }
    if (password != confirm) {
      _showMessage('Las contraseñas no coinciden', isError: true);
      return;
    }

    setState(() => _loading = true);
    try {
      debugPrint('[REGISTER] llamando a la API con email=$email');
      await ApiClient.post(
        '/register',
        body: {
          'name': '$name $lastName',
          'email': email,
          'password': password,
        },
        withAuth: false,
      );
      debugPrint('[REGISTER] respuesta OK');

      if (!mounted) return;
      _showMessage('Usuario registrado. Ya podés iniciar sesión.');
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      debugPrint('[REGISTER] ApiException: ${e.message}');
      _showMessage(e.message, isError: true);
    } catch (e, s) {
      debugPrint('[REGISTER] error inesperado: $e\n$s');
      _showMessage('No se pudo conectar con el servidor', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = max(constraints.maxHeight, 840.0);
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 24, top: 40),
                        child: Text(
                          'Crear Cuenta',
                          style: TextStyle(
                            color: Color(0xFFF28E2A),
                            fontSize: 34,
                            fontFamily: 'Work Sans',
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.68,
                          ),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 24,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 14,
                                children: [
                                  _label('Nombre'),
                                  _field(
                                    controller: _nameController,
                                    hint: 'Juan',
                                  ),
                                  _label('Apellido'),
                                  _field(
                                    controller: _lastNameController,
                                    hint: 'Pérez',
                                  ),
                                  _label('Email'),
                                  _field(
                                    controller: _emailController,
                                    hint: 'juan.perez@email.com',
                                    email: true,
                                  ),
                                  _label('Contraseña'),
                                  _field(
                                    controller: _passwordController,
                                    hint: 'Mínimo 6 caracteres',
                                    obscure: _obscurePass,
                                    onToggleVisibility: () => setState(
                                      () => _obscurePass = !_obscurePass,
                                    ),
                                  ),
                                  _label('Confirmar Contraseña'),
                                  _field(
                                    controller: _confirmController,
                                    hint: 'Repite tu contraseña',
                                    obscure: _obscureConfirm,
                                    onToggleVisibility: () => setState(
                                      () => _obscureConfirm = !_obscureConfirm,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
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
                                      onPressed: _loading ? null : _register,
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
                                              'Registrarse',
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
                                  const SizedBox(height: 8),
                                  Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      spacing: 4,
                                      children: [
                                        const Text(
                                          '¿Ya tenés cuenta?',
                                          style: TextStyle(
                                            color: Color(0xFF4B5563),
                                            fontSize: 13,
                                            fontFamily: 'Work Sans',
                                            fontWeight: FontWeight.w400,
                                            letterSpacing: -0.26,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => Navigator.of(context).pop(),
                                          child: const Text(
                                            'Iniciar Sesión',
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
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
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
    bool email = false,
    bool obscure = false,
    VoidCallback? onToggleVisibility,
  }) {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: controller,
        keyboardType: email ? TextInputType.emailAddress : null,
        obscureText: obscure,
        decoration: _fieldDecoration(hint).copyWith(
          suffixIcon: onToggleVisibility != null
              ? IconButton(
                  icon: Icon(
                    obscure ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: onToggleVisibility,
                )
              : null,
        ),
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
}