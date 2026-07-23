import 'package:flutter/material.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:jasec/widget/etiqueta.dart';

class BarraMensaje {
  final BuildContext context;

  BarraMensaje(this.context);

  bool Mensaje(String mensaje,
      {Color colorFondo = colorNegro,
      Color colorFuente = colorBlanco,
      double tamanoFuente = tamanoFuente10px,
      Widget? widget,
      fontWeight = FontWeight.bold}) {
    if (mensaje.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: widget!,
            backgroundColor: colorFondo,
          ),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Etiqueta(
              texto: mensaje,
              color: colorFuente,
              tipo: fontWeight,
            ),
            backgroundColor: colorFondo,
          ),
        );
      }
    }

    return true;
  }
}
