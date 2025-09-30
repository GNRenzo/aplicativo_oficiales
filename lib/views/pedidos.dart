import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:microcash_tripulacion/theme/util.dart';
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

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      setState(() {
        _currentDateTime = DateTime.now();
      });
    });
    _UpdateList();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _UpdateList());

  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
  var user = {};
  Future<void> _UpdateList() async {
    user =  await datosUsuario();
    final basicAuth = 'Basic ${base64Encode(utf8.encode('${user['user']}:${user['pass']}'))}';
    var rpa = await dio.request('$link/api_mobile/apk_tripulacion/listar_pedidos/?pe_user_id=${widget.trabajador['user_id']}&pe_fecha_atencion=${fechaH.split(' ')[0]}&pe_key_estado_plan_diario=EN RUTA',
        options: Options(method: 'GET', headers: {'Authorization': basicAuth}));
    var ra = await dio.request('$link/api_mobile/apk_tripulacion/listar_pedidos/?pe_user_id=${widget.trabajador['user_id']}&pe_fecha_atencion=${fechaH.split(' ')[0]}&pe_key_estado_plan_diario=EJECUTADO',
        options: Options(method: 'GET', headers: {'Authorization': basicAuth}));
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
    _controllerKm.text = '';
    setState(() {
      _filtroEstado = estado;
    });
  }

  late final TextEditingController _controllerKm = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String idHoja = '';
    String km = '';

    if (porAtender.isNotEmpty && porAtender[0]['id_hoja_ruta'] != null) {
      idHoja = porAtender[0]['id_hoja_ruta'];
      km = porAtender[0]['kilometraje_llegada'] != null ? (porAtender[0]['kilometraje_llegada']) : '';
    } else if (atendido.isNotEmpty && atendido[0]['id_hoja_ruta'] != null) {
      idHoja = atendido[0]['id_hoja_ruta'];
      km = atendido[0]['kilometraje_llegada'] != null ? (atendido[0]['kilometraje_llegada']) : '';
    }
    if (km != '') {
      _controllerKm.text = km;
    }

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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(children: [
                    _filteredParadas.length > 0 ? Text('RUTA:     ${_filteredParadas[0]['ruta']}', textScaleFactor: 1, style: TextStyle(fontWeight: FontWeight.bold)) : SizedBox(),
                  ])),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal, // Habilitar scroll horizontal
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  ElevatedButton.icon(
                      onPressed: () => _setFiltro(1),
                      style: ButtonStyle(
                          backgroundColor: _filtroEstado != 1 ? WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.onTertiary) : WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.tertiaryContainer),
                          foregroundColor: WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.onPrimaryFixed)),
                      label: const Text('Por Atender', textScaleFactor: 1, style: TextStyle(fontWeight: FontWeight.bold))),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                      onPressed: () => _setFiltro(2),
                      style: ButtonStyle(
                          backgroundColor: _filtroEstado != 2 ? WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.onTertiary) : WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.tertiaryContainer),
                          foregroundColor: WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.onPrimaryFixed)),
                      label: const Text('Atendido', textScaleFactor: 1, style: TextStyle(fontWeight: FontWeight.bold))),
                  const SizedBox(width: 8),
                  porAtender.length == 0
                      ? ElevatedButton.icon(
                          onPressed: () => _setFiltro(3),
                          style: ButtonStyle(
                              backgroundColor:
                                  _filtroEstado != 3 ? WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.onTertiary) : WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.tertiaryContainer),
                              foregroundColor: WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.onPrimaryFixed)),
                          label: const Text('Llegada Base', textScaleFactor: 1, style: TextStyle(fontWeight: FontWeight.bold)))
                      : SizedBox()
                ]),
              ),
              const SizedBox(height: 16),
              _filtroEstado != 3
                  ? Expanded(
                      child: ListView.builder(
                        itemCount: _filteredParadas.length,
                        itemBuilder: (context, index) {
                          final item = _filteredParadas[index];
                          return GestureDetector(
                            onTap: () {
                              if(_filteredParadas[index]['estado_detalle_hoja_ruta'] == "PROGRAMADA"){
                                Fluttertoast.showToast(msg: "Punto No se encuenta en ruta",backgroundColor: Colors.amber);
                              }else {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => Services(item: item, user: widget.trabajador, filtroStado: _filtroEstado, fecha: fechaH)));
                              }
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 5),
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  color: _filteredParadas[index]['key_estado_detalle_hoja_id'] == '47e3ad9a-b447-4979-ad0a-643e26e9891f'
                                      ? Colors.red.withOpacity(0.2)
                                      : _filteredParadas[index]['key_estado_detalle_hoja_id'] == '58491418-83db-4629-a913-a442d08c4aa1'
                                          ? Colors.green.withOpacity(0.2)
                                          : _filteredParadas[index]['key_estado_detalle_hoja_id'] == '3cd6b331-3210-4796-9f80-1d188fdd6b00'
                                              ? Colors.white70
                                              : _filteredParadas[index]['key_estado_detalle_hoja_id'] == '2fe25eba-342f-45e0-b3ed-8718203297b2'
                                                  ? Colors.orange.withOpacity(0.5)
                                                  : Colors.white70.withOpacity(0.2),
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                  border: Border.all(color: Colors.black.withOpacity(0.3), width: 1)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(child: Text("${_filteredParadas[index]['estado_detalle_hoja_ruta']}", style: TextStyle(fontWeight: FontWeight.bold))),
                                  Row(children: [
                                    _filteredParadas[index]['key_estado_detalle_hoja_id'] == '47e3ad9a-b447-4979-ad0a-643e26e9891f'
                                        ? Row(children: [SizedBox(width: MediaQuery.sizeOf(context).width * 0.05), Icon(Icons.error, color: Colors.red), SizedBox(width: MediaQuery.sizeOf(context).width * 0.05)])
                                        : _filteredParadas[index]['key_estado_detalle_hoja_id'] == '58491418-83db-4629-a913-a442d08c4aa1'
                                            ? Row(children: [SizedBox(width: MediaQuery.sizeOf(context).width * 0.05), Icon(Icons.check, color: Colors.green), SizedBox(width: MediaQuery.sizeOf(context).width * 0.05)])
                                            : _filteredParadas[index]['key_estado_detalle_hoja_id'] == '2fe25eba-342f-45e0-b3ed-8718203297b2'
                                                ? Row(children: [
                                                    SizedBox(width: MediaQuery.sizeOf(context).width * 0.05),
                                                    Icon(Icons.cancel, color: Colors.orange),
                                                    SizedBox(width: MediaQuery.sizeOf(context).width * 0.05)
                                                  ])
                                                : SizedBox(),
                                    Flexible(
                                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Text("Secuencias:  ${item['secuencia']}",
                                          maxLines: 3, textScaleFactor: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                                      SizedBox(width: 12),
                                      Text("AAHH:   ${item['aahh']}", maxLines: 3, textScaleFactor: 1, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                                      Text("${item['punto_asociado']}", textScaleFactor: 1, style: TextStyle(fontSize: 12)),
                                      Text(item['direccion_punto'], textScaleFactor: 1, style: TextStyle(fontSize: 12)),
                                      Row(children: [
                                        Text("BULTOS: ", textScaleFactor: 1, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                                        Flexible(child: Text("${item['envase']}", textScaleFactor: 1, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.primary)))
                                      ])
                                    ]))
                                  ]),
                                  _filteredParadas[index]['key_estado_detalle_hoja_id'] == '58491418-83db-4629-a913-a442d08c4aa1'
                                      ? Column(children: [
                                          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                                            Text("Hora Llegada:  ${item['fecha_hora_llegada']}",
                                                maxLines: 3,
                                                textScaleFactor: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                                            Text("Inicio Servicio:  ${item['fecha_hora_inicio_servicio']}",
                                                maxLines: 3, textScaleFactor: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold))
                                          ]),
                                          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                                            Text("Fin Servicio:  ${item['fecha_hora_fin_servicio']}",
                                                maxLines: 3,
                                                textScaleFactor: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                                            Text("Hora Salida:  ${item['fecha_hora_salida']}",
                                                maxLines: 3, textScaleFactor: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold))
                                          ])
                                        ])
                                      : SizedBox()
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 7),
                        const Center(child: Text("Km de Llegada", textScaleFactor: 1, maxLines: 2, textAlign: TextAlign.center, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
                        SizedBox(height: 12),
                        TextFormField(controller: _controllerKm, enabled: km.length == 0, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Km de Llegada Base', border: OutlineInputBorder())),
                        SizedBox(height: 12),
                        km == ''
                            ? ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.tertiaryContainer),
                                  foregroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onPrimaryFixed),
                                ),
                                onPressed: () async {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      return const AlertDialog(
                                        content: Row(
                                          children: [CircularProgressIndicator(), SizedBox(width: 20), Text("Cargando...")],
                                        ),
                                      );
                                    },
                                  );
                                  final basicAuth = 'Basic ${base64Encode(utf8.encode('${user['user']}:${user['pass']}'))}';
                                  var headers = {'Content-Type': 'application/json', 'Authorization': basicAuth};
                                  var data = json.encode({
                                    "pe_id_hoja_ruta": idHoja,
                                    "pe_kilometraje_llegada": _controllerKm.text,
                                  });
                                  var response = await dio.request('$link/api_mobile/apk_tripulacion/preliquidar_movil/', options: Options(method: 'POST', headers: headers), data: data);
                                  Navigator.of(context).pop();
                                  setState(() {
                                    if (response.statusCode == 200) {
                                      _controllerKm.text = '';
                                      _filtroEstado = 1;
                                      Fluttertoast.showToast(msg: response.data['resultSet'][0]['message']);
                                    }
                                  });
                                },
                                child: Text('Confirmar', textAlign: TextAlign.center, textScaleFactor: 1),
                              )
                            : SizedBox(),
                      ],
                    )
            ],
          ),
        ),
      ),
    );
  }
}
