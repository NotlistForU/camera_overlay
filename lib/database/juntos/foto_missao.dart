import 'package:sipam_foto/database/create.dart';
import 'package:sipam_foto/database/util/querys.dart';
import '../missoes/update.dart';

class FotoMissao {
  static String rotulo(String nome, int num) {
    final temp = num.toString().padLeft(3, '0');
    return '${nome.toLowerCase().replaceAll(' ', '_')}-$temp';
  }

  static Future<String> nome() async {
    final db = await Create.database;
    final missao = await missaoAtiva(db);
    final nome = missao['nome'] as String;
    final num = await Update.contador();
    return FotoMissao.rotulo(nome, num);
  }
}
