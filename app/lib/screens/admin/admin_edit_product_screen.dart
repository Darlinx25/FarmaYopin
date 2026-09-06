import 'package:flutter/material.dart';

import '../../models/product.dart';

class AdminEditProductScreen extends StatefulWidget {
  final Product product;

  const AdminEditProductScreen({super.key, required this.product});

  @override
  State<AdminEditProductScreen> createState() => _AdminEditProductScreenState();
}

class _AdminEditProductScreenState extends State<AdminEditProductScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('AdminEditProductScreen'),
      ),
    );
  }
}