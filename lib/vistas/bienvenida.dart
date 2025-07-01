import 'package:flutter/material.dart';

import 'iniciar_sesion.dart';
import 'registro.dart';

class Bienvenida extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido'),
        centerTitle: true,
      ),
      body: Align(
        alignment: Alignment(
            0, -0.4), 
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: 300,
                height: 300,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 10),
              Text(
                '¡Tu salud, nuestra prioridad!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => IniciarSesion()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF036280),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize:
                      Size(double.infinity, 50), 
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  'Iniciar sesión',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => Registro()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF036280),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize:
                      Size(double.infinity, 50), 
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
