import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sipam_foto/view/camera/widget/bottom_bar.dart' as widgets;
import 'package:sipam_foto/view/camera/permissoes.dart' as permissao;
import 'package:sipam_foto/view/camera/widget/preview.dart' as widgets;
import 'package:sipam_foto/model/missao.dart' as model;
import 'package:sipam_foto/view/missao.dart' as page;
import 'package:sipam_foto/database/missoes/select.dart' as select;

class Camera extends StatefulWidget {
  final double height =
      110; // ver depois como fica isso se vai ter bottom_bar_widget ou n
  final VoidCallback onUpdate;
  const Camera({super.key, required this.onUpdate});
  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  bool loading = true;
  int contador = 0;
  bool feedback = false;

  // preview
  CameraController? _cameraController;
  Widget get _cameraPreviewWidget {
    final ctrl = _cameraController;
    if (ctrl == null || !ctrl.value.isInitialized) {
      return const Center(child: Text("Câmera não inicializada"));
    }
    return CameraPreview(ctrl);
  }

  List<CameraDescription>? _cameras;
  File? imageFile;
  final GlobalKey _repaintKey = GlobalKey();
  late String dados;
  double? lat;
  double? lng;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    bool concedido = await permissao.requestCameraAndLocationPermissions();
    if (!mounted) return;
    if (concedido) {
      await _initCameraController();
    } else {
      dialogPermissaoNegada();
    }

    final missao = await select.Select.missaoAtiva();

    if (missao == null) {
      await _checkMissaoAtiva();
    }
  }

  Future<void> _checkMissaoAtiva() async {
    final missao = await select.Select.missaoAtiva();
    if (!mounted || missao == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: const Text('Missão ativa'),
          content: Text('Missão "${missao.nome}" está ativa.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Continuar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadContext() async {
    final missao = await select.Select.missaoAtiva();
    if (missao == null) return;
    model.Missao missaoAtiva = missao;
    contador = missao.contador;
  }

  Future<void> loadMissao() async {
    await _loadContext();
    widget.onUpdate();
  }

  void _feedback() {
    feedback = true;
    widget.onUpdate();
    Future.delayed(const Duration(milliseconds: 120), () {
      feedback = false;
      widget.onUpdate();
    });
  }

  Future<void> _initCameraController() async {
    try {
      // 1) lista de câmeras do dispositivo
      _cameras = await availableCameras();

      if (_cameras == null || _cameras!.isEmpty) {
        // sem câmeras disponíveis
        if (!mounted) return;
        setState(() {
          loading = false;
        });
        // opcional: mostrar diálogo/erro ao usuário
        return;
      }

      // 2) escolhe a câmera (ex.: primeira)
      final camera = _cameras!.first;

      // 3) cria o controller
      _cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      // 4) inicializa
      await _cameraController!.initialize();

      // 5) atualiza estado
      if (!mounted) return;
      setState(() {
        loading = false;
      });
    } catch (e, st) {
      // trate o erro apropriadamente (log, mostrar diálogo, etc.)
      if (!mounted) return;
      setState(() {
        loading = false;
      });
      // opcional: mostrar um SnackBar ou AlertDialog com a mensagem de erro
      debugPrint('Erro inicializando câmera: $e\n$st');
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Erro na câmera'),
          content: Text('Não foi possível inicializar a câmera: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void dialogPermissaoNegada() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: const Text('Permissões necessárias'),
          content: const Text(
            'A aplicação precisa de permissão para usar a câmera e a localização. '
            'Por favor, conceda as permissões nas configurações do aplicativo.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await openAppSettings(); // abre as configurações do app
              },
              child: const Text('Abrir configurações'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext c) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Câmera'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flag),
            onPressed: () async {
              final changed = await Navigator.push<bool>(
                c,
                MaterialPageRoute(builder: (_) => const page.Missao()),
              );
              if (changed == true) {
                loadMissao();
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            bottom: widget.height,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              decoration: BoxDecoration(
                border: feedback
                    ? Border.all(color: Colors.white, width: 6)
                    : null,
              ),
              child: widgets.Preview(
                imageFile: imageFile,
                preview: _cameraPreviewWidget,
                dados: dados,
                repaintKey: _repaintKey,
                lat: lat,
                lng: lng,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: null,
            // widgets.BottomBar(
            //   ultimaFoto: ultimaFoto,
            //   onFoto: onFoto,
            //   onMaps: onMaps,
            //   abrirMaps: abrirMaps,
            // ), // BottomBar widget
          ),
        ],
      ),
    );
  }
}
