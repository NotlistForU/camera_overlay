import 'package:sipam_foto/database/create.dart';
import 'package:sipam_foto/database/util/queries.dart';
import 'package:sipam_foto/model/missao.dart' as model;

// MISSOES
class Missao {
  // POR ENQUANTO NAO SE FAZ USO DELA TALVEZ mais tarde com um botao pra desativar todas sem ativar nenhuma.
  // static Future<void> desativarTodasMissoes() async {
  //   final db = await Create.database;
  //   await db.transaction((tsc) async {
  //     await tsc.update('missoes', {'ativa': 0});
  //   });
  // }

  static Future<void> ativarDesativar(model.Missao missao, bool ativa) async {
    final db = await Create.database;
    await db.transaction((tsc) async {
      if (ativa) {
        await tsc.update('missoes', {'ativa': 0});
      }
      await tsc.update(
        'missoes',
        {'ativa': ativa ? 1 : 0},
        where: 'id = ?',
        whereArgs: [missao.id],
      );
    });
  }

  // ATALHOS
  // ativa uma missao
  static Future<void> ativar(model.Missao missao) =>
      ativarDesativar(missao, true);
  // desativar uma missao
  static Future<void> desativar(model.Missao missao) =>
      ativarDesativar(missao, false);

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
