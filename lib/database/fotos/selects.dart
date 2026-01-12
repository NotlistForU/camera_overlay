import 'package:sipam_foto/database/create.dart';
import 'package:sipam_foto/database/util/filtrar.dart';
import 'package:sipam_foto/model/filtro.dart';
import 'package:sipam_foto/model/foto.dart';

class Selects {
  static Future<List<Foto>> todasFotos() async {
    final db = await Create.database;
    final result = await db.query('fotos', orderBy: 'data_criacao');
    return result.map((e) => Foto.fromMap(e)).toList();
  }

  static Future<List<Foto>> fotoMissao(int missaoid) async {
    final db = await Create.database;
    final result = await db.query(
      'fotos',
      where: 'missao_id = ?',
      whereArgs: [missaoid],
      orderBy: 'data_criacao DESC',
    );
    return result.map((e) => Foto.fromMap(e)).toList();
  }

  static Future<List<Foto>> fotoFiltro(Filtro filtro) async {
    // FILTRO POR...
    final db = await Create.database;
    final where = <String>[];
    final args = <Object>[];
    // NOME
    filtrar(
      where,
      args,
      'LOWER(nome) LIKE ?',
      filtro.nome?.isNotEmpty == true
          ? '%&{filtro.nome!.toLowerCase()}%'
          : null,
    );
    // DATA INICIAL
    filtrar(where, args, 'data_criacao', filtro.inicio?.millisecondsSinceEpoch);
    // DATA FINAL
    if (filtro.fim != null) {
      final diaTotal = DateTime(
        filtro.fim!.year,
        filtro.fim!.month,
        filtro.fim!.day,
        23,
        59,
        59,
      );
      filtrar(
        where,
        args,
        'data_criacao <= ?',
        diaTotal.millisecondsSinceEpoch,
      );
    }

    // ALTITUDE MÍNIMA
    filtrar(where, args, 'altitude >= ?', filtro.minimo);
    // ALTITUDE MÁXIMA
    filtrar(where, args, 'altitude <= ?', filtro.maximo);

    // consulta final
    final result = await db.query(
      'fotos',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args,
      orderBy: 'data_criacao DESC',
    );

    return result.map((e) => Foto.fromMap(e)).toList();
  }
}
