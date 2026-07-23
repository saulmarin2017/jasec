import 'dart:io';

import 'package:flutter/material.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:jasec/utilidades/utilidades.dart';
import 'package:jasec/widget/widget.dart';

class Salida extends StatefulWidget {
  const Salida({super.key});

  @override
  _Ordenes createState() => _Ordenes();
}

class _Ordenes extends State<Salida> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(milliseconds: 100), () {
        confirmarAccion(context);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Etiqueta(texto: "");
  }

  void confirmarAccion(BuildContext context) async {
    bool? respuesta = await DialogoConfirmacion(
        context, lblcerraraplicacion, lblfinalizarjornadalaboral);
    if (respuesta != true) {
      Navigator.popAndPushNamed(context, "inicio", arguments: {
        lblopcionprincipal: 1, //Regresamos a menu principal
        lblnombreopcion: lblMenu,
        lblimagenopcion: urlimagendefecto,
      });
    } else {
      await getPreferencia(lblregistrokilometrajeinicio)
          .then((kilometrajeinicial) async {
        double ki = double.parse(kilometrajeinicial);

        //Validamos que el kilometraje inicial sea menor al kilometraje final
        if (ki > 0) {
          String kmi = await getPreferencia(lblcodkilometrajeinicio);

          kmi = (kmi == "null") ? kmi = "0" : kmi;

          if (ki > 0) {
            await mostrarKilometrajeDialog(context, "");
          }
        }
      });
    }
  }

  Future<void> mostrarKilometrajeDialog(
      BuildContext context, String llave) async {
    String? resultado = await showDialog<String>(
      context: context,
      builder: (context) => KilometrajeFinal(),
    );

    if (resultado != null) {
      print(
          'Kilometraje ingresado: $resultado'); // Puedes manejar el valor aquí
      exit(0);
    }
  }
}
