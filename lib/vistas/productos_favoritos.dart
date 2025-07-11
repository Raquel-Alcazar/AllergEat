import 'package:flutter/material.dart';
import 'package:allergeat/modelos/favorite_product.dart';
import 'package:allergeat/db.dart';
import 'package:allergeat/modelos/user.dart' as u;
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:allergeat/modelos/detalle_producto.dart';

class ProductosFavoritos extends StatefulWidget {
  final u.User usuario;

  ProductosFavoritos({required this.usuario});

  @override
  ProductosFavoritosState createState() => ProductosFavoritosState();
}

class ProductosFavoritosState extends State<ProductosFavoritos>
    with SingleTickerProviderStateMixin {
  final List<Product> productos = [];
  late AnimationController _fadeController;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );
    cargarProductosFavoritos();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> buscarProducto(FavoriteProduct productoFavorito) async {
    final User user = User(userId: '0', password: '0');
    final configuration = ProductQueryConfiguration(
      productoFavorito.productBarcode,
      version: ProductQueryVersion.v3,
    );

    final product =
        (await OpenFoodAPIClient.getProductV3(configuration, user: user))
            .product;

    if (product != null) {
      productos.add(product);
    }
  }

  Future<void> cargarProductosFavoritos() async {
    List<FavoriteProduct> productosFavoritos =
        await DB.favoriteProductsbyUserId(widget.usuario.id);

    for (FavoriteProduct p in productosFavoritos) {
      if (mounted) {
        await buscarProducto(p);
      }
    }

    if (mounted) {
      setState(() => _cargando = false);
    }
  }

Widget productoFavoritoCard(Product producto) {
  return Container(
    width: MediaQuery.of(context).size.width - 32, 
    margin: EdgeInsets.only(bottom: 0),
    child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            producto.imageFrontUrl!,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                Icon(Icons.broken_image),
          ),
        ),
        title: Text(producto.productName ?? 'Sin nombre'),
        subtitle: Text(producto.brands ?? 'Desconocido'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  DetalleProducto(producto: producto, usuario: widget.usuario),
            ),
          );
        },
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Favoritos'),
          automaticallyImplyLeading: false,
        ),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(children: [
                _cargando
                  ? Expanded(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : Expanded(
                      child: productos.isEmpty
                          ? Center(
                              child: Text(
                                  'No se encontraron productos favoritos.'))
                          : ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: productos.length,
                              itemBuilder: (context, index) {
                                final producto = productos[index];
                                return productoFavoritoCard(producto);
                              },
                            ),
                    ),
            ])));
  }
}
