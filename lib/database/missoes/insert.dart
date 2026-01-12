import '../create.dart';

class Insert {
  static Future<void> missao({
    required String nome,
    required bool ativa,
  }) async {
    final db = await Create.database;
    await db.transaction((tsc) async {
      if (ativa) {
        await tsc.update('missoes', {'ativa': 0});
      }
      await tsc.insert('missoes', {
        'nome': nome,
        'ativa': ativa ? 1 : 0,
        'data_criacao': DateTime.now().millisecondsSinceEpoch,
      });
    });
  }
}
