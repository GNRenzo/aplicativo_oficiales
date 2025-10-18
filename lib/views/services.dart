import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:microcash_tripulacion/theme/util.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as ima;
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';
import 'package:intl/intl.dart';

class Services extends StatefulWidget {
  dynamic item;
  final dynamic user;
  final int filtroStado;
  final String fecha;

  Services({required this.item, required this.user, required this.filtroStado, required this.fecha});

  @override
  State<Services> createState() => _ServicesState();
}

class _ServicesState extends State<Services> {
  String link = dotenv.env['LINK'] ?? "http://localhost:8000";
  late Timer _timer;
  DateTime _currentDateTime = DateTime.now();
  String _selectedService = '';
  var dio = Dio();
  var comprobante = {};
  var motivos = [];
  late final TextEditingController _controllerComprobante = TextEditingController();

  String estado_plan = '';
  String estado_detalle = '';
  List arrbilletes = [];
  var firma;
  var foto;
  var serial = '';
  late final TextEditingController _controllerSerial = TextEditingController();
  late final TextEditingController _controllerSerieB = TextEditingController();

  late final TextEditingController _controllerDNIval = TextEditingController();
  late final TextEditingController _controllerNombreVal = TextEditingController();
  late final TextEditingController _controllerObservVal = TextEditingController();
  bool _validate = true;
  bool _validated = false;
  String _msg = '';

  List<String> kPreguntas = [
    '¿Cómo calificas la puntualidad del servicio?',
    '¿El Operador fue amable y está debidamente uniformado?',
    '¿El vehículo está limpio y en buen estado?',
  ];

  List<int?> kEncuestaRespuestas = [null, null, null];

