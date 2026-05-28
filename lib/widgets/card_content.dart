import 'package:app_exercicio_aula1/widgets/detalhes_externos_sheet.dart';
import 'package:app_exercicio_aula1/widgets/imagem_receita.dart';
import 'package:flutter/material.dart';
import '../modelos/receita_externa.dart';
import 'app_theme.dart';

class CardContent extends StatelessWidget {
  final ReceitaExterna receita;
  const CardContent({super.key, required this.receita});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => DetalhesExternosSheet(receita: receita),
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
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(16)),
              child: ImagemReceita(path: receita.imagemUrl, width: 110, height: 110),
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
