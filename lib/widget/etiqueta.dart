import 'package:flutter/material.dart';
import 'package:jasec/utilidades/publico.dart';

class Etiqueta extends StatelessWidget {
  final String texto;
  final double tamanoFuente;
  final Color color;
  final FontWeight tipo;
  final TextAlign alinear;

  const Etiqueta(
      {super.key,
      required this.texto,
      this.tamanoFuente = tamanoFuenteDefecto,
      this.color = colorAzulSecundario,
      this.tipo = FontWeight.normal,
      this.alinear = TextAlign.left});

  // ignore: empty_constructor_bodies
  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      textAlign: alinear,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: tamanoFuente,
        color: color,
      ),
    );
  }
}
