class ReceitaExterna {
  final String id;
  final String nome;
  final String categoria;
  final String area;
  final String instrucoes;
  final String imagemUrl;
  final List<String> ingredientes;

  const ReceitaExterna({
    required this.id,
    required this.nome,
    required this.categoria,
    required this.area,
    required this.instrucoes,
    required this.imagemUrl,
    required this.ingredientes,
  });

  factory ReceitaExterna.fromJson(Map<String, dynamic> json) {
    final ingredientes = <String>[];
    for (int i = 1; i <= 20; i++) {
      final ingrediente = (json['strIngredient$i'] as String? ?? '').trim();
      final medida = (json['strMeasure$i'] as String? ?? '').trim();
      if (ingrediente.isNotEmpty) {
        ingredientes.add(medida.isEmpty ? ingrediente : '$medida $ingrediente');
      }
    }

    return ReceitaExterna(
      id: json['idMeal'] as String,
      nome: json['strMeal'] as String,
      categoria: json['strCategory'] as String? ?? '',
      area: json['strArea'] as String? ?? '',
      instrucoes: json['strInstructions'] as String? ?? '',
      imagemUrl: json['strMealThumb'] as String? ?? '',
      ingredientes: ingredientes,
    );
  }
}
