import 'dart:io';
import 'package:flutter/material.dart';
// importe seus widgets reais:
import 'package:sipam_foto/view/camera/widget/mini_mapa.dart' as widget;
import 'package:sipam_foto/view/camera/widget/overlay.dart' as widget;

class Preview extends StatelessWidget {
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
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: repaintKey,
      child: Stack(
        children: [
          Positioned.fill(
            child: imageFile != null
                ? Image.file(imageFile!, fit: BoxFit.cover)
                : preview,
          ),
          if (lat != null && lng != null)
            Positioned(
              top: 10,
              right: 10,
              child: widget.MiniMap(lat: lat!, lng: lng!),
            ),
          Positioned(left: 4, bottom: 2, child: widget.Overlay(dados: dados)),
        ],
      ),
    );
  }
}
