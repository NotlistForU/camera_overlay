class Missao {
  final int id;
  final int contador;
  final DateTime data;
  final String nome;
  final bool ativa;
  Missao({
    required this.id,
    required this.contador,
    required this.data,
    required this.nome,
    required this.ativa,
  });
  Missao copyWith({
    int? id,
    int? contador,
    DateTime? data,
    String? nome,
    bool? ativa,
  }) {
    return Missao(
      id: id ?? this.id,
      contador: contador ?? this.contador,
      data: data ?? this.data,
      nome: nome ?? this.nome,
      ativa: ativa ?? this.ativa,
    );
  }
}
