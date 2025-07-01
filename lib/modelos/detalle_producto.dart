import 'package:allergeat/modelos/allergies.dart';
import 'package:allergeat/db.dart';
import 'package:allergeat/modelos/favorite_product.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'user.dart' as u;

class DetalleProducto extends StatefulWidget {
  final Product producto;
  final u.User usuario;

  DetalleProducto({required this.producto, required this.usuario});

  @override
  DetalleProductoState createState() => DetalleProductoState();
}

class DetalleProductoState extends State<DetalleProducto> {
  FavoriteProduct? productoFavorito;

  @override
  void initState() {
    super.initState();
    cargarProductoFavorito();
  }

  Future<void> cargarProductoFavorito() async {
    var producto = await DB.favoriteProductByUserIdAndProductBarcode(
        widget.usuario.id, widget.producto.barcode ?? '');

    setState(() {
      productoFavorito = producto;
    });
  }

  bool esFavorito() {
    return productoFavorito is FavoriteProduct;
  }

  void toggleFavorito() async {
    Text message;

    if (widget.producto.barcode == null) {
      message = Text('El producto no se puede añadir a favoritos');
    } else if (esFavorito()) {
      DB.deleteProductoFavorito(productoFavorito!);
      productoFavorito = null;

      message = Text('Producto eliminado de favoritos');
    } else {
      final producto = FavoriteProduct(
          id: 0,
          userId: widget.usuario.id,
          productBarcode: widget.producto.barcode!);
      await DB.insertProductoFavorito(producto);
      productoFavorito = producto;

      message = Text('Producto añadido a favoritos');
    }

    if (context.mounted) {
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: message),
        );
      });
    }
  }

  String getIngredients(Product producto) {
    return producto
            .ingredientsTextInLanguages?[OpenFoodFactsLanguage.SPANISH] ??
        producto.ingredientsText ??
        "No disponible";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.producto.productName ?? 'Producto'),
        actions: [
          IconButton(
            iconSize: 40,
            onPressed: toggleFavorito,
            tooltip:
                esFavorito() ? 'Quitar de favoritos' : 'Añadir a favoritos',
            icon: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Icon(
                esFavorito() ? Icons.favorite : Icons.favorite_border,
                key: ValueKey<bool>(esFavorito()),
                color: Colors.red,
                size: 30,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (widget.producto.imageFrontUrl != null)
            Center(
              child: Hero(
                tag: widget.producto.barcode ?? 'img',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    widget.producto.imageFrontUrl!,
                    height: 250,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          SizedBox(height: 20),
          Text(
            widget.producto.productName ?? 'Sin nombre',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          productoApto(),
          SizedBox(height: 10),
          _detalle('Marca', widget.producto.brands),
          _detalle('Cantidad', widget.producto.quantity),
          _detalle(
              'Alérgenos',
              widget.producto.allergens?.ids
                  .map((id) => Allergies.toSpanish(id))
                  .join(", ")),
          _detalle('Nutriscore',
              widget.producto.nutriscore?.toString().toUpperCase()),
          _detalle('Código de barras', widget.producto.barcode),
          _detalle('Ingredientes', getIngredients(widget.producto)),
        ],
      ),
    );
  }

  Text productoApto() {
    if (widget.producto.allergens!.ids
        .any((id) => widget.usuario.allergies!.contains(id))) {
      return Text(
        '👎 Este producto no es apto para ti',
        style: TextStyle(backgroundColor: Colors.red, fontSize: 18),
      );
    } else {
      return Text(
        '👍 Este producto es apto para ti',
        style: TextStyle(backgroundColor: Colors.green, fontSize: 18),
      );
    }
  }

  Widget _detalle(String titulo, String? valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 2),
          Text(
            valor ?? 'No disponible',
            style: TextStyle(fontSize: 15),
          ),
        ],
      ),
    );
  }
}
