import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static const _dbName = 'farmayopin.db';
  static const _dbVersion = 1;

  Database? _db;

  Future<Database> get database async => _db ??= await _open();

  Future<Database> _open() async {
    final isDesktop =
        !kIsWeb &&
        (Platform.isLinux || Platform.isWindows || Platform.isMacOS);

    if (isDesktop) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final path = isDesktop
        ? p.join((await getApplicationSupportDirectory()).path, _dbName)
        : p.join(await getDatabasesPath(), _dbName);

    return openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE cart_items (
        user_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        image_url TEXT,
        PRIMARY KEY (user_id, product_id)
      )
    ''');
  }
}