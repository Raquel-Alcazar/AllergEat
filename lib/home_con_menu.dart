import 'package:allergeat/user.dart' as u;
import 'package:flutter/material.dart';
import 'busqueda_productos.dart';
import 'productos_favoritos.dart';
import 'perfil.dart';

class HomeConMenu extends StatefulWidget {
  final u.User usuario;
  final int paginaInicial;

  HomeConMenu({required this.usuario, this.paginaInicial = 0});

  @override
  _HomeConMenuState createState() => _HomeConMenuState();
}

class _HomeConMenuState extends State<HomeConMenu> {
  late int _paginaSeleccionada = 0;

  late List<Widget> _paginas;

    @override
  void initState() {
  super.initState();
  _paginaSeleccionada = widget.paginaInicial;
  _paginas = [
    BusquedaProductos(usuario: widget.usuario),
    FavoritosScreen(),
    PerfilScreen(usuario: widget.usuario),
  ];
}

  void _onItemTapped(int index) {
    setState(() {
      _paginaSeleccionada = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _paginas[_paginaSeleccionada],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _paginaSeleccionada,
        selectedItemColor: Colors.pink.shade300,
        unselectedItemColor: Colors.grey.shade600,
        backgroundColor: Colors.white,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Buscar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}