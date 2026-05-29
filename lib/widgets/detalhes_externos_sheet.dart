import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../modelos/receita.dart';
import '../modelos/receita_externa.dart';
import '../services/receita_service.dart';
import 'app_theme.dart';
import 'imagem_receita.dart';

// Painel de detalhes de uma receita externa (TheMealDB)
class DetalhesExternosSheet extends StatefulWidget {
  final ReceitaExterna receita;
  const DetalhesExternosSheet({super.key, required this.receita});

  @override
  State<DetalhesExternosSheet> createState() => _DetalhesExternosSheetState();
}

class _DetalhesExternosSheetState extends State<DetalhesExternosSheet> {
  final _service = ReceitaService();
  bool _salvando = false;
  bool _salvo = false;

  // Converte a receita externa para o modelo interno e persiste no Supabase.
  Future<void> _salvar() async {
    setState(() => _salvando = true);
    try {
      final r = widget.receita;
      final passos = r.instrucoes
          .split(RegExp(r'\r?\n'))
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      await _service.salvar(Receita(
        id: const Uuid().v4(),
        nome: r.nome,
        categoria: r.categoria,
        tempoPreparo: 0,
        porcoes: 2,
        ingredientes: r.ingredientes,
        modoPreparo: passos.isNotEmpty ? passos : [r.instrucoes],
        imagemPath: r.imagemUrl,
        criadoEm: DateTime.now(),
      ));
      if (mounted) setState(() => _salvo = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ImagemReceita(
                  path: widget.receita.imagemUrl,
                  width: double.infinity,
                  height: 180),
            ),
            const SizedBox(height: 16),
            Text(widget.receita.nome,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _chip(Icons.restaurant_menu, widget.receita.categoria),
                _chip(Icons.public, widget.receita.area),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Ingredientes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ...widget.receita.ingredientes.map(
              (i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 6, right: 8),
                      child:
                          Icon(Icons.circle, size: 7, color: AppTheme.laranja),
                    ),
                    Expanded(child: Text(i)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Modo de preparo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(widget.receita.instrucoes,
                style: const TextStyle(height: 1.6, fontSize: 14)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _salvo || _salvando ? null : _salvar,
              icon: _salvando
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Icon(_salvo
                      ? Icons.check_rounded
                      : Icons.bookmark_add_outlined),
              label:
                  Text(_salvo ? 'Salva nas suas receitas!' : 'Salvar receita'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _salvo ? Colors.green : AppTheme.laranja,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.laranjaClaro,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.laranja),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.laranja,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
