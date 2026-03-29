import 'dart:io';
import 'package:flutter/material.dart';
// importe seus widgets reais:
import 'mini_mapa.dart' as widgets;
import 'overlay.dart' as widgets;

class Preview extends StatelessWidget {
  final bool temMiniMapa;
  final File? imageFile;
  final Widget preview;
  final String dados;
  final GlobalKey repaintKey;
  final double? lat;
  final double? lng;
  final double turns;

  const Preview({
    super.key,
    required this.imageFile,
    required this.preview,
    required this.dados,
    required this.repaintKey,
    this.lat,
    this.lng,
    required this.temMiniMapa,
    required this.turns,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: repaintKey,
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedRotation(
              turns: turns,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              child: preview,
            ),
          ),
          Positioned.fill(child: preview),
          if (lat != null && lng != null)
            Positioned(
              // No modo retrato, fica no topo. Quando deita pra direita (turns == 0.25),
              // vai pro canto superior esquerdo físico (que é o "topo" pro usuário).
              top: (turns == 0.0 || turns == -0.25) ? 10 : null,

              // Quando deita pra esquerda (turns == -0.25), o "topo" do usuário
              // vira a parte de baixo física do celular.
              bottom: (turns == 0.25) ? 10 : null,

              // No modo retrato ou deitado pra esquerda, fica colado na direita física.
              right: (turns == 0.0)
                  ? 10
                  : (turns == 0.25)
                  ? 10
                  : null,

              // Quando deita pra direita, cola na esquerda física.
              left: (turns == -0.25) ? 10 : null,

              child: RotatedBox(
                // Mesma matemática do texto: compensa o giro pra manter o mapa em pé
                quarterTurns: turns == 0.25 ? 1 : (turns == -0.25 ? 3 : 0),
                child: widgets.MiniMap(
                  temMiniMapa: temMiniMapa,
                  lat: lat!,
                  lng: lng!,
                ),
              ),
            ),
          Positioned(
            // No modo retrato ou deitado pra direita, ele gruda na esquerda da tela (que vira o "chão" pra direita)
            left: (turns == 0.0 || turns == 0.25) ? 1 : null,

            // Deitado pra esquerda, ele gruda na direita da tela
            right: (turns == -0.25) ? 1 : null,

            // No modo retrato ou deitado pra esquerda, gruda embaixo
            bottom: (turns == 0.0 || turns == -0.25) ? 1 : null,

            // Deitado pra direita, gruda no topo
            top: (turns == 0.25) ? 1 : null,

            child: RotatedBox(
              // Aqui é a mágica: compensa o giro físico do celular para o texto ficar "em pé" pros olhos do usuário
              quarterTurns: turns == 0.25 ? 1 : (turns == -0.25 ? 3 : 0),
              child: widgets.Overlay(dados: dados),
            ),
          ),
        ],
      ),
    );
  }
}
