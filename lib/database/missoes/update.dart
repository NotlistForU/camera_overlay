import 'package:sipam_foto/database/create.dart';
import 'package:sipam_foto/database/util/querys.dart';

// MISSOES
class Update {
  // ativa uma missao
  static Future<void> ativa(String nome) async {
    final db = await Create.database;
    await db.transaction((tsc) async {
      await tsc.update('missoes', {'ativa': 0});
      await tsc.update(
        'missoes',
        {'ativa': 1},
        where: 'nome = ?',
        whereArgs: [nome],
      );
    });
  }

  // OBSERVAÇÕES:
  // & = função
  // path: database/juntos/foto_missao/
  // &nome e &rotulo  estao dentro de path.
  // &contador() vai ser usada na &nome().  o &rotulo tambem
  // adicionar +1 ao contador da missao
  static Future<int> contador() async {
    final db = await Create.database;
    return await db.transaction((tsc) async {
      final missao = await isAtiva(db);
      final missaoid = missao['id'] as int;
      final contador = missao['contador'] as int;
      final num = contador + 1;
      await tsc.update(
        'missoes',
        {'contador': num},
        where: 'id = ?',
        whereArgs: [missaoid],
      );
      return num;
    });
  }
}
