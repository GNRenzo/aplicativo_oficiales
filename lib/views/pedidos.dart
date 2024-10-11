import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:microcash_tripulacion/views/login.dart';
import 'package:intl/intl.dart';
import 'package:microcash_tripulacion/views/services.dart';

class Pedidos extends StatefulWidget {
  final Map<String, dynamic> trabajador;

  const Pedidos({super.key, required this.trabajador});

  @override
  State<Pedidos> createState() => _PedidoState();
}

class _PedidoState extends State<Pedidos> {
  String link = dotenv.env['LINK'] ?? "http://localhost:8000";
  var porAtender = [];
  var atendido = [];
  int _filtroEstado = 1;
  late Timer _timer;
  DateTime _currentDateTime = DateTime.now();
  var dio = Dio();

  String fechaH =
      "${DateTime.now().year.toString().padLeft(4, '0')}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')} ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}";

  @override
  void initState() {
    _UpdateList();
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
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
    var fecha = fechaH;
    var rpa = await dio.request('$link/api_mobile/apk_tripulación/listar_pedidos/?pe_user_id=${widget.trabajador['user_id']}&pe_fecha_atencion=${fecha.split(' ')[0]}&pe_key_estado_plan_diario=22',
        options: Options(method: 'GET'));
    var ra = await dio.request('$link/api_mobile/apk_tripulación/listar_pedidos/?pe_user_id=${widget.trabajador['user_id']}&pe_fecha_atencion=${fecha.split(' ')[0]}&pe_key_estado_plan_diario=19',
        options: Options(method: 'GET'));
    setState(() {
      porAtender = rpa.data['resultSet'];
      atendido = ra.data['resultSet'];
    });
  }

  List<dynamic> get _filteredParadas {
    if (_filtroEstado == 1) {
      return porAtender;
    } else {
      return atendido;
    }
  }

  void _setFiltro(int estado) {
    setState(() {
      _filtroEstado = estado;
    });
  }

  @override
  Widget build(BuildContext context) {
    _UpdateList();
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.onPrimaryFixed,
            title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('MICROCASH', textScaleFactor: 1, style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
              Text(DateFormat('dd MMM yyyy hh:mma', 'es_ES').format(_currentDateTime), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13))
            ]),
            leading: IconButton(
                icon: Icon(Icons.logout_rounded, color: Theme.of(context).colorScheme.tertiaryContainer),
                onPressed: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginPage()));
                }),
            centerTitle: true),
        body: RefreshIndicator(
            onRefresh: () async {
              await _UpdateList();
            },
            child: Container(
                height: MediaQuery.sizeOf(context).height,
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.onPrimary,
                child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(children: [
                        _filteredParadas.length > 0 ? Text('RUTA:     ${_filteredParadas[0]['id_hoja_ruta']}', textScaleFactor: 1, style: TextStyle(fontWeight: FontWeight.bold)) : SizedBox(),
                      ])),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    ElevatedButton.icon(
                        onPressed: () => _setFiltro(1),
                        style: ButtonStyle(
                            backgroundColor:
                                _filtroEstado == 2 ? WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.onTertiary) : WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.tertiaryContainer),
                            foregroundColor: WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.onPrimaryFixed)),
                        label: const Text('Por Atender', textScaleFactor: 1, style: TextStyle(fontWeight: FontWeight.bold))),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                        onPressed: () => _setFiltro(2),
                        style: ButtonStyle(
                            backgroundColor:
                                _filtroEstado == 1 ? WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.onTertiary) : WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.tertiaryContainer),
                            foregroundColor: WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.onPrimaryFixed)),
                        label: const Text('Atendido', textScaleFactor: 1, style: TextStyle(fontWeight: FontWeight.bold)))
                  ]),
                  const SizedBox(height: 16),
                  Expanded(
                      child: ListView.builder(
                          itemCount: _filteredParadas.length,
                          itemBuilder: (context, index) {
                            final item = _filteredParadas[index];
                            return GestureDetector(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => Services(item: item, user: widget.trabajador, filtroStado: _filtroEstado, fecha: fechaH)));
                                },
                                child: Container(
                                    margin: EdgeInsets.symmetric(vertical: 5),
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        color: _filteredParadas[index]['key_estado_detalle_hoja_id'] == 29
                                            ? Colors.red.withOpacity(0.2)
                                            : _filteredParadas[index]['key_estado_detalle_hoja_id'] == 35
                                                ? Colors.green.withOpacity(0.2)
                                                : _filteredParadas[index]['key_estado_detalle_hoja_id'] == 33
                                                    ? Colors.white70
                                                    : Colors.yellow.withOpacity(0.2),
                                        borderRadius: BorderRadius.all(Radius.circular(10)),
                                        border: Border.all(color: Colors.black.withOpacity(0.3), width: 1)),
                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Row(children: [
                                        _filteredParadas[index]['key_estado_detalle_hoja_id'] == 29
                                            ? Row(children: [SizedBox(width: MediaQuery.sizeOf(context).width * 0.05), Icon(Icons.error, color: Colors.red), SizedBox(width: MediaQuery.sizeOf(context).width * 0.05)])
                                            : _filteredParadas[index]['key_estado_detalle_hoja_id'] == 35
                                                ? Row(
                                                    children: [SizedBox(width: MediaQuery.sizeOf(context).width * 0.05), Icon(Icons.check, color: Colors.green), SizedBox(width: MediaQuery.sizeOf(context).width * 0.05)])
                                                : SizedBox(),
                                        Flexible(
                                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                          Text("Secuencias:  ${item['secuencia']}",
                                              maxLines: 3, textScaleFactor: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                                          SizedBox(width: 12),
                                          Text("AAHH:   ${item['aahh']}", maxLines: 3, textScaleFactor: 1, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                                          Text("${item['punto_asociado']}", textScaleFactor: 1, style: TextStyle(fontSize: 12)),
                                          Text(item['direccion_punto'], textScaleFactor: 1, style: TextStyle(fontSize: 12)),
                                          Text("Serial del Maletín:  ${item['lonchera']}", textScaleFactor: 1, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                                          Row(children: [
                                            Text("ENVASE: ", textScaleFactor: 1, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                                            Flexible(child: Text("${item['envase']}", textScaleFactor: 1, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.primary)))
                                          ])
                                        ]))
                                      ]),
                                      _filteredParadas[index]['key_estado_detalle_hoja_id'] == 35
                                          ? Column(children: [
                                              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                                                Text("Hora Llegada:  ${item['fecha_hora_llegada']}",
                                                    maxLines: 3,
                                                    textScaleFactor: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                                                Text("Inicio Servicio:  ${item['fecha_hora_inicio_servicio']}",
                                                    maxLines: 3,
                                                    textScaleFactor: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold))
                                              ]),
                                              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                                                Text("Fin Servicio:  ${item['fecha_hora_fin_servicio']}",
                                                    maxLines: 3,
                                                    textScaleFactor: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                                                Text("Hora Salida:  ${item['fecha_hora_salida']}",
                                                    maxLines: 3,
                                                    textScaleFactor: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold))
                                              ])
                                            ])
                                          : SizedBox()
                                    ])));
                          }))
                ]))));
  }
}
