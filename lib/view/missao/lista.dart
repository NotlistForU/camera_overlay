import 'package:flutter/material.dart';

class Lista extends StatelessWidget {
  final String nome;
  final bool ativa;
  final VoidCallback onTap;
  const Lista({
    super.key,
    required this.nome,
    required this.ativa,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: ativa ? Colors.blue.withAlpha(50) : null,
      child: ListTile(
        title: Text(
          nome,
          style: TextStyle(
            fontWeight: ativa ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: ativa
            ? const Icon(Icons.check_circle, color: Colors.blue)
            : null,
        onTap: onTap,
      ),
    );
  }
}
