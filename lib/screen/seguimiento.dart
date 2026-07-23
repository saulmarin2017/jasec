import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:jasec/widget/texboxform.dart';
import 'package:jasec/widget/dialogo.dart';

class Seguimiento extends StatefulWidget {
  const Seguimiento({Key? key}) : super(key: key);

  @override
  State<Seguimiento> createState() => _SeguimientoState();
}

class _SeguimientoState extends State<Seguimiento> {
  final GlobalKey<FormState> formularioRegistro = GlobalKey<FormState>();

  final Map<String, String> valoresFormulario = {
    'id': '',
    'idFK': '',
    'numeroOTC': '',
    'funcionario1': '',
    'fechaCarga': ''
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: colorAzulSecundario,
            ),
          ),
          title: Text(
            "ORDENES",
            style: const TextStyle(
                fontSize: tamanoAltoPorDefecto, color: colorBlanco),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Form(
              key: formularioRegistro,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 0,
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          const Divider(
                            color: colorAzulPrimario,
                          ),
                          AutoSizeText(
                            "Complete Formulario",
                            style: const TextStyle(
                                color: colorAzulSecundario,
                                fontWeight: FontWeight.bold),
                            maxFontSize: tamanoFuenteErrores,
                            minFontSize: tamanoFuenteErrores,
                            textAlign: TextAlign.left,
                          ),
                          const Divider(
                            color: colorAzulPrimario,
                          ),
                          const SizedBox(height: 10),
                          TextBoxForm(
                            textoEtiqueta: "Orden Externa",
                            tipo: TextInputType.name,
                            propiedadFormulario: 'numeroOTC',
                            valorFormulario: valoresFormulario,
                            enfoque: true,
                          ),
                          const SizedBox(height: tamanoAltoPorDefecto),
                          TextBoxForm(
                            textoEtiqueta: "Id Externo",
                            tipo: TextInputType.phone,
                            propiedadFormulario: 'idFK',
                            valorFormulario: valoresFormulario,
                            autoCorrector: false,
                            sugerirTexto: false,
                          ),
                          const SizedBox(height: tamanoAltoPorDefecto),
                          TextBoxForm(
                              textoEtiqueta: "Funcionario 1",
                              tipo: TextInputType.emailAddress,
                              propiedadFormulario: 'funcionario1',
                              valorFormulario: valoresFormulario),
                          const SizedBox(height: tamanoAltoPorDefecto),
                          TextBoxForm(
                            textoEtiqueta: "Fecha de Carga",
                            tipo: TextInputType.datetime,
                            propiedadFormulario: 'fechaCarga',
                            valorFormulario: valoresFormulario,
                            helperInicial: "DD/MM/YYYY",
                          ),
                          const SizedBox(height: tamanoAltoPorDefecto),
                          ElevatedButton(
                            style: ButtonStyle(
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                )),
                                backgroundColor: MaterialStateProperty.all(
                                    colorAzulPrimario)),
                            onPressed: () {
                              if (formularioRegistro.currentState!.validate()) {
                                //Navigator.pop(context);
                              } else {
                                Dialogo(
                                    context,
                                    lblinformacion,
                                    lbldatosDelFormularioInvalidos,
                                    Icons.error);
                              }
                            },
                            child: SizedBox(
                              width: double.infinity,
                              height: 30,
                              child: Center(
                                  child: Text("Guardar",
                                      style: const TextStyle(
                                        color: colorBlanco,
                                        fontWeight: FontWeight.bold,
                                        //fontFamily: 'Raleway',
                                        //fontSize: 22.0,
                                      ))),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            style: ButtonStyle(
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                )),
                                backgroundColor: MaterialStateProperty.all(
                                    colorAzulPrimario)),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: SizedBox(
                              width: double.infinity,
                              height: 30,
                              child: Center(
                                  child: Text("Cancelar",
                                      style: const TextStyle(
                                        color: colorBlanco,
                                        fontWeight: FontWeight.bold,
                                        //fontFamily: 'Raleway',
                                        //fontSize: 22.0,
                                      ))),
                            ),
                          ),
                        ],
                      )),
                ],
              ),
            ),
          ),
        ));
  }
}
