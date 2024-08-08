import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as ima;
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';
import 'package:intl/intl.dart';
import 'home.dart';

class Services extends StatefulWidget {
  final dynamic item;
  final dynamic user;

  Services({required this.item, required this.user});

  @override
  State<Services> createState() => _ServicesState();
}

class _ServicesState extends State<Services> {
  late Timer _timer;
  DateTime _currentDateTime = DateTime.now();
  String _selectedService = '';

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
      setState(() {
        _currentDateTime = DateTime.now();
        data['usuario'] = widget.user['name'];
        data['canje'] = '0001267';
      });
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
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 13),
              )
            ],
          ),
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.only(top: 16, left: 30, right: 30),
            color: Theme.of(context).colorScheme.onPrimary,
            child: Column(
              children: [
                WidgetDatos(context, widget.item),
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
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Theme.of(context)
                                      .colorScheme
                                      .tertiaryContainer),
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  Theme.of(context).colorScheme.onPrimaryFixed),
                            ),
                            child: const Text('ATENCIÓN SERVICIO',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedService = 'FALSA PARADA';
                              });
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Theme.of(context)
                                      .colorScheme
                                      .tertiaryContainer),
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  Theme.of(context).colorScheme.onPrimaryFixed),
                            ),
                            child: const Text('FALSA PARADA',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      )
                    : Stack(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            width: MediaQuery.sizeOf(context).width,
                            padding: const EdgeInsets.all(16),
                            color: Colors.grey[400],
                            child: Text(
                              _selectedService,
                              textScaleFactor: 1,
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            child: IconButton(
                              icon: Icon(Icons.close),
                              onPressed: _showExitConfirmationDialog,
                            ),
                          ),
                        ],
                      ),
                const SizedBox(height: 16),
                if (_selectedService.isNotEmpty)
                  _selectedService == 'ATENCIÓN SERVICIO'
                      ? Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildButton(
                                    'Llegada\nal punto', 'Llegada al punto', 0),
                                _buildButton(
                                    'Inicio\nServicio', 'Inicio Servicio', 1),
                                _buildButton(
                                    'Fin de\nServicio', 'Fin de Servicio', 2),
                                _buildButton(
                                    'Salida de\nPunto', 'Salida de Punto', 3),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _selectedService == "" 'ATENCIÓN SERVICIO' &&
                                    _isPressed[1] == true &&
                                    !_isPressed[2]
                                ? FormularioFinServicio()
                                : SizedBox()
                          ],
                        )
                      : Container(
                          width: MediaQuery.sizeOf(context).width,
                          padding: const EdgeInsets.all(16),
                          color: Colors.grey[200],
                          child: Text(
                            _selectedService,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  late Map<String, dynamic> data = {
    'Llegada al punto': null,
    'Inicio Servicio': null,
    'Fin de Servicio': null,
    'Salida de Punto': null,
    'canje': null,
    'num_serial': null,
    'billetes': [],
    'usuario': null,
    'firma': null
  };
  List<bool> _isPressed = [false, false, false, false];
  List<bool> _dataProc = [false, false, false, false];

  Widget _buildButton(String title, String key, int index) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            if (index == 0 || _isPressed[index - 1]) {
              if (index == 2 && !_dataProc[3]) {
                Fluttertoast.showToast(
                    msg: "Complete Los Datos ", backgroundColor: Colors.amber);
                return;
              } else {
                _updateTime(key, index);
              }
            } else {
              Fluttertoast.showToast(
                  msg: "Seleccione el paso correctamente ",
                  backgroundColor: Colors.amber);
            }
          },
          child: Container(
            height: 50,
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _isPressed[index] ? Colors.blue : Colors.grey,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(30.0),
                bottomLeft: Radius.circular(30.0),
              ),
            ),
            child: Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              textAlign: TextAlign.center,
              softWrap: true,
            ),
          ),
        ),
        Text(
          data[key] != null ? data[key]! : '',
          style:
              const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void _updateTime(String action, int index) {
    if (_isPressed[index]) return;

    String currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
    setState(
      () {
        _isPressed[index] = true;
        data[action] = currentTime;
      },
    );
  }

  void limpiarDatos() {
    setState(
      () {
        _selectedService = '';
        data = {
          'Llegada al punto': null,
          'Inicio Servicio': null,
          'Fin de Servicio': null,
          'Salida de Punto': null,
          'num_serial': null,
          'billetes': [],
          'firma': null
        };
        sigFirma.clear();
        _isPressed = [false, false, false, false];
        _dataProc = [false, false, false, false];
        _controllerSerial.text = '';
      },
    );
  }

  void _showExitConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alerta'),
          content: Text('¿Está seguro que desea salir?'),
          actions: <Widget>[
            TextButton(
              child: Text('Salir'),
              onPressed: () {
                setState(() {
                  limpiarDatos();
                });
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  late final TextEditingController _controllerSerial = TextEditingController();
  late final TextEditingController _controllerSerieB = TextEditingController();
  SignatureController sigFirma = SignatureController(
      penStrokeWidth: 1.5,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
      exportPenColor: Colors.black);

  Widget FormularioFinServicio() {
    String seriales = '';
    if (data['billetes'] != null && data['billetes'] is List) {
      List<String> serialesList = [];
      for (var billete in data['billetes']) {
        serialesList.add(billete['Serie']);
      }
      seriales = serialesList.join(', ');
    }
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.6,
      child: Column(
        children: [
          !_dataProc[0]
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    const SizedBox(height: 10),
                    const Center(
                      child: Text(
                        " BILLETES SOSPECHOSOS",
                        textScaleFactor: 1,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        data['billetes'] != null
                            ? Text(
                                "CANTIDAD DE BILLETES SOSPECHOSOS  ${data['billetes'].length}",
                              )
                            : SizedBox()
                      ],
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _controllerSerieB,
                      decoration: InputDecoration(
                        labelText: 'Serial de Billete',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    _billeteImage != null
                        ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Image.file(
                                _billeteImage!,
                                height: 120,
                              ),
                          ),
                        )
                        : Container(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: _takePhoto,
                          child: Text('Foto Billete'),
                        ),
                        ElevatedButton(
                          onPressed: _addBillete,
                          child: Text('Agregar Billete'),
                        ),

                      ],
                    ),

                    SizedBox(height: 10),
                    data['billetes'].length>0?Container(
                      height: 200,
                      child: ListView.builder(
                        itemCount: data['billetes'].length,
                        itemBuilder: (context, index) {
                          var billete = data['billetes'][index];
                          return ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${billete['Serie']}'),
                                Text(billete['image'] != null ? 'Ver' : 'Sin imagen')
                              ],
                            ),
                            onTap: billete['image'] != null
                                ? () => _viewImage(billete['image'])
                                : null,
                          );
                        },
                      ),
                    ):SizedBox(),
                      SizedBox(height: 10),
                    Container(
                      width: MediaQuery.sizeOf(context).width,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(
                            () {
                              _dataProc[0] = true;
                            },
                          );
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
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Flexible(child: Text("NUMERO DE SERIAL")),
                        SizedBox(width: 8),
                        Flexible(
                          child: TextFormField(
                            controller: _controllerSerial,
                            onChanged: (value) {
                              data['num_serial'] = value;
                            },
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              hintText: 'Ingrese Serial',
                              enabledBorder: OutlineInputBorder(
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(10.0)),
                                borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 40),
                    Container(
                      width: MediaQuery.sizeOf(context).width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _dataProc[0] = false;
                              });
                            },
                            child: Text("Atras"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                if (data['num_serial'].toString().trim() !=
                                        '' &&
                                    data['num_serial'] != null) {
                                  _dataProc[1] = true;
                                } else {
                                  Fluttertoast.showToast(
                                      msg: "Debe Ingresar Serial");
                                }
                              });
                            },
                            child: Text("Siguiente"),
                          ),
                        ],
                      ),
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
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(5.0),
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
                                    data['firma'] = null;
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
                                      Fluttertoast.showToast(
                                          msg: "No Eiste Firma para Registrar");
                                      return;
                                    }
                                    Uint8List recorder =
                                        await sigFirma.toPngBytes() ??
                                            Uint8List(0);
                                    final tempDir =
                                        await getTemporaryDirectory();
                                    final filePath =
                                        '${tempDir.path}/firma_${DateTime.now().toString().split('.')[0].replaceAll('-', '').replaceAll(':', '').replaceAll(' ', '')}.jpg';
                                    var image = ima.decodeImage(
                                        Uint8List.fromList(recorder));
                                    File(filePath).writeAsBytesSync(
                                        ima.encodePng(image!));
                                    setState(() {
                                      data['firma'] = filePath;
                                    });
                                    Fluttertoast.showToast(
                                        backgroundColor: Colors.blue,
                                        msg: "Firma Capturada");
                                  },
                                  icon: Icon(Icons.save_as_outlined,
                                      color: Colors.blue),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _dataProc[1] = false;
                                  });
                                },
                                child: Text("Atras"),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  if (data['firma'].toString().trim() != '' &&
                                      data['firma'] != null) {
                                    setState(() {
                                      _dataProc[2] = true;
                                    });
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: "Debe Registrar una firma");
                                  }
                                },
                                child: Text("Siguiente"),
                              )
                            ],
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
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("CS CANJE: ${data['canje']}"),
                          Text("IMPORTE:  ${widget.item['importe']}"),
                          if (data['billetes'] != null) ...[
                            Text(
                                "BILLETES SOSPECHOSOS:  ${data['billetes'].toList().length}"),
                            Text("SERIALES: $seriales"),
                          ],
                          Text("ENVASE SERIAL: ${data['num_serial']}"),
                          Text("CONFORMIDAD: ${widget.user['name']}"),
                          SizedBox(
                            height: 15,
                          ),
                          Center(
                            child: data['firma'] != null
                                ? Image.file(
                                    File(data['firma']!),
                                    width: 150,
                                    height: 100,
                                    fit: BoxFit.contain,
                                  )
                                : Text("Dibujar Firma"),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _dataProc[2] = false;
                              _dataProc[3] = false;
                            });
                          },
                          child: Text("Atras"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _dataProc[3] = true;
                            });
                            if (data['firma'].toString().trim() != '' &&
                                data['firma'] != null) {
                              print(data);
                            } else {
                              Fluttertoast.showToast(
                                  msg: "Debe Registrar una firma");
                            }
                          },
                          child: Text("CONFIRMAR"),
                        )
                      ],
                    ),
                  ],
                )
              : SizedBox(),
          _dataProc[3]
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _dataProc[3] = false;
                        });
                      },
                      child: Text("Atras"),
                    ),
                  ],
                )
              : SizedBox(),
        ],
      ),
    );
  }

  File? _billeteImage;
  final ImagePicker _picker = ImagePicker();

  void _addBillete() {
    if (_controllerSerieB.text.isNotEmpty) {
      // && _billeteImage != null
      var billete = {
        'Serie': _controllerSerieB.text,
        'image': _billeteImage != null ? _billeteImage!.path : null,
      };
      setState(
        () {
          data['billetes'].add(billete);
          _controllerSerieB.clear();
          _billeteImage = null;
        },
      );
    }
  }

  void _takePhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _billeteImage = File(pickedFile.path);
      });
    }
  }

  void _viewImage(String imagePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.file(File(imagePath)),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cerrar'),
              ),
            ],
          ),
        );
      },
    );
  }
}