  Widget encuestaSimpleContainer() {
    const iconos = <IconData>[
      Icons.sentiment_very_dissatisfied,
      Icons.sentiment_dissatisfied,
      Icons.sentiment_neutral,
      Icons.sentiment_satisfied,
      Icons.sentiment_very_satisfied,
    ];

    return StatefulBuilder(
      builder: (context, setState) {
        Widget filaPregunta(int idx) {
          final sel = kEncuestaRespuestas[idx];
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${idx + 1}. ${kPreguntas[idx]}',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: MediaQuery.sizeOf(context).height*0.012),textScaleFactor: 1 ),
                SizedBox(height:  MediaQuery.sizeOf(context).height*0.007),
                Row(
                  children: List.generate(5, (i) {
                    final val = i + 1;
                    final activo = sel == val;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: InkWell(
                        onTap: () =>
                            setState(() => kEncuestaRespuestas[idx] = val),
                        borderRadius: BorderRadius.circular(8),
                        child: Icon(
                          iconos[i],
                          size: MediaQuery.sizeOf(context).height*0.03,
                          color: activo ? Colors.blue : Colors.black87,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              filaPregunta(0),
              filaPregunta(1),
              filaPregunta(2),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      setState(() {
        _currentDateTime = DateTime.now();
      });
    });
    estado_plan = widget.item['key_estado_plan_id'];
    estado_detalle = widget.item['key_estado_detalle_hoja_id'];
    if ( widget.item['fecha_hora_llegada'] != null) {
      _selectedService = 'ATENCIÓN SERVICIO';
    }
  }

  var user = {};

  List<bool> _dataProc = [false, false, false, false, false, false];

  Widget _buildButton(String title, String key, int index) {
    return Column(children: [
      GestureDetector(
          onTap: () async {
            if (widget.filtroStado == 1) {
              showDialog(
                context: context,
                barrierDismissible: false, // Evitar que se cierre al tocar fuera del dialog
                builder: (BuildContext context) {
                  return const AlertDialog(
                    content: Row(
                      children: [
                        CircularProgressIndicator(), // Indicador circular de carga
                        SizedBox(width: 20),
                        Text(
                          "Cargando...",
                          textScaleFactor: 1,
                        ),
                      ],
                    ),
                  );
                },
              );
              String anterior = "";
              if (index == 2) {
                anterior = 'fecha_hora_llegada';
              }
              if (index == 3) {
                anterior = 'fecha_hora_inicio_servicio';
              }
              if (index == 4) {
                anterior = 'fecha_hora_fin_servicio';
              }
              if (index == 1 || widget.item[anterior] != null) {
                if (widget.item[key] != null) {
                  Fluttertoast.showToast(msg: "Dato Ya Registrado");
                  Navigator.of(context).pop();
                } else {
                  user = await datosUsuario();
                  final basicAuth = 'Basic ${base64Encode(utf8.encode('${user['user']}:${user['pass']}'))}';
                  if (index == 1) {
                    FormData formData = FormData.fromMap({
                      "pe_user_id": widget.user['user_id'],
                      "pe_key_detalle_hoja_ruta_id": widget.item['id_detalle_hoja_ruta'],
                    });
                    var response = await dio.request('$link/api_mobile/apk_tripulacion/llegada_punto/',
                        options: Options(method: 'POST', headers: {'Authorization': basicAuth, 'Content-Type': 'multipart/form-data'}), data: formData);
                    if (response.statusCode == 200) {
                      Fluttertoast.showToast(msg: response.data['message']);
                      if (index != 4) {
                        await UpdateList(widget.item['id_pedido']);
                      } else {
                        Navigator.of(context).pop();
                      }
                    } else {
                      Fluttertoast.showToast(msg: "Error ${response.statusMessage}");
                    }
                    Navigator.of(context).pop();
                  }
                  if (index == 2) {
                    FormData formData = FormData.fromMap({
                      "pe_user_id": widget.user['user_id'],
                      "pe_key_detalle_hoja_ruta_id": widget.item['id_detalle_hoja_ruta'],
                    });
                    var response = await dio.request('$link/api_mobile/apk_tripulacion/inicio_servicio/',
                        options: Options(method: 'POST', headers: {'Authorization': basicAuth, 'Content-Type': 'multipart/form-data'}), data: formData);
                    if (response.statusCode == 200) {
                      Fluttertoast.showToast(msg: response.data['message']);
                      if (index != 4) {
                        await UpdateList(widget.item['id_pedido']);
                      } else {
                        Navigator.of(context).pop();
                      }
                    } else {
                      Fluttertoast.showToast(msg: "Error ${response.statusMessage}");
                    }
                    Navigator.of(context).pop();
                  }

                  if (index == 4) {
                    FormData formData = FormData.fromMap({
                      "pe_user_id": widget.user['user_id'],
                      "pe_key_detalle_hoja_ruta_id": widget.item['id_detalle_hoja_ruta'],
                    });
                    var response = await dio.request('$link/api_mobile/apk_tripulacion/salida_punto/',
                        options: Options(method: 'POST', headers: {'Authorization': basicAuth, 'Content-Type': 'multipart/form-data'}), data: formData);
                    if (response.statusCode == 200) {
                      Fluttertoast.showToast(msg: response.data['message']);
                      if (index != 4) {
                        await UpdateList(widget.item['id_pedido']);
                      } else {
                        Navigator.of(context).pop();
                      }
                    } else {
                      Fluttertoast.showToast(msg: "Error ${response.statusMessage}");
                    }
                    Navigator.of(context).pop();
                  }
                }
              } else {
                Fluttertoast.showToast(msg: "Seleccione el paso correctamente ");
                Navigator.of(context).pop();
              }
            }
          },
          child: Container(
              height: 45,
              margin: const EdgeInsets.symmetric(horizontal: 11),
              alignment: AlignmentDirectional.center,
              decoration: BoxDecoration(
                color: widget.item[key] != null ? Colors.blue : Colors.grey,
              ),
              child: Text(title, style: TextStyle(color: Colors.white, fontSize: MediaQuery.sizeOf(context).width * 0.030), textScaleFactor: 1, textAlign: TextAlign.center, softWrap: true))),
      Text("${widget.item[key] != 'null' && widget.item[key] != null ? widget.item[key].toString().replaceAll(' ', '\n') : ''}",
          textScaleFactor: 1, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: MediaQuery.sizeOf(context).width * 0.032))
    ]);
  }

  SignatureController sigFirma = SignatureController(penStrokeWidth: 1.5, penColor: Colors.black, exportBackgroundColor: Colors.white, exportPenColor: Colors.black);

  bool respUser = false;

  Widget FormularioFinServicio() {
    String seriales = '';
    if (arrbilletes != null && arrbilletes is List) {
      List<String> serialesList = [];
      for (var billete in arrbilletes) {
        serialesList.add(billete['Serie']);
      }
      seriales = serialesList.join(', ');
    }
    return SizedBox(
      child: Column(
        children: [
          //DATOS PERSONA
          !_dataProc[0]
              ? Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: TextFormField(
                                controller: _controllerDNIval, enabled: !_validated, decoration: const InputDecoration(labelText: 'DNI', border: OutlineInputBorder()), textInputAction: TextInputAction.next)),
                        SizedBox(width: 10),
                        ElevatedButton(
                            onPressed: () async {
                              user = await datosUsuario();
                              final basicAuth = 'Basic ${base64Encode(utf8.encode('${user['user']}:${user['pass']}'))}';
                              var response = await dio.request(
                                  '$link/api_mobile/apk_tripulacion/validar_contacto_punto/?pe_key_punto_asociado=${widget.item['key_punto_asociado']}&pe_dni_contacto=${_controllerDNIval.text}',
                                  options: Options(headers: {'Authorization': basicAuth}, method: 'GET'));
                              respUser = response.data['resultSet'][0]['validator'];
                              setState(() {
                                _validated = response.data['resultSet'][0]['validator'];
                                _msg = response.data['resultSet'][0]['message'];
                                if (_validated) {
                                  _controllerNombreVal.text = response.data['resultSet'][0]['contacto'];
                                }
                              });
                              Fluttertoast.showToast(msg: _msg);
                            },
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.tertiaryContainer),
                                foregroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onPrimaryFixed)),
                            child: Text("Validar"))
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextFormField(controller: _controllerNombreVal, enabled: !_validated, decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder()), textInputAction: TextInputAction.next),
                    const SizedBox(height: 10),
                    TextFormField(controller: _controllerObservVal, decoration: const InputDecoration(labelText: 'Observacion', border: OutlineInputBorder()), textInputAction: TextInputAction.next),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                if (_controllerNombreVal.text != '' && (respUser || _controllerObservVal.text.trim().isNotEmpty)) {
                                  _dataProc[0] = true;
                                  switch (widget.item['key_modalidad_servicio_id']) {
                                    case 1:
                                      _dataProc[1] = true;
                                      break;
                                    case 2:
                                      _dataProc[1] = true;
                                      _dataProc[2] = true;
                                      break;
                                    case 3:
                                      print('CONTRA ENTREGA CON RECUENTO');
                                      break;
                                  }
                                } else {
                                  Fluttertoast.showToast(msg: "Datos incompletos");
                                }
                              });
                            },
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.tertiaryContainer),
                                foregroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onPrimaryFixed)),
                            child: Text("Siguiente")),
                      ],
                    ),
                  ],
                )
              : SizedBox(),
          // FIRMA CONTACTO
          _dataProc[0] && !_dataProc[1]
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    const SizedBox(height: 10),
                    Column(
                      children: [
                        const SizedBox(height: 10),
                        const Center(child: Text("FIRMA DEL CONTACTO", textScaleFactor: 1, maxLines: 2, textAlign: TextAlign.center, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
                        const SizedBox(height: 5),
                        Container(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(26)),
                            child: Column(children: [
                              Padding(padding: const EdgeInsets.all(1.0), child: Signature(controller: sigFirma, height: 220, backgroundColor: Colors.grey.shade100)),
                              Container(
                                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, mainAxisSize: MainAxisSize.max, children: [
                                IconButton(
                                    icon: Icon(Icons.clear, color: Colors.red),
                                    onPressed: () {
                                      sigFirma.clear();
                                      firma = null;
                                    }),
                                IconButton(
                                    icon: Icon(Icons.undo, color: Colors.amber),
                                    onPressed: () {
                                      sigFirma.undo();
                                    }),
                                IconButton(
                                    icon: Icon(Icons.redo, color: Colors.amber),
                                    onPressed: () {
                                      sigFirma.redo();
                                    }),
                                IconButton(
                                    onPressed: () async {
                                      if (sigFirma.isEmpty) {
                                        Fluttertoast.showToast(msg: "No Existe Firma para Registrar");
                                        return;
                                      }
                                      Uint8List recorder = await sigFirma.toPngBytes() ?? Uint8List(0);
                                      final tempDir = await getTemporaryDirectory();
                                      final filePath = '${tempDir.path}/firma_${DateTime.now().toString().split('.')[0].replaceAll('-', '').replaceAll(':', '').replaceAll(' ', '')}.jpg';
                                      var image = ima.decodeImage(Uint8List.fromList(recorder));
                                      File(filePath).writeAsBytesSync(ima.encodePng(image!));
                                      setState(() {
                                        firma = filePath;
                                      });
                                      Fluttertoast.showToast(msg: "Firma Capturada");
                                    },
                                    icon: Icon(Icons.save_as_outlined, color: Colors.blue))
                              ])),
                              SizedBox(height: 5),
                              ElevatedButton(
                                  onPressed: () {
                                    if (firma.toString().trim() != '' && firma != null) {
                                      setState(() {
                                        _dataProc[1] = true;
                                        foto = null;
                                      });
                                    } else {
                                      Fluttertoast.showToast(msg: "Debe Registrar una firma");
                                    }
                                  },
                                  style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.tertiaryContainer),
                                      foregroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onPrimaryFixed)),
                                  child: Text("Siguiente"))
                            ]))
                      ],
                    ),
                  ],
                )
              : SizedBox(),
          // ENCUESTA
          _dataProc[1] && !_dataProc[2]
              ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: encuestaSimpleContainer(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: () async{
                        user = await datosUsuario();
                        bool isEncuestaCompleta() => kEncuestaRespuestas.every((v) => v != null);
                        if (isEncuestaCompleta()) {
                          final basicAuth = 'Basic ${base64Encode(utf8.encode('${user['user']}:${user['pass']}'))}';
                          var response = await dio.request("$link/api_mobile/apk_tripulacion/registrar_encuesta_postservicio/", options: Options(headers: {'Authorization': basicAuth}, method: 'POST'), data: {
                            "pe_key_detalle_hoja_ruta_id": widget.item['id_detalle_hoja_ruta'],
                            "pe_calificacion_puntualidad": kEncuestaRespuestas[0],
                            "pe_calificacion_amabilidad": kEncuestaRespuestas[1],
                            "pe_calificacion_limpieza_vehiculo": kEncuestaRespuestas[2],
                          });
                          print(response);
                          if (response.statusCode == 200) {
                            setState(() {
                              _dataProc[2] = true;
                            });

                          }else {
                            Fluttertoast.showToast(msg: "Error ${response.statusMessage}");
                          }
                        } else {
                          Fluttertoast.showToast(
                            msg: "Por favor, completa la encuesta.",
                            backgroundColor: Colors.amber.withOpacity(0.5),
                          );
                        }
                      },
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.tertiaryContainer),
                          foregroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onPrimaryFixed)),
                      child: Text("Siguiente"))
                ],
              ),
            ],
          )
              : SizedBox(),
          // FOTO
          _dataProc[2] && !_dataProc[3]
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton.icon(
                              iconAlignment: IconAlignment.end,
                              icon: Icon(Icons.camera_alt_outlined),
                              onPressed: _tomarFoto,
                              label: const Text(
                                "FOTO",
                                textScaleFactor: 1,
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ))
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    _fileFoto != null
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                                child: Image.file(
                              _fileFoto!,
                              height: 200,
                            )))
                        : Container(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              if (_fileFoto.toString().trim() != '' && _fileFoto != null) {
                                setState(() {
                                  _dataProc[3] = true;
                                });
                              } else {
                                Fluttertoast.showToast(msg: "Debe Registrar una Foto");
                              }
                            },
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.tertiaryContainer),
                                foregroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onPrimaryFixed)),
                            child: Text("Siguiente"))
                      ],
                    ),
                  ],
                )
              : SizedBox(),
          // CONFIRMAR
          _dataProc[3] && !_dataProc[4]
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    const SizedBox(height: 7),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(textScaleFactor: 1, "IMPORTE:  ${widget.item['importe']}"),
                          Text(textScaleFactor: 1, "CONFORMIDAD: ${widget.item['contacto1'].toString().split('[')[0]}"),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _fileFoto != null
                                  ? Image.file(
                                      _fileFoto!,
                                      width: 80,
                                      height: 150,
                                      fit: BoxFit.contain,
                                    )
                                  : Text(
                                      "Sin Foto",
                                      textScaleFactor: 1,
                                    ),
                              firma != null
                                  ? Image.file(
                                      File(firma!),
                                      width: 80,
                                      height: 150,
                                      fit: BoxFit.contain,
                                    )
                                  : Text(
                                      "Dibujar Firma",
                                      textScaleFactor: 1,
                                    ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            user = await datosUsuario();
                            final basicAuth = 'Basic ${base64Encode(utf8.encode('${user['user']}:${user['pass']}'))}';
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return const AlertDialog(
                                  content: Row(
                                    children: [
                                      CircularProgressIndicator(),
                                      SizedBox(width: 20),
                                      Text("Cargando..."),
                                    ],
                                  ),
                                );
                              },
                            );

                            List<MultipartFile> firma_ = [];
                            String nombrefirma = '';
                            if (firma != null) {
                              nombrefirma = firma.toString().split('cache/').last; // Extraer el nombre del archivo
                              MultipartFile firmaz = await MultipartFile.fromFile(firma, filename: nombrefirma);
                              firma_.add(firmaz);
                            }
                            List<MultipartFile> foto_ = [];
                            String nombrefoto = '';
                            if (_fileFoto != null) {
                              nombrefoto = _fileFoto!.path.toString().split('cache/').last;
                              MultipartFile fotox = await MultipartFile.fromFile(_fileFoto!.path, filename: nombrefoto);
                              foto_.add(fotox);
                            }
                            FormData formData = FormData.fromMap({
                              "pe_user_id": widget.user['user_id'],
                              "pe_key_detalle_hoja_ruta_id": widget.item['id_detalle_hoja_ruta'],
                              "pe_ruta_firma": nombrefirma,
                              "file": firma_,
                              "pe_ruta_foto": nombrefoto,
                              "pe_foto_contacto": foto_,
                              "pe_validacion_contacto": _validated ? 1 : 0,
                              "pe_dni_contacto": _controllerDNIval.text,
                              "pe_nombre_contacto": _controllerNombreVal.text,
                              "pe_observacion_contacto": _controllerObservVal.text
                            });
                            var response = await dio.request('$link/api_mobile/apk_tripulacion/fin_servicio/',
                                options: Options(method: 'POST', headers: {'Authorization': basicAuth, 'Content-Type': 'multipart/form-data'}), data: formData);
                            Navigator.of(context).pop();
                            if (response.statusCode == 200) {
                              Fluttertoast.showToast(msg: response.data['message']);
                              await UpdateList(widget.item['id_pedido']);
                            } else {
                              Fluttertoast.showToast(msg: response.statusMessage ?? response.data['message']);
                            }
                          },
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.tertiaryContainer),
                              foregroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onPrimaryFixed)),
                          child: Text(
                            "CONFIRMAR",
                            textScaleFactor: 1,
                          ),
                        )
                      ],
                    ),
                  ],
                )
              : SizedBox(),
        ],
      ),
    );
  }

  File? _fileImage;
  File? _fileFoto;
  final ImagePicker _picker = ImagePicker();

  void _takePhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _fileImage = File(pickedFile.path);
      });
    }
  }

  void _tomarFoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _fileFoto = File(pickedFile.path);
      });
    }
  }

  void _addParada() async {
    List<MultipartFile> files = [];
    if (_controllerComprobante.text.isNotEmpty) {
      if (_fileImage != null) {
        MultipartFile arcparada = await MultipartFile.fromFile(_fileImage!.path, filename: _fileImage!.path.split('cache/')[1]);
        files.add(arcparada);
      }
      FormData formData = FormData.fromMap({
        'pe_motivo_falsa_parada': _controllerComprobante.text,
        'pe_ruta_foto': files.length > 0 ? _fileImage!.path.split('cache/')[1] : '',
        'pe_user_id': widget.user['user_id'],
        "pe_key_detalle_hoja_ruta_id": widget.item['id_detalle_hoja_ruta'],
        'file': files,
      });

      try {
        user = await datosUsuario();
        final basicAuth = 'Basic ${base64Encode(utf8.encode('${user['user']}:${user['pass']}'))}';
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
        var response = await dio.request('$link/api_mobile/apk_tripulacion/generar_falsa_parada/', options: Options(method: 'POST', headers: {'Authorization': basicAuth, 'Content-Type': 'multipart/form-data'}), data: formData);
        if (response.statusCode == 200) {
          Navigator.pop(context);
          Fluttertoast.showToast(msg: response.data['message']);
        }
        Navigator.of(context).pop();
      } catch (e) {
        Fluttertoast.showToast(msg: "ERROR. Se debe cargar Foto del Local.");
        Navigator.of(context).pop();
      }
    } else {
      Fluttertoast.showToast(msg: "Complete los Datos de Parada");
    }
  }

  void _viewImage(String imagePath) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
            Image.file(File(imagePath)),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cerrar'))
          ]));
        });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.onPrimaryFixed,
            title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('MICROCASH', textScaleFactor: 1, style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
              Text(DateFormat('dd MMM yyyy hh:mma', 'es_ES').format(_currentDateTime), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13))
            ]),
            foregroundColor: Colors.white),
        body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.sizeOf(context).height,
            padding: const EdgeInsets.only(top: 16, left: 17, right: 17),
            color: Theme.of(context).colorScheme.onPrimary,
            child: Column(
              children: [
                WidgetDatos(context, widget.item),
                if (widget.filtroStado == 1 && widget.item['key_estado_hoja_id'] == '70e06ba0-9745-4c9c-95b4-edde04779dc1')
                  _selectedService == ''
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedService = 'ATENCIÓN SERVICIO';
                                });
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.tertiaryContainer),
                                foregroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onPrimaryFixed),
                              ),
                              child: const Text('ATENCIÓN\nSERVICIO', textScaleFactor: 1, style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedService = 'FALSA PARADA';
                                });
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.tertiaryContainer),
                                foregroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onPrimaryFixed),
                              ),
                              child: const Text('FALSA\nPARADA', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                            ),
                          ],
                        )
                      : Stack(children: [
                          Container(
                              alignment: Alignment.center,
                              width: MediaQuery.sizeOf(context).width,
                              padding: EdgeInsets.all(MediaQuery.sizeOf(context).height * 0.005),
                              color: Colors.grey[400],
                              child: Column(
                                children: [
                                  Text(_selectedService, textScaleFactor: 1, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                  Text("(${widget.item['modalidad_servicio']})", textScaleFactor: 1, style: const TextStyle(fontSize: 11)),
                                ],
                              ))
                        ]),
                const SizedBox(height: 12),
                if (_selectedService.isNotEmpty)
                  _selectedService == 'ATENCIÓN SERVICIO'
                      ? Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(child: _buildButton('Llegada\npunto', 'fecha_hora_llegada', 1)),
                                Expanded(child: _buildButton('Inicio\nServicio', 'fecha_hora_inicio_servicio', 2)),
                                Expanded(child: _buildButton('Fin\nServicio', 'fecha_hora_fin_servicio', 3)),
                                Expanded(child: _buildButton('Salida\nPunto', 'fecha_hora_salida', 4)),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _selectedService == 'ATENCIÓN SERVICIO' && widget.item['fecha_hora_inicio_servicio'] != null && widget.item['fecha_hora_fin_servicio'] == null ? FormularioFinServicio() : SizedBox(),
                          ],
                        )
                      : Container(
                          width: MediaQuery.sizeOf(context).width,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _controllerComprobante,
                                decoration: const InputDecoration(
                                  labelText: 'Motivo',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 20),
                              _fileImage != null
                                  ? Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Center(
                                        child: Image.file(
                                          _fileImage!,
                                          height: 100,
                                        ),
                                      ),
                                    )
                                  : Container(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    onPressed: _takePhoto,
                                    child: Text('Foto Local'),
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.tertiaryContainer),
                                      foregroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onPrimaryFixed),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: _addParada,
                                    child: Text('Confirmar'),
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.tertiaryContainer),
                                      foregroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onPrimaryFixed),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                            ],
                          ),
                        ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> UpdateList(String idPedido) async {
    var fecha = widget.fecha;
    user = await datosUsuario();
    final basicAuth = 'Basic ${base64Encode(utf8.encode('${user['user']}:${user['pass']}'))}';
    var rpa = await dio.request(
      '$link/api_mobile/apk_tripulacion/listar_pedidos/?pe_user_id=${widget.user['user_id']}&pe_fecha_atencion=${fecha.split(' ')[0]}&pe_key_estado_plan_diario=EN RUTA',
      options: Options(method: 'GET', headers: {'Authorization': basicAuth}),
    );
    setState(() {
      widget.item = rpa.data['resultSet'].firstWhere((item) => item['id_pedido'] == idPedido);
    });
  }
}

