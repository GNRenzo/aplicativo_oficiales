
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:microcash_tripulacion/views/home.dart';
import 'package:nb_utils/nb_utils.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String link = dotenv.env['LINK'] ?? "http://localhost:8000";

  int currentYear = DateTime.now().year;
  late final TextEditingController _controllerUser = TextEditingController();
  late final TextEditingController _controllerPassword =
      TextEditingController();

  bool isView = true;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  void _validateAndSubmit() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

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
                  Text('Iniciando Sesión...'),
                ],
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.onPrimary,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20))),
          );
        },
      );

      var dio = Dio();
      var datas = FormData.fromMap({
        'username': _controllerUser.text,
        'password': _controllerPassword.text
      });

      try {
        final response =
            await dio.post("$link/control_accesos/api-token/", data: datas);

        if (response.statusCode == 200) {
          Map<String, dynamic>? decodedToken =
              JwtDecoder.decode(response.data['access']);

          Map<String, dynamic> dataUser = {
            'user_id': decodedToken?['user_id'],
            'username': decodedToken?['username'],
            'name': decodedToken?['name'],
            'numero_documento': decodedToken?['numero_documento'],
            'email': decodedToken?['email'],
            'key_grupo_usuario_id': decodedToken?['key_grupo_usuario_id'],
            'key_tipo_usuario_id': decodedToken?['key_tipo_usuario_id']
          };

          Navigator.of(context).pop();
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => MyHomePage(
                    trabajador: dataUser,
                  )));
        }
      } on DioException catch (e) {
        final response = e.response;
        var err =
            'Código: 500 \n Error: No se pudo establecer la conexión con el servidor. Revise su conexión a internet e intentelo nuevamente en unos minutos.';

        if (response != null) {
          err = 'Credenciales Incorrectas';
        }

        toasty(context, "Credenciales incorrectas.",
            bgColor: Theme.of(context).colorScheme.error,
            textColor: Theme.of(context).colorScheme.onPrimary,
            gravity: ToastGravity.CENTER);

        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration:
                  BoxDecoration(color: Theme.of(context).colorScheme.onPrimary),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.only(left: 32, right: 32, bottom: 32),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.90,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 600) {
                      // Horizontal Layout
                      return Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Expanded(child: SizedBox()),
                                Column(
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Image.asset(
                                            "assets/images/logo_armadillo.png",
                                            fit: BoxFit.cover,
                                            width: 300)
                                      ],
                                    ),
                                  ],
                                ),
                                const Expanded(child: SizedBox()),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Expanded(child: SizedBox()),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 40),
                                      child: Text(
                                        'Tripulación',
                                        style: TextStyle(
                                            fontFamily: 'inter',
                                            fontWeight: FontWeight.w700,
                                            fontSize: 35,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Text("2.0.1",
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 32),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  height: 55,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _controllerUser.text = '';
                                        _controllerPassword.text = '';
                                        isView = true;
                                      });

                                      _showLoginModal(context);
                                    },
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Theme.of(context)
                                                  .colorScheme
                                                  .tertiaryContainer),
                                      foregroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Theme.of(context)
                                                  .colorScheme
                                                  .onPrimaryFixed),
                                    ),
                                    label: const Text(
                                      '  Iniciar Sesión',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    icon: const Icon(Icons.login_rounded),
                                  ),
                                ),
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  margin: const EdgeInsets.only(top: 32),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(" Todos los derechos reservados ",
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'inter',
                                              fontSize: 10)),
                                      Icon(
                                        Icons.copyright_rounded,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        size: 15,
                                      ),
                                      Text(" $currentYear",
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'inter',
                                              fontSize: 10)),
                                    ],
                                  ),
                                ),
                                const Expanded(child: SizedBox()),
                              ],
                            ),
                          ),
                        ],
                      );
                    } else {
                      // Vertical Layout
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(child: SizedBox()),
                          Column(
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Image.asset(
                                      "assets/images/logo_armadillo.png",
                                      fit: BoxFit.cover,
                                      width: 300)
                                ],
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 40),
                                child: Text(
                                  'Tripulación',
                                  style: TextStyle(
                                      fontFamily: 'inter',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 35,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Text("2.0.1",
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const Expanded(child: SizedBox()),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: 55,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _controllerUser.text = '';
                                      _controllerPassword.text = '';
                                      isView = true;
                                    });
                                    _showLoginModal(context);
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Theme.of(context)
                                                .colorScheme
                                                .tertiaryContainer),
                                    foregroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Theme.of(context)
                                                .colorScheme
                                                .onPrimaryFixed),
                                  ),
                                  label: const Text(
                                    '  Iniciar Sesión',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  icon: const Icon(Icons.login_rounded),
                                ),
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                margin: const EdgeInsets.only(top: 32),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(" Todos los derechos reservados ",
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'inter',
                                            fontSize: 10)),
                                    Icon(
                                      Icons.copyright_rounded,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      size: 15,
                                    ),
                                    Text(" $currentYear",
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'inter',
                                            fontSize: 10)),
                                  ],
                                ),
                              ),
                            ],
                          )
                        ],
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLoginModal(BuildContext context) {
    showModalBottomSheet<void>(
      showDragHandle: true,
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                  left: 32,
                  right: 32),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Iniciar Sesión',
                        style: TextStyle(
                            fontFamily: 'inter',
                            fontWeight: FontWeight.w700,
                            fontSize: 25,
                            color: Theme.of(context).colorScheme.primary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _controllerUser,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).nextFocus();
                        },
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.person,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          suffixIcon: _ClearButton(controller: _controllerUser),
                          labelText: 'Usuario',
                          hintText: 'Ingrese su usuario',
                          border: OutlineInputBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(100.0)),
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(100.0)),
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(100.0)),
                            borderSide: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .tertiaryContainer),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(100.0)),
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.error),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(100.0)),
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.error),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El campo Usuario no debe estar vacío';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _controllerPassword,
                        obscureText: isView,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) {
                          _validateAndSubmit();
                        },
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.key,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          suffixIcon: IconButton(
                              icon: Icon(isView
                                  ? Icons.remove_red_eye
                                  : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  isView = !isView;
                                });
                              }),
                          labelText: 'Contraseña',
                          hintText: 'Ingrese su contraseña',
                          border: OutlineInputBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(100.0)),
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(100.0)),
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(100.0)),
                            borderSide: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .tertiaryContainer),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(100.0)),
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.error),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(100.0)),
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.error),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El campo Contraseña no debe estar vacío';
                          }
                          return null;
                        },
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
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Theme.of(context)
                                            .colorScheme
                                            .secondaryFixed),
                                foregroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Theme.of(context)
                                            .colorScheme
                                            .onPrimaryFixed),
                              ),
                              label: const Text(
                                'Cerrar',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SizedBox(
                              height: 55,
                              child: ElevatedButton.icon(
                                onPressed: _validateAndSubmit,
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Theme.of(context)
                                              .colorScheme
                                              .tertiaryContainer),
                                  foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Theme.of(context)
                                              .colorScheme
                                              .onPrimaryFixed),
                                ),
                                label: const Text(
                                  '  Ingresar',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                icon: const Icon(Icons.login_rounded),
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ClearButton extends StatelessWidget {
  const _ClearButton({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) => IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => controller.clear(),
      );
}
