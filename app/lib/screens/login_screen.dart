import 'package:flutter/material.dart';

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

class _LoginBody extends StatelessWidget {
  const _LoginBody();

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
                                  Container(
                                    width: double.infinity,
                                    height: 48,
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    decoration: ShapeDecoration(
                                      color: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        side: const BorderSide(
                                          width: 1,
                                          color: Color(0xFFE5E7EB),
                                        ),
                                        borderRadius: BorderRadius.circular(12),
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
                                  Container(
                                    width: double.infinity,
                                    height: 48,
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    decoration: ShapeDecoration(
                                      color: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        side: const BorderSide(
                                          width: 1,
                                          color: Color(0xFFE5E7EB),
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      spacing: 8,
                                      children: [
                                        Container(
                                          width: 20,
                                          height: 20,
                                          clipBehavior: Clip.antiAlias,
                                          decoration: const BoxDecoration(),
                                          child: const Stack(),
                                        ),
                                      ],
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
                                      Container(
                                        width: 18,
                                        height: 18,
                                        decoration: ShapeDecoration(
                                          color: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            side: const BorderSide(
                                              width: 1.50,
                                              color: Color(0xFFF28E2A),
                                            ),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
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
                                  const Text(
                                    '¿Olvidaste tu contraseña?',
                                    style: TextStyle(
                                      color: Color(0xFFF28E2A),
                                      fontSize: 13,
                                      fontFamily: 'Work Sans',
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: -0.26,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: 50,
                        decoration: ShapeDecoration(
                          color: const Color(0xFFF28E2A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 8,
                          children: [
                            Text(
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
                          ],
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
                      const Positioned(
                        left: 160.50,
                        top: 23,
                        child: Text(
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