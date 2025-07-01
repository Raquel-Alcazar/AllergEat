import 'package:allergeat/modelos/allergies.dart';
import 'package:allergeat/db.dart';
import 'package:allergeat/modelos/user.dart';
import 'package:flutter/material.dart';

class GestionarAlergias extends StatefulWidget {
  final User usuario;

  GestionarAlergias({required this.usuario});

  @override
  GestionarAlergiasState createState() =>
      GestionarAlergiasState();
}

class GestionarAlergiasState extends State<GestionarAlergias> {
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
              activeColor: Color(0xFF81BECE), 
              inactiveThumbColor: Color.fromARGB(255, 176, 181, 175), 
              inactiveTrackColor: Color(0xFFE8EDE7), 
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
                color: Colors.white, 
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}