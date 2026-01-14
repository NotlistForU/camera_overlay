import 'package:sipam_foto/database/create.dart';
import 'package:sipam_foto/database/util/queries.dart';
import 'package:sipam_foto/database/missoes/update.dart' as update;

class FotoMissao {
  static String rotulo(String nome, int num) {
    final temp = num.toString().padLeft(3, '0');
    return '${nome.toLowerCase().replaceAll(' ', '_')}-$temp';
  }

  static Future<String> nome() async {
    final db = await Create.database;
    final missao = await isAtiva(db);
    final nome = missao['nome'] as String;
    final num = await update.Missao.contador();
    return FotoMissao.rotulo(nome, num);
  }
}
