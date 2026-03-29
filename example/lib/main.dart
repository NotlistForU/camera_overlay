import 'package:flutter/material.dart';
import 'package:camera_overlay/camera_overlay.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  runApp(const MeuAppTeste());
}

// Criamos o MaterialApp aqui na raiz
class MeuAppTeste extends StatelessWidget {
  const MeuAppTeste({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teste Camera Overlay',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CameraOverlayTeste01(), // Aqui chamamos a sua tela
    );
  }
}

class CameraOverlayTeste01 extends StatefulWidget {
  const CameraOverlayTeste01({super.key}); // Construtor simplificado do Dart

  @override
  State<CameraOverlayTeste01> createState() => _CameraOverlayTeste01State();
}

class _CameraOverlayTeste01State extends State<CameraOverlayTeste01> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("Teste 01")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CameraOverlay(
                  titulo: "Câmera",
                  temBotaoGoogleMaps: true,
                  temBotaoGaleria: true,
                  temMiniMapa: true,
                  onFotoFinal: (bytes, localizacao) async {
                    debugPrint("Foto Capturada");
                  },
                ),
              ),
            );
          },
          child: const Text("Abrir câmera"),
        ),
      ),
    );
  }
}
