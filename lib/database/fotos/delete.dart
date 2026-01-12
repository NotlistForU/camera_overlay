import 'dart:io';

import 'package:sipam_foto/database/create.dart';
import 'package:sipam_foto/model/foto.dart';

class Delete {
  static Future<void> foto(Foto foto) async {
    await fotos([foto]);
  }

  static Future<void> fotos(List<Foto> fotos) async {
    if (fotos.isEmpty) return;
    final db = await Create.database;
    final batch = db.batch();
    for (final foto in fotos) {
      // apaga arquivo físico
      final file = File(foto.path);
      if (await file.exists()) {
        await file.delete();
      }
      // apaga no banco
      batch.delete('fotos', where: 'id = ?', whereArgs: [foto.id]);
    }
    await batch.commit(noResult: true);
  }
}
