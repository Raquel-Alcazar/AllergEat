import 'package:flutter/material.dart';
import 'gestionar_alergias.dart';
import 'package:allergeat/modelos/user.dart' as u;
import 'package:allergeat/db.dart';
import 'package:allergeat/vistas/bienvenida.dart';

class Perfil extends StatefulWidget {
  final u.User usuario;

  Perfil({required this.usuario});

  @override
  PerfilState createState() => PerfilState();
}

class PerfilState extends State<Perfil> {
  final _formKey = GlobalKey<FormState>();
  late String nombre;
  late String apellidos;
  late String email;
  late String password;

  List<String> alergiasSeleccionadas = [];

  @override
  void initState() {
    super.initState();
    nombre = widget.usuario.name;
    apellidos = widget.usuario.surname;
    email = widget.usuario.email;
    password = widget.usuario.password;
  }

  void _guardarCambios() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      final usuario = widget.usuario;
      usuario.name = nombre;
      usuario.surname = apellidos;
      usuario.password = password; 

      DB.updateUser(usuario);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Datos guardados')),
      );
    }
  }

  void cerrarSesion() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("¿Cerrar sesión?"),
          content: Text("¿Estás segura de que quieres cerrar sesión?"),
          actions: [
            TextButton(
              child: Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop(); 
              },
            ),
            TextButton(
              child: Text(
                "Cerrar sesión",
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop(); 
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => Bienvenida()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Perfil de usuario'),
        backgroundColor: Color(0xFF378BA4),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.red),
            iconSize: 30,
            tooltip: 'Cerrar sesión',
            onPressed: cerrarSesion,
          ),
        ],
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
                  backgroundColor: Color(0xFF81BECE),
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
                  labelText: 'Nombre',
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
                initialValue: apellidos,
                style: TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Apellidos',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce tus apellidos';
                  }
                  return null;
                },
                onSaved: (value) => apellidos = value ?? apellidos,
              ),
              SizedBox(height: 20),
              TextFormField(
                initialValue: email,
                readOnly: true,
                enableInteractiveSelection: false,
                focusNode: AlwaysDisabledFocusNode(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600, 
                ),
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: Icon(Icons.email),
                ),
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
                      onPressed: () { _guardarCambios(); },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF036280),
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GestionarAlergias(
                              usuario: widget.usuario,
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
                                color: Color(0xFF012E4A),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(
                              Icons.settings,
                              size: 18,
                              color: Color(0xFF012E4A),
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

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
