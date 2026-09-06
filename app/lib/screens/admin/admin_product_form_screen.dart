import 'package:flutter/material.dart';

class AdminProductFormScreen extends StatefulWidget {
  const AdminProductFormScreen({super.key});

  @override
  State<AdminProductFormScreen> createState() => _AdminProductFormScreenState();
}

class _AdminProductFormScreenState extends State<AdminProductFormScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('AdminProductFormScreen'),
      ),
    );
  }
}