import 'package:flutter/material.dart';

class Overlay extends StatelessWidget {
  final String dados;

  const Overlay({super.key, required this.dados});

  @override
  Widget build(BuildContext context) {
    final display = dados.isNotEmpty ? dados : '-';
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: const EdgeInsets.all(8.0),
      child: Text(
        display,
        softWrap: true,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.white,
          shadows: [
            Shadow(blurRadius: 4, color: Colors.black, offset: Offset(1, 1)),
          ],
        ),
      ),
    );
  }
}
