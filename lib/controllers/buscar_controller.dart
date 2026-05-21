import 'package:flutter/foundation.dart';
import '../modelos/receita.dart';
import '../services/receita_service.dart';

class BuscarController extends ChangeNotifier {
  final ReceitaService _service;

  BuscarController(this._service);

  List<Receita> _todas = [];
  List<Receita> resultados = [];
  String query = '';
  String categoria = 'Todos';
  String tempoLabel = '+1 hora';
  bool carregando = false;

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
