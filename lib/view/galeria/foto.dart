import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_view/photo_view.dart';
import 'package:sipam_foto/model/foto.dart' as model;
import 'package:sipam_foto/database/fotos/delete.dart' as delete;

class Foto extends StatelessWidget {
  final AssetEntity asset;
  final model.Foto foto;
  const Foto({super.key, required this.asset, required this.foto});

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              await delete.Foto.uma(foto);
              if (c.mounted) {
                Navigator.pop(c, true);
              }
            },
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: FutureBuilder(
        future: asset.file,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return PhotoView(
            imageProvider: FileImage(snapshot.data!),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
          );
        },
      ),
    );
  }
}
