import 'dart:async';
import 'dart:io' show Platform, File;
import 'package:camera_overlay/src/camera/overlay.dart';
import 'package:exif/exif.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sensors_plus/sensors_plus.dart';

// IMPORT salvamento local de dados simples.
import 'package:shared_preferences/shared_preferences.dart';

// IMPORT enums
import 'enum.dart';

// IMPORT service
import 'service/localizacao.dart' as service;

import 'package:http/http.dart' as http;

//IMPORT model

import 'model/localizacao.dart' as model;

// IMPORT cases
import 'cases/loading.dart' as cases;
import 'cases/permissao_negada.dart' as cases;
import 'cases/camera_pronta.dart' as cases;
import 'cases/erro.dart' as cases;

import 'permissoes.dart' as permissao;

import 'package:archive/archive.dart';

class CameraOverlay extends StatefulWidget {
  final double? lat;
  final double? lng;
  final double? alt;
  final String titulo;
  final bool temBotaoGoogleMaps;
  final bool temBotaoGaleria;
  final bool temMiniMapa;
  final Future<void> Function(bool)? onMiniMapaChanged;

  /// Ângulo para corrigir a foto quando o celular deitar para a DIREITA.
  ///
  /// O padrão é `-90`. Se a foto sair invertida, tente passar `90`.
  final int anguloRotacaoDireita;

  /// Ângulo para corrigir a foto quando o celular deitar para a ESQUERDA.
  ///
  /// O padrão é `90`. Se a foto sair invertida, tente passar `-90`.
  final int anguloRotacaoEsquerda;
  final Future<void> Function(
    Uint8List bytes,
    model.Localizacao? localizacao,
    String? observacoes,
  )
  onFotoFinal;

  final List<Widget>? configsExtras;
  const CameraOverlay({
    super.key,
    this.lat,
    this.lng,
    this.alt,
    this.titulo = 'Câmera',
    this.temBotaoGoogleMaps = true,
    this.temBotaoGaleria = false,
    this.temMiniMapa = true,
    this.onMiniMapaChanged,
    required this.onFotoFinal,
    this.anguloRotacaoDireita = -90,
    this.anguloRotacaoEsquerda = 90,
    this.configsExtras,
  });
  @override
  State<CameraOverlay> createState() => _CameraState();
}

class _CameraState extends State<CameraOverlay> {
  CameraStatus _state = CameraStatus.loading;
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  String? _erro;
  File? _fotoTemporaria;
  double _minZoom = 1.0;
  double _maxZoom = 1.0;
  double _currentZoom = 1.0;
  final GlobalKey _repaintKey = GlobalKey();
  bool feedback = false;
  model.Localizacao? localizacaoAtual;

  late final StreamSubscription<model.Localizacao> sub;
  StreamSubscription<AccelerometerEvent>? _accelSubscription;
  double _turns = 0.0;

  String _observacao = '';
  final TextEditingController _obsController = TextEditingController();

  late bool _exibirMiniMapa;

  img.BitmapFont? _fonte;

  @override
  void initState() {
    super.initState();
    _exibirMiniMapa = widget.temMiniMapa;
    _carregarFonte();
    _carregarPreferencias();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _initFluxo();
    _accelSubscription = accelerometerEventStream().listen((
      AccelerometerEvent event,
    ) {
      double novoGiro = _turns;

      if (event.x > 9.0) {
        novoGiro = 0.25;
      } else if (event.x < -9.0) {
        novoGiro = -0.25;
      } else if (event.y > 9.0) {
        novoGiro = 0.0;
      }
      if (novoGiro != _turns) {
        setState(() {
          _turns = novoGiro;
        });
      }
    });
  }

  @override
  void dispose() {
    _accelSubscription?.cancel();
    // libera orientação ao sair da câmera
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    sub.cancel();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _carregarFonte() async {
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

      _fonte = img.BitmapFont.fromZip(bytes);

      debugPrint('Fonte carregada!');
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
    }
  }

  void _carregarPreferencias() async {
    final preferencias = await SharedPreferences.getInstance();
    setState(() {
      _exibirMiniMapa = preferencias.getBool('exibirMiniMapa') ?? false;
      _sugestoesObservacoes =
          preferencias.getStringList('sugestoesObservacoes') ?? [];
    });
  }

  void onUpdate() {
    if (!mounted) return;
    setState(() {});
  }

  void triggerFeedback() {
    feedback = true;
    onUpdate();

    Future.delayed(const Duration(milliseconds: 120), () {
      feedback = false;
      onUpdate();
    });
  }

