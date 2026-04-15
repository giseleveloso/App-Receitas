import 'package:flutter/material.dart';
import '../modelos/receita.dart';
import '../database/db_helper.dart';
import '../widgets/app_theme.dart';
import '../widgets/receita_card.dart';
import '../widgets/detalhes_sheet.dart';
import '../constantes/filtros.dart';

// Tela de busca com filtros por nome/ingrediente, categoria e tempo de preparo.
// É StatefulWidget porque mantém o estado do campo de busca e dos filtros selecionados.
class BuscarScreen extends StatefulWidget {
  const BuscarScreen({super.key});

  @override
  BuscarScreenState createState() => BuscarScreenState();
}

class BuscarScreenState extends State<BuscarScreen> {
  final _db = DBHelper();
  final _searchController = TextEditingController();

  List<Receita> _todasReceitas = []; // cópia local de todas as receitas do banco
  List<Receita> _resultados = [];    // subconjunto filtrado exibido na tela
  String _categoriaSelected = 'Todos';
  String _tempoLabelSelected = '+1 hora';

  @override
  void initState() {
    super.initState();
    // Sempre que o texto mudar, reaplica os filtros automaticamente
    _searchController.addListener(_filtrar);
    reload();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Exposto publicamente para que o MainNav possa recarregar ao trocar de aba
  Future<void> reload() async {
    final receitas = await _db.getReceitas();
    setState(() {
      _todasReceitas = receitas;
    });
    _filtrar();
  }

  // Aplica os três filtros (busca por texto, categoria e tempo) simultaneamente.
  // Atualiza _resultados com as receitas que passam em todos os critérios.
  void _filtrar() {
    final query = _searchController.text.toLowerCase().trim();
    // Busca o valor numérico correspondente ao label de tempo selecionado
    final tempoMax = temposFiltro.firstWhere(
      (t) => t['label'] == _tempoLabelSelected,
      orElse: () => {'label': '+1 hora', 'value': null},
    )['value'] as int?;

    setState(() {
      _resultados = _todasReceitas.where((r) {
        // Filtro de texto: verifica nome e cada ingrediente
        final matchesSearch = query.isEmpty ||
            r.nome.toLowerCase().contains(query) ||
            r.ingredientes.any((i) => i.toLowerCase().contains(query));

        // Filtro de categoria: "Todos" desativa o filtro
        final matchesCategoria =
            _categoriaSelected == 'Todos' || r.categoria == _categoriaSelected;

        // Filtro de tempo: tempoMax null = sem limite ("+1 hora")
        final matchesTempo = tempoMax == null || r.tempoPreparo <= tempoMax;

        return matchesSearch && matchesCategoria && matchesTempo;
      }).toList();
    });
  }

  // Abre o painel de detalhes e recarrega os resultados se o favorito mudar
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
            // Expanded + SingleChildScrollView fazem o conteúdo abaixo do header rolar
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

  // Header fixo no topo com fundo branco
  Widget _buildHeader() {
    return Container(
      width: double.infinity, // garante que o fundo se estende até a borda
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

  // Campo de texto com ícone de lupa e botão X para limpar a busca
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
          // Botão X aparece apenas quando há texto digitado
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

  // Chips de seleção de categoria — o chip selecionado fica laranja
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
          children: ['Todos', ...categorias].map((cat) {
            final selected = cat == _categoriaSelected;
            return GestureDetector(
              onTap: () {
                setState(() => _categoriaSelected = cat);
                _filtrar(); // reaplicar filtros ao trocar categoria
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

  // Chips de seleção de tempo máximo — funciona igual ao de categoria
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
          children: temposFiltro.map((t) {
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

  // Lista de receitas que passaram pelos filtros, com contador de resultados
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

        // Estado vazio: nenhuma receita passou pelos filtros
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
          // Lista não rolável (o scroll é feito pelo SingleChildScrollView pai)
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
