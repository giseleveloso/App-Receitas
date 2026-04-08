import 'package:flutter/material.dart';
import '../widgets/app_theme.dart';
import 'home_screen.dart';
import 'favoritos_screen.dart';
import 'buscar_screen.dart';
import 'nova_receita_screen.dart';

class MainNav extends StatefulWidget {
  const MainNav({super.key});

  @override
  State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  int _selectedIndex = 0;

  final _homeKey = GlobalKey<HomeScreenState>();
  final _favoritosKey = GlobalKey<FavoritosScreenState>();
  final _buscarKey = GlobalKey<BuscarScreenState>();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeScreen(key: _homeKey),
      FavoritosScreen(key: _favoritosKey),
      BuscarScreen(key: _buscarKey),
    ];
  }

  Future<void> _onTabTapped(int index) async {
    if (index == 3) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const NovaReceitaScreen()),
      );
      _homeKey.currentState?.reload();
      _favoritosKey.currentState?.reload();
      _buscarKey.currentState?.reload();
      return;
    }

    setState(() => _selectedIndex = index);

    if (index == 0) _homeKey.currentState?.reload();
    if (index == 1) _favoritosKey.currentState?.reload();
    if (index == 2) _buscarKey.currentState?.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
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
