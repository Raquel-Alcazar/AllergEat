import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

void main() {
  OpenFoodAPIConfiguration.userAgent =
      UserAgent(name: 'mi_app', url: 'https://miapp.com');
  OpenFoodAPIConfiguration.globalLanguages = <OpenFoodFactsLanguage>[
    OpenFoodFactsLanguage.SPANISH,
  ];
  OpenFoodAPIConfiguration.globalCountry = OpenFoodFactsCountry.SPAIN;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OpenFoodFacts Demo',
      home: BusquedaProductos(),
    );
  }
}

class BusquedaProductos extends StatefulWidget {
  @override
  _BusquedaProductosState createState() => _BusquedaProductosState();
}

class _BusquedaProductosState extends State<BusquedaProductos> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _productos = [];
  bool _cargando = false;

  Future<void> buscarProductosPorTexto(String textoBusqueda) async {
    setState(() {
      _cargando = true;
      _productos.clear();
    });

    final User user = User(userId: '0', password: '0');

    final ProductSearchQueryConfiguration configuration =
        ProductSearchQueryConfiguration(
      parametersList: <Parameter>[
        SearchTerms(terms: [textoBusqueda]),
        const SortBy(option: SortOption.POPULARITY),
      ],
      version: ProductQueryVersion.v3
    );

    final SearchResult result =
        await OpenFoodAPIClient.searchProducts(user, configuration);

    setState(() {
      _productos.addAll(result.products?.where((producto) {
            return producto.productName != null &&
                producto.productName!.isNotEmpty &&
                producto.imageFrontUrl != null;
          }) ??
          []);
      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buscar productos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Introduce nombre del producto',
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                final texto = _searchController.text.trim();
                if (texto.isNotEmpty) {
                  buscarProductosPorTexto(texto);
                }
              },
              child: Text('Buscar'),
            ),
            SizedBox(height: 20),
            _cargando
                ? CircularProgressIndicator()
                : Expanded(
                    child: _productos.isEmpty
                        ? Text('No se encontraron productos.')
                        : ListView.builder(
                            itemCount: _productos.length,
                            itemBuilder: (context, index) {
                              final producto = _productos[index];
                              return ListTile(
                                leading: Image.network(
                                  producto.imageFrontUrl!,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(Icons.broken_image),
                                ),
                                title: Text(producto.productName ?? 'Sin nombre'),
                                subtitle: Text('Código: ${producto.barcode ?? 'Desconocido'}'),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DetalleProducto(producto: producto),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
          ],
        ),
      ),
    );
  }
}

class DetalleProducto extends StatelessWidget {
  final Product producto;

  DetalleProducto({required this.producto});

  String getIngredients(Product producto) {
    return producto.ingredientsTextInLanguages?[OpenFoodFactsLanguage.SPANISH] ??
           producto.ingredientsText ??
           "No disponible";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(producto.productName ?? 'Producto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (producto.imageFrontUrl != null)
              Center(
                child: Image.network(
                  producto.imageFrontUrl!,
                  height: 150,
                ),
              ),
            SizedBox(height: 16),
            Text('Nombre: ${producto.productName ?? 'Desconocido'}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Marca: ${producto.brands ?? 'Desconocida'}'),
            SizedBox(height: 8),
            Text('Cantidad: ${producto.quantity ?? 'No especificada'}'),
            SizedBox(height: 8),
            Text('Código de barras: ${producto.barcode ?? 'N/A'}'),
            SizedBox(height: 8),
            Text('Nutriscore: ${producto.nutriscore?.toString().toUpperCase() ?? 'No disponible'}'),
            SizedBox(height: 8),
            Text('Ingredientes: ${getIngredients(producto)}'),
          ],
        ),
      ),
    );
  }
}
