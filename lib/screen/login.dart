import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:jasec/class/autenticacion.dart';
import 'package:jasec/class/log.dart';
import 'package:jasec/class/red.dart';
import 'package:jasec/db/db.dart';
import 'package:jasec/model/model.dart';
import 'package:jasec/model/vmlistadosdblocal.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:jasec/utilidades/utilidades.dart';
import 'package:jasec/widget/barramensaje.dart';
import 'package:jasec/widget/widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> formularioLogin = GlobalKey<FormState>();
  String _usuario = "";
  String _clave = "";

  String errorBackend = "";

  bool recordarUsuario = false;
  TextEditingController usuarioController = TextEditingController();

  final Map<String, String> valoresFormulario = {lblUsuario: '', lblClave: ''};

  late Red red;

  final bd = db.instance;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      //Carga preferencias del usuario
      inicializar();

      var data = await bd.obtenerRegistros("LISTADOS");
      listadosdblocal = data.map((d) => ListadosDBlocal.fromMap(d)).toList();

      red = Red(context: context);

      // Escucha cambios RED
      red.iniciarMonitoreoRed((ConnectivityResult result) {
        cambiarEstadoRed(result);
      });
    });
  }

  @override
  void dispose() {
    red.detenerMonitoreoRed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 100, vertical: 100),
                child: Center(
                  child: Form(
                    key: formularioLogin,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.all(25),
                                  child: FadeInImage(
                                    placeholder: AssetImage(urlimagenlogo),
                                    image: AssetImage(urlimagenlogo),
                                    alignment: Alignment.topCenter,
                                    fit: BoxFit.cover,
                                    fadeInDuration: Duration(milliseconds: 300),
                                  ),
                                ),
                                const SizedBox(height: tamanoAltoPorDefecto),
                                const Text(
                                  lblSIAR,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: tamanoFuenteTitulosDefecto),
                                ),
                                const SizedBox(height: tamanoAltoPorDefecto),
                                const Text(
                                  '$lblNombreAPP ($lblversion)',
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20),
                                TextBoxForm(
                                    controlador: usuarioController,
                                    icono: Icons.person,
                                    textoEtiqueta: lblUsuario.toUpperCase(),
                                    tipo: TextInputType.text,
                                    propiedadFormulario: lblUsuario,
                                    valorFormulario: valoresFormulario,
                                    obligatorio: true,
                                    enfoque: true,
                                    texto: _usuario),
                                const SizedBox(height: tamanoAltoPorDefecto),
                                TextBoxForm(
                                    icono: Icons.key,
                                    textoEtiqueta: lblClave.toUpperCase(),
                                    tipo: TextInputType.visiblePassword,
                                    propiedadFormulario: lblClave,
                                    valorFormulario: valoresFormulario,
                                    password: true,
                                    autoCorrector: false,
                                    sugerirTexto: false,
                                    obligatorio: true,
                                    texto: _clave),
                                const SizedBox(height: tamanoAltoPorDefecto),
                                ElevatedButton(
                                  onPressed: () async {
                                    if (formularioLogin.currentState!
                                        .validate()) {
                                      BarraMensaje(context)
                                          .Mensaje(lblprocesando);

                                      await _validar().then((valido) async {
                                        if (!errorBackend.isNotEmpty) {
                                          if (valido) {
                                            await confirmarAccion(context);
                                            final bd = db.instance;
                                            var data = await bd
                                                .obtenerRegistros("LISTADOS");

                                            listadosdblocal = data
                                                .map((d) =>
                                                    ListadosDBlocal.fromMap(d))
                                                .toList();
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content: Etiqueta(
                                                texto:
                                                    lblUsuarioClaveIncorrectos,
                                                color: colorRojoPrimario,
                                                tipo: FontWeight.bold,
                                              )),
                                            );

                                            Dialogo(
                                                context,
                                                lblinformacion.toUpperCase(),
                                                lblUsuarioClaveIncorrectos,
                                                Icons.error);
                                          }
                                        }
                                      });
                                    } else {
                                      Dialogo(
                                          context,
                                          lblinformacion.toUpperCase(),
                                          lbldatosDelFormularioInvalidos,
                                          Icons.error);
                                    }
                                  },
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: Center(
                                        child: Text(lblingresar.toUpperCase(),
                                            style: const TextStyle(
                                              color: colorBlanco,
                                              fontFamily: lblfuenteDefecto,
                                              fontSize: tamanoFuenteDefecto,
                                            ))),
                                  ),
                                ),
                                const SizedBox(height: 25),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .start, // Alinea el contenido a la izquierda
                                  crossAxisAlignment: CrossAxisAlignment
                                      .center, // Alinea verticalmente en el centro
                                  children: [
                                    Checkbox(
                                      value: recordarUsuario,
                                      onChanged: (bool? newValue) {
                                        setState(() {
                                          recordarUsuario = newValue ?? false;
                                          _guardarNombreUsuario(
                                              recordarUsuario); // Guardar en SharedPreferences
                                        });
                                      },
                                    ),
                                    const Text(
                                      lblRecordarUsuario,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                              ],
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void cambiarEstadoRed(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
        // Log.escribir("Conectado a WiFi");
        print("Conectado a WiFi");
        conexionInternet = true;
        break;
      case ConnectivityResult.mobile:
        //Log.escribir("Conectado a datos móviles");
        print("Conectado a datos móviles");
        conexionInternet = true;
        break;
      case ConnectivityResult.none:
        //Log.escribir("Sin conexión");
        print("Sin conexión");
        conexionInternet = false;
        break;
      default:
        print("Estado desconocido");
        //Log.escribir("Estado desconocido");
        conexionInternet = false;
        break;
    }

    setState(() {
      conexionInternet;
    });
  }

  //Validamos los campos y mostramos dialogo de cargando
  Future<bool> _validar() async {
    bool valido = false;
    VmUsuario vmUsuario = VmUsuario(items: []);

    _usuario = (_usuario.isNotEmpty)
        ? _usuario
        : valoresFormulario[lblUsuario].toString().toUpperCase().trim();

    if (_usuario.isNotEmpty) {
      if (_usuario.toString().toUpperCase().trim() !=
          valoresFormulario[lblUsuario].toString().toUpperCase().trim()) {
        _usuario =
            valoresFormulario[lblUsuario].toString().toUpperCase().trim();
        _guardarNombreUsuario(true);
      }
    }

    _clave =
        (_clave.isNotEmpty) ? _clave : valoresFormulario[lblClave].toString();

    //Loading minetras autentica
    DialogoProgreso(context, lblinformacion, lblprocesando, Icons.network_check,
        widget:
            Center(child: SizedBox(width: 200, height: 200, child: Loading())),
        cerrar: false);
    try {
      if (_usuario.isEmpty || _clave.isEmpty) {
        Dialogo(context, lblinformacion.toUpperCase(), lblUsuarioClaveVacios,
            Icons.error,
            cerrar: false);
        valido = false;
      }

      // Se iuala la respuesta del backend a la clase de usuarios actual
      await _loginApi(_usuario.toUpperCase(), _clave).then((r) {
        if (r.items != null) {
          vmUsuario.items!.addAll(r.items!);
          vmUsuario.error = r.error;
        }
      });

      //Se valida que se devuela lista de usuarios y que no este vacia
      if (vmUsuario.items != null) {
        if (vmUsuario.items!.isEmpty) {
          BarraMensaje(context).Mensaje('$lblNoData para $_usuario',
              colorFondo: colorRojoPrimario, colorFuente: colorBlanco);
          await Log.escribir(
              "Usuario : ${_usuario.toUpperCase()} no encontrado, _validar");

          if (vmUsuario.error != null) {
            if (vmUsuario.items!.isEmpty) {
              errorBackend = vmUsuario.error.toString();
            }
          }

          _usuario = "";
          _clave = "";

          return false;
        }
      }

      //Si devolvio error prematuro al conectarse a el servidor de backend
      if (vmUsuario.error != null) {
        errorBackend = vmUsuario.error.toString();

        _usuario = "";
        _clave = "";

        return false;
      } else {
        errorBackend = "";
      }

      //Validamos que el usuario si contenga una lista de usuarios
      if (vmUsuario.items is List && vmUsuario.items!.isNotEmpty) {
        valido = true;
      } else {
        valido = false;
      }

      _usuario = "";
      _clave = "";
    } catch ($e) {
      //Log fisico
      await Log.escribir('Error en _validar: ${$e.toString()}');
      Navigator.of(context).pop();
    } finally {
      // Siempre cerrar el loading
      Navigator.of(context).pop();
    }
    return valido;
  }

