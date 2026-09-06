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
      await ApiClient.post(
        '/register',
        body: {
          'name': '$name $lastName',
          'email': email,
          'password': password,
        },
        withAuth: false,
      );

      if (!mounted) return;
      _showMessage('Usuario registrado. Ya podés iniciar sesión.');
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      _showMessage(e.message, isError: true);
    } catch (_) {
      _showMessage('No se pudo conectar con el servidor', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration({required String hint}) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color: const Color(0xFFFAFAF9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Crear Cuenta',
                      style: TextStyle(
                        color: Color(0xFFF28E2A),
                        fontSize: 34,
                        fontFamily: 'Work Sans',
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.68,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Nombre',
                      style: TextStyle(
                        color: Color(0xFF4B5563),
                        fontSize: 13,
                        fontFamily: 'Work Sans',
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.26,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 48,
                      child: TextField(
                        controller: _nameController,
                        decoration: _fieldDecoration(hint: 'Juan'),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Apellido',
                      style: TextStyle(
                        color: Color(0xFF4B5563),
                        fontSize: 13,
                        fontFamily: 'Work Sans',
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.26,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 48,
                      child: TextField(
                        controller: _lastNameController,
                        decoration: _fieldDecoration(hint: 'Pérez'),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Email',
                      style: TextStyle(
                        color: Color(0xFF4B5563),
                        fontSize: 13,
                        fontFamily: 'Work Sans',
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.26,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 48,
                      child: TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _fieldDecoration(hint: 'juan.perez@email.com'),
                      ),
                    ),
                    const SizedBox(height: 14),
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
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 48,
                      child: TextField(
                        controller: _passwordController,
                        obscureText: _obscurePass,
                        decoration: _fieldDecoration(hint: 'Mínimo 8 caracteres').copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscurePass = !_obscurePass),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Confirmar Contraseña',
                      style: TextStyle(
                        color: Color(0xFF4B5563),
                        fontSize: 13,
                        fontFamily: 'Work Sans',
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.26,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 48,
                      child: TextField(
                        controller: _confirmController,
                        obscureText: _obscureConfirm,
                        decoration: _fieldDecoration(hint: 'Repite tu contraseña').copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
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
                    const SizedBox(height: 24),
                    Center(
                      child: Column(
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
      ),
    );
  }
}