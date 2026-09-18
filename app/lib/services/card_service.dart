import 'package:flutter/foundation.dart';

import '../db/database_helper.dart';
import '../models/card.dart';

class CardService extends ChangeNotifier {
  CardService._();

  static final CardService instance = CardService._();

  int? _userId;
  CardModel? _defaultCard;

  int? get userId => _userId;

  CardModel? get defaultCard => _defaultCard;

  Future<void> load(int userId) async {
    _userId = userId;
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'cards',
      where: 'user_id = ? AND is_default = ?',
      whereArgs: [userId, 1],
      limit: 1,
    );
    _defaultCard = rows.isEmpty ? null : CardModel.fromMap(rows.first);
    notifyListeners();
  }

  Future<CardModel> saveAsDefault(CardModel card) async {
    final userId = _userId;
    if (userId == null) return card;

    final db = await DatabaseHelper.instance.database;
    final id = await db.transaction<int>((txn) async {
      await txn.delete('cards', where: 'user_id = ?', whereArgs: [userId]);
      return txn.insert('cards', {
        'user_id': userId,
        'holder': card.holder,
        'number': card.number,
        'expiry': card.expiry,
        'last4': card.last4,
        'is_default': 1,
      });
    });

    _defaultCard = CardModel(
      id: id,
      userId: userId,
      holder: card.holder,
      number: card.number,
      expiry: card.expiry,
      last4: card.last4,
      isDefault: true,
    );
    notifyListeners();
    return _defaultCard!;
  }

  Future<void> reset() async {
    _userId = null;
    _defaultCard = null;
    notifyListeners();
  }
}