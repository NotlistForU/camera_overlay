class Filtro {
  final String? nome;
  final DateTime? inicio;
  final DateTime? fim;
  final double? minimo;
  final double? maximo;
  final bool? localizacao;
  const Filtro({
    this.nome,
    this.inicio,
    this.fim,
    this.minimo,
    this.maximo,
    this.localizacao,
  });
  // singleton para filtro vazio.
  static const Filtro empty = Filtro();
  // Verifica ser um filtro qualquer esta vazio:
  bool get isEmpty {
    return nome == null &&
        inicio == null &&
        fim == null &&
        minimo == null &&
        maximo == null &&
        localizacao == null;
  }

  Filtro copyWith({
    String? nome,
    DateTime? inicio,
    DateTime? fim,
    double? minimo,
    double? maximo,
    bool? localizacao,
  }) {
    return Filtro(
      nome: nome ?? this.nome,
      inicio: inicio ?? this.inicio,
      fim: fim ?? this.fim,
      minimo: minimo ?? this.minimo,
      maximo: maximo ?? this.maximo,
      localizacao: localizacao ?? this.localizacao,
    );
  }
}
