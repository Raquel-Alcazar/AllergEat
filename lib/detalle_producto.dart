import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
class DetalleProducto extends StatefulWidget {
  final Product producto;

  DetalleProducto({required this.producto});

  @override
  _DetalleProductoState createState() => _DetalleProductoState();
}

class _DetalleProductoState extends State<DetalleProducto> {
  bool esFavorito = false;


  void toggleFavorito() {
  setState(() {
    if (esFavorito) {
      //favoritos.remove(widget.producto.barcode);
      esFavorito = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Producto eliminado de favoritos')),
      );
    } else {
      //favoritos.add(widget.producto.barcode!);
      esFavorito = true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Producto añadido a favoritos')),
      );
    }
  });
}

  String getIngredients(Product producto) {
    return producto.ingredientsTextInLanguages?[OpenFoodFactsLanguage.SPANISH] ??
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
            icon: Icon(
              esFavorito ? Icons.favorite : Icons.favorite_border,
              color: Colors.red,
            ),
            onPressed: toggleFavorito,
            tooltip: esFavorito ? 'Quitar de favoritos' : 'Añadir a favoritos',
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
          SizedBox(height: 10),
          _detalle('Marca', widget.producto.brands),
          _detalle('Cantidad', widget.producto.quantity),
          _detalle('Código de barras', widget.producto.barcode),
          _detalle('Nutriscore',
              widget.producto.nutriscore?.toString().toUpperCase()),
          _detalle('Ingredientes', getIngredients(widget.producto)),
        ],
      ),
    );
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
              color: Colors.pink.shade300,
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
