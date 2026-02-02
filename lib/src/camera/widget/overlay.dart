import 'package:flutter/material.dart';

class Overlay extends StatelessWidget {
  final String dados;

  const Overlay({super.key, required this.dados});

  @override
  Widget build(BuildContext context) {
    final display = dados.isNotEmpty ? dados : '-';
    return Text(
      display,
      style: const TextStyle(
        fontSize: 16,
        color: Colors.white,
        shadows: [
          Shadow(blurRadius: 4, color: Colors.black, offset: Offset(1, 1)),
        ],
      ),
    );
  }
}
