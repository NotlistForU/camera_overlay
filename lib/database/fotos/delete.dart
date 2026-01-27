import 'dart:io';

import 'package:photo_manager/photo_manager.dart';
import 'package:sipam_foto/database/create.dart';
import 'package:sipam_foto/model/foto.dart' as model;

class Foto {
  static Future<void> uma(model.Foto foto) async {
    await varias([foto]);
  }

  static Future<void> varias(List<model.Foto> fotos) async {
    if (fotos.isEmpty) return;
    final ids = fotos.map((f) => f.assetId).toList();
    await PhotoManager.editor.deleteWithIds(ids);
    final db = await Create.database;
    final batch = db.batch();
    for (final foto in fotos) {
      // apaga no banco
      batch.delete('fotos', where: 'id = ?', whereArgs: [foto.id]);
    }
    await batch.commit(noResult: true);
  }
}
