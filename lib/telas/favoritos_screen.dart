import 'package:flutter/material.dart';
import '../modelos/receita.dart';
import '../controllers/favoritos_controller.dart';
import '../widgets/app_theme.dart';
import '../widgets/receita_card.dart';
import '../widgets/detalhes_sheet.dart';

class FavoritosScreen extends StatefulWidget {
  final FavoritosController controller;

  const FavoritosScreen({super.key, required this.controller});

  @override
  FavoritosScreenState createState() => FavoritosScreenState();
}

class FavoritosScreenState extends State<FavoritosScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onUpdate);
    widget.controller.carregar();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() => setState(() {});

  void _abrirDetalhe(Receita receita) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DetalheSheet(
        receita: receita,
        onFavoritoChanged: widget.controller.carregar,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return Scaffold(
      backgroundColor: AppTheme.cinzaFundo,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
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
            Expanded(
              child: c.carregando
                  ? const Center(
                      child: CircularProgressIndicator(color: AppTheme.laranja),
                    )
                  : c.favoritos.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: c.carregar,
                          color: AppTheme.laranja,
                          child: ListView.separated(
                            padding: const EdgeInsets.all(20),
                            itemCount: c.favoritos.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final receita = c.favoritos[index];
                              return SizedBox(
                                height: 90,
                                child: ReceitaCard(
                                  receita: receita,
                                  compacto: true,
                                  onTap: () => _abrirDetalhe(receita),
                                  onFavoritoChanged: c.toggleFavorito,
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_outline, size: 72, color: Colors.grey.shade300),
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
