import 'package:flutter/material.dart';
import 'package:jasec/utilidades/publico.dart';

class LineaHorizontal extends StatelessWidget {
  final double grosor;
  final Color color;
  const LineaHorizontal({
    super.key,
    this.color = colorAzulSecundario,
    this.grosor = 2,
  });

  // ignore: empty_constructor_bodies
  @override
  Widget build(BuildContext context) {
    return Divider(
      color: color,
      thickness: grosor, // Grosor
    );
  }
}
