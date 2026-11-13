import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

class OverlayService {
  static void desenharTextoComContorno(
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

  // Roda em background (isolate) — decodifica, desenha o texto, e codifica em JPEG
  static Uint8List desenharOverlay(
    Uint8List bytes,
    String texto,
    img.BitmapFont fonte,
  ) {
    final imagem = img.decodeImage(bytes)!;

    const larguraReferencia = 1536;
    final escala = imagem.width / larguraReferencia;
    final alturaReferencia = (imagem.height / escala).round();

    final camada = img.Image(
      width: larguraReferencia,
      height: alturaReferencia,
      numChannels: 4,
    );

    img.fill(camada, color: img.ColorRgba8(0, 0, 0, 0));

    final numeroDeLinhas = texto.split('\n').length;
    const espacamentoEntreLinhas = 8;
    final alturaLinha = fonte.lineHeight + espacamentoEntreLinhas;
    final alturaTotalDoTexto = numeroDeLinhas * alturaLinha;

    const margemInferior = 30;

    final y = camada.height - alturaTotalDoTexto - margemInferior;

    desenharTextoComContorno(camada, texto, fonte: fonte, x: 20, y: y);

    final overlayRedimensionado = img.copyResize(
      camada,
      width: imagem.width,
      height: imagem.height,
      interpolation: img.Interpolation.linear,
    );

    img.compositeImage(imagem, overlayRedimensionado);

    return Uint8List.fromList(img.encodeJpg(imagem, quality: 90));
  }

  static Future<img.BitmapFont?> carregarFonte() async {
    try {
      final data = await rootBundle.load(
        'packages/camera_overlay/assets/fonts/RobotoBold.zip',
      );

      final bytes = data.buffer.asUint8List();

      return img.BitmapFont.fromZip(bytes);
    } catch (e) {
      return null;
    }
  }
}
