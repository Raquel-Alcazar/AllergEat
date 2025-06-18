import 'package:flutter/material.dart';

import 'pantalla_iniciar_sesion.dart';
import 'pantalla_registro.dart';

class Bienvenida extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Definimos colores y estilos comunes (puedes ajustarlos o importarlos de un tema global)
    final primaryColor = Theme.of(context).primaryColor;
    final buttonTextStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.w600);

    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '¡Bienvenido a la AllergEat!',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PantallaIniciarSesion()),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Iniciar sesión', style: buttonTextStyle),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PantallaRegistro()),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Registrarse', style: buttonTextStyle),
            ),
          ],
        ),
      ),
    );
  }
}
