import 'package:flutter/material.dart';
import 'package:allergeat/db.dart';
import 'package:allergeat/user.dart' as u;
import 'home_con_menu.dart';

class PantallaRegistro extends StatefulWidget {
  @override
  _PantallaRegistroState createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();

  String nombre = '';
  String apellidos = '';
  String email = '';
  String password = '';
  String repetirPassword = '';

  bool _obscurePassword = true;
  bool _obscureRepeatPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _registrarse() async {
    if (context.mounted && _formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      u.User usuario = u.User(
          id: 0,
          name: nombre,
          surname: apellidos,
          email: email,
          password: password);

      u.User? usuarioEncontrado = await DB.userByEmail(usuario.email);

      if (usuarioEncontrado is u.User) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('¡Email ya en uso!')),
        );
      } else {
        await DB.insertUser(usuario);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuario registrado con éxito')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeConMenu(
              usuario: usuario,
              paginaInicial:
                  0, // Esto hace que se abra directamente la pestaña de búsqueda
            ),
          ),
        );
      }
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
                validator: (value) =>
                    value!.contains('@') ? null : 'Introduce un correo válido',
                onSaved: (value) => email = value!,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
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
                validator: (value) => value!.length < 6
                    ? 'Debe tener al menos 6 caracteres'
                    : null,
                onSaved: (value) => password = value!,
              ),
              SizedBox(height: 20),
              TextFormField(
                obscureText: _obscureRepeatPassword,
                decoration: InputDecoration(
                  labelText: 'Repite la contraseña',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureRepeatPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureRepeatPassword = !_obscureRepeatPassword;
                      });
                    },
                  ),
                ),
                validator: (value) => value != _passwordController.text
                    ? 'Las contraseñas no coinciden'
                    : null,
                onSaved: (value) => repetirPassword = value!,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _registrarse,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF036280),
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
