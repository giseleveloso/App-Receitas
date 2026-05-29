import 'package:flutter/material.dart';
import '../widgets/app_theme.dart';
import '../services/receita_service.dart';
import '../controllers/home_controller.dart';
import '../controllers/favoritos_controller.dart';
import '../controllers/buscar_controller.dart';
import '../controllers/nova_receita_controller.dart';
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

  final _service = ReceitaService();

  late final HomeController _homeController;
  late final FavoritosController _favoritosController;
  late final BuscarController _buscarController;
  late final NovaReceitaController _novaReceitaController;

  final _novaReceitaKey = GlobalKey<NovaReceitaScreenState>();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _homeController = HomeController(_service);
    _favoritosController = FavoritosController(_service);
    _buscarController = BuscarController(_service);
    _novaReceitaController = NovaReceitaController(_service);

    _pages = [
      HomeScreen(controller: _homeController),
      FavoritosScreen(controller: _favoritosController),
      BuscarScreen(controller: _buscarController),
      NovaReceitaScreen(
        key: _novaReceitaKey,
        controller: _novaReceitaController,
        onSaved: _onReceitaSalva,
      ),
    ];
  }

  @override
  void dispose() {
    _homeController.dispose();
    _favoritosController.dispose();
    _buscarController.dispose();
    _novaReceitaController.dispose();
    super.dispose();
  }

  // Chamado quando uma nova receita é salva: reseta o formulário,
  // recarrega todas as telas e volta para a home.
  void _onReceitaSalva() {
    _novaReceitaKey.currentState?.reset();
    _homeController.carregar();
    _favoritosController.carregar();
    _buscarController.carregar();
    setState(() => _selectedIndex = 0);
  }

  // Recarrega os dados da aba selecionada ao navegar para ela
  void _onTabTapped(int index) {
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        _homeController.carregar();
      case 1:
        _favoritosController.carregar();
      case 2:
        _buscarController.carregar();
    }
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
