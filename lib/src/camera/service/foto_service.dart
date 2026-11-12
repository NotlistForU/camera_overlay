import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:exif/exif.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';

class FotoService {
  // Cache estático: carrega a fonte do ZIP apenas uma vez
  static img.BitmapFont? _fonteCache;

  static Future<img.BitmapFont> _obterFonte() async {
    if (_fonteCache != null) return _fonteCache!;

    try {
      final data = await rootBundle.load(
        'packages/camera_overlay/assets/fonts/RobotoBold.zip',
      );
      final bytes = data.buffer.asUint8List();

      debugPrint('ZIP possui ${bytes.length} bytes');
      final archive = ZipDecoder().decodeBytes(bytes);
      for (final file in archive) {
        debugPrint('Arquivo no zip: ${file.name}');
      }

      _fonteCache = img.BitmapFont.fromZip(bytes);
      debugPrint('Fonte carregada e salva em cache!');
      return _fonteCache!;
    } catch (e, s) {
      debugPrint('Erro ao carregar fonte: $e');
      debugPrint(s.toString());
      rethrow;
    }
  }

  static Future<void> salvarFotoFinal({
    required File fotoTemporaria,
    required Future<void> Function(
      Uint8List bytes,
      dynamic localizacao,
      String obs,
    )
    onFotoFinal,
    double? lat,
    double? lng,
    double? alt,
    String observacao = '',
    dynamic localizacaoAtual,
    double turns = 0.0,
    int anguloRotacaoDireita = 90,
    int anguloRotacaoEsquerda = -90,
  }) async {
    try {
      // Garante que a fonte está carregada antes de processar
      final fonte = await _obterFonte();

      Uint8List finalBytes = await fotoTemporaria.readAsBytes();

      if (turns != 0.0) {
        finalBytes = await compute(_girarPrintBackground, {
          'bytes': finalBytes,
          'turns': turns,
          'anguloDireita': anguloRotacaoDireita,
          'anguloEsquerda': anguloRotacaoEsquerda,
        });
      }

      String? data;
      String overlay = '';

      final bool isLatLngNull = lat == null && lng == null && alt == null;

      if (isLatLngNull) {
        overlay = localizacaoAtual?.dados ?? 'Obtendo GPS...';
      } else {
        data = await lerDataFoto(finalBytes);

        overlay =
            """
Lat: ${lat != null ? lat.toStringAsFixed(6) : 'Não informado'}
Log: ${lng != null ? lng.toStringAsFixed(6) : 'Não informado'}
Alt: ${alt != null ? '${alt.toStringAsFixed(2)} m' : 'Não informado'} ${data != null ? '\n$data' : ''}""";
      }

      if (observacao.isNotEmpty) {
        overlay += '\nObs: $observacao';
      }

      finalBytes = _desenharOverlay(finalBytes, overlay, fonte);

      await onFotoFinal(finalBytes, localizacaoAtual, observacao);

      if (await fotoTemporaria.exists()) {
        await fotoTemporaria.delete();
        debugPrint('Foto temporária deletada com sucesso.');
      }
    } catch (e) {
      debugPrint('Erro no FotoService.salvarFotoFinal: $e');
      rethrow;
    }
  }

  static Future<Uint8List> _girarPrintBackground(
    Map<String, dynamic> dados,
  ) async {
    final Uint8List bytes = dados['bytes'];
    final double turns = dados['turns'];
    final int anguloDireita = dados['anguloDireita'];
    final int anguloEsquerda = dados['anguloEsquerda'];

    img.Image? screenshot = img.decodeImage(bytes);

    if (screenshot != null) {
      img.Image screenshotGirado;

      if (turns == 0.25) {
        screenshotGirado = img.copyRotate(screenshot, angle: anguloDireita);
      } else if (turns == -0.25) {
        screenshotGirado = img.copyRotate(screenshot, angle: anguloEsquerda);
      } else {
        screenshotGirado = screenshot;
      }

      return img.encodePng(screenshotGirado);
    }

    return bytes;
  }

  static Future<String?> lerDataFoto(Uint8List bytes) async {
    final exif = await readExifFromBytes(bytes);
    final data = exif['EXIF DateTimeOriginal']?.printable;

    if (data == null || data.isEmpty) return null;

    try {
      final DateTime dataFoto = DateFormat(
        'yyyy:MM:dd HH:mm:ss',
      ).parseStrict(data);

      return DateFormat('dd/MM/yyyy HH:mm:ss').format(dataFoto);
    } catch (e) {
      return null;
    }
  }

  static void _desenharTextoComContorno(
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

  static Uint8List _desenharOverlay(
    Uint8List bytes,
    String texto,
    img.BitmapFont fonte,
  ) {
    final imagem = img.decodeImage(bytes)!;
    /**
    * Referência	Tamanho do overlay
    1920	Original
    1600	20% maior
    1536	25% maior
    1280	50% maior
    */
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

    _desenharTextoComContorno(camada, texto, fonte: fonte, x: 20, y: y);

    final overlayRedimensionado = img.copyResize(
      camada,
      width: imagem.width,
      height: imagem.height,
      interpolation: img.Interpolation.linear,
    );

    img.compositeImage(imagem, overlayRedimensionado);

    return Uint8List.fromList(img.encodeJpg(imagem, quality: 90));
  }
}
