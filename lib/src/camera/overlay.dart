import 'package:intl/intl.dart';
import 'package:camera_overlay/src/camera/model/localizacao.dart';
import 'package:image/image.dart' as img;

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

void desenharTextoComContorno(
  img.Image imagem,
  String texto, {
  required img.BitmapFont fonte,
  required int x,
  required int y,
}) {
  final deslocamentos = [
    [-1, -1],
    [0, -1],
    [1, -1],
    [-1, 0],
    [1, 0],
    [-1, 1],
    [0, 1],
    [1, 1],
  ];

  for (final d in deslocamentos) {
    img.drawString(
      imagem,
      texto,
      font: fonte,
      x: x + d[0],
      y: y + d[1],
      color: img.ColorRgb8(0, 0, 0),
    );
  }

  img.drawString(
    imagem,
    texto,
    font: fonte,
    x: x,
    y: y,
    color: img.ColorRgb8(255, 255, 255),
  );
}
