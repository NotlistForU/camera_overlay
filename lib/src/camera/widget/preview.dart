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

  const Preview({
    super.key,
    required this.imageFile,
    required this.preview,
    required this.dados,
    required this.repaintKey,
    this.lat,
    this.lng,
    required this.temMiniMapa,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: repaintKey,
      child: Stack(
        children: [
          Positioned.fill(child: preview),
          if (lat != null && lng != null)
            Positioned(
              top: 10,
              right: 10,
              child: widgets.MiniMap(
                temMiniMapa: temMiniMapa,
                lat: lat!,
                lng: lng!,
              ),
            ),
          Positioned(left: 1, bottom: 1, child: widgets.Overlay(dados: dados)),
        ],
      ),
    );
  }
}
