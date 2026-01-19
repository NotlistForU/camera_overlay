import '../create.dart';

class Insert {
  static Future<void> foto({
    required int missaoid,
    required String nome,
    required String asset_id,
    double? latitude,
    double? longitude,
    double? altitude,
  }) async {
    final db = await Create.database;
    await db.insert('fotos', {
      'missao_id': missaoid,
      'nome': nome,
      'asset_id': asset_id,
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'data_criacao': DateTime.now().millisecondsSinceEpoch,
    });
  }
}