Widget WidgetDatos(BuildContext context, Map<String, dynamic> item) {
  return Stack(
    children: [
      Column(
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
                        "Secuencias: ${item['secuencia']}      AAHH: ${item['aahh']}",
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
            "${item['punto_asociado']}",
            textScaleFactor: 1,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            item['direccion_punto'],
            textScaleFactor: 1,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              Text(
                "SERIAL DEL MALETÍN: ",
                textScaleFactor: 1,
                style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
              ),
              Text(item['lonchera']),
            ],
          ),
          Row(children: [
            Text(
              "BULTO: ",
              textScaleFactor: 1,
              style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
            ),
            Flexible(
              child: Text(
                "${item['envase']}",
                textScaleFactor: 1,
                style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.primary),
              ),
            )
          ]),
          ...item.entries.where((entry) => entry.key.startsWith('contacto')).map((entry) {
            // Dividir el valor del contacto en nombre y número
            final match = RegExp(r'(.+?)\s+\[(\d+)\]').firstMatch(entry.value.toString());
            if (match != null) {
              final nombre = match.group(1); // Captura el nombre
              final numero = match.group(2); // Captura el número
              // Buscar el DNI relacionado en las claves 'dni_contacto_ope' o 'dni_contacto_ope2'
              final dniKey = entry.key.endsWith('1')
                  ? 'dni_contacto_ope'
                  : entry.key.endsWith('2')
                      ? 'dni_contacto_ope2'
                      : null;
              final dni = dniKey != null && item.containsKey(dniKey) ? item[dniKey].toString() : 'DNI NO DISPONIBLE';
              return Text(
                '${entry.key.toString().toUpperCase()}: $nombre $dni [$numero]',
                textScaleFactor: 1,
                style: const TextStyle(fontSize: 13),
              );
            }
            // Si el formato no coincide, mostrar el valor original
            return Text(
              '${entry.key.toString().toUpperCase()}: ${entry.value.toString()}',
              textScaleFactor: 1,
              style: const TextStyle(fontSize: 13),
            );
          }),
          Text(
            "IMPORTE: ${item['importe']}",
            textScaleFactor: 1,
            style: const TextStyle(
              fontSize: 13,
            ),
          ),
          Text("${item['modalidad_servicio']}", textScaleFactor: 1, style: const TextStyle(fontSize: 13)),
          SizedBox(height: 7)
        ],
      ),
      Positioned(
        right: 12,
        bottom: 12, // o top: 12 si lo quieres arriba
        child: ElevatedButton.icon(
            onPressed: () =>
                _mostrarImagenDialog(context, item['ruta_foto_url']),
            icon: const Icon(Icons.image, size: 16, color: Colors.white),
            label: const Text(
              "Foto",
              style: TextStyle(fontSize: 12, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade300,
              // rojo bajito
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            )),
      ),
    ],
  );
}

