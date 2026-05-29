// Modelo de dados de uma receita criada pelo próprio usuário do app.
class Receita {
  final String id;
  final String nome;
  final String categoria;
  final int tempoPreparo;
  final int porcoes;
  final List<String> ingredientes;
  final List<String> modoPreparo;
  final String? imagemPath; // URL pública no Supabase Storage
  final DateTime criadoEm;
  final bool favorito;

  Receita({
    required this.id,
    required this.nome,
    required this.categoria,
    required this.tempoPreparo,
    required this.porcoes,
    required this.ingredientes,
    required this.modoPreparo,
    this.imagemPath,
    required this.criadoEm,
    this.favorito = false,
  });

  String get tempoFormatado {
    if (tempoPreparo < 60) return '$tempoPreparo min';
    final h = tempoPreparo ~/ 60;
    final m = tempoPreparo % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}min';
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'nome': nome,
        'categoria': categoria,
        'tempo_preparo': tempoPreparo,
        'porcoes': porcoes,
        'ingredientes': ingredientes,
        'modo_preparo': modoPreparo,
        'imagem_path': imagemPath,
        'criado_em': criadoEm.toIso8601String(),
        'favorito': favorito,
      };

  factory Receita.fromMap(Map<String, dynamic> map) => Receita(
        id: map['id'] as String,
        nome: map['nome'] as String,
        categoria: map['categoria'] as String,
        tempoPreparo: map['tempo_preparo'] as int,
        porcoes: map['porcoes'] as int,
        ingredientes: List<String>.from(map['ingredientes'] as List),
        modoPreparo: List<String>.from(map['modo_preparo'] as List),
        imagemPath: map['imagem_path'] as String?,
        criadoEm: DateTime.parse(map['criado_em'] as String),
        favorito: map['favorito'] as bool,
      );
}
