import 'package:flutter/material.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:jasec/widget/etiqueta.dart';

Future<void> MostrarWidgetEnDialogo(
    BuildContext context, Widget contenido, String titulo) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true, // Permite cerrar tocando fuera
    barrierLabel: lblcancelar,
    transitionDuration: Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Scaffold(
        appBar: AppBar(
          title: Etiqueta(
              texto: titulo,
              color: colorBlanco,
              tamanoFuente: tamanoFuenteDefecto),
          leading: IconButton(
            icon: Icon(
              Icons.close,
              color: colorBlanco,
            ),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ),
        body: contenido, // Usamos el widget pasado como parámetro
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
          position: Tween<Offset>(begin: Offset(0, 1), end: Offset(0, 0))
              .animate(animation),
          child: child);
    },
  );
}

void Dialogo(
    BuildContext ctx, String? titulo, String? contenido, IconData? icono,
    {Widget? widget, bool cerrar = true}) {
  showDialog(
      barrierDismissible: cerrar,
      context: ctx,
      builder: (ctx) {
        return AlertDialog(
          titlePadding: EdgeInsets.all(0),
          backgroundColor: colorBlanco,
          elevation: 10,
          title: Container(
            decoration: BoxDecoration(
              color: colorAzulSecundario, // Fondo del panel
            ),
            padding: EdgeInsets.all(10),
            width: double.infinity,
            child: Etiqueta(
              texto: titulo!,
              color: colorBlanco,
              tipo: FontWeight.bold,
            ),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
          content: (widget != null)
              ? widget
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Etiqueta(
                      texto: contenido!,
                      color: colorNegro,
                      tipo: FontWeight.bold,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Icon(
                      icono,
                      color: colorAzulSecundario,
                      size: 25,
                    ),
                  ],
                ),
          actions: [
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx, true);
                },
                child: Text(
                  lblaceptar.toUpperCase(),
                  style: const TextStyle(
                      color: colorAzulSecundario,
                      fontSize: tamanoFuenteDefecto,
                      fontWeight: FontWeight.bold),
                ))
          ],
        );
      });
}

void DialogoProgreso(
    BuildContext ctx, String? titulo, String? contenido, IconData? icono,
    {Widget? widget, bool cerrar = true}) {
  showDialog(
    context: ctx,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: colorBlanco,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: progresoCirculo(
                color: colorBlanco,
                colorFondo: colorAzulPrimario,
                dimensiones: 50),
          ),
        ),
      );
    },
  );
  /* showDialog(
      barrierDismissible: cerrar,
      context: ctx,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          titlePadding: EdgeInsets.all(10),
          backgroundColor: Colors.transparent,
          elevation: 10,
          title: Container(
            decoration: BoxDecoration(
              color: colorAzulSecundario, // Fondo del panel
            ),
            padding: EdgeInsets.all(10),
            width: double.infinity,
            child: Etiqueta(
              texto: titulo!,
              color: colorBlanco,
              tipo: FontWeight.bold,
            ),
          ),
          content: (widget != null)
              ? widget
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Etiqueta(
                      texto: contenido!,
                      color: colorNegro,
                      tipo: FontWeight.bold,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Icon(
                      icono,
                      color: colorAzulSecundario,
                      size: 25,
                    ),
                  ],
                ),
        );
      });*/
}

void showModal(Widget obj, BuildContext ctx) {
  showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return obj;
      });
}

Widget progresoCirculo(
    {Color color = colorAzulPrimario,
    Color colorFondo = colorGrisPrimario,
    double dimensiones = 25}) {
  return Center(
    child: SizedBox(
      width: dimensiones,
      height: dimensiones,
      child: CircularProgressIndicator(
        strokeAlign: BorderSide.strokeAlignCenter,
        strokeWidth: 2,
        color: color,
        backgroundColor: colorFondo,
      ),
    ),
  );
}
