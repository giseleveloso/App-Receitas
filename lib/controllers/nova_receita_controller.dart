import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../modelos/receita.dart';
import '../services/receita_service.dart';

class NovaReceitaController extends ChangeNotifier {
  final ReceitaService _service;
  final _picker = ImagePicker();
  final _uuid = const Uuid();

  NovaReceitaController(this._service);

  String categoria = 'Almoço';
  List<String> ingredientes = [];
  List<String> passos = [];
  File? imagem;
  bool salvando = false;

  Future<void> escolherImagem() async {
    final picked = await _picker.pickImage(
        source: ImageSource.gallery, maxWidth: 800, imageQuality: 80);
    if (picked != null) {
      imagem = File(picked.path);
      notifyListeners();
    }
  }

  void addIngrediente(String texto) {
    final t = texto.trim();
    if (t.isEmpty) return;
    ingredientes.add(t);
    notifyListeners();
  }

  void removerIngrediente(int index) {
    ingredientes.removeAt(index);
    notifyListeners();
  }

  void addPasso(String texto) {
    final t = texto.trim();
    if (t.isEmpty) return;
    passos.add(t);
    notifyListeners();
  }

  void removerPasso(int index) {
    passos.removeAt(index);
    notifyListeners();
  }

  void atualizarCategoria(String c) {
    categoria = c;
    notifyListeners();
  }

  Future<void> salvar({
    required String nome,
    required String tempo,
    required String porcoes,
    required VoidCallback onSucesso,
    required void Function(String) onErro,
  }) async {
    salvando = true;
    notifyListeners();
    try {
      final receita = Receita(
        id: _uuid.v4(),
        nome: nome.trim(),
        categoria: categoria,
        tempoPreparo: int.tryParse(tempo) ?? 15,
        porcoes: int.tryParse(porcoes) ?? 2,
        ingredientes: List.from(ingredientes),
        modoPreparo: List.from(passos),
        imagemPath: imagem?.path,
        criadoEm: DateTime.now(),
      );
      await _service.salvar(receita);
      onSucesso();
    } catch (e) {
      onErro('Erro ao salvar: $e');
    } finally {
      salvando = false;
      notifyListeners();
    }
  }

  void reset() {
    categoria = 'Almoço';
    ingredientes.clear();
    passos.clear();
    imagem = null;
    salvando = false;
    notifyListeners();
  }
}
