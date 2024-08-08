import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:microcash_tripulacion/views/login.dart';
import 'package:intl/intl.dart';
import 'package:microcash_tripulacion/views/services.dart';

class MyHomePage extends StatefulWidget {
  final Map<String, dynamic> trabajador;

  const MyHomePage({super.key, required this.trabajador});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String link = dotenv.env['LINK'] ?? "http://localhost:8000";

  final Dio _dio = Dio();

  late List<dynamic> paradasTripulacion = [];
  int _filtroEstado = 1;
  late Timer _timer;
  DateTime _currentDateTime = DateTime.now();

  @override
  void initState() {
    _UpdateList();
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 2), (Timer timer) {
      setState(() {
        _currentDateTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _UpdateList() async {
    final List<dynamic> _paradas = [
      {
        'sec': 10,
        'aaahh': '09:00 - 11:00',
        'cod_pd': 'PD-014 LA MERCED',
        'direc': 'AV. ALFREDO BENAVIDES N° 2192',
        'serial': 'PR00056',
        'estado': 1,
        'contactos': {'contacto1': "Juan Perez", "contacto2": "Luis Sanchez"},
        'importe': 500
      },
      {
        'sec': 20,
        'aaahh': '09:00 - 11:00',
        'cod_pd': 'PD-014 LA MERCED',
        'direc': 'AV. ALFREDO BENAVIDES N° 2192',
        'serial': 'PR00057',
        'estado': 1,
        'contactos': {'contacto1': "Juan Perez", "contacto2": "Luis Sanchez"},
        'importe': 600
      },
      {
        'sec': 30,
        'aaahh': '09:00 - 11:00',
        'cod_pd': 'PD-014 LA MERCED',
        'direc': 'AV. ALFREDO BENAVIDES N° 2192',
        'serial': 'PR00057',
        'estado': 1,
        'contactos': {'contacto1': "Juan Perez", "contacto2": "Luis Sanchez"},
        'importe': 700
      },
      {
        'sec': 40,
        'aaahh': '09:00 - 11:00',
        'cod_pd': 'PD-014 LA MERCED',
        'direc': 'AV. ALFREDO BENAVIDES N° 2192',
        'serial': 'PR00057',
        'estado': 1,
        'contactos': {'contacto1': "Juan Perez", "contacto2": "Luis Sanchez"},
        'importe': 800
      },
      {
        'sec': 50,
        'aaahh': '09:00 - 11:00',
        'cod_pd': 'PD-014 LA MERCED',
        'direc': 'AV. ALFREDO BENAVIDES N° 2192',
        'serial': 'PR00060',
        'estado': 1,
        'contactos': {'contacto1': "Juan Perez", "contacto2": "Luis Sanchez"},
        'importe': 900
      },
      {
        'sec': 60,
        'aaahh': '09:00 - 11:00',
        'cod_pd': 'PD-014 LA MERCED',
        'direc': 'AV. ALFREDO BENAVIDES N° 2192',
        'serial': 'PR00061',
        'estado': 2,
        'contactos': {'contacto1': "Juan Perez", "contacto2": "Luis Sanchez"},
        'importe': 400
      },
      {
        'sec': 70,
        'aaahh': '09:00 - 11:00',
        'cod_pd': 'PD-014 LA MERCED',
        'direc': 'AV. ALFREDO BENAVIDES N° 2192',
        'serial': 'PR00056',
        'estado': 2,
        'contactos': {'contacto1': "Juan Perez", "contacto2": "Luis Sanchez"},
        'importe': 300
      },
    ];
    setState(() {
      paradasTripulacion = _paradas;
    });
  }

  List<dynamic> get _filteredParadas {
    return paradasTripulacion
        .where((item) => item['estado'] == _filtroEstado)
        .toList();
  }

  void _setFiltro(int estado) {
    setState(() {
      _filtroEstado = estado;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimaryFixed,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'MICROCASH',
              textScaleFactor: 1,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14),
            ),
            Text(
              DateFormat('dd MMM yyyy hh:mma', 'es_ES')
                  .format(_currentDateTime),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 13),
            )
          ],
        ),
        leading: IconButton(
          icon: Icon(
            Icons.logout_rounded,
            color: Theme.of(context).colorScheme.tertiaryContainer,
          ),
          onPressed: () {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginPage()));
          },
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _UpdateList();
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.onPrimary,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _setFiltro(1),
                    style: ButtonStyle(
                      backgroundColor:
                      _filtroEstado == 2 ?
                      WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.onTertiary):
                      WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.tertiaryContainer),
                      foregroundColor: WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.onPrimaryFixed),

                    ),
                    label: const Text('  Por Atender', style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _setFiltro(2),
                    style: ButtonStyle(
                      backgroundColor:
                      _filtroEstado == 1 ?
                      WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.onTertiary):
                      WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.tertiaryContainer),
                      foregroundColor: WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.onPrimaryFixed),

                    ),
                    label: const Text('Atendido', style: TextStyle(fontWeight: FontWeight.bold),),
                  ),

                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredParadas.length,
                  itemBuilder: (context, index) {
                    final item = _filteredParadas[index];
                    return GestureDetector(
                      onTap: () {
                        if (item['estado'] == 2) {
                          _showDetailsDialog(context, item);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Services(item: item, user: widget.trabajador)),
                          );
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(color: Colors.white),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          "Secuencias: ",
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Flexible(
                                        child: Text("${item['sec']}"),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Flexible(
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          "AAAHHH: ",
                                          maxLines: 3,
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Flexible(
                                        child: Text("${item['aaahh']}"),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${item['cod_pd']}"),
                                Text(item['direc']),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  "SERIAL DE ENVASE: ",
                                  style: TextStyle(
                                      color:
                                      Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text("${item['serial']}"),
                              ],
                            ),
                            const Divider(
                              key: Key('divider'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailsDialog(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Detalles"),
          content: SingleChildScrollView(
            child: WidgetDatos(context, item),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Salir'.toUpperCase(),
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

Widget WidgetDatos(BuildContext context, Map<String, dynamic> item) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    "Secuencias: ${item['sec']}   AAAHHH: ${item['aaahh']}",
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    textScaleFactor: 1,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(width: 15),
        ],
      ),
      Text(
        "${item['cod_pd']}",
        style: TextStyle(
          fontSize: 13,
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(
        item['direc'],
        style: TextStyle(
          fontSize: 13,
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
      Row(
        children: [
          const Text(
            "SERIAL DE ENVASE: ",
            style: TextStyle(
              fontSize: 13,
            ),
          ),
          Text("${item['serial']}"),
        ],
      ),
      if (item['contactos'] != null) ...[
        ...item['contactos'].entries.map(
              (entry) =>
              Text('${entry.key.toString().toUpperCase()}: ${entry.value}'),
        ),
      ],
      Text(
        "IMPORTE: ${item['importe']}",
        style: const TextStyle(
          fontSize: 13,
        ),
      ),
    ],
  );
}
