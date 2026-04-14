import 'dart:io';

import 'package:camera/camera.dart';
import 'package:camera_overlay/src/camera/overlay.dart';
import 'package:flutter/material.dart';
import '../model/localizacao.dart' as model;
import '../widget/bottom_bar.dart' as widgets;
import '../widget/preview.dart' as widgets;

const double height = widgets.BottomBar.height;

Widget cameraPronta({
  required String titulo,
  required bool temBotaoGoogleMaps,
  required bool temBotaoGaleria,
  required bool temMiniMapa,
  required bool feedback,
  required bool tirandoFoto,
  required File? fotoTemporaria,
  required CameraController controller,
  required Function(ScaleStartDetails) onScaleStart,
  required Function(ScaleUpdateDetails) onScaleUpdate,
  required GlobalKey repaintKey,
  required VoidCallback onFoto,
  required VoidCallback onMaps,
  required VoidCallback? onAbrirGaleria,
  required bool podeAbrirMaps,
  required model.Localizacao? localizacaoAtual,
  required double turns,
  required String observacao,
  required VoidCallback onAddObservacao,
}) {
  String overlay = localizacaoAtual?.dados ?? 'Obtendo GPS...';
  if (observacao.isNotEmpty) {
    overlay += '\nObs: $observacao';
  }

  return Scaffold(
    appBar: AppBar(
      title: Text(titulo),
      actions: [
        IconButton(
          icon: const Icon(Icons.note_add),
          onPressed: onAddObservacao,
        ),
      ],
    ),
    body: Stack(
      children: [
        Positioned.fill(
          bottom: height,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            decoration: BoxDecoration(
              border: feedback
                  ? Border.all(color: Colors.white, width: 6)
                  : null,
            ),
            child: widgets.Preview(
              turns: turns,
              temMiniMapa: temMiniMapa,
              imageFile: fotoTemporaria,
              preview: GestureDetector(
                onScaleStart: onScaleStart,
                onScaleUpdate: onScaleUpdate,
                child: CameraPreview(controller),
              ),
              dados: overlay,
              repaintKey: repaintKey,
              lat: localizacaoAtual?.latitude,
              lng: localizacaoAtual?.longitude,
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: widgets.BottomBar(
            temBotaoGoogleMaps: temBotaoGoogleMaps,
            temBotaoGaleria: temBotaoGaleria,
            tirandoFoto: tirandoFoto,
            fotoTemporaria: fotoTemporaria,
            onFoto: onFoto,
            onMaps: onMaps,
            onAbrirGaleria: onAbrirGaleria,
            abrirMaps: podeAbrirMaps,
          ),
        ),
      ],
    ),
  );
}
