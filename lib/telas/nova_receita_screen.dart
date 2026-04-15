import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../database/db_helper.dart';
import '../modelos/receita.dart';
import '../widgets/app_theme.dart';

const _categorias = ['Café da manhã', 'Almoço', 'Jantar', 'Lanche'];

// Tela de formulário para cadastrar uma nova receita.
// O parâmetro [onSaved] é um callback chamado pelo MainNav após salvar,
// que redireciona para a home e atualiza as outras telas.
class NovaReceitaScreen extends StatefulWidget {
  final VoidCallback? onSaved;

  const NovaReceitaScreen({super.key, this.onSaved});

  @override
  State<NovaReceitaScreen> createState() => NovaReceitaScreenState();
}

class NovaReceitaScreenState extends State<NovaReceitaScreen> {
  // Chave do formulário — usada para acionar a validação de todos os campos de uma vez
  final _formKey = GlobalKey<FormState>();
  final _db = DBHelper();
  final _uuid = const Uuid(); // gera IDs únicos para cada receita
  final _picker = ImagePicker();

  // Controllers leem e escrevem nos campos de texto
  final _nomeCtrl = TextEditingController();
  final _tempoCtrl = TextEditingController(text: '15');
  final _porcoesCtrl = TextEditingController(text: '2');
  final _ingredienteCtrl = TextEditingController();
  final _passoCtrl = TextEditingController();

  String _categoria = 'Almoço';
  final List<String> _ingredientes = []; // lista em memória, atualizada com setState
  final List<String> _passos = [];
  File? _imagem;
  bool _salvando = false; // desabilita o botão enquanto salva no banco

  @override
  void dispose() {
    // Libera os controllers da memória quando a tela é destruída
    _nomeCtrl.dispose();
    _tempoCtrl.dispose();
    _porcoesCtrl.dispose();
    _ingredienteCtrl.dispose();
    _passoCtrl.dispose();
    super.dispose();
  }

  // Limpa todos os campos do formulário.
  // Chamado pelo MainNav após salvar com sucesso, antes de voltar para a home.
  void reset() {
    _formKey.currentState?.reset();
    setState(() {
      _nomeCtrl.clear();
      _tempoCtrl.text = '15';
      _porcoesCtrl.text = '2';
      _ingredienteCtrl.clear();
      _passoCtrl.clear();
      _categoria = 'Almoço';
      _ingredientes.clear();
      _passos.clear();
      _imagem = null;
      _salvando = false;
    });
  }

  // Abre a galeria do dispositivo para o usuário escolher uma foto
  Future<void> _escolherImagem() async {
    final picked = await _picker.pickImage(
        source: ImageSource.gallery, maxWidth: 800, imageQuality: 80);
    if (picked != null) setState(() => _imagem = File(picked.path));
  }

  // Adiciona o texto do campo de ingrediente à lista e limpa o campo
  void _addIngrediente() {
    final t = _ingredienteCtrl.text.trim();
    if (t.isEmpty) return;
    setState(() {
      _ingredientes.add(t);
      _ingredienteCtrl.clear();
    });
  }

  // Adiciona o texto do campo de passo à lista e limpa o campo
  void _addPasso() {
    final t = _passoCtrl.text.trim();
    if (t.isEmpty) return;
    setState(() {
      _passos.add(t);
      _passoCtrl.clear();
    });
  }

  // Valida o formulário, monta o objeto Receita e salva no banco de dados
  Future<void> _salvar() async {
    // Aciona os validators de todos os TextFormFields
    if (!_formKey.currentState!.validate()) return;

    // Validações extras que o Form não cobre (listas não vazias)
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
        id: _uuid.v4(), // ID único gerado automaticamente
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

      if (!mounted) return;
      // Se veio do MainNav, chama o callback; senão, fecha a tela com Navigator
      if (widget.onSaved != null) {
        widget.onSaved!();
      } else {
        Navigator.pop(context, true);
      }
    } catch (e) {
      _snack('Erro ao salvar: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  // Exibe uma mensagem rápida (snackbar) na parte inferior da tela
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
      // Form agrupa todos os campos e permite validar todos de uma vez com _formKey
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [

            // ── Foto ──────────────────────────────────────────
            // Toque abre a galeria; mostra a imagem escolhida ou um botão de adicionar
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
            // Dois campos lado a lado usando Row + Expanded
            Row(children: [
              Expanded(
                child: TextFormField(
                  controller: _tempoCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _inputDeco('Tempo ', '15'),
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
            // Chips de seleção única — o selecionado fica laranja
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
            // Lista dinâmica: cada item adicionado aparece com botão de remover (X)
            const Text('Ingredientes',
                style:
                    TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            // asMap().entries fornece índice (e.key) e valor (e.value) para cada item
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
            // Campo de entrada + botão "+" para adicionar à lista
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _ingredienteCtrl,
                  decoration:
                      _inputDeco('Adicione um por vez', 'Ex: 2 ovos'),
                  onSubmitted: (_) => _addIngrediente(), // permite confirmar pelo teclado
                ),
              ),
              const SizedBox(width: 8),
              _btnAdd(_addIngrediente),
            ]),
            const SizedBox(height: 20),

            // ── Modo de preparo ───────────────────────────────
            // Igual aos ingredientes, mas os itens são numerados sequencialmente
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
                    child: Text('${e.key + 1}', // número do passo
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
            // Fica desabilitado e mostra um spinner enquanto o salvamento está em andamento
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

  // Estilo padrão para todos os campos de texto do formulário
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

  // Botão "+" quadrado laranja usado ao lado dos campos de ingrediente e passo
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
