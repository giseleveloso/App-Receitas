import 'package:app_exercicio_aula1/widgets/card_content.dart';
import 'package:flutter/material.dart';
import '../modelos/receita_externa.dart';
import '../services/meal_service.dart';
import 'app_theme.dart';

class ReceitaDoDiaCard extends StatefulWidget {
  const ReceitaDoDiaCard({super.key});

  @override
  State<ReceitaDoDiaCard> createState() => ReceitaDoDiaCardState();
}

class ReceitaDoDiaCardState extends State<ReceitaDoDiaCard> {
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
            CardContent(receita: _receita!),
        ],
      ),
    );
  }
}
