import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Create {
  static Database? _db;
  static Future<Database> get database async {
    if (_db != null) {
      return _db!;
    }
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
      CREATE TABLE fotos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        data_criacao INTEGER NOT NULL,
        missao_id INTEGER NOT NULL,
        nome TEXT NOT NULL,
        path TEXT NOT NULL,
        latitude REAL,
        altitude REAL,
        FOREIGN KEY (missao_id) REFERENCES missoes(id)
      )
      ''');
        await db.execute('''
        CREATE TABLE  missoes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        contador INTEGER NOT NULL DEFAULT 0,
        data_criacao INTEGER NOT NULL,
        nome TEXT NOT NULL UNIQUE,
        ativa INTEGER NOT NULL
        )
        ''');
      },
    );
    return _db!;
  }
}
