import 'package:flutter/material.dart';
import '../modelos/receita.dart';
import '../controllers/buscar_controller.dart';
import '../widgets/app_theme.dart';
import '../widgets/receita_card.dart';
import '../widgets/detalhes_sheet.dart';
import '../constantes/filtros.dart';

class BuscarScreen extends StatefulWidget {
  final BuscarController controller;

  const BuscarScreen({super.key, required this.controller});

  @override
  BuscarScreenState createState() => BuscarScreenState();
}

class BuscarScreenState extends State<BuscarScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onUpdate);
    // Listener no campo de texto: repassa cada digitação ao controller para filtrar em tempo real
    _searchController.addListener(
        () => widget.controller.atualizarQuery(_searchController.text));
    widget.controller.carregar();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onUpdate);
    _searchController.dispose();
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
    return Scaffold(
      backgroundColor: AppTheme.cinzaFundo,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildCampoBusca(),
                    const SizedBox(height: 24),
                    _buildFiltroCategoria(),
                    const SizedBox(height: 20),
                    _buildFiltroTempo(),
                    const SizedBox(height: 24),
                    _buildResultados(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: AppTheme.branco,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: const Text(
        'Buscar',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: AppTheme.preto,
        ),
      ),
    );
  }

  Widget _buildCampoBusca() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.branco,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar por nome ou ingredientes',
          hintStyle: const TextStyle(color: AppTheme.cinzaTexto, fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: AppTheme.cinzaTexto),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, color: AppTheme.cinzaTexto),
                  onPressed: () {
                    _searchController.clear();
                    widget.controller.atualizarQuery('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFiltroCategoria() {
    final categoriaAtual = widget.controller.categoria;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categoria',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppTheme.preto,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['Todos', ...categorias].map((cat) {
            final selected = cat == categoriaAtual;
            return GestureDetector(
              onTap: () => widget.controller.atualizarCategoria(cat),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? AppTheme.laranja : AppTheme.branco,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : AppTheme.preto,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFiltroTempo() {
    final tempoAtual = widget.controller.tempoLabel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tempo máximo',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppTheme.preto,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: temposFiltro.map((t) {
            final label = t['label'] as String;
            final selected = label == tempoAtual;
            return GestureDetector(
              onTap: () => widget.controller.atualizarTempo(label),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? AppTheme.laranja : AppTheme.branco,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : AppTheme.preto,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildResultados() {
    final resultados = widget.controller.resultados;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resultados (${resultados.length})',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppTheme.preto,
          ),
        ),
        const SizedBox(height: 12),
        if (resultados.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Icon(Icons.search_off, size: 56, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  const Text(
                    'Nenhuma receita encontrada.',
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
            itemCount: resultados.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final receita = resultados[index];
              return SizedBox(
                height: 90,
                child: ReceitaCard(
                  receita: receita,
                  compacto: true,
                  onTap: () => _abrirDetalhe(receita),
                  onFavoritoChanged: widget.controller.toggleFavorito,
                ),
              );
            },
          ),
      ],
    );
  }
}
