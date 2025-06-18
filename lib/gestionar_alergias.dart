import 'package:flutter/material.dart';

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