  Future<void> _onXFileImage() async {
    if (_tirandoFoto) return;

    setState(() => _tirandoFoto = true);

    try {
      final XFile? xfile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );

      if (xfile == null) return;

      final File file = File(xfile.path);

      setState(() {
        _fotoTemporaria = file;
      });

      await salvarFotoFinal();
    } catch (e) {
      _erro = e.toString();
      _setState(CameraStatus.erro);
    } finally {
      if (mounted) {
        setState(() => _tirandoFoto = false);
      }
    }
  }

  // flag
  bool _tirandoFoto = false;
  void getTirandofoto() => _tirandoFoto;
  Future<void> _onFoto() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_tirandoFoto) return;
    try {
      setState(() {
        _tirandoFoto = true;
      });
      final XFile xfile = await _controller!.takePicture();
      final File file = File(xfile.path);
      setState(() {
        _fotoTemporaria = file;
        triggerFeedback();
      });
      await salvarFotoFinal();
      setState(() {
        _tirandoFoto = false;
      });
    } catch (e) {
      _erro = e.toString();
      _setState(CameraStatus.erro);

      setState(() {
        _tirandoFoto = false;
      });
    }
  }

  Future<void> salvarFotoFinal() async {
    try {
      Uint8List finalBytes = await _fotoTemporaria!.readAsBytes();
      if (_turns != 0.0) {
        finalBytes = await compute(_girarPrintBackground, {
          'bytes': finalBytes,
          'turns': _turns,
          'anguloDireita': widget.anguloRotacaoDireita,
          'anguloEsquerda': widget.anguloRotacaoEsquerda,
        });
      }

      String? data;
      String? overlay;
      String dados = '';

      bool isLatLngNull = true;

      if (widget.lat != null || widget.lng != null || widget.alt != null) {
        isLatLngNull = false;
      }
      if (isLatLngNull) {
        overlay = localizacaoAtual?.dados ?? 'Obtendo GPS...';
      } else {
        data = await lerDataFoto(finalBytes);

        //Keep the string flush against the wall, because the """ counts the indentation, which would leave the text offset when displayed in the overlay.
        dados =
            """
Lat: ${widget.lat != null ? widget.lat!.toStringAsFixed(6) : 'Não informado'}
Log: ${widget.lng != null ? widget.lng!.toStringAsFixed(6) : 'Não informado'}
Alt: ${widget.alt != null ? '${widget.alt!.toStringAsFixed(2)} m' : 'Não informado'} ${data != null ? '\n$data' : ''}""";

        overlay = dados;
      }

      if (_observacao.isNotEmpty) {
        overlay += '\nObs: $_observacao';
      }
      if (_fonte == null) {
        debugPrint("_fonte tava nulla.....");
        return;
      }
      debugPrint("Fonte nao estava nulla....");
      finalBytes = _desenharOverlay(finalBytes, overlay, _fonte!);
      await widget.onFotoFinal(finalBytes, localizacaoAtual, _observacao);

      if (_fotoTemporaria != null && await _fotoTemporaria!.exists()) {
        await _fotoTemporaria!.delete();
        debugPrint('Foto temporaria deletada');
      }
      setState(() {
        _fotoTemporaria = null;
      });
    } catch (e) {
      _erro = e.toString();
      _setState(CameraStatus.erro);
    }
  }

  Future<String?> lerDataFoto(Uint8List bytes) async {
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

  // Roda em background (isolate) — decodifica, desenha o texto, e codifica em JPEG
  Uint8List _desenharOverlay(
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

    // Largura de referência para desenhar o overlay
    const larguraReferencia = 1536;

    // Calcula as dimensões proporcionais da camada
    final escala = imagem.width / larguraReferencia;
    final alturaReferencia = (imagem.height / escala).round();

    // Cria uma camada transparente
    final camada = img.Image(
      width: larguraReferencia,
      height: alturaReferencia,
      numChannels: 4,
    );

    img.fill(camada, color: img.ColorRgba8(0, 0, 0, 0));

    // Calcula o posicionamento do texto
    final numeroDeLinhas = texto.split('\n').length;

    const espacamentoEntreLinhas = 8;
    final alturaLinha = fonte.lineHeight + espacamentoEntreLinhas;
    final alturaTotalDoTexto = numeroDeLinhas * alturaLinha;

    const margemInferior = 30;

    final y = camada.height - alturaTotalDoTexto - margemInferior;

    // Desenha o texto na camada transparente
    _desenharTextoComContorno(camada, texto, fonte: fonte, x: 20, y: y);

    // Redimensiona a camada para acompanhar a fotografia
    final overlayRedimensionado = img.copyResize(
      camada,
      width: imagem.width,
      height: imagem.height,
      interpolation: img.Interpolation.linear,
    );

    // Sobrepõe o texto à fotografia
    img.compositeImage(imagem, overlayRedimensionado);

    return Uint8List.fromList(img.encodeJpg(imagem, quality: 90));
  }

  static Future<Uint8List> _girarPrintBackground(
    Map<String, dynamic> dados,
  ) async {
    final Uint8List bytes = dados['bytes'];
    final double turns = dados['turns'];
    final int anguloDireita = dados['anguloDireita'];
    final int anguloEsquerda = dados['anguloEsquerda'];

    // Decodifica a imagem
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

      // Transforma de volta em bytes PNG e retorna
      return img.encodePng(screenshotGirado);
    }

    // Se der algum erro bizarro, devolve a imagem original
    return bytes;
  }

  Future<bool> podeAbrirMaps() async {
    debugPrint(
      ">>> podeAbrirMaps chamado: localizacaoAtual = $localizacaoAtual",
    );
    try {
      localizacaoAtual != null;

      final tentativa = await http
          .get(Uri.parse("https://www.google.com"))
          .timeout(const Duration(seconds: 5));
      return tentativa.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<void> _onMaps() async {
    if (await podeAbrirMaps()) {
      Uri url;
      if (Platform.isIOS) {
        url = Uri.parse(
          "geo:${localizacaoAtual!.latitude},${localizacaoAtual!.longitude}",
        );
      }
      if (Platform.isAndroid) {
        url = Uri.parse(
          "geo:${localizacaoAtual!.latitude},${localizacaoAtual!.longitude}?q=${localizacaoAtual!.latitude},${localizacaoAtual!.longitude}",
        );
      } else {
        url = Uri.parse(
          "https://maps.google.com/?q=${localizacaoAtual!.latitude},${localizacaoAtual!.longitude}",
        );
      }
      try {
        final launch = await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
        if (!launch) {
          debugPrint('>>>> nao conseguiu abrir o Map');
        }
      } catch (e, s) {
        debugPrint(">>> ERRO ao abrir Maps: $e");
        debugPrint(">>> Stacktrace: $s");
      }
    }
  }

  double _baseZoom = 1.0;

  void _handleScaleStart(ScaleStartDetails details) {
    _baseZoom = _currentZoom;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    double zoom = (_baseZoom * details.scale).clamp(_minZoom, _maxZoom);
    debugPrint("scale: ${details.scale}");
    debugPrint("min: $_minZoom max: $_maxZoom");
    debugPrint("zoom calculado: $zoom");
    await _controller!.setZoomLevel(zoom);
    _currentZoom = zoom;
  }

  Future<void> _initFluxo() async {
    try {
      final permitido = await permissao.requestAllPermissions();
      if (!permitido) {
        _setState(CameraStatus.permissaoNegada);
        return;
      }

      _setState(CameraStatus.inicializandoCamera);
      await _initCamera();

      // começa a escutar
      final stream = service.emTempoReal();

      sub = stream.listen((loc) {
        setState(() {
          localizacaoAtual = loc;
        });
      });

      // aguarda PRIMEIRA localização antes de liberar câmera
      localizacaoAtual = await stream.first;

      _setState(CameraStatus.pronta);
    } catch (e) {
      _erro = e.toString();
      _setState(CameraStatus.erro);
    }
  }

  void getInitFluxo() => _initFluxo();

  void _setState(CameraStatus novo) {
    if (!mounted) return;
    setState(() => _state = novo);
  }

  void getSetState(CameraStatus novo) => _setState(novo);

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras == null || _cameras!.isEmpty) {
      throw Exception('Nenhuma câmera disponível');
    }
    _controller = CameraController(
      _cameras!.first,
      ResolutionPreset.veryHigh,
      enableAudio: false,
    );
    await _controller!.initialize();
    _minZoom = await _controller!.getMinZoomLevel();
    _maxZoom = await _controller!.getMaxZoomLevel();
  }

  late List<String> _sugestoesObservacoes = [];

  void _mostrarDialogoObservacao() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Adicionar Observação'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _obsController,
                  autofocus: true,
                  minLines: 1,
                  maxLines: 6,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    hintText: 'Digite a observação...',
                  ),
                  onChanged: (textoDigitado) {
                    // Isso aqui vai forçar o cameraPronta a desenhar de novo com o texto novo
                    setState(() {
                      _observacao = textoDigitado;
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Sugestões',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: _sugestoesObservacoes.map((sugestao) {
                    return ActionChip(
                      label: Text(sugestao),
                      onPressed: () {
                        setState(() {
                          _obsController.text = sugestao;
                          _observacao = sugestao;
                          // Seleciona o final do texto.
                          _obsController.selection = TextSelection.fromPosition(
                            TextPosition(offset: _obsController.text.length),
                          );
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () async {
                if (_obsController.text.isNotEmpty) {
                  String text = _obsController.text.trim();

                  setState(() {
                    if (!_sugestoesObservacoes.contains(text)) {
                      if (_sugestoesObservacoes.length >= 5) {
                        _sugestoesObservacoes.removeAt(0);
                      }
                      _sugestoesObservacoes.add(text);
                    }
                  });
                  await preferences.setStringList(
                    'sugestoesObservacoes',
                    _sugestoesObservacoes,
                  );
                }
                if (!context.mounted) return;
                Navigator.pop(dialogContext);
              },
              child: const Text('Pronto'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarConfig({
    required Future<void> Function(bool)? onMiniMapaChanged,
  }) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // O StatefulBuilder é necessário para as chavinhas atualizarem enquanto o dialog estiver aberto
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            return AlertDialog(
              title: const Text('Configurações'),
              content: Column(
                mainAxisSize:
                    MainAxisSize.min, // Para a coluna não ocupar a tela toda
                children: [
                  SwitchListTile(
                    title: const Text('Ativar Minimapa'),
                    value: _exibirMiniMapa,
                    onChanged: (bool novoValor) async {
                      debugPrint('Botão Ativar Minimapa CLICADO!');

                      await preferences.setBool('exibirMiniMapa', novoValor);
                      if (onMiniMapaChanged != null) {
                        await onMiniMapaChanged(novoValor);
                      }

                      setStateDialog(() {
                        _exibirMiniMapa =
                            novoValor; // Atualiza visualmente dentro do Dialog
                      });

                      if (!mounted) return;

                      setState(() {
                        _exibirMiniMapa = novoValor;
                      });
                      debugPrint(_exibirMiniMapa.toString());
                    },
                  ),
                  if (widget.configsExtras != null) ...widget.configsExtras!,

                  // SwitchListTile(
                  //   title: const Text('Ativar Overlay'),
                  //   value: _overlayAtivo,
                  //   onChanged: (bool novoValor) {
                  //     setStateDialog(() {
                  //       _overlayAtivo =
                  //           novoValor; // Atualiza visualmente dentro do Dialog
                  //     });
                  //     setState(() {
                  //       // Atualiza a sua tela principal por trás
                  //     });
                  //   },
                  // ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Pronto'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('>>> BUILD CAMERA PAGE <<<');
    switch (_state) {
      case CameraStatus.loading:
        return cases.loading();
      case CameraStatus.permissaoNegada:
        return cases.permissaoNegada(context);
      case CameraStatus.inicializandoCamera:
        return cases.loading(texto: 'Inicializando câmera...');
      case CameraStatus.pronta:
        return FutureBuilder<bool>(
          future: podeAbrirMaps(),
          builder: (context, snapshot) {
            final podeAbrir = snapshot.data ?? false;

            return cases.cameraPronta(
              turns: _turns,
              titulo: widget.titulo,
              temBotaoGoogleMaps: widget.temBotaoGoogleMaps,
              temMiniMapa: _exibirMiniMapa,
              temBotaoGaleria: widget.temBotaoGaleria,
              tirandoFoto: _tirandoFoto,
              feedback: feedback,
              fotoTemporaria: _fotoTemporaria,
              controller: _controller!,
              onScaleStart: _handleScaleStart,
              onScaleUpdate: _handleScaleUpdate,
              repaintKey: _repaintKey,
              onFoto: _onFoto,
              onMaps: _onMaps,
              onAbrirGaleria: _onXFileImage,
              podeAbrirMaps: podeAbrir,
              localizacaoAtual: localizacaoAtual,
              observacao: _observacao,
              onAddObservacao: _mostrarDialogoObservacao,
              onConfig: () =>
                  _mostrarConfig(onMiniMapaChanged: widget.onMiniMapaChanged),
            );
          },
        );
      case CameraStatus.erro:
        return cases.erro(mensagem: _erro ?? 'Erro desconhecido');
    }
  }
}
