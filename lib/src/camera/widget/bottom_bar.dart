import 'dart:io';
import 'package:flutter/material.dart';

class BottomBar extends StatelessWidget {
  final bool temBotaoGoogleMaps;
  final bool temBotaoGaleria;
  final File? fotoTemporaria;
  final bool tirandoFoto;
  final VoidCallback onFoto;
  final VoidCallback onMaps;
  final VoidCallback? onAbrirGaleria;
  final bool abrirMaps;
  static const double height = 110;
  const BottomBar({
    super.key,
    required this.temBotaoGoogleMaps,
    required this.temBotaoGaleria,
    required this.fotoTemporaria,
    required this.onFoto,
    required this.onMaps,
    required this.abrirMaps,
    required this.onAbrirGaleria,
    required this.tirandoFoto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: Colors.white12, width: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Galeria
          temBotaoGaleria
              ? IconButton(
                  onPressed: onAbrirGaleria,
                  icon: fotoTemporaria == null
                      ? const Icon(
                          Icons.photo_library_outlined,
                          color: Colors.white,
                          size: 30,
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.file(
                            fotoTemporaria!,
                            width: 36,
                            height: 36,
                            fit: BoxFit.cover,
                          ),
                        ),
                )
              : IconButton(
                  onPressed: null,
                  icon: const Icon(
                    Icons.photo_library_outlined,
                    color: Color.fromRGBO(1, 2, 3, 0),
                    size: 30,
                  ),
                ),

          // Botao de tirar foto
          GestureDetector(
            onTap: onFoto,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: Center(
                child: tirandoFoto
                    ? const CircularProgressIndicator(strokeWidth: 3)
                    : Container(
                        width: 54,
                        height: 54,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
          // botao do google maps
          temBotaoGoogleMaps
              ? IconButton(
                  onPressed: abrirMaps ? onMaps : null,
                  icon: Icon(
                    Icons.public,
                    color: abrirMaps ? Colors.white : Colors.white24,
                    size: 30,
                  ),
                )
              : IconButton(
                  onPressed: null,
                  icon: const Icon(
                    Icons.photo_library_outlined,
                    color: Color.fromRGBO(1, 2, 3, 0),
                    size: 30,
                  ),
                ),
        ],
      ),
    );
  }
}
