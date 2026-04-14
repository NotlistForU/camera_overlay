import 'package:intl/intl.dart';

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
}