//Validamos credenciales hacia el backend
  Future<VmUsuario> _loginApi(
    String usuario,
    String clave,
  ) async {
    VmUsuario obj = VmUsuario(items: []);
    Autenticacion srvUsuario = Autenticacion();

    await srvUsuario.loginAPI(usuario, clave).then((resp) async {
      if (resp.error != null) {
        //Log fisico
        await Log.escribir(resp.error!);

        BarraMensaje(context).Mensaje(
            "${lblErrorConexionBac.toUpperCase()} ${resp.error!}",
            colorFuente: colorRojoPrimario);

        obj = VmUsuario(error: resp.error.toString());
      } else {
        if (resp.items is List && resp.items!.isNotEmpty) {
          idUsuarioLogin = resp.items![0].codUsuario;
          usuarioLogin = resp.items![0].nombreUsuario ?? "";
          codCuadrillaUsaurio = resp.items![0].codenccuadrilla;
          codBodegaUsuario = resp.items![0].codbodega;
          tipoUsuario = resp.items![0].tipoUsuario;
          obj = resp;

          //Esto define como se mostrara el menu inicial, segun el perfil del usuario
          if (resp.items![0].indluminarias == "S") {
            perfilUsuario = PerfilUsuario.AlumbradoPublicoLuminaria;
            luminaria = "S";
          } else {
            luminaria = "N";
            perfilUsuario = PerfilUsuario.ServicioTecnico;
          }
        }
      }
    });

    return obj;
  }

  // Guardar el estado cuando cambia el checkbox
  Future<void> _guardarNombreUsuario(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('guarda_nombre_usuario', value);
    await prefs.setString(lblUsuario, valoresFormulario[lblUsuario].toString());
  }

  // Cargar el estado guardado
  Future<void> _cargarUsuarioGuardado() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      recordarUsuario = prefs.getBool('guarda_nombre_usuario') ??
          false; // Si no existe, es false
      valoresFormulario[lblUsuario] = prefs.getString(lblUsuario) ?? "";
      _usuario = valoresFormulario[lblUsuario]!.trim();
      usuarioController.text = valoresFormulario[lblUsuario]!.trim();
    });

    //
    //Navigator.popAndPushNamed(context, "persona");
  }

  Future<void> confirmarAccion(BuildContext context) async {
    bool? respuesta = await DialogoConfirmacion(
        context, lblvalidacioniniciojornada, lbldeseainiciarjornada);

    if (respuesta == true) {
      //Redireccionamos al listado de ordenes de trabajo, segun nel flujo
      Navigator.popAndPushNamed(context, "inicio", arguments: {
        lblopcionprincipal: 4,
        lblnombreopcion: lblordenestrabajo,
        lblllave: 0,
        lblimagenopcion: urlimagenordenes
      });
    } else {
      //Redireccionamos al Menu principal
      Navigator.popAndPushNamed(context, "inicio", arguments: {
        lblopcionprincipal: 1,
        lblnombreopcion: lblMenu,
        lblllave: 0,
        lblimagenopcion: urlimagensolicitud
      });
    }
  }

  Future<void> inicializar() async {
    await _cargarUsuarioGuardado(); // Cargar estado guardado al iniciar
    await cargarHabilitarLog();
  }

  Future<void> cargarHabilitarLog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    registrarLog =
        prefs.getBool(lblhabilitarlog) ?? false; // Si no existe, es false
  }
}
