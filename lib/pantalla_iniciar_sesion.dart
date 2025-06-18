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

  void _iniciarSesion() async {
    if (context.mounted && _formKey.currentState!.validate()) {
      final usuario = _usuarioController.text;
      final password = _passwordController.text;

      User? usuarioEncontrado = await DB.userByEmail(usuario);

      if (usuarioEncontrado is User && usuarioEncontrado.password == password) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('¡Inicio de sesión correcto para $usuario!')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeConMenu(
              usuario: usuarioEncontrado,
              paginaInicial:
                  0, // Esto hace que se abra directamente la pestaña de búsqueda
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
                  border: OutlineInputBorder(),
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
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
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
                child: Text('Entrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}