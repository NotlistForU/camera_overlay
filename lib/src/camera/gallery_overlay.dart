import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:camera_overlay/main.dart';
import 'package:camera_overlay/src/camera/service/overlay_service.dart';
import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class GalleryOverlay extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final double? altitude;
  final String? observacoes;
  final Future<void> Function(
    Uint8List bytes,
    double? latitude,
    double? longitude,
    double? altitude,
    String? observacoes,
  )
  onImagemGallery;

  const GalleryOverlay({
    super.key,
    required this.onImagemGallery,
    this.latitude,
    this.longitude,
    this.altitude,
    this.observacoes,
  });
  @override
  State<GalleryOverlay> createState() => _GalleryOverlayState();
}

class _GalleryOverlayState extends State<GalleryOverlay> {
  img.BitmapFont? _fonte;

  Future<void> _carregarFonte() async {
    _fonte = await OverlayService.carregarFonte();
  }

  Future<void> salvarFotoFinal({File? imagem}) async {
    if (imagem == null) return;

    try {
      final data = await lerDataFoto(imagem);
      final overlay = montarOverlay(data);

      Uint8List finalBytes = await imagem.readAsBytes();

      if (_fonte != null) {
        finalBytes = OverlayService.desenharOverlay(
          finalBytes,
          overlay,
          _fonte!,
        );
      }

      await widget.onImagemGallery(
        finalBytes,
        widget.latitude,
        widget.longitude,
        widget.altitude,
        widget.observacoes,
      );
    } catch (e) {
      debugPrint('Erro ao processar imagem da galeria: $e');
    }
  }

  Future<String?> lerDataFoto(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final exif = await readExifFromBytes(bytes);

      final data = exif['EXIF DateTimeOriginal']?.printable;

      if (data == null || data.isEmpty) {
        return null;
      }

      final dataFoto = DateFormat('yyyy:MM:dd HH:mm:ss').parseStrict(data);

      return DateFormat('dd/MM/yyyy HH:mm:ss').format(dataFoto);
    } catch (e) {
      return null;
    }
  }

  String montarOverlay(String? data) {
    final latitude = widget.latitude?.toStringAsFixed(6) ?? 'Não informado';

    final longitude = widget.longitude?.toStringAsFixed(6) ?? 'Não informado';

    final altitude = widget.altitude != null
        ? '${widget.altitude!.toStringAsFixed(2)} m'
        : 'Não informado';

    final observacoes = widget.observacoes?.trim();

    return [
      'Lat: $latitude',
      'Log: $longitude',
      'Alt: $altitude',
      'Data: ${data ?? 'Não informado'}',
      if (observacoes != null && observacoes.isNotEmpty) 'Obs: $observacoes',
    ].join('\n');
  }

  bool _carregando = false;

  Future<void> _selecionarImagem() async {
    if (_carregando) return;

    setState(() => _carregando = true);

    try {
      _fonte ??= await OverlayService.carregarFonte();

      final XFile? imagem = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );

      if (imagem == null) return;

      await salvarFotoFinal(imagem: File(imagem.path));
    } catch (e) {
      debugPrint('Erro ao selecionar imagem: $e');
    } finally {
      if (mounted) {
        setState(() => _carregando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _carregando ? null : _selecionarImagem,
      icon: _carregando
          ? const CircularProgressIndicator()
          : const Icon(Icons.photo_library),
      tooltip: 'Selecionar imagem da galeria',
    );
  }
}
