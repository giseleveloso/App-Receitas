import 'package:image_picker/image_picker.dart';
import '../database/db_helper.dart';
import '../modelos/receita.dart';
import '../constantes/filtros.dart';

class ReceitaService {
  final _db = DBHelper();

  Future<List<Receita>> carregarTodas() => _db.getReceitas();

  Future<List<Receita>> carregarDestaques() => _db.getDestaques();

  Future<void> salvar(Receita receita) => _db.inserir(receita);

  Future<void> toggleFavorito(String id, bool novoFavorito) =>
      _db.toggleFavorito(id, novoFavorito);

  Future<String> uploadImagem(XFile imagem) => _db.uploadImagem(imagem);

  List<Receita> filtrar(
    List<Receita> receitas, {
    String query = '',
    String categoria = 'Todos',
    String tempoLabel = '+1 hora',
  }) {
    final q = query.toLowerCase().trim();
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
