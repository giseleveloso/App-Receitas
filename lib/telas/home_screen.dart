import 'package:app_exercicio_aula1/widgets/imagem_receita.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../modelos/receita.dart';
import '../database/db_helper.dart';
import '../widgets/app_theme.dart';
import '../widgets/receita_card.dart';
import '../widgets/detalhes_sheet.dart';
import 'nova_receita_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _db = DBHelper();

  List<Receita> _destaques = [];
  List<Receita> _todasReceitas = [];
  int _carouselIndex = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _loading = true);
    final destaques = await _db.getDestaques();
    final todas = await _db.getReceitas();
    setState(() {
      _destaques = destaques;
      _todasReceitas = todas;
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
        onFavoritoChanged: _carregar,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cinzaFundo,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.laranja,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NovaReceitaScreen()),
          );
          _carregar();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.laranja))
          : RefreshIndicator(
              onRefresh: _carregar,
              color: AppTheme.laranja,
              child: CustomScrollView(
                slivers: [
                  _buildAppBar(),
                  SliverToBoxAdapter(child: _buildCarrossel()),
                  SliverToBoxAdapter(child: _buildSecaoTodasReceitas()),
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
            ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 100,
      backgroundColor: AppTheme.branco,
      flexibleSpace: const FlexibleSpaceBar(
        titlePadding: EdgeInsets.fromLTRB(20, 0, 20, 16),
        title: Text(
          'Receitas Rápidas',
          style: TextStyle(
            color: AppTheme.preto,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildCarrossel() {
    if (_destaques.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Row(
            children: [
              Icon(Icons.star_rounded, color: AppTheme.laranja, size: 20),
              SizedBox(width: 6),
              Text(
                'Em destaque',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.laranja,
                ),
              ),
            ],
          ),
        ),
        CarouselSlider.builder(
          itemCount: _destaques.length,
          itemBuilder: (context, index, realIndex) {
            final receita = _destaques[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: GestureDetector(
                onTap: () => _abrirDetalhe(receita),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ImagemReceita(
                        path: receita.imagemPath,
                        width: double.infinity,
                        height: 200,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              receita.nome,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.access_time,
                                    size: 14, color: Colors.white70),
                                const SizedBox(width: 4),
                                Text(
                                  '${receita.tempoFormatado} · ${receita.categoria}',
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          options: CarouselOptions(
            height: 200,
            viewportFraction: 0.85,
            enableInfiniteScroll: _destaques.length > 1,
            autoPlay: _destaques.length > 1,
            autoPlayInterval: const Duration(seconds: 4),
            onPageChanged: (index, _) => setState(() => _carouselIndex = index),
          ),
        ),
        if (_destaques.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _destaques.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _carouselIndex == i ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _carouselIndex == i
                        ? AppTheme.laranja
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSecaoTodasReceitas() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Todas as receitas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          if (_todasReceitas.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.restaurant_menu,
                        size: 60, color: AppTheme.cinzaTexto),
                    SizedBox(height: 12),
                    Text(
                      'Nenhuma receita ainda.\nToque em + para adicionar!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.cinzaTexto),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _todasReceitas.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final receita = _todasReceitas[index];
                return SizedBox(
                  height: 90,
                  child: ReceitaCard(
                    receita: receita,
                    compacto: true,
                    onTap: () => _abrirDetalhe(receita),
                    onFavoritoChanged: _carregar,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