void _mostrarImagenDialog(BuildContext context, String? url) async {
  // 1) Validar URL
  if (url == null || url.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No hay URL de imagen')),
    );
    return;
  }

  // 2) Opcional: precargar para detectar errores antes de abrir
  final imageProvider = NetworkImage(url);
  try {
    await precacheImage(imageProvider, context);
  } catch (_) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No se pudo precargar la imagen')),
    );
    // igual abrimos el diálogo para mostrar el errorBuilder
  }

  // 3) Abrir diálogo con constraints y zoom
  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black54,
    builder: (ctx) {
      final size = MediaQuery.of(ctx).size;
      final maxW = math.min(size.width * 0.95, 1200.0);
      final maxH = math.min(size.height * 0.9, 900.0);
      final controller = TransformationController();

      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        child: Stack(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxW, maxHeight: maxH),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    color: Colors.black,
                    child: StatefulBuilder(
                      builder: (ctx2, setState) {
                        final controller = TransformationController();
                        ImageStreamListener? listener;

                        void _setInitialFit(Size imgSize, Size viewport) {
                          final iw = imgSize.width, ih = imgSize.height;
                          final vw = viewport.width, vh = viewport.height;
                          final scale = math.min(vw / iw, vh / ih); // contain
                          final tx = (vw - iw * scale) / 2; // centrar X
                          final ty = (vh - ih * scale) / 2; // centrar Y
                          controller.value = Matrix4.identity()
                            ..translate(tx, ty)
                            ..scale(scale);
                        }

                        return LayoutBuilder(
                          builder: (ctx3, cons) {
                            final viewport =
                                Size(cons.maxWidth, cons.maxHeight);

                            // preparar stream para conocer tamaño real de la imagen
                            final image = Image.network(url);
                            final stream =
                                image.image.resolve(const ImageConfiguration());

                            listener ??= ImageStreamListener((info, _) {
                              _setInitialFit(
                                Size(info.image.width.toDouble(),
                                    info.image.height.toDouble()),
                                viewport,
                              );
                              // quitamos el listener luego de la primera vez
                              stream.removeListener(listener!);
                            });

                            // Añadir listener (idempotente)
                            stream.addListener(listener!);

                            return GestureDetector(
                              onDoubleTapDown: (d) {
                                final m = controller.value;
                                final zoomed = m.getMaxScaleOnAxis() > 1.05;
                                if (zoomed) {
                                  // volver al “fit to contain” centrado
                                  // ojo: si quieres recordar el viewport, vuelve a calcular con _setInitialFit
                                  _setInitialFit(
                                    // usamos el último tamaño conocido; si no lo tienes, puedes volver a pedirlo
                                    Size(cons.maxWidth, cons.maxHeight),
                                    Size(cons.maxWidth, cons.maxHeight),
                                  );
                                } else {
                                  const z = 2.5;
                                  // zoom hacia el punto tocado
                                  final f = d.localPosition;
                                  controller.value = controller.value
                                    ..translate(
                                        -f.dx * (z - 1), -f.dy * (z - 1))
                                    ..scale(z);
                                }
                                setState(() {});
                              },
                              child: InteractiveViewer(
                                transformationController: controller,
                                minScale: 0.5,
                                maxScale: 6,
                                panEnabled: true,
                                clipBehavior: Clip.none,
                                constrained: false,
                                // permite crecer
                                boundaryMargin: const EdgeInsets.all(80),
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  // importante: sin BoxFit para que respete tamaño real
                                  child: image,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Material(
                color: Colors.black54,
                shape: const CircleBorder(),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
