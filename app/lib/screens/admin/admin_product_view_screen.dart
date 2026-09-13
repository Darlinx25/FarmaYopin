import 'package:flutter/material.dart';

import '../../models/product.dart';

class AdminProductViewScreen extends StatelessWidget {
  final Product product;

  const AdminProductViewScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFFAFAF9),
    );
  }
}