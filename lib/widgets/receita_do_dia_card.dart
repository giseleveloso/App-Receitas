import 'package:flutter/material.dart';
import '../modelos/receita_externa.dart';
import '../services/meal_service.dart';
import 'app_theme.dart';

class ReceitaDoDiaCard extends StatefulWidget {
  const ReceitaDoDiaCard({super.key});

  @override
  State<ReceitaDoDiaCard> createState() => _ReceitaDoDiaCardState();
}

class _ReceitaDoDiaCardState extends State<ReceitaDoDiaCard> {
  final _service = MealService();
  ReceitaExterna? _receita;
  bool _carregando = true;
  bool _erro = false;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = false;
    });
    final receita = await _service.buscarAleatoria();
    setState(() {
      _receita = receita;
      _carregando = false;
      _erro = receita == null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.wb_sunny_outlined,
                      color: AppTheme.laranja, size: 20),
                  SizedBox(width: 6),
                  Text(
                    'Receita do Dia',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.laranja),
                  ),
                ],
              ),
              IconButton(
                icon: _carregando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppTheme.laranja),
                      )
                    : const Icon(Icons.refresh_rounded,
                        color: AppTheme.laranja),
                onPressed: _carregando ? null : _carregar,
                tooltip: 'Nova receita',
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (_carregando)
            Container(
              height: 110,
              decoration: BoxDecoration(
                color: AppTheme.laranjaClaro,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: CircularProgressIndicator(color: AppTheme.laranja),
              ),
            )
          else if (_erro || _receita == null)
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.laranjaClaro,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: TextButton.icon(
                  onPressed: _carregar,
                  icon: const Icon(Icons.refresh, color: AppTheme.laranja),
                  label: const Text('Tentar novamente',
                      style: TextStyle(color: AppTheme.laranja)),
                ),
              ),
            )
          else
            _CardContent(receita: _receita!),
        ],
      ),
    );
  }
}

class _CardContent extends StatelessWidget {
  final ReceitaExterna receita;
  const _CardContent({required this.receita});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _DetalhesExternosSheet(receita: receita),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.branco,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(16)),
              child: Image.network(
                receita.imagemUrl,
                width: 110,
                height: 110,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 110,
                  height: 110,
                  color: AppTheme.laranjaClaro,
                  child: const Icon(Icons.restaurant,
                      color: AppTheme.laranja, size: 40),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      receita.nome,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${receita.categoria} · ${receita.area}',
                      style: const TextStyle(
                          color: AppTheme.cinzaTexto, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.list_alt_rounded,
                            size: 13, color: AppTheme.laranja),
                        const SizedBox(width: 4),
                        Text(
                          '${receita.ingredientes.length} ingredientes · toque para ver',
                          style: const TextStyle(
                              color: AppTheme.laranja,
                              fontSize: 11,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetalhesExternosSheet extends StatelessWidget {
  final ReceitaExterna receita;
  const _DetalhesExternosSheet({required this.receita});

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
              child: Image.network(
                receita.imagemUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(receita.nome,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _chip(Icons.restaurant_menu, receita.categoria),
                _chip(Icons.public, receita.area),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Ingredientes',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ...receita.ingredientes.map(
              (i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 6, right: 8),
                      child: Icon(Icons.circle,
                          size: 7, color: AppTheme.laranja),
                    ),
                    Expanded(child: Text(i)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Modo de preparo',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(receita.instrucoes,
                style: const TextStyle(height: 1.6, fontSize: 14)),
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
