import 'package:flutter/material.dart';
import 'db.dart';
import 'user.dart';
import 'home_con_menu.dart';

class PantallaIniciarSesion extends StatefulWidget {
  @override
  PantallaIniciarSesionState createState() => PantallaIniciarSesionState();
}

class PantallaIniciarSesionState extends State<PantallaIniciarSesion> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;

  void _iniciarSesion() async {
    if (context.mounted && _formKey.currentState!.validate()) {
      final usuario = _usuarioController.text;
      final password = _passwordController.text;

      User? usuarioEncontrado = await DB.userByEmail(usuario);

      if (usuarioEncontrado is User && usuarioEncontrado.password == password) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('¡Bienvenid@ $usuario!')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeConMenu(
              usuario: usuarioEncontrado,
              paginaInicial: 0,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('¡Credenciales no válidas!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Iniciar sesión'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _usuarioController,
                decoration: InputDecoration(
                  labelText: 'Usuario',
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(30), // mismo borde redondeado
                  ),
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 14, horizontal: 20), // padding interno
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce tu usuario';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce tu contraseña';
                  }
                  if (value.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _iniciarSesion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF036280),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize:
                      Size(double.infinity, 50), // ancho completo, altura 50
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  'Entrar',
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
