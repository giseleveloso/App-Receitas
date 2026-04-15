import 'package:flutter/material.dart';
import '../widgets/app_theme.dart';
import 'home_screen.dart';
import 'favoritos_screen.dart';
import 'buscar_screen.dart';
import 'nova_receita_screen.dart';

// Widget principal da navegação do app.
// É StatefulWidget porque precisa guardar e atualizar o índice da aba ativa.
class MainNav extends StatefulWidget {
  const MainNav({super.key});

  @override
  State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  // Guarda qual aba está selecionada (0 = Início, 1 = Favoritos, 2 = Buscar, 3 = Novo)
  int _selectedIndex = 0;

  // GlobalKeys permitem acessar os métodos internos de cada tela a partir daqui.
  // Por exemplo: chamar reload() na HomeScreen quando necessário.
  final _homeKey = GlobalKey<HomeScreenState>();
  final _favoritosKey = GlobalKey<FavoritosScreenState>();
  final _buscarKey = GlobalKey<BuscarScreenState>();
  final _novaReceitaKey = GlobalKey<NovaReceitaScreenState>();

  // Lista das 4 telas do app. É criada uma única vez no initState.
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    // Instancia cada tela com sua respectiva key e, no caso da NovaReceita,
    // passa um callback para ser chamado quando o usuário salvar uma receita.
    _pages = [
      HomeScreen(key: _homeKey),
      FavoritosScreen(key: _favoritosKey),
      BuscarScreen(key: _buscarKey),
      NovaReceitaScreen(key: _novaReceitaKey, onSaved: _onReceitaSalva),
    ];
  }

  // Chamado automaticamente quando uma nova receita é salva.
  // Limpa o formulário, atualiza todas as telas com os dados mais recentes
  // e redireciona o usuário de volta para a tela inicial.
  void _onReceitaSalva() {
    _novaReceitaKey.currentState?.reset();
    _homeKey.currentState?.reload();
    _favoritosKey.currentState?.reload();
    _buscarKey.currentState?.reload();
    setState(() => _selectedIndex = 0);
  }

  // Chamado quando o usuário toca em uma aba da barra inferior.
  // Atualiza o índice e recarrega os dados da tela selecionada.
  void _onTabTapped(int index) {
    setState(() => _selectedIndex = index);

    if (index == 0) _homeKey.currentState?.reload();
    if (index == 1) _favoritosKey.currentState?.reload();
    if (index == 2) _buscarKey.currentState?.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack mantém todas as telas "vivas" na memória,
      // mostrando apenas a do índice selecionado. Isso evita recriar
      // as telas toda vez que o usuário troca de aba.
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      // Barra de navegação inferior com 4 abas.
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.laranja,
        unselectedItemColor: AppTheme.cinzaTexto,
        backgroundColor: AppTheme.branco,
        elevation: 12,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),

        // Cada item define ícone normal, ícone ativo (quando selecionado) e label.
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            activeIcon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded),
            activeIcon: Icon(Icons.search_rounded),
            label: 'Buscar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'Novo',
          ),
        ],
      ),
    );
  }
}
