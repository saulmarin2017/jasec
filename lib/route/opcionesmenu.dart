import 'package:flutter/cupertino.dart';

class OpcionesMenu {
  OpcionesMenu(
      {required this.ruta,
      required this.icon,
      required this.nombre,
      required this.screen});

  final String ruta;
  final IconData icon;
  final String nombre;
  final Widget screen;
}
