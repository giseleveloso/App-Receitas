import 'package:flutter/foundation.dart';
import '../modelos/receita.dart';
import '../services/receita_service.dart';

// Controller da tela de busca. Mantém o estado dos filtros ativos e
// recalcula os resultados sempre que algum filtro muda.
class BuscarController extends ChangeNotifier {
  final ReceitaService _service;

  BuscarController(this._service);

  List<Receita> _todas =
      []; // lista completa carregada do banco (não exposta à UI)
  List<Receita> resultados = []; // subconjunto filtrado exibido na tela
  String query = '';
  String categoria = 'Todos';
  String tempoLabel = '+1 hora';
  bool carregando = false;

  // Carrega todas as receitas do banco e aplica os filtros atuais
  Future<void> carregar() async {
    carregando = true;
    notifyListeners();
    _todas = await _service.carregarTodas();
    carregando = false;
    _aplicarFiltros();
  }

  void atualizarQuery(String q) {
    query = q;
    _aplicarFiltros();
  }

  void atualizarCategoria(String c) {
    categoria = c;
    _aplicarFiltros();
  }

  void atualizarTempo(String label) {
    tempoLabel = label;
    _aplicarFiltros();
  }

  Future<void> toggleFavorito(String id, bool novoFavorito) async {
    await _service.toggleFavorito(id, novoFavorito);
    await carregar();
  }

  // Delega a filtragem ao ReceitaService e notifica a UI com os novos resultados
  void _aplicarFiltros() {
    resultados = _service.filtrar(
      _todas,
      query: query,
      categoria: categoria,
      tempoLabel: tempoLabel,
    );
    notifyListeners();
  }
}
