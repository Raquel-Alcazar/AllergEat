import 'package:allergeat/allergies.dart';
import 'package:allergeat/db.dart';
import 'package:allergeat/user.dart';
import 'package:flutter/material.dart';

class GestionarAlergiasScreen extends StatefulWidget {
  final User usuario;

  GestionarAlergiasScreen({required this.usuario});

  @override
  GestionarAlergiasScreenState createState() =>
      GestionarAlergiasScreenState();
}

class GestionarAlergiasScreenState extends State<GestionarAlergiasScreen> {
  late List<String> seleccionadas;

  @override
  void initState() {
    super.initState();
    seleccionadas = widget.usuario.allergies!;
  }

  Future<void> saveAllergies() async {
    await DB.updateAllergies(widget.usuario, seleccionadas);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Alergias guardadas correctamente'),
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestionar alergias'),
        backgroundColor: Color(0xFF378BA4),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          Text(
            'Selecciona tus alergias:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ...Allergies.allergies.keys.map((alergia) {
            final estaSeleccionada = seleccionadas.contains(Allergies.toCode(alergia));

            return SwitchListTile(
              title: Text(alergia),
              value: estaSeleccionada,
              activeColor: Color(0xFF81BECE), // rosa oscuro activo
              inactiveThumbColor: Color.fromARGB(255, 176, 181, 175), // rosa suave thumb desactivado
              inactiveTrackColor: Color(0xFFE8EDE7), // rosa muy suave track desactivado
              onChanged: (bool valor) {
                setState(() {
                  if (valor) {
                    seleccionadas.add(Allergies.toCode(alergia));
                  } else {
                    seleccionadas.remove(Allergies.toCode(alergia));
                  }
                });
              },
            );
          }),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => saveAllergies(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF036280), // rosa oscuro
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