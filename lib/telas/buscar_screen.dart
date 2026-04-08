import 'package:flutter/material.dart';
import '../modelos/receita.dart';
import '../database/db_helper.dart';
import '../widgets/app_theme.dart';
import '../widgets/receita_card.dart';
import '../widgets/detalhes_sheet.dart';

const List<String> _categorias = [
  'Todos',
  'Café da manhã',
  'Almoço',
  'Jantar',
  'Lanche',
];

const List<Map<String, dynamic>> _tempos = [
  {'label': '5 min', 'value': 5},
  {'label': '15 min', 'value': 15},
  {'label': '30 min', 'value': 30},
  {'label': '1 hora', 'value': 60},
  {'label': '+1 hora', 'value': null},
];

class BuscarScreen extends StatefulWidget {
  const BuscarScreen({super.key});

  @override
  BuscarScreenState createState() => BuscarScreenState();
}

class BuscarScreenState extends State<BuscarScreen> {
  final _db = DBHelper();
  final _searchController = TextEditingController();

  List<Receita> _todasReceitas = [];
  List<Receita> _resultados = [];
  String _categoriaSelected = 'Todos';
  String _tempoLabelSelected = '+1 hora';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filtrar);
    reload();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> reload() async {
    final receitas = await _db.getReceitas();
    setState(() {
      _todasReceitas = receitas;
    });
    _filtrar();
  }

  void _filtrar() {
    final query = _searchController.text.toLowerCase().trim();
    final tempoMax = _tempos.firstWhere(
      (t) => t['label'] == _tempoLabelSelected,
      orElse: () => {'label': '+1 hora', 'value': null},
    )['value'] as int?;

    setState(() {
      _resultados = _todasReceitas.where((r) {
        final matchesSearch = query.isEmpty ||
            r.nome.toLowerCase().contains(query) ||
            r.ingredientes.any((i) => i.toLowerCase().contains(query));

        final matchesCategoria =
            _categoriaSelected == 'Todos' || r.categoria == _categoriaSelected;

        final matchesTempo = tempoMax == null || r.tempoPreparo <= tempoMax;

        return matchesSearch && matchesCategoria && matchesTempo;
      }).toList();
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
                    _filtrar();
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
          children: _categorias.map((cat) {
            final selected = cat == _categoriaSelected;
            return GestureDetector(
              onTap: () {
                setState(() => _categoriaSelected = cat);
                _filtrar();
              },
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
          children: _tempos.map((t) {
            final label = t['label'] as String;
            final selected = label == _tempoLabelSelected;
            return GestureDetector(
              onTap: () {
                setState(() => _tempoLabelSelected = label);
                _filtrar();
              },
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resultados (${_resultados.length})',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppTheme.preto,
          ),
        ),
        const SizedBox(height: 12),
        if (_resultados.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Icon(Icons.search_off,
                      size: 56, color: Colors.grey.shade300),
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
            itemCount: _resultados.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final receita = _resultados[index];
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
      ],
    );
  }
}
