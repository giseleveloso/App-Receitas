import 'package:app_exercicio_aula1/widgets/imagem_receita.dart';
import 'package:flutter/material.dart';
import '../modelos/receita.dart';
import '../database/db_helper.dart';
import 'app_theme.dart';

// Card reutilizável para exibir uma receita em listas.
// Usado em: HomeScreen, FavoritosScreen e BuscarScreen.
// O parâmetro [compacto] controla o tamanho da imagem (menor em listas densas).
// O parâmetro [onFavoritoChanged] é opcional — se não for passado, o ícone de favorito não aparece.
class ReceitaCard extends StatelessWidget {
  final Receita receita;
  final bool compacto;
  final VoidCallback onTap;
  final VoidCallback? onFavoritoChanged;

  const ReceitaCard({
    super.key,
    required this.receita,
    required this.onTap,
    this.compacto = false,
    this.onFavoritoChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.branco,
          borderRadius: BorderRadius.circular(14),
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
            // Imagem da receita com bordas arredondadas apenas no lado esquerdo
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                bottomLeft: Radius.circular(14),
              ),
              child: ImagemReceita(
                path: receita.imagemPath,
                width: compacto ? 90 : 110,
                height: compacto ? 90 : 110,
              ),
            ),

            // Nome e informações da receita
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      receita.nome,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis, // adiciona "..." se o nome for longo
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${receita.tempoFormatado} · ${receita.categoria}',
                      style: const TextStyle(
                          color: AppTheme.cinzaTexto, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),

            // Botão de favorito — só aparece se onFavoritoChanged foi fornecido
            if (onFavoritoChanged != null)
              IconButton(
                icon: Icon(
                  receita.favorito ? Icons.favorite : Icons.favorite_border,
                  color: receita.favorito
                      ? AppTheme.laranja
                      : AppTheme.cinzaTexto,
                ),
                onPressed: () async {
                  // Inverte o estado de favorito no banco e notifica a tela pai
                  await DBHelper().toggleFavorito(receita.id, !receita.favorito);
                  onFavoritoChanged!();
                },
              ),
          ],
        ),
      ),
    );
  }
}
