import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:allergeat/db.dart';
import 'package:allergeat/user.dart' as u;

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
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFFFF0F5),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Color(0xFFFFC1CC),
          secondary: Color(0xFFFFD6DD),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFFFFC1CC),
          foregroundColor: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          hintStyle: TextStyle(color: Colors.grey.shade600),
        ),
      ),
      home: PantallaRegistro(),
    );
  }
}

class PantallaRegistro extends StatefulWidget {
  @override
  _PantallaRegistroState createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  final _formKey = GlobalKey<FormState>();
  String nombre = '';
  String apellidos = '';
  String email = '';
  String password = '';
  String repetirPassword = '';

  void _registrarse() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      u.User usuario = u.User(id: 0, name: nombre, surname: apellidos, email: email, password: password);
      DB.insertUser(usuario);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuario registrado con éxito')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeConMenu()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registro')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value) =>
                    value!.isEmpty ? 'Introduce tu nombre' : null,
                onSaved: (value) => nombre = value!,
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(labelText: 'Apellidos'),
                validator: (value) =>
                    value!.isEmpty ? 'Introduce tus apellidos' : null,
                onSaved: (value) => apellidos = value!,
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(labelText: 'Correo electrónico'),
                validator: (value) => value!.contains('@')
                    ? null
                    : 'Introduce un correo válido',
                onSaved: (value) => email = value!,
              ),
              SizedBox(height: 20),
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(labelText: 'Contraseña'),
                validator: (value) => value!.length < 6
                    ? 'Debe tener al menos 6 caracteres'
                    : null,
                onSaved: (value) => password = value!,
              ),
              SizedBox(height: 20),
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(labelText: 'Repite la contraseña'),
                /*validator: (value) => value != password
                    ? 'Las contraseñas no coinciden'
                    : null,*/
                onSaved: (value) => repetirPassword = value!,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _registrarse,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFFC1CC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  'Registrarse',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeConMenu extends StatefulWidget {
  @override
  _HomeConMenuState createState() => _HomeConMenuState();
}

class _HomeConMenuState extends State<HomeConMenu> {
  int _paginaSeleccionada = 0;

  final List<Widget> _paginas = [
    BusquedaProductos(),
    FavoritosScreen(),
    PerfilScreen(),  // Añadida pantalla Perfil aquí
  ];

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

class BusquedaProductos extends StatefulWidget {
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
                                    trailing: Icon(Icons.arrow_forward_ios_rounded,
                                        size: 16),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DetalleProducto(producto: producto),
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
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (producto.imageFrontUrl != null)
            Center(
              child: Hero(
                tag: producto.barcode ?? 'img',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    producto.imageFrontUrl!,
                    height: 250,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          SizedBox(height: 20),
          Text(
            producto.productName ?? 'Sin nombre',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          _detalle('Marca', producto.brands),
          _detalle('Cantidad', producto.quantity),
          _detalle('Código de barras', producto.barcode),
          _detalle('Nutriscore',
              producto.nutriscore?.toString().toUpperCase()),
          _detalle('Ingredientes', getIngredients(producto)),
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

// Pantalla Favoritos provisional

class FavoritosScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favoritos'),
      ),
      body: Center(
        child: Text(
          'Aquí podrás guardar productos favoritos.',
          style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// Pantalla Perfil con botón para ir a Alergias

class PerfilScreen extends StatefulWidget {
  @override
  _PerfilScreenState createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  String nombre = "Raquel García López";
  String email = "raquel@email.com";
  String password = "123456";

  List<String> alergiasSeleccionadas = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil de usuario'),
        backgroundColor: Color(0xFFFFC1CC),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: CircleAvatar(
                  radius: 80,
                  backgroundColor: Colors.pink.shade100,
                  child: Icon(
                    Icons.person,
                    size: 100,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 30),
              TextFormField(
                initialValue: nombre,
                style: TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Nombre completo',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce tu nombre';
                  }
                  return null;
                },
                onSaved: (value) => nombre = value ?? nombre,
              ),
              SizedBox(height: 20),
              TextFormField(
                initialValue: email,
                style: TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce un correo válido';
                  }
                  return null;
                },
                onSaved: (value) => email = value ?? email,
              ),
              SizedBox(height: 20),
              TextFormField(
                initialValue: password,
                obscureText: true,
                style: TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres';
                  }
                  return null;
                },
                onSaved: (value) => password = value ?? password,
              ),
              SizedBox(height: 30),
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          _formKey.currentState?.save();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Datos guardados')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFFC1CC),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'Guardar cambios',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(5),
                      splashColor: Colors.pink.shade200,
                      highlightColor: Colors.pink.shade50,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GestionarAlergiasScreen(
                              alergiasSeleccionadas: alergiasSeleccionadas,
                              onGuardar: (lista) {
                                setState(() {
                                  alergiasSeleccionadas = lista;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Alergias guardadas correctamente'),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Gestionar alergias',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFFB0003A),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(
                              Icons.settings,
                              size: 18,
                              color: Color(0xFFB0003A),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GestionarAlergiasScreen extends StatefulWidget {
  final List<String> alergiasSeleccionadas;
  final Function(List<String>) onGuardar;

  GestionarAlergiasScreen(
      {required this.alergiasSeleccionadas, required this.onGuardar});

  @override
  _GestionarAlergiasScreenState createState() =>
      _GestionarAlergiasScreenState();
}

class _GestionarAlergiasScreenState extends State<GestionarAlergiasScreen> {
  List<String> alergias = [
    'Gluten',
    'Lácteos',
    'Frutos secos',
    'Huevos',
    'Soja',
    'Mariscos',
    'Pescado',
    'Cacahuetes',
    'Sésamo',
    'Mostaza',
    'Apio',
    'Sulfitos',
  ];

  late List<String> seleccionadas;

  @override
  void initState() {
    super.initState();
    seleccionadas = List<String>.from(widget.alergiasSeleccionadas);
  }

  Color getSwitchActiveColor(bool isActive) {
    return isActive ? Color(0xFFFF6F91) : Color(0xFFFFC1CC);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestionar alergias'),
        backgroundColor: Color(0xFFFFC1CC),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          Text(
            'Selecciona tus alergias:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ...alergias.map((alergia) {
            final estaSeleccionada = seleccionadas.contains(alergia);
            return SwitchListTile(
              title: Text(alergia),
              value: estaSeleccionada,
              activeColor: Color(0xFFFF6F91), // rosa oscuro activo
              inactiveThumbColor: Color(0xFFFFC1CC), // rosa suave thumb desactivado
              inactiveTrackColor: Color(0xFFFFE1E6), // rosa muy suave track desactivado
              onChanged: (bool valor) {
                setState(() {
                  if (valor) {
                    seleccionadas.add(alergia);
                  } else {
                    seleccionadas.remove(alergia);
                  }
                });
              },
            );
          }).toList(),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              widget.onGuardar(seleccionadas);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFF6F91), // rosa oscuro
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: EdgeInsets.symmetric(vertical: 18),
            ),
            child: Text(
              'Guardar alergias',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white, // texto blanco para buen contraste
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
