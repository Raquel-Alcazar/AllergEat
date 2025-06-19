import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'detalle_producto.dart';
import 'user.dart' as u;

class BusquedaProductos extends StatefulWidget {
  final u.User usuario;

  BusquedaProductos({required this.usuario});

  @override
  _BusquedaProductosState createState() => _BusquedaProductosState();
}

class _BusquedaProductosState extends State<BusquedaProductos>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _productos = [];
  bool _cargando = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Añadido checkbox para alergias
  bool _filtrarAlergias = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> buscarProductosPorTexto(String textoBusqueda) async {
    setState(() {
      _cargando = true;
      _productos.clear();
      _fadeController.reset();
    });

    final User user = User(userId: '0', password: '0');

    final ProductSearchQueryConfiguration configuration =
        ProductSearchQueryConfiguration(
      parametersList: <Parameter>[
        SearchTerms(terms: [textoBusqueda]),
        const SortBy(option: SortOption.POPULARITY),
      ],
      version: ProductQueryVersion.v3,
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
      _fadeController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buscar productos'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Introduce nombre del producto',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search, color: Colors.pink.shade200),
                  onPressed: () {
                    final texto = _searchController.text.trim();
                    if (texto.isNotEmpty) {
                      buscarProductosPorTexto(texto);
                    }
                  },
                ),
              ),
            ),

            // Aquí está el checkbox añadido
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: _filtrarAlergias,
                    onChanged: (bool? valor) {
                      setState(() {
                        _filtrarAlergias = valor ?? false;
                      });
                    },
                    activeColor: Colors.pink.shade200,
                  ),
                  SizedBox(width: 0), // Menos espacio aquí
                  Text(
                    'Filtrar por alergias',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.pink.shade400,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),
            _cargando
                ? CircularProgressIndicator()
                : Expanded(
                    child: _productos.isEmpty
                        ? Text('No se encontraron productos.')
                        : FadeTransition(
                            opacity: _fadeAnimation,
                            child: ListView.builder(
                              itemCount: _productos.length,
                              itemBuilder: (context, index) {
                                final producto = _productos[index];
                                return Card(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 3,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: ListTile(
                                    leading: Hero(
                                      tag: producto.barcode ?? index,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          producto.imageFrontUrl!,
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Icon(Icons.broken_image),
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                        producto.productName ?? 'Sin nombre'),
                                    subtitle: Text(
                                        'Código: ${producto.barcode ?? 'Desconocido'}'),
                                    trailing: Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 16),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DetalleProducto(
                                              producto: producto,
                                              usuario: widget.usuario),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
          ],
        ),
      ),
    );
  }
}
