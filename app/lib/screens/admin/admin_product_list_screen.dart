import 'package:flutter/material.dart';

class AdminProductListScreen extends StatefulWidget {
  const AdminProductListScreen({super.key});

  @override
  State<AdminProductListScreen> createState() => _AdminProductListScreenState();
}

class _AdminProductListScreenState extends State<AdminProductListScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('AdminProductListScreen'),
      ),
    );
  }
}