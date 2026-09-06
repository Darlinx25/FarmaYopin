import 'package:flutter/material.dart';

import '../../models/product.dart';

class AdminProductHistoryScreen extends StatefulWidget {
  final Product product;

  const AdminProductHistoryScreen({super.key, required this.product});

  @override
  State<AdminProductHistoryScreen> createState() => _AdminProductHistoryScreenState();
}

class _AdminProductHistoryScreenState extends State<AdminProductHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('AdminProductHistoryScreen'),
      ),
    );
  }
}