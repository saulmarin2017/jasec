import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:jasec/utilidades/utilidades.dart';
import 'package:jasec/widget/barramensaje.dart';
import 'package:jasec/widget/dialogo.dart';
import 'package:jasec/widget/etiqueta.dart';

class Red {
  final BuildContext? context;

  Red({this.context});

  final Connectivity conexion = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> subscripciones;

  Function(ConnectivityResult)? onStatusChange;

  void iniciarMonitoreoRed(Function(ConnectivityResult) onChange) {
    onStatusChange = onChange;
    subscripciones = conexion.onConnectivityChanged
        .listen((List<ConnectivityResult> resultList) {
      // Tomamos el primer resultado como el más reciente
      if (resultList.isNotEmpty) {
        onStatusChange?.call(resultList.first);
      }
    });
  }

  void detenerMonitoreoRed() {
    subscripciones.cancel();
  }

  Future<bool> verificarConexionRed(BuildContext context) async {
    const int maxReintentos = 2;
    int intento = 0;
    conexionInternet = false;
    while (intento < maxReintentos) {
      try {
        var estadoConexion = await Connectivity().checkConnectivity();

        //Hay conexion a red
        if (estadoConexion[0] != ConnectivityResult.none) {
          //Hay conexion a internet real mente
          conexionInternet = await conexionBackEnd();
          break;
        } else {
          conexionInternet = false;
          intento++;

          if (intento < maxReintentos) {
            // Mostrar aviso al usuario
            /* Dialogo(
                context,
                'Sin conexión',
                'Por favor habilite Wi-Fi o datos móviles. Reintentando...',
                Icons.wifi_off);*/

            BarraMensaje(context).Mensaje("",
                widget: Column(
                  children: [
                    Center(
                        child: Etiqueta(
                      texto: 'Por favor habilite Wi-Fi o datos móviles.',
                      color: colorRojoPrimario,
                    )),
                    Center(
                        child: Icon(
                      Icons.wifi_off,
                      color: colorRojoPrimario,
                    ))
                  ],
                ),
                colorFondo: colorAzulPrimario);

            await Future.delayed(
                Duration(seconds: 120)); // espera antes del siguiente intento
          }
        }
      } on PlatformException catch (e) {
        conexionInternet = false;
        Dialogo(
            context, 'Error al verificar conectividad', e.message, Icons.error);
        break;
      }
    }

    if (!conexionInternet) {
      if (context.mounted) {
        BarraMensaje(context).Mensaje("",
            widget: Column(
              children: [
                Center(
                    child: Etiqueta(
                  texto:
                      'No se pudo establecer conexión tras $maxReintentos intentos.',
                  color: colorRojoPrimario,
                )),
                Center(
                    child: Icon(
                  Icons.warning,
                  color: colorAmarrillo,
                ))
              ],
            ),
            colorFondo: colorAzulClaro);
      }

      /* Dialogo(
          context,
          'Sin conexión',
          'No se pudo establecer conexión tras $maxReintentos intentos.',
          Icons.warning);*/
    }

    return conexionInternet;
  }
}
