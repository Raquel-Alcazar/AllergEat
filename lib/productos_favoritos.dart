import 'package:flutter/material.dart';

class FavoritosScreen extends StatelessWidget {
  // Lista ficticia de productos favoritos
  final List<Map<String, String>> productosFavoritos = [
    {
      'nombre': 'Chocolate Negro 70%',
      'descripcion': 'Tableta de chocolate negro con 70% cacao',
      'imagenUrl':
          'https://images.unsplash.com/photo-1562440499-02a28c7ffb90?auto=format&fit=crop&w=50&q=80',
    },
    {
      'nombre': 'Leche Sin Lactosa',
      'descripcion': 'Leche fresca sin lactosa de 1 litro',
      'imagenUrl':
          'https://images.unsplash.com/photo-1585238342028-35c6d64442a0?auto=format&fit=crop&w=50&q=80',
    },
    {
      'nombre': 'Pan Integral',
      'descripcion': 'Pan integral de trigo 500g',
      'imagenUrl':
          'https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&w=50&q=80',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favoritos'),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: productosFavoritos.length,
        itemBuilder: (context, index) {
          final producto = productosFavoritos[index];
          return Card(
            margin: EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  producto['imagenUrl']!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.broken_image),
                ),
              ),
              title: Text(producto['nombre']!),
              subtitle: Text(producto['descripcion']!),
              trailing: Icon(Icons.favorite, color: Colors.pink.shade400),
            ),
          );
        },
      ),
    );
  }
}
