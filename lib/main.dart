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

class ProductoDetailScreen extends StatelessWidget {
  final Product producto;

  ProductoDetailScreen({required this.producto});

  @override
  Widget build(BuildContext context) {
    // Obtenemos los alérgenos como texto
    final alergenosText = producto.allergens?.names.toString() ?? '';
  
    // Convertimos a lista si hay datos
    final alergenosList = alergenosText.isNotEmpty ? alergenosText.split(',') : [];
    print('Lista de alérgenos: $alergenosList');
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          producto.productName ?? "Detalles del Producto",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite_border),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Añadido a favoritos')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen principal
            Center(
              child: Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[200],
                ),
                child: producto.imageFrontUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          producto.imageFrontUrl!,
                          fit: BoxFit.contain,
                        ),
                      )
                    : Icon(Icons.fastfood, size: 60, color: Colors.grey),
              ),
            ),
            SizedBox(height: 24),

            // Nombre y marca
            Text(
              producto.productName ?? "Nombre no disponible",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal[800],
              ),
            ),
            SizedBox(height: 8),
            Text(
              producto.brands ?? 'Marca desconocida',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            Divider(height: 32, thickness: 1),

            // Información básica
            _buildInfoRow('Código de barras', producto.barcode ?? 'No disponible'),
            _buildInfoRow('Categoría', producto.categories ?? 'No especificada'),
            _buildInfoRow('Cantidad', producto.quantity ?? 'No especificada'),
            Divider(height: 32, thickness: 1),

            // Sección de alérgenos (solo si hay datos)
            if (alergenosList.isNotEmpty) ...[
              Text(
                'Alérgenos:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal[800],
                ),
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: alergenosList.map((alergeno) => Chip(
                  label: Text(alergeno.trim()),
                  backgroundColor: Colors.red[50],
                  labelStyle: TextStyle(color: Colors.red[900]),
                )).toList(),
              ),
              SizedBox(height: 16),
              Divider(height: 32, thickness: 1),
            ],

            // Ingredientes
            Text(
              'Ingredientes:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal[800],
              ),
            ),
            SizedBox(height: 8),
            Text(
              producto.ingredientsText ?? 'Información no disponible',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24),

            // Botón de acción
            Center(
              child: ElevatedButton.icon(
                icon: Icon(Icons.share),
                label: Text('Compartir Producto'),
                onPressed: () {
                  // Lógica para compartir
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.teal[700],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
}
