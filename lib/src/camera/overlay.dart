import 'package:intl/intl.dart';
import 'package:camera_overlay/src/camera/model/localizacao.dart';

extension Overlay on Localizacao {
  String get dados {
    final formatador = DateFormat('dd/MM/yyyy HH:mm:ss', 'pt_BR');
    final dataFormatada = formatador.format(data);

    return """
Lat: ${latitude.toStringAsFixed(6)}
Log: ${longitude.toStringAsFixed(6)}
Alt: ${altitude.toStringAsFixed(2)} m
$dataFormatada""";
  }
}
