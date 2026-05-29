import 'package:image_picker/image_picker.dart';
import '../database/db_helper.dart';
import '../modelos/receita.dart';
import '../constantes/filtros.dart';

// Camada de serviço entre os controllers e o DBHelper.
// Centraliza a lógica de negócio (ex.: filtragem) para que os controllers fiquem enxutos.
class ReceitaService {
  final _db = DBHelper();

  Future<List<Receita>> carregarTodas() => _db.getReceitas();

  Future<List<Receita>> carregarDestaques() => _db.getDestaques();

  Future<void> salvar(Receita receita) => _db.inserir(receita);

  Future<void> toggleFavorito(String id, bool novoFavorito) =>
      _db.toggleFavorito(id, novoFavorito);

  Future<String> uploadImagem(XFile imagem) => _db.uploadImagem(imagem);

  // Filtra uma lista já carregada em memória por texto, categoria e tempo máximo.
  // Busca por nome e também por qualquer ingrediente que contenha o texto digitado.
  List<Receita> filtrar(
    List<Receita> receitas, {
    String query = '',
    String categoria = 'Todos',
    String tempoLabel = '+1 hora',
  }) {
    final q = query.toLowerCase().trim();
    // Localiza o valor numérico correspondente ao label selecionado (null = sem limite)
    final tempoMax = temposFiltro.firstWhere(
      (t) => t['label'] == tempoLabel,
      orElse: () => {'label': '+1 hora', 'value': null},
    )['value'] as int?;

    return receitas.where((r) {
      final matchesSearch = q.isEmpty ||
          r.nome.toLowerCase().contains(q) ||
          r.ingredientes.any((i) => i.toLowerCase().contains(q));
      final matchesCategoria = categoria == 'Todos' || r.categoria == categoria;
      final matchesTempo = tempoMax == null || r.tempoPreparo <= tempoMax;
      return matchesSearch && matchesCategoria && matchesTempo;
    }).toList();
  }
}
