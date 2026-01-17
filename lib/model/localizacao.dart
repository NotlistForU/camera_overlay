class Localizacao {
  final double latitude;
  final double longitude;
  final double altitude;
  final DateTime data;
  Localizacao({
    required this.latitude,
    required this.longitude,
    required this.altitude,
    DateTime? data,
  }) : data = data ?? DateTime.now();

  String get dados =>
      """
Lat: ${latitude.toStringAsFixed(6)}
Log: ${longitude.toStringAsFixed(6)}
Alt: ${altitude.toStringAsFixed(2)} m
$data""";
}
