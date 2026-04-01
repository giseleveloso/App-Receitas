import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../database/db_helper.dart';
import '../modelos/receita.dart';
import '../widgets/app_theme.dart';

const _categorias = ['Café da manhã', 'Almoço', 'Jantar', 'Lanche'];

class NovaReceitaScreen extends StatefulWidget {
  const NovaReceitaScreen({super.key});

  @override
  State<NovaReceitaScreen> createState() => _NovaReceitaScreenState();
}

class _NovaReceitaScreenState extends State<NovaReceitaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _db = DBHelper();
  final _uuid = const Uuid();
  final _picker = ImagePicker();

  final _nomeCtrl = TextEditingController();
  final _tempoCtrl = TextEditingController(text: '15');
  final _porcoesCtrl = TextEditingController(text: '2');
  final _ingredienteCtrl = TextEditingController();
  final _passoCtrl = TextEditingController();

  String _categoria = 'Almoço';
  final List<String> _ingredientes = [];
  final List<String> _passos = [];
  File? _imagem;
  bool _salvando = false;

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _tempoCtrl.dispose();
    _porcoesCtrl.dispose();
    _ingredienteCtrl.dispose();
    _passoCtrl.dispose();
    super.dispose();
  }

  Future<void> _escolherImagem() async {
    final picked = await _picker.pickImage(
        source: ImageSource.gallery, maxWidth: 800, imageQuality: 80);
    if (picked != null) setState(() => _imagem = File(picked.path));
  }

  void _addIngrediente() {
    final t = _ingredienteCtrl.text.trim();
    if (t.isEmpty) return;
    setState(() {
      _ingredientes.add(t);
      _ingredienteCtrl.clear();
    });
  }

  void _addPasso() {
    final t = _passoCtrl.text.trim();
    if (t.isEmpty) return;
    setState(() {
      _passos.add(t);
      _passoCtrl.clear();
    });
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_ingredientes.isEmpty) {
      _snack('Adicione pelo menos um ingrediente.', Colors.orange);
      return;
    }
    if (_passos.isEmpty) {
      _snack('Adicione pelo menos um passo.', Colors.orange);
      return;
    }

    setState(() => _salvando = true);
    try {
      final receita = Receita(
        id: _uuid.v4(),
        nome: _nomeCtrl.text.trim(),
        categoria: _categoria,
        tempoPreparo: int.tryParse(_tempoCtrl.text) ?? 15,
        porcoes: int.tryParse(_porcoesCtrl.text) ?? 2,
        ingredientes: List.from(_ingredientes),
        modoPreparo: List.from(_passos),
        imagemPath: _imagem?.path,
        criadoEm: DateTime.now(),
      );
      await _db.inserir(receita);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _snack('Erro ao salvar: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  void _snack(String msg, Color cor) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), backgroundColor: cor));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Receita',
            style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: AppTheme.branco,
        foregroundColor: AppTheme.preto,
        elevation: 0,
      ),
      backgroundColor: AppTheme.cinzaFundo,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Foto ──────────────────────────────────────────
            GestureDetector(
              onTap: _escolherImagem,
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  color: AppTheme.laranjaClaro,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppTheme.laranja.withValues(alpha: 0.4), width: 2),
                ),
                child: _imagem != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(_imagem!,
                            fit: BoxFit.cover, width: double.infinity),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt_outlined,
                              size: 40, color: AppTheme.laranja),
                          SizedBox(height: 8),
                          Text('Adicionar foto',
                              style: TextStyle(
                                  color: AppTheme.laranja,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Nome ──────────────────────────────────────────
            TextFormField(
              controller: _nomeCtrl,
              decoration: _inputDeco('Nome da receita', 'Ex: Bolo de Caneca'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 12),

            // ── Tempo e Porções ───────────────────────────────
            Row(children: [
              Expanded(
                child: TextFormField(
                  controller: _tempoCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _inputDeco('Tempo (min)', '15'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _porcoesCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _inputDeco('Porções', '2'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
                ),
              ),
            ]),
            const SizedBox(height: 16),

            // ── Categoria ─────────────────────────────────────
            const Text('Categoria',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.cinzaTexto)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categorias.map((c) {
                final sel = _categoria == c;
                return GestureDetector(
                  onTap: () => setState(() => _categoria = c),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? AppTheme.laranja : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(c,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: sel ? Colors.white : AppTheme.cinzaTexto)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // ── Ingredientes ──────────────────────────────────
            const Text('Ingredientes',
                style:
                    TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ..._ingredientes.asMap().entries.map((e) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.circle,
                      size: 8, color: AppTheme.laranja),
                  title: Text(e.value),
                  trailing: IconButton(
                    icon: const Icon(Icons.close,
                        size: 18, color: Colors.red),
                    onPressed: () =>
                        setState(() => _ingredientes.removeAt(e.key)),
                  ),
                )),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _ingredienteCtrl,
                  decoration:
                      _inputDeco('Adicione um por vez', 'Ex: 2 ovos'),
                  onSubmitted: (_) => _addIngrediente(),
                ),
              ),
              const SizedBox(width: 8),
              _btnAdd(_addIngrediente),
            ]),
            const SizedBox(height: 20),

            // ── Modo de preparo ───────────────────────────────
            const Text('Modo de preparo',
                style:
                    TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ..._passos.asMap().entries.map((e) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 12,
                    backgroundColor: AppTheme.laranja,
                    child: Text('${e.key + 1}',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 11)),
                  ),
                  title: Text(e.value),
                  trailing: IconButton(
                    icon: const Icon(Icons.close,
                        size: 18, color: Colors.red),
                    onPressed: () =>
                        setState(() => _passos.removeAt(e.key)),
                  ),
                )),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(
                child: TextField(
                  controller: _passoCtrl,
                  maxLines: 2,
                  decoration: _inputDeco(
                      'Adicione cronologicamente', 'Descreva o passo'),
                  onSubmitted: (_) => _addPasso(),
                ),
              ),
              const SizedBox(width: 8),
              _btnAdd(_addPasso),
            ]),
            const SizedBox(height: 28),

            // ── Botão salvar ──────────────────────────────────
            ElevatedButton(
              onPressed: _salvando ? null : _salvar,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.laranja,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: _salvando
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Salvar receita',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String label, String hint) => InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.laranja, width: 1.5),
        ),
      );

  Widget _btnAdd(VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppTheme.laranja,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      );
}
