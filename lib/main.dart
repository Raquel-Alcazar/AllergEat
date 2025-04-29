import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

void main() {
  OpenFoodAPIConfiguration.userAgent = UserAgent(name: 'MiAppFlutter - TFG');
  runApp(MiApp());
}

class MiApp extends StatefulWidget {
  @override
  _MiAppState createState() => _MiAppState();
}

class _MiAppState extends State<MiApp> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    BuscarProductoScreen(), // Página de Buscar Producto
    ProductosFavoritosScreen(), // Página de Productos Favoritos
    PerfilScreen(), // Página de Perfil
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: ThemeData(
    useMaterial3: true, // Si quieres usar diseño Material 3
    primarySwatch: Colors.teal,
    scaffoldBackgroundColor: Colors.grey[100],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.teal,
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Colors.teal,
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
    ),
    textTheme: TextTheme(
      bodyMedium: TextStyle(fontSize: 16, color: Colors.black87),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      filled: true,
      fillColor: Colors.white,
      labelStyle: TextStyle(color: Colors.teal),
    ),
elevatedButtonTheme: ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.teal,
    foregroundColor: Colors.white, // ← Esto pone el texto en blanco
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    textStyle: TextStyle(fontSize: 16),
  ),
),
  ),
  home: Scaffold(
    body: _pages[_selectedIndex],
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Productos',
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
  ),
);

  }
}

class BuscarProductoScreen extends StatefulWidget {
  @override
  BuscarProductoScreenState createState() => BuscarProductoScreenState();
}

class BuscarProductoScreenState extends State<BuscarProductoScreen> {
  List<Product> productos = [];
  bool cargando = false;
  int page = 1;
  String ultimoQuery = "";
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !cargando) {
        buscarProducto(ultimoQuery, cargarMas: true);
      }
    });
  }

  Future<void> buscarProducto(String query, {bool cargarMas = false}) async {
    if (!cargarMas) {
      productos.clear();
      page = 1;
    }

    setState(() => cargando = true);
    ultimoQuery = query;

    User user = User(userId: 'raquel-alcazar', password: '1234raquel', comment: 'Prueba Flutter');
    
    final SearchResult result = await OpenFoodAPIClient.searchProducts(
      user,
      ProductSearchQueryConfiguration(

        fields: [ 
              ProductField.NAME,
              ProductField.BRANDS,
              ProductField.BARCODE,
              ProductField.IMAGE_FRONT_URL,
              ProductField.INGREDIENTS_TEXT,
              ProductField.NUTRISCORE,
              ProductField.NUTRIMENTS,
              ProductField.ALLERGENS,
              ProductField.CATEGORIES,
              ProductField.QUANTITY,
            ],  
        parametersList: [SearchTerms(terms: [query]), PageSize(size: 20), PageNumber(page: page)],
        version: ProductQueryVersion.v3,
      ),
    );

    setState(() {
      // Agregar todos los productos que tienen un nombre no vacío y una imagen
      productos.addAll(result.products?.where((producto) {
        return producto.productName != null && producto.productName!.isNotEmpty && producto.imageFrontUrl != null;
      }) ?? []);
      cargando = false;
      if (result.products != null && result.products!.isNotEmpty) {
        page++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController controladorBusqueda = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text("Buscar Producto")),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: controladorBusqueda,
              decoration: InputDecoration(
                labelText: "Escribe un producto",
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => buscarProducto(controladorBusqueda.text),
                ),
              ),
            ),
          ),
          Expanded(
            child: cargando && productos.isEmpty
                ? Center(child: CircularProgressIndicator())
                : productos.isEmpty
                    ? Center(child: Text("No se encontraron productos"))
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: productos.length,
                        itemBuilder: (context, index) {
                          return Padding(
  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
  child: InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductoDetailScreen(producto: productos[index]),
        ),
      );
    },
    borderRadius: BorderRadius.circular(12),
    child: Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: productos[index].imageFrontUrl != null
                  ? Image.network(
                      productos[index].imageFrontUrl!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    )
                  : Icon(Icons.fastfood, size: 60),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productos[index].productName ?? "Sin nombre",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    productos[index].brands ?? "Marca desconocida",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  ),
);

                        },
                      ),
          ),
        ],
      ),
    );
  }
}
}
