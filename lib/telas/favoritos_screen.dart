import 'package:flutter/material.dart';
import '../modelos/receita.dart';
import '../database/db_helper.dart';
import '../widgets/app_theme.dart';
import '../widgets/receita_card.dart';
import '../widgets/detalhes_sheet.dart';

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

  Future<void> reload() async {
    setState(() => _loading = true);
    final favoritos = await _db.getDestaques();
    setState(() {
      _favoritos = favoritos;
      _loading = false;
    });
  }

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
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppTheme.laranja),
                    )
                  : _favoritos.isEmpty
                      ? _buildEmptyState()
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
