import 'package:flutter/material.dart';

import '../../models/product.dart';

class AdminEditProductScreen extends StatelessWidget {
  final Product product;

  const AdminEditProductScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFFAFAF9),
    );
  }
}