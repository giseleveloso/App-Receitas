import 'package:flutter/foundation.dart';
import '../modelos/receita.dart';
import '../services/receita_service.dart';

class HomeController extends ChangeNotifier {
  final ReceitaService _service;

  HomeController(this._service);

  List<Receita> destaques = []; // receitas favoritadas (exibidas no carrossel)
  List<Receita> todasReceitas =
      []; // todas as receitas (exibidas na lista abaixo)
  bool carregando = false;

  // Busca destaques e todas as receitas e notifica a UI
  Future<void> carregar() async {
    carregando = true;
    notifyListeners();
    destaques = await _service.carregarDestaques();
    todasReceitas = await _service.carregarTodas();
    carregando = false;
    notifyListeners();
  }

  // Alterna o favorito e recarrega a lista para refletir a mudança na UI
  Future<void> toggleFavorito(String id, bool novoFavorito) async {
    await _service.toggleFavorito(id, novoFavorito);
    await carregar();
  }
}
