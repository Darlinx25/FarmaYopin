import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../db/database_helper.dart';
import '../models/purchase.dart';

class PurchaseService extends ChangeNotifier {
  PurchaseService._();

  static final PurchaseService instance = PurchaseService._();

  List<Purchase> _purchases = [];

  List<Purchase> get purchases => List.unmodifiable(_purchases);

  bool get isEmpty => _purchases.isEmpty;

  Future<void> load(int userId) async {
    final db = await DatabaseHelper.instance.database;
    final purchaseRows = await db.query(
      'purchases',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    final itemRows = await db.query(
      'purchase_items',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    final groups = <int, List<PurchaseItem>>{};
    for (final row in itemRows) {
      final purchaseId = row['purchase_id'] as int;
      groups.putIfAbsent(purchaseId, () => []).add(PurchaseItem.fromMap(row));
    }

    _purchases = purchaseRows
        .map((row) => Purchase.fromMap(row, groups[row['id']] ?? []))
        .toList();
    notifyListeners();
  }

  Future<void> savePurchase(int userId, Purchase purchase) async {
    final db = await DatabaseHelper.instance.database;
    await db.transaction((txn) async {
      await txn.insert(
        'purchases',
        {
          'id': purchase.id,
          'user_id': userId,
          ...purchase.toInsertMap(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await txn.delete(
        'purchase_items',
        where: 'purchase_id = ? AND user_id = ?',
        whereArgs: [purchase.id, userId],
      );
      for (final item in purchase.items) {
        await txn.insert('purchase_items', item.toInsertMap(purchase.id, userId));
      }
    });
  }

  Future<void> reset() async {
    _purchases = [];
    notifyListeners();
  }
}