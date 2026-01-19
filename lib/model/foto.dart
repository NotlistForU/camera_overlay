class Foto {
  final int id;
  final DateTime data;
  final int missaoid;
  final String nome;
  final String assetId;
  final double? latitude;
  final double? longitude;
  final double? altitude;
  Foto({
    required this.id,
    required this.data,
    required this.missaoid,
    required this.nome,
    required this.assetId,
    this.latitude,
    this.longitude,
    this.altitude,
  });
  // construtor  quando vem do banco de dados
  factory Foto.fromMap(Map<String, dynamic> map) {
    return Foto(
      id: map['id'] as int,
      data: DateTime.fromMillisecondsSinceEpoch(map['data_criacao'] as int),
      missaoid: map['missao_id'] as int,
      nome: map['nome'] as String,
      assetId: map['asset_id'] as String,
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
      altitude: map['altitude'] as double?,
    );
  }
  // converter para quando vai para o banco
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'data_criacao': data.millisecondsSinceEpoch,
      'missao_id': missaoid,
      'nome': nome,
      'asset_id': assetId,
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
    };
  }
}
