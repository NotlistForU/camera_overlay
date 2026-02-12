import 'dart:async';
import 'dart:io' show Platform, File;
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

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

// IMPORT widgets
import 'widget/preview.dart' as widgets;
import 'widget/bottom_bar.dart' as widgets;

import 'permissoes.dart' as permissao;

class CameraOverlay extends StatefulWidget {
  final bool temBotaoGoogleMaps;
  final bool temBotaoGaleria;
  final bool temMiniMapa;
  final VoidCallback? onAbrirGaleria;
  final Future<void> Function(Uint8List bytes, model.Localizacao? localizacao)
  onFotoFinal;
  const CameraOverlay({
    super.key,
    required this.temBotaoGoogleMaps,
    required this.temBotaoGaleria,
    required this.temMiniMapa,
    required this.onFotoFinal,
    this.onAbrirGaleria,
  });
  @override
  State<CameraOverlay> createState() => _CameraState();
}

class _CameraState extends State<CameraOverlay> {
  CameraStatus _state = CameraStatus.loading;

  CameraController? _controller;
  List<CameraDescription>? _cameras;
  String? _erro;
  File? _ultimaFoto;
  File? _fotoTemporaria;
  File? _fotoAtual;
  final GlobalKey _repaintKey = GlobalKey();
  bool feedback = false;
  model.Localizacao? localizacaoAtual;

  late final StreamSubscription<model.Localizacao> sub;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _initFluxo();
  }

  @override
  void dispose() {
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
    }
  }

  Future<void> salvarFotoFinal() async {
    try {
      final boundary =
          _repaintKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;

      final image = await boundary.toImage(pixelRatio: 4);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      await widget.onFotoFinal(pngBytes, localizacaoAtual);

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
              temBotaoGoogleMaps: widget.temBotaoGoogleMaps,
              temMiniMapa: widget.temMiniMapa,
              temBotaoGaleria: widget.temBotaoGaleria,
              tirandoFoto: _tirandoFoto,
              feedback: feedback,
              fotoTemporaria: _fotoTemporaria,
              controller: _controller!,
              repaintKey: _repaintKey,
              onFoto: _onFoto,
              onMaps: _onMaps,
              onAbrirGaleria: widget.onAbrirGaleria,
              podeAbrirMaps: podeAbrir,
              localizacaoAtual: localizacaoAtual,
            );
          },
        );
      case CameraStatus.erro:
        return cases.erro(mensagem: _erro ?? 'Erro desconhecido');
    }
  }
}
