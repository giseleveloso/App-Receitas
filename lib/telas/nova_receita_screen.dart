import 'package:flutter/material.dart';
import '../controllers/nova_receita_controller.dart';
import '../widgets/app_theme.dart';
import '../constantes/filtros.dart';

class NovaReceitaScreen extends StatefulWidget {
  final NovaReceitaController controller;
  final VoidCallback? onSaved;

  const NovaReceitaScreen(
      {super.key, required this.controller, this.onSaved});

  @override
  State<NovaReceitaScreen> createState() => NovaReceitaScreenState();
}

class NovaReceitaScreenState extends State<NovaReceitaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _tempoCtrl = TextEditingController(text: '15');
  final _porcoesCtrl = TextEditingController(text: '2');
  final _ingredienteCtrl = TextEditingController();
  final _passoCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onUpdate);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onUpdate);
    _nomeCtrl.dispose();
    _tempoCtrl.dispose();
    _porcoesCtrl.dispose();
    _ingredienteCtrl.dispose();
    _passoCtrl.dispose();
    super.dispose();
  }

  void _onUpdate() => setState(() {});

  // Chamado pelo MainNav após salvar com sucesso — limpa formulário e estado do controller
  void reset() {
    widget.controller.reset();
    _formKey.currentState?.reset();
    _nomeCtrl.clear();
    _tempoCtrl.text = '15';
    _porcoesCtrl.text = '2';
    _ingredienteCtrl.clear();
    _passoCtrl.clear();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final c = widget.controller;
    if (c.ingredientes.isEmpty) {
      _snack('Adicione pelo menos um ingrediente.', Colors.orange);
      return;
    }
    if (c.passos.isEmpty) {
      _snack('Adicione pelo menos um passo.', Colors.orange);
      return;
    }

    await c.salvar(
      nome: _nomeCtrl.text,
      tempo: _tempoCtrl.text,
      porcoes: _porcoesCtrl.text,
      onSucesso: () {
        if (widget.onSaved != null) {
          widget.onSaved!();
        } else if (mounted) {
          Navigator.pop(context, true);
        }
      },
      onErro: (msg) => _snack(msg, Colors.red),
    );
  }

  void _snack(String msg, Color cor) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), backgroundColor: cor));
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
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
              onTap: c.escolherImagem,
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  color: AppTheme.laranjaClaro,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppTheme.laranja.withValues(alpha: 0.4), width: 2),
                ),
                child: c.imagem != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(c.imagem!,
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
            const Text('Categoria',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.cinzaTexto)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categorias.map((cat) {
                final sel = c.categoria == cat;
                return GestureDetector(
                  onTap: () => c.atualizarCategoria(cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? AppTheme.laranja : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(cat,
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
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ...c.ingredientes.asMap().entries.map((e) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.circle,
                      size: 8, color: AppTheme.laranja),
                  title: Text(e.value),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, size: 18, color: Colors.red),
                    onPressed: () => c.removerIngrediente(e.key),
                  ),
                )),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _ingredienteCtrl,
                  decoration: _inputDeco('Adicione um por vez', 'Ex: 2 ovos'),
                  onSubmitted: (_) {
                    c.addIngrediente(_ingredienteCtrl.text);
                    _ingredienteCtrl.clear();
                  },
                ),
              ),
              const SizedBox(width: 8),
              _btnAdd(() {
                c.addIngrediente(_ingredienteCtrl.text);
                _ingredienteCtrl.clear();
              }),
            ]),
            const SizedBox(height: 20),

            // ── Modo de preparo ───────────────────────────────
            const Text('Modo de preparo',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ...c.passos.asMap().entries.map((e) => ListTile(
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
                    icon: const Icon(Icons.close, size: 18, color: Colors.red),
                    onPressed: () => c.removerPasso(e.key),
                  ),
                )),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(
                child: TextField(
                  controller: _passoCtrl,
                  maxLines: 2,
                  decoration: _inputDeco(
                      'Adicione cronologicamente', 'Descreva o passo'),
                  onSubmitted: (_) {
                    c.addPasso(_passoCtrl.text);
                    _passoCtrl.clear();
                  },
                ),
              ),
              const SizedBox(width: 8),
              _btnAdd(() {
                c.addPasso(_passoCtrl.text);
                _passoCtrl.clear();
              }),
            ]),
            const SizedBox(height: 28),

            // ── Botão salvar ──────────────────────────────────
            ElevatedButton(
              onPressed: c.salvando ? null : _salvar,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.laranja,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: c.salvando
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
