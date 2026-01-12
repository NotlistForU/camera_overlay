// UTILS -> logo filtrar é uma função. Não confundir com o MODEL -> Filtro.
void filtrar(
  List<String> where,
  List<Object?> args,
  String condition,
  Object? value,
) {
  if (value == null) return;
  if (value is String && value.isEmpty) return;
  where.add(condition);
  args.add(value);
}
