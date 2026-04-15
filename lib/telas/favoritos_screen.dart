import 'package:flutter/material.dart';
import '../modelos/receita.dart';
import '../database/db_helper.dart';
import '../widgets/app_theme.dart';
import '../widgets/receita_card.dart';
import '../widgets/detalhes_sheet.dart';

// Tela que exibe apenas as receitas marcadas como favorito.
// É StatefulWidget porque a lista pode mudar enquanto o app está aberto
// (ex: usuário desfavorita uma receita no painel de detalhes).
class FavoritosScreen extends StatefulWidget {
  const FavoritosScreen({super.key});

  @override
  FavoritosScreenState createState() => FavoritosScreenState();
}

class FavoritosScreenState extends State<FavoritosScreen> {
  final _db = DBHelper();
  List<Receita> _favoritos = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    reload();
  }

  // Exposto publicamente para que o MainNav possa recarregar ao trocar de aba
  Future<void> reload() async {
    setState(() => _loading = true);
    final favoritos = await _db.getDestaques(); // busca apenas as marcadas como favorito
    setState(() {
      _favoritos = favoritos;
      _loading = false;
    });
  }

  // Abre o painel de detalhes e recarrega a lista se o favorito mudar
  void _abrirDetalhe(Receita receita) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DetalheSheet(
        receita: receita,
        onFavoritoChanged: reload,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cinzaFundo,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header fixo no topo com fundo branco
            Container(
              width: double.infinity, // garante que o fundo se estende até a borda
              color: AppTheme.branco,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: const Text(
                'Favoritos',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.preto,
                ),
              ),
            ),

            // Conteúdo principal: loading, estado vazio ou lista de favoritos
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppTheme.laranja),
                    )
                  : _favoritos.isEmpty
                      ? _buildEmptyState()
                      // RefreshIndicator permite puxar para recarregar
                      : RefreshIndicator(
                          onRefresh: reload,
                          color: AppTheme.laranja,
                          child: ListView.separated(
                            padding: const EdgeInsets.all(20),
                            itemCount: _favoritos.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final receita = _favoritos[index];
                              return SizedBox(
                                height: 90,
                                child: ReceitaCard(
                                  receita: receita,
                                  compacto: true,
                                  onTap: () => _abrirDetalhe(receita),
                                  onFavoritoChanged: reload,
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // Exibido quando não há nenhuma receita favoritada ainda
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_outline,
              size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            'Nenhum favorito ainda.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.cinzaTexto,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Toque no coração de uma receita\npara adicioná-la aqui.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.cinzaTexto, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
