import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:microcash_tripulacion/views/login.dart';
import 'package:nb_utils/nb_utils.dart';

class MyHomePage extends StatefulWidget {

  final Map<String, dynamic> trabajador;

  const MyHomePage({super.key, required this.trabajador});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String link = dotenv.env['LINK'] ?? "http://localhost:8000";

  final Dio _dio = Dio();
  List<dynamic> _clientes = [];
  List<dynamic> _puntosAsociados = [];
  List<dynamic> _rutas = [];
  List<dynamic> _paradas = [];
  int? _selectedClienteId;
  int? _selectedPuntoId;
  int? _selectedRutaId;
  late final TextEditingController _controllerTurno = TextEditingController();
  late final TextEditingController _controllerHoraInicio = TextEditingController();
  late final TextEditingController _controllerHoraFinal = TextEditingController();
  late final TextEditingController _controllerParadaHoraLlegada = TextEditingController();
  late final TextEditingController _controllerParadaFalsaParada = TextEditingController();
  late final TextEditingController _controllerParadaHoraSalida = TextEditingController();
  late final TextEditingController _controllerParadaComprobante = TextEditingController();
  late final TextEditingController _controllerParadaMotivo = TextEditingController();

  late final TextEditingController _controllerServicioHoraInicio = TextEditingController();
  late final TextEditingController _controllerServicioHoraFinal = TextEditingController();
  late final TextEditingController _controllerServicioCantidad = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchRutas();
    _fetchClientes();
  }

  Future<void> _fetchClientes() async {

    try {
      final response = await _dio.get("$link/tablas/cliente/listar/?key_status=1&id=0");
      setState(() {
        _clientes = response.data['resultSet'];
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _fetchRutas() async {

    try {
      final response = await _dio.get("$link/tablas/ruta/listarAPK/?key_estado=1&id=0");
      setState(() {
        _rutas = response.data['resultSet'];
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _fetchPuntosAsociados(int clienteId) async {

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Padding(
            padding: EdgeInsets.all(15),
            child: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Obteniendo Datos...'),
              ],
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
        );
      },
    );

    try {
      final response = await _dio.get('$link/tablas/punto_asociado/listarAPK/?key_estado=1&key_cliente=0', queryParameters: {'id': clienteId});
      setState(() {
        _puntosAsociados = response.data['resultSet'];
        _selectedPuntoId = null;
      });
    } catch (e) {
      print(e);
    }

    Navigator.of(context).pop();
  }

  Future<void> _fetchTripulacion() async {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Scaffold(
            appBar: AppBar(
              title: Text('Registrar Parada', style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryFixed, fontWeight: FontWeight.w600)),
              centerTitle: true,
              leading: const SizedBox(),
              actions: [
                IconButton(
                  icon: Icon(Icons.close, size: 30, color: Theme.of(context).colorScheme.onPrimaryFixed,),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            body: ListView(
              children: [
                const SizedBox(height: 16),
                TextFormField(
                  controller: _controllerParadaHoraLlegada,
                  keyboardType: TextInputType.datetime,
                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                  readOnly: true,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.access_time, color: Theme.of(context).colorScheme.primary,),
                    labelText: 'Hora de Llegada',
                    labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                    border: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                  onTap: () async {
                    final newTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                        cancelText: "Cancelar",
                        confirmText: "Aceptar",
                        errorInvalidText: "Error: Hora inválida",
                        helpText: "Ingresar hora",
                        hourLabelText: "Hora",
                        minuteLabelText: "Minuto");
                    if (newTime != null) {
                      var hh = newTime.hour < 10
                          ? "0${newTime.hour}"
                          : newTime.hour.toString();
                      var mm = newTime.minute < 10
                          ? "0${newTime.minute}"
                          : newTime.minute.toString();

                      setState(() {
                        _controllerParadaHoraLlegada.text = "$hh:$mm:00";
                      });
                    }
                  },
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _controllerParadaFalsaParada,
                  keyboardType: TextInputType.datetime,
                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                  readOnly: true,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.access_time, color: Theme.of(context).colorScheme.primary,),
                    labelText: 'Falsa Parada',
                    labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                    border: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                  onTap: () async {
                    final newTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                        cancelText: "Cancelar",
                        confirmText: "Aceptar",
                        errorInvalidText: "Error: Hora inválida",
                        helpText: "Falsa Parada",
                        hourLabelText: "Hora",
                        minuteLabelText: "Minuto");
                    if (newTime != null) {
                      var hh = newTime.hour < 10
                          ? "0${newTime.hour}"
                          : newTime.hour.toString();
                      var mm = newTime.minute < 10
                          ? "0${newTime.minute}"
                          : newTime.minute.toString();

                      setState(() {
                        _controllerParadaFalsaParada.text = "$hh:$mm:00";
                      });
                    }
                  },
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _controllerParadaHoraSalida,
                  keyboardType: TextInputType.datetime,
                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                  readOnly: true,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.access_time, color: Theme.of(context).colorScheme.primary,),
                    labelText: 'Hora de Salida',
                    labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                    border: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                  onTap: () async {
                    final newTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                        cancelText: "Cancelar",
                        confirmText: "Aceptar",
                        errorInvalidText: "Error: Hora inválida",
                        helpText: "Falsa Parada",
                        hourLabelText: "Hora",
                        minuteLabelText: "Minuto");
                    if (newTime != null) {
                      var hh = newTime.hour < 10
                          ? "0${newTime.hour}"
                          : newTime.hour.toString();
                      var mm = newTime.minute < 10
                          ? "0${newTime.minute}"
                          : newTime.minute.toString();

                      setState(() {
                        _controllerParadaHoraSalida.text = "$hh:$mm:00";
                      });
                    }
                  },
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _controllerParadaComprobante,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).nextFocus();
                  },
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.numbers_rounded, color: Theme.of(context).colorScheme.primary,),
                    labelText: 'Comprobante Visita',
                    hintText: 'Ingrese Comprobante Visita',
                    border: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _controllerParadaMotivo,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.format_list_bulleted_rounded, color: Theme.of(context).colorScheme.primary,),
                    labelText: 'Motivo',
                    hintText: 'Ingrese Motivo',
                    border: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    SizedBox(
                      height: 55,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.secondaryFixed),
                          foregroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onPrimaryFixed),
                        ),
                        label: const Text('Cerrar', style: TextStyle(fontWeight: FontWeight.bold),),
                        icon: const Icon(Icons.close),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                        child: SizedBox(
                          height: 55,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _paradas.add({
                                  "hora_llegada": _controllerParadaHoraLlegada.text,
                                  "falsa_parada": _controllerParadaFalsaParada.text,
                                  "hora_salida": _controllerParadaHoraSalida.text,
                                  "comprobante": _controllerParadaComprobante.text,
                                  "motivo": _controllerParadaMotivo.text,
                                });
                              });

                              Navigator.of(context).pop();
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.tertiaryContainer),
                              foregroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onPrimaryFixed),
                            ),
                            label: const Text('Agregar', style: TextStyle(fontWeight: FontWeight.bold),),
                            icon: const Icon(Icons.add),
                          ),
                        ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _fetchServicio() async {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Scaffold(
            appBar: AppBar(
              title: Text('Registrar Servicio', style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryFixed, fontWeight: FontWeight.w600)),
              centerTitle: true,
              leading: const SizedBox(),
              actions: [
                IconButton(
                  icon: Icon(Icons.close, size: 30, color: Theme.of(context).colorScheme.onPrimaryFixed,),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            body: ListView(
              children: [
                const SizedBox(height: 16),
                TextFormField(
                  controller: _controllerServicioHoraInicio,
                  keyboardType: TextInputType.datetime,
                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                  readOnly: true,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.access_time, color: Theme.of(context).colorScheme.primary,),
                    labelText: 'Hora de Inicio',
                    labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                    border: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                  onTap: () async {
                    final newTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                        cancelText: "Cancelar",
                        confirmText: "Aceptar",
                        errorInvalidText: "Error: Hora inválida",
                        helpText: "Ingresar hora",
                        hourLabelText: "Hora",
                        minuteLabelText: "Minuto");
                    if (newTime != null) {
                      var hh = newTime.hour < 10
                          ? "0${newTime.hour}"
                          : newTime.hour.toString();
                      var mm = newTime.minute < 10
                          ? "0${newTime.minute}"
                          : newTime.minute.toString();

                      setState(() {
                        _controllerServicioHoraInicio.text = "$hh:$mm:00";
                      });
                    }
                  },
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _controllerServicioHoraFinal,
                  keyboardType: TextInputType.datetime,
                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                  readOnly: true,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.access_time, color: Theme.of(context).colorScheme.primary,),
                    labelText: 'Hora de Término',
                    labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                    border: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                  onTap: () async {
                    final newTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                        cancelText: "Cancelar",
                        confirmText: "Aceptar",
                        errorInvalidText: "Error: Hora inválida",
                        helpText: "Falsa Parada",
                        hourLabelText: "Hora",
                        minuteLabelText: "Minuto");
                    if (newTime != null) {
                      var hh = newTime.hour < 10
                          ? "0${newTime.hour}"
                          : newTime.hour.toString();
                      var mm = newTime.minute < 10
                          ? "0${newTime.minute}"
                          : newTime.minute.toString();

                      setState(() {
                        _controllerServicioHoraFinal.text = "$hh:$mm:00";
                      });
                    }
                  },
                ),
                const SizedBox(height: 32),

                TextFormField(
                  controller: _controllerServicioCantidad,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).nextFocus();
                  },
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.numbers_rounded, color: Theme.of(context).colorScheme.primary,),
                    labelText: 'Cantidad de CS',
                    hintText: 'Ingrese Cantidad de CS',
                    border: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
                Row(
                  children: [
                    SizedBox(
                      height: 55,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.secondaryFixed),
                          foregroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onPrimaryFixed),
                        ),
                        label: const Text('Cerrar', style: TextStyle(fontWeight: FontWeight.bold),),
                        icon: const Icon(Icons.close),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                        child: SizedBox(
                          height: 55,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() {

                              });
                              Navigator.of(context).pop();
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.tertiaryContainer),
                              foregroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onPrimaryFixed),
                            ),
                            label: const Text('Aceptar', style: TextStyle(fontWeight: FontWeight.bold),),
                            icon: const Icon(Icons.add),
                          ),
                        ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimaryFixed,
        title: Text('Microcash Tripulación', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: Icon(Icons.logout_rounded, color: Theme.of(context).colorScheme.tertiaryContainer, ),
          onPressed: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginPage()));
          },
        ),
        centerTitle: true,
      ),
      floatingActionButton: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FilledButton.icon(
            onPressed: () async {
              await _fetchServicio();
            },
            label: const Text('Servicio'),
            icon: const Icon(Icons.miscellaneous_services_rounded),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.primary),
              foregroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onPrimary),
            ),
          ),
          SizedBox(width: 12),
          FilledButton.icon(
            onPressed: () async {
              await _fetchTripulacion();
            },
            label: const Text('Agregar Parada'),
            icon: const Icon(Icons.add),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.tertiaryContainer),
              foregroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onPrimaryFixed),
            ),
          )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        color: Theme.of(context).colorScheme.onPrimary,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ruta', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary, fontSize: 18)),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: _buildDropdownButtonFormField(
                    hint: 'Ruta',
                    value: _selectedRutaId,
                    items: _rutas,
                    onChanged: (int? newValue) {
                      setState(() {
                        var rpta = _rutas.where((i) => i['id'] == newValue).first;
                        _controllerTurno.text = rpta['turno_ruta'].toString();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 4),
                SizedBox(
                  width: 102.5,
                  child: TextFormField(
                    controller: _controllerTurno,
                    enabled: false,
                    style: TextStyle(color: Theme.of(context).colorScheme.primary),
                    decoration: InputDecoration(
                      labelText: 'TURNO',
                      labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                      hintText: 'Ingrese Turno',
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 8),
            Text('Cliente', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary, fontSize: 18)),
            const SizedBox(height: 4),
            _buildDropdownButtonFormField(
              hint: 'Cliente',
              value: _selectedClienteId,
              items: _clientes,
              onChanged: (int? newValue) {
                setState(() {
                  _selectedClienteId = newValue;
                  _fetchPuntosAsociados(newValue!);
                });
              },
            ),
            const SizedBox(height: 8),
            Text('Punto', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary, fontSize: 18)),
            const SizedBox(height: 4),
            _buildDropdownButtonFormField(
              hint: 'Punto',
              value: _selectedPuntoId,
              items: _puntosAsociados,
              onChanged: (int? newValue) {
                setState(() {
                  _selectedPuntoId = newValue;
                });
              },
            ),
            const SizedBox(height: 12),
            Text('Arco Programado', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary, fontSize: 18)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _controllerHoraInicio,
                    keyboardType: TextInputType.datetime,
                    style: TextStyle(color: Theme.of(context).colorScheme.primary),
                    readOnly: true,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.access_time, color: Theme.of(context).colorScheme.primary,),
                      labelText: 'Inicio',
                      labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                    onTap: () async {
                      final newTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                          cancelText: "Cancelar",
                          confirmText: "Aceptar",
                          errorInvalidText: "Error: Hora inválida",
                          helpText: "Ingresar hora",
                          hourLabelText: "Hora",
                          minuteLabelText: "Minuto");
                      if (newTime != null) {
                        var hh = newTime.hour < 10
                            ? "0${newTime.hour}"
                            : newTime.hour.toString();
                        var mm = newTime.minute < 10
                            ? "0${newTime.minute}"
                            : newTime.minute.toString();

                        setState(() {
                          _controllerHoraInicio.text = "$hh:$mm:00";
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _controllerHoraFinal,
                    keyboardType: TextInputType.datetime,
                    style: TextStyle(color: Theme.of(context).colorScheme.primary),
                    readOnly: true,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.access_time, color: Theme.of(context).colorScheme.primary,),
                      labelText: 'Final',
                      labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                    onTap: () async {
                      final newTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                          cancelText: "Cancelar",
                          confirmText: "Aceptar",
                          errorInvalidText: "Error: Hora inválida",
                          helpText: "Ingresar hora",
                          hourLabelText: "Hora",
                          minuteLabelText: "Minuto");
                      if (newTime != null) {
                        var hh = newTime.hour < 10
                            ? "0${newTime.hour}"
                            : newTime.hour.toString();
                        var mm = newTime.minute < 10
                            ? "0${newTime.minute}"
                            : newTime.minute.toString();

                        setState(() {
                          _controllerHoraFinal.text = "$hh:$mm:00";
                        });
                      }
                    },
                  ),
                )
              ],
            ),
            const SizedBox(height: 8),
            const Divider(key: Key('divider')),
            const SizedBox(height: 8),
            Text('Paradas:', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary, fontSize: 18)),
            const SizedBox(height: 16),
            Expanded(
                child: ListView.builder(
                  itemCount: _paradas.length,
                  itemBuilder: (context, index) {
                    final item = _paradas[index];
                    return Container(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Row(
                                children: [
                                  Text("Hora de Llegada: ", style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),),
                                  Text(item['hora_llegada']),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Row(
                                children: [
                                  Text("Falsa Parada: ", style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),),
                                  Text(item['falsa_parada']),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Row(
                                children: [
                                  Text("Hora de Salida: ", style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),),
                                  Text(item['hora_salida']),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Row(
                                children: [
                                  Text("Comprobante: ", style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),),
                                  Text(item['comprobante']),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Text("Motivo: ", style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),),
                              Text(item['motivo']),
                            ],
                          ),
                          const Divider(key: Key('divider')),
                        ],
                      ),
                    );
                  }
                )
            ),
          ],
        )
      ),
    );
  }

  Widget _buildDropdownButtonFormField({
    required String hint,
    required int? value,
    required List<dynamic> items,
    required ValueChanged<int?>? onChanged,
  }) {
    return DropdownButtonFormField<int>(
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      iconEnabledColor: Theme.of(context).colorScheme.onPrimaryFixed,
      decoration: InputDecoration(
        filled: true,
        fillColor: Theme.of(context).colorScheme.secondaryFixed,
        contentPadding: const EdgeInsets.only(left: 24, right: 16, top: 16, bottom: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary.withOpacity(0),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: BorderSide(
            color:  Theme.of(context).colorScheme.primary.withOpacity(0),
            width: 1.5,
          ),
        ),
      ),
      hint: Text(hint),
      value: value,
      onChanged: onChanged,
      items: items.map<DropdownMenuItem<int>>((dynamic item) {
        return DropdownMenuItem<int>(
          value: item['id'],
          child: Text(item['descripcion'] ?? item['razon_social'] ?? item['razon_social_punto'], style: TextStyle(fontWeight: FontWeight.normal, color: Theme.of(context).colorScheme.onPrimaryFixed),),
        );
      }).toList(),
    );
  }

}