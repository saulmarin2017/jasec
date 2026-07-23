import 'package:flutter/material.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:jasec/widget/widget.dart';

Future<bool?> DialogoConfirmacion(
    BuildContext context, String titulo, String pregunta,
    {Color colorFonfoTitulo = colorAzulSecundario}) async {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      titlePadding: EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(1)), // Bordes redondeados
      title: Container(
        decoration: BoxDecoration(
          color: colorFonfoTitulo, // Fondo del panel
        ),
        padding: EdgeInsets.all(10),
        width: double.infinity,
        child: // 🏷️ Título
            Etiqueta(
          texto: titulo,
          color: colorBlanco,
          tipo: FontWeight.bold,
        ),
      ),
      content: Etiqueta(
        texto: pregunta,
        color: colorNegro,
      ),
      actions: [
        // ❌ Botón "No"
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(false), // Retorna "false"
          style: ElevatedButton.styleFrom(
            backgroundColor: colorAzulPrimario, // Fondo gris
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Etiqueta(
            texto: lblno,
            color: colorBlanco,
            tipo: FontWeight.bold,
          ),
        ),

        // ✅ Botón "Sí"
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true), // Retorna "true"
          style: ElevatedButton.styleFrom(
            backgroundColor: colorAzulPrimario, // Fondo azul
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Etiqueta(
            texto: lblsi,
            color: colorBlanco,
            tipo: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}
