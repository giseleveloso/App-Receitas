import 'package:flutter/foundation.dart';
import '../modelos/receita.dart';
import '../services/receita_service.dart';

// Controller da tela de favoritos. Carrega somente as receitas marcadas como favorito.
class FavoritosController extends ChangeNotifier {
  final ReceitaService _service;

  FavoritosController(this._service);

  List<Receita> favoritos = [];
  bool carregando = false;

  Future<void> carregar() async {
    carregando = true;
    notifyListeners();
    favoritos = await _service.carregarDestaques();
    carregando = false;
    notifyListeners();
  }

  // Altera o favorito e recarrega a lista
  Future<void> toggleFavorito(String id, bool novoFavorito) async {
    await _service.toggleFavorito(id, novoFavorito);
    await carregar();
  }
}
