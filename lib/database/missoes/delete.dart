import 'dart:io';
import 'package:flutter/foundation.dart'; // Para debugPrint
import 'package:sipam_foto/database/create.dart';
import 'package:sipam_foto/model/missao.dart';

class Delete {
  static Future<void> missao(Missao missao) async {
    DebugPrintCallback debugPrint = debugPrintThrottled;
    final db = await Create.database;
    if (missao.ativa) {
      throw Exception('Desative a missão para poder excluir.');
    }
    final fotos = await db.query(
      'fotos',
      columns: ['path'],
      where: 'missao_id = ?',
      whereArgs: [missao.id],
    );
    for (final foto in fotos) {
      final path = foto['path'] as String;
      final file = File(path);
      if (await file.exists()) {
        try {
          await file.delete();
        } catch (erro) {
          debugPrint('Erro ao apagar arquivo $path');
        }
      }
    }
    await db.delete('fotos', where: 'missao_id = ?', whereArgs: [missao.id]);
    await db.delete("missoes", where: 'id = ?', whereArgs: [missao.id]);
  }
}
