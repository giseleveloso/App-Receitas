import 'package:flutter/foundation.dart';
import '../modelos/receita.dart';
import '../services/receita_service.dart';

class HomeController extends ChangeNotifier {
  final ReceitaService _service;

  HomeController(this._service);

  List<Receita> destaques = [];
  List<Receita> todasReceitas = [];
  bool carregando = false;

  Future<void> carregar() async {
    carregando = true;
    notifyListeners();
    destaques = await _service.carregarDestaques();
    todasReceitas = await _service.carregarTodas();
    carregando = false;
    notifyListeners();
  }

  Future<void> toggleFavorito(String id, bool novoFavorito) async {
    await _service.toggleFavorito(id, novoFavorito);
    await carregar();
  }
}
