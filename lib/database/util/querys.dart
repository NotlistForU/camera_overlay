import 'package:sqflite/sqflite.dart';

Future<Map<String, Object?>> missaoAtiva(Database db) async {
  final result = await db.query(
    'missoes',
    where: 'ativa = ?',
    whereArgs: [1],
    limit: 1,
  );
  if (result.isEmpty) {
    throw Exception('Nenhuma missão ativa');
  }
  return result.first;
}
