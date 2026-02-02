import 'package:flutter/material.dart';
import '../enum.dart';

class SemMissao extends StatelessWidget {
  final void Function(CameraStatus) onSetState;
  final VoidCallback onInitFluxo;
  const SemMissao({
    super.key,
    required this.onSetState,
    required this.onInitFluxo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Câmera')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            onInitFluxo();
            onSetState(CameraStatus.loading);
          },
          child: const Text('Ativar missão'),
        ),
      ),
    );
  }
}
