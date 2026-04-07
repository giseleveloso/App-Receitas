import 'package:app_exercicio_aula1/widgets/imagem_receita.dart';
import 'package:flutter/material.dart';
import '../modelos/receita.dart';
import 'app_theme.dart';

class DetalheSheet extends StatelessWidget {
  final Receita receita;
  final VoidCallback onFavoritoChanged;

  const DetalheSheet({super.key, required this.receita, required this.onFavoritoChanged});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet( //Abre deslizando de baixo
      initialChildSize: 0.75, //começa ocupando 75%
      maxChildSize: 0.95, // pode expandir até 95%
      minChildSize: 0.5, //pode encolher até 50%
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
                  path: receita.imagemPath,
                  width: double.infinity,
                  height: 180),
            ),
            const SizedBox(height: 16),
            Text(
              receita.nome,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _chip(Icons.access_time, receita.tempoFormatado),
                _chip(Icons.people_outline, '${receita.porcoes} porções'),
                _chip(Icons.restaurant_menu, receita.categoria),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Ingredientes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ...receita.ingredientes.map(
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
            ...receita.modoPreparo.asMap().entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: AppTheme.laranja,
                          child: Text(
                            '${e.key + 1}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(e.value),
                          ),
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
