import 'package:flutter/material.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:jasec/widget/widget.dart';

// Este widget personalizado es un ElevatedButton reutilizable.
// ignore: must_be_immutable
class Boton extends StatelessWidget {
  final String textoEtiqueta;
  final Color colorFondo;
  final Color colorTexto;
  final double tamanoFuente;
  final double? bordenRedondeado;
  final FontWeight? tipoFuente;
  final Function() onPressed;
  Function()? onLongPress;

  Boton(
      {super.key,
      required this.textoEtiqueta,
      required this.colorTexto,
      required this.onPressed,
      this.onLongPress,
      this.tamanoFuente = tamanoFuente8px,
      this.colorFondo = colorAzulPrimario,
      this.bordenRedondeado = borderRadiusElevatedButton,
      this.tipoFuente = FontWeight.bold});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed, // Ejecuta la función proporcionada
        onLongPress: onLongPress ?? () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: colorFondo, // Color del fondo del botón
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(bordenRedondeado!), // Bordes redondeados
          ),
        ),
        child: Etiqueta(
          texto: textoEtiqueta,
          color: colorTexto,
          tipo: tipoFuente!,
          tamanoFuente: tamanoFuente,
        ));
  }
}
