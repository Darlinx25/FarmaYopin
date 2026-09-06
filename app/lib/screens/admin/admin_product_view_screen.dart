import 'package:flutter/material.dart';

import '../../models/product.dart';

class AdminProductViewScreen extends StatefulWidget {
  final Product product;

  const AdminProductViewScreen({super.key, required this.product});

  @override
  State<AdminProductViewScreen> createState() => _AdminProductViewScreenState();
}

class _AdminProductViewScreenState extends State<AdminProductViewScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('AdminProductViewScreen'),
      ),
    );
  }
}