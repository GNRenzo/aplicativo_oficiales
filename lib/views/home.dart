import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:microcash_tripulacion/views/login.dart';
import 'package:intl/intl.dart';
import 'package:microcash_tripulacion/views/pedidos.dart';

class MyHomePage extends StatefulWidget {
  final Map<String, dynamic> trabajador;

  const MyHomePage({super.key, required this.trabajador});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String link = dotenv.env['LINK'] ?? "http://localhost:8000";
  var dio = Dio();
  late Timer _timer;
  DateTime _currentDateTime = DateTime.now();
  String fechaH =
      "${DateTime.now().year.toString().padLeft(4, '0')}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')} ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}";

  var resultado;
  var respValidar;
  bool activarKm = false;

  Future<String> getAndroidId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id; // Android ID como alternativa
    }
    return 'No disponible en este dispositivo';
  }

  var userId = 0;
  var name = '';

  TextEditingController serialController = TextEditingController();
  TextEditingController serialKm = TextEditingController();

  Future<void> obtenerDatosServicio() async {
    var fecha = fechaH;
    var response = await dio.request(
      '$link/api_mobile/apk_tripulación/contar_tipo_servicio/?pe_user_id=19&pe_fecha_atencion=${fecha.split(' ')[0]}',
      options: Options(
        method: 'GET',
      ),
    );
    if (response.statusCode == 200) {
      resultado = response.data;
    }
  }

  Future<void> ValidarSerial(String serial) async {
    var fecha = fechaH;
    var response = await dio.request(
      '$link/api_mobile/apk_tripulación/validar_correlativo_ruta/?pe_user_id=19&pe_correlativo=$serial&pe_fecha_atencion=${fecha.split(' ')[0]}',
      options: Options(
        method: 'GET',
      ),
    );
    if (response.statusCode == 200) {
      respValidar = response.data;
    }
  }

  @override
  void initState() {
    obtenerDatosServicio();
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
      setState(() {
        _currentDateTime = DateTime.now();
      });
    });
    name = (widget.trabajador['name']);
    userId = (widget.trabajador['user_id']);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    getAndroidId();
    fechaH =
        "${DateTime.now().year.toString().padLeft(4, '0')}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')} ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}";
    if (resultado == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    } else {
      if (resultado['resultSet'][0]['estado_hoja_ruta'] == 23) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.onPrimaryFixed,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'MICROCASH',
                  textScaleFactor: 1,
                  style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.w600, fontSize: 14),
                ),
                Text(
                  DateFormat('dd MMM yyyy hh:mma', 'es_ES').format(_currentDateTime),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                )
              ],
            ),
            leading: IconButton(
              icon: Icon(
                Icons.logout_rounded,
                color: Theme.of(context).colorScheme.tertiaryContainer,
              ),
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginPage()));
              },
            ),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: resultado != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: MediaQuery.sizeOf(context).width * 0.2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('RUTA: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text('CHOFER: ', style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          SizedBox(width: 20),
                          Container(
                            width: MediaQuery.sizeOf(context).width * 0.6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(resultado['itFailed'] ? '' : resultado['resultSet'][0]['key_hoja_ruta'].toString()),
                                Text(name),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        'SERVICIOS :',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('CANJE DE SENCILLO'),
                                Text(resultado['itFailed'] ? '' : resultado['resultSet'][0]['count_canje_envio_recojo'].toString()),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('RECOJOS'),
                                Text(resultado['itFailed'] ? '' : resultado['resultSet'][0]['count_recojo'].toString()),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('ENVIOS'),
                                Text(resultado['itFailed'] ? '' : resultado['resultSet'][0]['count_envio'].toString()),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30),
                      Container(
                        alignment: Alignment.center,
                        width: MediaQuery.sizeOf(context).width,
                        padding: const EdgeInsets.all(16),
                        color: Colors.grey[400],
                        child: Text(
                          "VERIFICACIÓN DE SERIALES RECIBIDOS",
                          textScaleFactor: 1,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 35.0),
                        child: Column(children: [
                          TextFormField(
                            enabled: !activarKm,
                            controller: serialController,
                            decoration: const InputDecoration(
                              labelText: 'Serial',
                              border: OutlineInputBorder(),
                            ),
                            textInputAction: TextInputAction.next,
                          ),
                          SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "SERIALES REGISTRADOS:",
                                  textScaleFactor: 1,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "${resultado['itFailed'] ? '' : resultado['resultSet'][0]['cantidad_envases_ruta_validados'].toString()}/${resultado['itFailed'] ? '' : resultado['resultSet'][0]['cantidad_envases_ruta'].toString()}",
                                ),
                              ],
                            ),
                          )
                        ]),
                      ),
                      SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: activarKm
                                ? null
                                : () async {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false, // Evitar que se cierre al tocar fuera del dialog
                                      builder: (BuildContext context) {
                                        return const AlertDialog(
                                          content: Row(
                                            children: [
                                              CircularProgressIndicator(), // Indicador circular de carga
                                              SizedBox(width: 20),
                                              Text("Cargando..."),
                                            ],
                                          ),
                                        );
                                      },
                                    );

                                    await ValidarSerial(serialController.text);
                                    await obtenerDatosServicio();
                                    setState(() {
                                      serialController.text = '';
                                    });

                                    // Cerrar el dialogo después de que la operación termine
                                    Navigator.of(context).pop();
                                    Fluttertoast.showToast(msg: respValidar['resultSet'][0]['message']);
                                  },
                            style: ButtonStyle(
                              backgroundColor: activarKm ? null : MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.tertiaryContainer),
                              foregroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onPrimaryFixed),
                            ),
                            child: const Text(
                              "Validar",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: activarKm
                                ? null
                                : () {
                                    //setState(() {});
                                    Fluttertoast.showToast(msg: "En Mantenimiento");
                                  },
                            style: ButtonStyle(
                              backgroundColor: activarKm ? null : MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.tertiaryContainer),
                              foregroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onPrimaryFixed),
                            ),
                            child: const Text(
                              "Reseteo",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: activarKm
                                ? null
                                : () {
                                    if (!resultado['itFailed'] && resultado['resultSet'][0]['cantidad_envases_ruta'] != resultado['resultSet'][0]['cantidad_envases_ruta_validados']) {
                                      Fluttertoast.showToast(msg: "EXISTEN ENVASES SIN VALIDAR. POR FAVOR, VALIDAR TODOS LOS ENVASES ANTES DE DESPACHAR");
                                    } else {
                                      setState(() {
                                        activarKm = true;
                                      });
                                    }
                                  },
                            style: ButtonStyle(
                              backgroundColor: activarKm
                                  ? null
                                  : !resultado['itFailed'] && resultado['resultSet'][0]['cantidad_envases_ruta'] != resultado['resultSet'][0]['cantidad_envases_ruta_validados']
                                      ? null
                                      : MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.tertiaryContainer),
                              foregroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onPrimaryFixed),
                            ),
                            child: const Text(
                              "Siguiente",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      activarKm
                          ? Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 30.0),
                              child: Column(
                                children: [
                                  SizedBox(height: 30),
                                  TextFormField(
                                    controller: serialKm,
                                    decoration: const InputDecoration(
                                      labelText: 'KILOMETRAJE',
                                      border: OutlineInputBorder(),
                                    ),
                                    textInputAction: TextInputAction.next,
                                  ),
                                  SizedBox(height: 30),
                                  ElevatedButton(
                                    onPressed: () async {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false, // Evitar que se cierre al tocar fuera del dialog
                                        builder: (BuildContext context) {
                                          return const AlertDialog(
                                            content: Row(
                                              children: [
                                                CircularProgressIndicator(), // Indicador circular de carga
                                                SizedBox(width: 20),
                                                Text("Cargando..."),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                      var headers = {'Content-Type': 'application/json'};
                                      String androidId = await getAndroidId();
                                      var data = json.encode({
                                        "pe_user_id": userId,
                                        "pe_fecha_atencion": fechaH,
                                        "pe_fecha_despacho": fechaH.split(' ')[0],
                                        "pe_hora_despacho": fechaH.split(' ')[1],
                                        "pe_kilometraje_salida": serialKm.text,
                                        "pe_fecha_hora_salida": fechaH.split(' ')[0],
                                        "pe_estacion_despacho": "MÓVIL",
                                        "pe_taquilla_despacho": androidId,
                                        "pe_key_hoja_ruta": resultado['resultSet'][0]['key_hoja_ruta']
                                      });
                                      var response = await dio.request(
                                        '$link/api_mobile/apk_tripulación/despachar_movil/',
                                        options: Options(
                                          method: 'POST',
                                          headers: headers,
                                        ),
                                        data: data,
                                      );
                                      Navigator.of(context).pop();
                                      setState(() {
                                        if (response.statusCode == 200) {
                                          Fluttertoast.showToast(msg: response.data['resultSet'][0]['message']);
                                          Future.delayed(Duration.zero, () {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(builder: (context) => Pedidos(trabajador: widget.trabajador)), // Cambiar a la pantalla deseada
                                            );
                                          });
                                        }
                                      });
                                    },
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.tertiaryContainer),
                                      foregroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onPrimaryFixed),
                                    ),
                                    child: const Text(
                                      "Confirmar Despacho",
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : SizedBox()
                    ],
                  )
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.all(22.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                        ],
                      ),
                    ),
                  ),
          ),
        );
      } else {
        // Navegar a otra pantalla automáticamente
        Future.delayed(Duration.zero, () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Pedidos(trabajador: widget.trabajador)), // Cambiar a la pantalla deseada
          );
        });

        // Mientras navega, mostrar un cargando o algo mientras se realiza la navegación
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }
    }
  }
}
