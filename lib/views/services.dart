import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  var selectMotivo;

  int estado_plan = 0;
  int estado_detalle = 0;
  List arrbilletes = [];
  var firma;
  var serial = '';
  late final TextEditingController _controllerSerial = TextEditingController();
  late final TextEditingController _controllerSerieB = TextEditingController();

  @override
  void initState() {
    obtenerDatos();
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
      setState(() {
        _currentDateTime = DateTime.now();
      });
    });
    estado_plan = widget.item['key_estado_plan_id'];
    estado_detalle = widget.item['key_estado_detalle_hoja_id'];
    if (widget.item['fecha_hora_llegada'] != null) {
      _selectedService = 'ATENCIÓN SERVICIO';
    }
  }

  obtenerDatos() async {
    var response = await dio.request(
      '$link/api_mobile/apk_tripulación/siguiente_cv/',
      options: Options(
        method: 'GET',
      ),
    );
    comprobante = (response.data['resultSet'][0]) ?? {};
    _controllerComprobante.text = (response.data['resultSet'][0]['correlativo']) ?? {};

    var response2 = await dio.request(
      '$link/tablas/motivo/listar/?key_estado_id=1',
      options: Options(
        method: 'GET',
      ),
    );
    motivos = response2.data['resultSet'];
  }

  List<bool> _dataProc = [false, false, false, false];

  Widget _buildButton(String title, String key, int index) {
    return Column(
      children: [
        GestureDetector(
          onTap: () async {
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
            print("$estado_plan  $estado_detalle");
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
              } else {
                if (index != 3) {
                  FormData formData = FormData.fromMap({
                    "pe_etapa_atencion": index,
                    "pe_user_id": widget.user['user_id'],
                    "pe_key_detalle_hoja_ruta_id": widget.item['id_detalle_hoja_ruta'],
                    "pe_serial_envase": "",
                    "pe_seriales_billetes": "",
                    "pe_ruta_firma": ""
                  });
                  var response = await dio.request('$link/api_mobile/apk_tripulación/atencion_servicio/', options: Options(method: 'POST', headers: {'Content-Type': 'multipart/form-data'}), data: formData);
                  if (response.statusCode == 200) {
                    Fluttertoast.showToast(msg: response.data['message']);
                    await UpdateList(widget.item['id_pedido']);
                  } else {
                    print(response.statusMessage);
                  }
                }
              }
            } else {
              Fluttertoast.showToast(msg: "Seleccione el paso correctamente ");
            }
            Navigator.of(context).pop();

            if (index == 4) {
              Navigator.of(context).pop();
            }
          },
          child: Container(
            height: 50,
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: widget.item[key] != null ? Colors.blue : Colors.grey,
            ),
            child: Text(
              title,
              style: TextStyle(color: Colors.white, fontSize: MediaQuery.sizeOf(context).width * 0.032),
              textScaleFactor: 1,
              textAlign: TextAlign.center,
              softWrap: true,
            ),
          ),
        ),
        Text(
          "${widget.item[key] != 'null' && widget.item[key] != null ? widget.item[key].toString().replaceAll(' ', '\n') : ''}",
          textScaleFactor: 1,
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: MediaQuery.sizeOf(context).width * 0.032),
        ),
      ],
    );
  }

  SignatureController sigFirma = SignatureController(penStrokeWidth: 1.5, penColor: Colors.black, exportBackgroundColor: Colors.white, exportPenColor: Colors.black);

  Widget FormularioFinServicio() {
    String seriales = '';
    if (arrbilletes != null && arrbilletes is List) {
      List<String> serialesList = [];
      for (var billete in arrbilletes) {
        serialesList.add(billete['Serie']);
      }
      seriales = serialesList.join(', ');
    }
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.55,
      child: Column(
        children: [
          !_dataProc[0]
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    const SizedBox(height: 7),
                    const Center(
                      child: Text(
                        "BILLETES SOSPECHOSOS",
                        textScaleFactor: 1,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(children: [
                      arrbilletes != null
                          ? Text(
                              "CANTIDAD DE BILLETES SOSPECHOSOS  ${arrbilletes.length}",
                              textScaleFactor: 1,
                              style: TextStyle(fontSize: 13),
                            )
                          : SizedBox()
                    ]),
                    SizedBox(height: 12),
                    TextFormField(controller: _controllerSerieB, decoration: InputDecoration(labelText: 'Serial de Billete', border: OutlineInputBorder())),
                    SizedBox(height: 12),
                    _fileImage != null
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Image.file(
                                _fileImage!,
                                height: 120,
                              ),
                            ),
                          )
                        : Container(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.tertiaryContainer),
                            foregroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onPrimaryFixed),
                          ),
                          onPressed: _takePhoto,
                          child: Text(
                            'Foto\nBillete',
                            textAlign: TextAlign.center,
                            textScaleFactor: 1,
                          ),
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.tertiaryContainer),
                            foregroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onPrimaryFixed),
                          ),
                          onPressed: _addBillete,
                          child: Text(
                            'Agregar\nBillete',
                            textAlign: TextAlign.center,
                            textScaleFactor: 1,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    arrbilletes.length > 0
                        ? Container(
                            height: int.parse(arrbilletes.length.toString()) * 50,
                            child: ListView.builder(
                              physics: BouncingScrollPhysics(),
                              itemCount: arrbilletes.length,
                              itemBuilder: (context, index) {
                                var billete = arrbilletes[index];
                                return ListTile(
                                  title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('${billete['Serie']}'), Text(billete['image'] != null ? 'Ver' : 'Sin imagen')]),
                                  onTap: billete['image'] != null ? () => _viewImage(billete['image']) : null,
                                );
                              },
                            ),
                          )
                        : SizedBox(),
                    Container(
                      width: MediaQuery.sizeOf(context).width,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.tertiaryContainer),
                          foregroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onPrimaryFixed),
                        ),
                        onPressed: () {
                          if (arrbilletes.length == 0) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("¿Estás seguro?"),
                                  content: Text("No hay billetes en la lista. ¿Deseas continuar?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("Cancelar"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _dataProc[0] = true;
                                        });
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("Continuar"),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            setState(() {
                              _dataProc[0] = true;
                            });
                          }
                        },
                        child: Text("Siguiente"),
                      ),
                    )
                  ],
                )
              : SizedBox(),
          _dataProc[0] && !_dataProc[1]
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    const SizedBox(height: 10),
                    const Center(
                      child: Text(
                        "REGISTRE SERIAL DE ENVASE\nMICROCASH",
                        textScaleFactor: 1,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 40),
                    TextFormField(
                      controller: _controllerSerial,
                      decoration: const InputDecoration(
                        labelText: 'Número de Serial',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        serial = value;
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.tertiaryContainer),
                            foregroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onPrimaryFixed),
                          ),
                          onPressed: () async {
                            if (serial.toString().trim() == '' || serial == null) {
                              Fluttertoast.showToast(msg: "Debe Ingresar Serial");
                              return;
                            }
                            var response = await dio.request(
                              '$link/api_mobile/apk_tripulación/validar_envase_recojo/?pe_serial_envase=${_controllerSerial.text}',
                              options: Options(
                                method: 'GET',
                              ),
                            );
                            if (response.data['resultSet'][0]['validator']) {
                              setState(() {
                                _dataProc[1] = true;
                              });
                            } else {
                              Fluttertoast.showToast(msg: response.data['resultSet'][0]['message']);
                            }
                          },
                          child: Text("Siguiente"),
                        ),
                      ],
                    )
                  ],
                )
              : SizedBox(),
          _dataProc[1] && !_dataProc[2]
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    const SizedBox(height: 10),
                    const Center(
                      child: Text(
                        "FIRMA DEL CONTACTO",
                        textScaleFactor: 1,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: Signature(
                              controller: sigFirma,
                              height: 220,
                              backgroundColor: Colors.grey.shade100,
                            ),
                          ),
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.clear, color: Colors.red),
                                  onPressed: () {
                                    sigFirma.clear();
                                    firma = null;
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.undo, color: Colors.amber),
                                  onPressed: () {
                                    sigFirma.undo();
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.redo, color: Colors.amber),
                                  onPressed: () {
                                    sigFirma.redo();
                                  },
                                ),
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
                                  icon: Icon(Icons.save_as_outlined, color: Colors.blue),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 5),
                          ElevatedButton(
                            onPressed: () {
                              if (firma.toString().trim() != '' && firma != null) {
                                setState(() {
                                  _dataProc[2] = true;
                                });
                              } else {
                                Fluttertoast.showToast(msg: "Debe Registrar una firma");
                              }
                            },
                            child: Text("Siguiente"),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : SizedBox(),
          _dataProc[2] && !_dataProc[3]
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
                          Text(textScaleFactor: 1, "CS CANJE:  ${widget.item['comprobante_servicio']}"),
                          Text(textScaleFactor: 1, "IMPORTE:  ${widget.item['importe']}"),
                          if (arrbilletes != null) ...[
                            Text(textScaleFactor: 1, "BILLETES SOSPECHOSOS:  ${arrbilletes.toList().length}"),
                            arrbilletes.toList().length!=0?Text(textScaleFactor: 1, "SERIALES: $seriales"):SizedBox(),
                          ],
                          Text(textScaleFactor: 1, "ENVASE SERIAL: ${serial}"),
                          Text(textScaleFactor: 1, "CONFORMIDAD: ${widget.user['name']}"),
                          const SizedBox(height: 15),
                          Center(
                            child: firma != null
                                ? Image.file(
                                    File(firma!),
                                    width: 150,
                                    height: 100,
                                    fit: BoxFit.contain,
                                  )
                                : Text(
                                    "Dibujar Firma",
                                    textScaleFactor: 1,
                                  ),
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
                            if (firma.toString().trim() != '' && firma != null) {
                              List<MultipartFile> billetesFiles = [];
                              for (var billete in arrbilletes) {
                                billetesFiles.add(await MultipartFile.fromFile(
                                  billete['image'], // Ruta del archivo de imagen
                                  filename: billete['Serie'], // Nombre del archivo (el serial del billete)
                                ));
                              }

                              List<MultipartFile> firma_ = [];
                              String nombrefirma = '';
                              if (firma != null) {
                                nombrefirma = firma.toString().split('cache/').last; // Extraer el nombre del archivo
                                MultipartFile firmaz = await MultipartFile.fromFile(firma, filename: nombrefirma);
                                firma_.add(firmaz);
                              }

                              FormData formData = FormData.fromMap({
                                "pe_etapa_atencion": 3,
                                "pe_user_id": widget.user['user_id'],
                                "pe_key_detalle_hoja_ruta_id": widget.item['id_detalle_hoja_ruta'],
                                "pe_serial_envase": serial,
                                "pe_seriales_billetes": billetesFiles,
                                "pe_ruta_firma": nombrefirma,
                                "file": firma_
                              });
                              print(serial);
                              var response = await dio.request('$link/api_mobile/apk_tripulación/atencion_servicio/', options: Options(method: 'POST', headers: {'Content-Type': 'multipart/form-data'}), data: formData);
                              if (response.statusCode == 200) {
                                print(response.data);
                                Fluttertoast.showToast(msg: response.data['message']);
                                await UpdateList(widget.item['id_pedido']);
                              } else {
                                print(response.statusMessage);
                              }
                            } else {
                              Fluttertoast.showToast(msg: "Debe Registrar una firma");
                            }
                          },
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
  final ImagePicker _picker = ImagePicker();

  void _addBillete() {
    if (_controllerSerieB.text.isNotEmpty && _fileImage != null) {
      var billete = {
        'Serie': _controllerSerieB.text,
        'image': _fileImage != null ? _fileImage!.path : null,
      };
      setState(
        () {
          arrbilletes.add(billete);
          _controllerSerieB.clear();
          _fileImage = null;
        },
      );
    } else {
      Fluttertoast.showToast(msg: "Datos Incompletos ");
    }
  }

  void _takePhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _fileImage = File(pickedFile.path);
      });
    }
  }

  void _addParada() async {
    List<MultipartFile> files = [];
    if (_controllerComprobante.text.isNotEmpty && selectMotivo != null) {
      if (_fileImage != null) {
        MultipartFile arcparada = await MultipartFile.fromFile(_fileImage!.path, filename: _fileImage!.path.split('cache/')[1]);
        files.add(arcparada);
      }
      FormData formData = FormData.fromMap({
        'pe_key_detalle_correlativo_id': comprobante['id'],
        'pe_key_motivo_comprobante_visita_id': selectMotivo['id'],
        'pe_ruta_foto': files.length > 0 ? _fileImage!.path.split('cache/')[1] : '',
        'pe_key_asignacion_plan_diario_envase_id': widget.item['key_asignacion_plan_diario_envase_id'],
        'pe_user_id': widget.user['user_id'],
        "pe_key_detalle_hoja_ruta_id": widget.item['id_detalle_hoja_ruta'],
        'file': files,
      });

      var dio = Dio();
      try {
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
        var response = await dio.request('$link/api_mobile/apk_tripulación/generar_falsa_parada/', options: Options(method: 'POST', headers: {'Content-Type': 'multipart/form-data'}), data: formData);
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
                if (widget.filtroStado == 1 && widget.item['key_estado_plan_id'] == 22)
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
                              padding: const EdgeInsets.all(16),
                              color: Colors.grey[400],
                              child: Text(_selectedService, textScaleFactor: 1, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)))
                        ]),
                const SizedBox(height: 12),
                if (_selectedService.isNotEmpty)
                  _selectedService == 'ATENCIÓN SERVICIO'
                      ? Column(
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildButton('Llegada\nal punto', 'fecha_hora_llegada', 1),
                                  _buildButton('Inicio\nServicio', 'fecha_hora_inicio_servicio', 2),
                                  _buildButton('Fin de\nServicio', 'fecha_hora_fin_servicio', 3),
                                  _buildButton('Salida de\nPunto', 'fecha_hora_salida', 4),
                                ],
                              ),
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
                                enabled: _controllerComprobante.text.length == 0 ? true : false,
                                controller: _controllerComprobante,
                                decoration: const InputDecoration(
                                  labelText: 'Comprobante Visita',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 20),
                              DropdownButtonFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Motivos',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: motivos.map((item) {
                                    return DropdownMenuItem(value: item, child: Text(item['nombre']));
                                  }).toList(),
                                  onChanged: (value) {
                                    selectMotivo = value ?? {};
                                  }),
                              const SizedBox(height: 10),
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

  Future<void> UpdateList(int idPedido) async {
    var fecha = widget.fecha;
    var rpa = await dio.request(
      '$link/api_mobile/apk_tripulación/listar_pedidos/?pe_user_id=${widget.user['user_id']}&pe_fecha_atencion=${fecha.split(' ')[0]}&pe_key_estado_plan_diario=22',
      options: Options(
        method: 'GET',
      ),
    );
    setState(() {
      widget.item = rpa.data['resultSet'].firstWhere((item) => item['id_pedido'] == idPedido);
    });
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
          const Text(
            "SERIAL DE ENVASE:   ",
            textScaleFactor: 1,
            style: TextStyle(
              fontSize: 13,
            ),
          ),
          Text(item['lonchera']),
        ],
      ),
      ...item.entries.where((entry) => entry.key.startsWith('contacto')).map((entry) => Text('${entry.key.toString().toUpperCase()}: ${entry.value}', textScaleFactor: 1, style: TextStyle(fontSize: 13))),
      Text(
        "IMPORTE: ${item['importe']}",
        textScaleFactor: 1,
        style: const TextStyle(
          fontSize: 13,
        ),
      ),
      SizedBox(
        height: 7,
      )
    ],
  );
}
