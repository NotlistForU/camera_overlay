import 'dart:io';
import 'dart:typed_data';

import 'package:camera_overlay/src/camera/service/foto_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class GalleryOverlay extends StatefulWidget {
  final double? lat;
  final double? lng;
  final double? alt;
  final String? observacao;
  final Future<void> Function(Uint8List bytes, dynamic localizacao, String obs)
  onFotoFinal;

  const GalleryOverlay({
    super.key,
    this.lat,
    this.lng,
    this.alt,
    this.observacao,
    required this.onFotoFinal,
  });

  @override
  State<GalleryOverlay> createState() => _GalleryOverlayState();
}

class _GalleryOverlayState extends State<GalleryOverlay> {
  File? _fotoTemporaria;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onXFileImage();
    });
  }

  Future<void> _onXFileImage() async {
    final XFile? xfile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (xfile == null) {
      if (mounted) Navigator.pop(context);
      return;
    }

    _fotoTemporaria = File(xfile.path);

    try {
      await FotoService.salvarFotoFinal(
        fotoTemporaria: _fotoTemporaria!,
        lat: widget.lat,
        lng: widget.lng,
        alt: widget.alt,
        observacao: widget.observacao ?? '',
        onFotoFinal: widget.onFotoFinal,
      );

      _fotoTemporaria = null;
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao processar imagem: $e')));
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
