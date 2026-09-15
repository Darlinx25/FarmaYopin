import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../db/database_helper.dart';
import '../models/cart_item.dart';

class CartService extends ChangeNotifier {
  CartService._();

  static final CartService instance = CartService._();

  int? _userId;
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get count => _items.fold(0, (sum, item) => sum + item.quantity);

  double get total => _items.fold(0, (sum, item) => sum + item.subtotal);

  bool get isEmpty => _items.isEmpty;

  Future<void> load(int userId) async {
    _userId = userId;
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'cart_items',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    _items
      ..clear()
      ..addAll(rows.map(CartItem.fromMap));
    notifyListeners();
  }

  Future<void> add(CartItem item) async {
    final userId = _userId;
    if (userId == null) return;

    final existing = _items
        .where((i) => i.productId == item.productId)
        .toList();
    if (existing.isNotEmpty) {
      existing.first.quantity += item.quantity;
    } else {
      _items.add(item);
    }
    await _upsert(userId, existing.isNotEmpty ? existing.first : item);
    notifyListeners();
  }

  Future<void> updateQuantity(int productId, int quantity) async {
    final userId = _userId;
    if (userId == null) return;

    if (quantity <= 0) {
      return remove(productId);
    }

    final index = _items.indexWhere((i) => i.productId == productId);
    if (index == -1) return;

    _items[index].quantity = quantity;
    await _upsert(userId, _items[index]);
    notifyListeners();
  }

  Future<void> remove(int productId) async {
    final userId = _userId;
    if (userId == null) return;

    _items.removeWhere((i) => i.productId == productId);
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'cart_items',
      where: 'user_id = ? AND product_id = ?',
      whereArgs: [userId, productId],
    );
    notifyListeners();
  }

  Future<void> clear() async {
    final userId = _userId;
    if (userId == null) return;

    _items.clear();
    final db = await DatabaseHelper.instance.database;
    await db.delete('cart_items', where: 'user_id = ?', whereArgs: [userId]);
    notifyListeners();
  }

  Future<void> reset() async {
    _userId = null;
    _items.clear();
    notifyListeners();
  }

  Future<void> _upsert(int userId, CartItem item) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      'cart_items',
      {
        'user_id': userId,
        ...item.toMap(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}