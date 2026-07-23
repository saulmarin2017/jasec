import 'package:flutter/material.dart';
import 'package:jasec/class/autenticacion.dart';
import 'package:jasec/model/model.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:jasec/utilidades/utilidades.dart';
import 'package:jasec/widget/barramensaje.dart';

import 'package:jasec/widget/widget.dart';

class CambioClave extends StatefulWidget {
  const CambioClave({super.key});

  @override
  State<CambioClave> createState() => _CambioClaveState();
}

class _CambioClaveState extends State<CambioClave> {
  Autenticacion srvUsuario = Autenticacion();

  final GlobalKey<FormState> frmCambioClave = GlobalKey<FormState>();

  final String _claveActual = "";
  final String _nuevaClave = "";
  final String _confirmeClave = "";

  TextEditingController usuarioController = TextEditingController();

  final Map<String, String> valoresFormulario = {
    lblClaveActual: '',
    lblNuevaClave: '',
    lblConfirmeClave: ''
  };

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(left: 100, right: 100, bottom: 25),
          child: Form(
            key: frmCambioClave,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                    padding: EdgeInsets.all(5),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Espacio(alto: 15),
                          TextBoxForm(
                              icono: Icons.key_off,
                              textoEtiqueta: lblClaveActual.toUpperCase(),
                              tipo: TextInputType.visiblePassword,
                              propiedadFormulario: lblClaveActual,
                              valorFormulario: valoresFormulario,
                              obligatorio: true,
                              enfoque: true,
                              texto: _claveActual),
                          Espacio(alto: 15),
                          TextBoxForm(
                              icono: Icons.key,
                              textoEtiqueta: lblNuevaClave.toUpperCase(),
                              tipo: TextInputType.visiblePassword,
                              propiedadFormulario: lblNuevaClave,
                              valorFormulario: valoresFormulario,
                              password: true,
                              autoCorrector: false,
                              sugerirTexto: false,
                              obligatorio: true,
                              texto: _nuevaClave),
                          Espacio(alto: 15),
                          TextBoxForm(
                              icono: Icons.key,
                              textoEtiqueta: lblConfirmeClave.toUpperCase(),
                              tipo: TextInputType.visiblePassword,
                              propiedadFormulario: lblConfirmeClave,
                              valorFormulario: valoresFormulario,
                              password: true,
                              autoCorrector: false,
                              sugerirTexto: false,
                              obligatorio: true,
                              texto: _confirmeClave),
                          Espacio(alto: 15),
                          ElevatedButton(
                            onPressed: () async {
                              if (frmCambioClave.currentState!.validate()) {
                                if (valoresFormulario[lblNuevaClave]!
                                        .toUpperCase() !=
                                    valoresFormulario[lblConfirmeClave]!
                                        .toUpperCase()) {
                                  Dialogo(context, lblinformacion.toUpperCase(),
                                      lblClavesnoCoinciden, Icons.error);

                                  return;
                                }

                                await _validar().then((valido) {
                                  if (valido) {
                                    realizarCambioClave(
                                        valoresFormulario[lblNuevaClave]!);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Etiqueta(
                                        texto: lblUsuarioClaveIncorrectos,
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
                                });
                              } else {
                                Dialogo(
                                    context,
                                    lblinformacion.toUpperCase(),
                                    lbldatosDelFormularioInvalidos,
                                    Icons.error);
                              }
                            },
                            child: Center(
                                child: Etiqueta(
                              texto: lblCambiarClave.toUpperCase(),
                              color: colorBlanco,
                            )),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    ]);
  }

  //Validamos los campos y mostramos dialogo de cargando
  Future<bool> _validar() async {
    bool valido = false;

    String claveActual = (_claveActual.isNotEmpty)
        ? _claveActual
        : valoresFormulario[lblClaveActual].toString();
    String nuevaClave = (_nuevaClave.isNotEmpty)
        ? _nuevaClave
        : valoresFormulario[lblNuevaClave].toString();
    String confirmeClave = (_confirmeClave.isNotEmpty)
        ? _confirmeClave
        : valoresFormulario[lblConfirmeClave].toString();

    //Loading minetras autentica
    /*Dialogo(context, lblinformacion, lblprocesando, Icons.network_check,
        widget: SizedBox(
          width: 100,
          height: 150,
          child: Loading(),
        ),
        cerrar: false);*/

    progresoCirculo();

    try {
      if (claveActual.isEmpty || nuevaClave.isEmpty || confirmeClave.isEmpty) {
        Dialogo(context, lblinformacion.toUpperCase(), lblClavesnoCoinciden,
            Icons.error,
            cerrar: false);
        valido = false;
      }

      VmUsuario vmUsuario = await _loginApi(usuarioLogin, claveActual);

      if (vmUsuario.items is List && vmUsuario.items!.isNotEmpty) {
        valido = true;
      } else {
        valido = false;
      }
    } finally {
      // Siempre cerrar el loading, en esta caso no se debe cerrar porque la ventana se abre en un dialogo
      // Navigator.of(context).pop();
    }

    return valido;
  }

//Validamos credenciales hacia el backend
  Future<VmUsuario> _loginApi(String usuario, String clave) async {
    VmUsuario obj = VmUsuario();

    await srvUsuario.loginAPI(usuario, clave).then((usuario) {
      if (usuario.items is List && usuario.items!.isNotEmpty) {
        idUsuarioLogin = usuario.items![0].codUsuario;
        obj = usuario;
      }
    });

    return obj;
  }

  void realizarCambioClave(String clave) async {
    await srvUsuario.cambiarClave(clave).then((r) {
      if (r) {
        BarraMensaje(context)
            .Mensaje(lblCambioClaveExito, colorFondo: colorVerdePrimario);
        Navigator.popAndPushNamed(
          context,
          "login",
        );
      } else {
        BarraMensaje(context)
            .Mensaje(lblAgoSalioMal, colorFondo: colorRojoPrimario);
      }

      Navigator.popAndPushNamed(context, "inicio", arguments: {
        lblopcionprincipal: 6, //Salir o registrar kilometraje
        lblnombreopcion: lblsalir,
        lblllave: 0,
        lblimagenopcion: usrliamgensalida
      });

      //Navigator.of(context).pop();
    });
  }
}
