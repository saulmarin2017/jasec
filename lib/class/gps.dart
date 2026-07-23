import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jasec/class/log.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:jasec/widget/barramensaje.dart';

class GPS {
  final BuildContext context;

  GPS(this.context);

  late StreamSubscription<ServiceStatus> subscripcionGPS;
  Function(ServiceStatus)? onGpsStatusChanged;

  void iniciarMonitoreoGPS(Function(ServiceStatus) onChange) {
    onGpsStatusChanged = onChange;
    subscripcionGPS =
        Geolocator.getServiceStatusStream().listen((ServiceStatus status) {
      onGpsStatusChanged?.call(status);
    });
  }

  Future<bool> gpsHabilitado() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  void detenerMonitoreo() {
    subscripcionGPS.cancel();
  }

  //Poscicion por defecto de oficinas centrales de JASEC
  final Position posGPSJASEC = Position(
    latitude: 9.8641374, // Latitud de jasec
    longitude: -83.9225502, // Longitud de jasec
    accuracy: 0.0,
    altitude: 0.0,
    altitudeAccuracy: 0,
    headingAccuracy: 0,
    heading: 0.0,
    speed: 0.0,
    speedAccuracy: 0.0,
    timestamp: DateTime.now(),
  );

  Future<bool> exigirGPSYPermisos() async {
    Position? position = posGPSJASEC;
    bool respuesta = false;

    bool permisosOk = await _verificarPermisos(context);

    if (!permisosOk) return false; // Usuario negó los permisos

    while (true) {
      bool gpsActivo = await Geolocator.isLocationServiceEnabled();
      if (gpsActivo) {
        break;
      } else {
        BarraMensaje(context).Mensaje("Habilita GPS 📡, para continuar",
            colorFuente: colorBlanco, colorFondo: colorRojoPrimario);
        // Si no está activo, abrimos la configuración y esperamos a que el usuario la active
        await Geolocator.openLocationSettings();

        // Opcional: dar un pequeño delay para que la configuración tenga tiempo de cambiar
        await Future.delayed(Duration(seconds: 10));
      }
    }

    //while (!gpsActivo) {
    //  gpsActivo = await _mostrarDialogoActivarGPS(context);
    //}

    position = await obtenerUltimaPosicionConocida();

    PosGPSGlobal = position;

    respuesta = true;

    return respuesta;
  }

  Future<bool> _verificarPermisos(BuildContext context) async {
    LocationPermission permiso = await Geolocator.checkPermission();

    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Permiso de ubicación denegado")),
        );
        Log.escribir('Permiso GPS Denegado');
        return false;
      }
    }

    if (permiso == LocationPermission.deniedForever) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Permisos denegados permanentemente"),
          content: Text(
              "Debes ir a la configuración de la app y habilitar los permisos de ubicación."),
          actions: [
            TextButton(
              onPressed: () {
                Geolocator.openAppSettings();
                Navigator.of(context).pop();
              },
              child: Text("Abrir configuración"),
            ),
          ],
        ),
      );
      return false;
    }

    return true;
  }

  Future<bool> esperarGPSActivado(BuildContext context,
      {int timeoutSegundos = 30}) async {
    // Abre la configuración del sistema para activar el GPS
    await Geolocator.openLocationSettings();

    int tiempoEsperado = 0;
    const int intervalo = 2; // segundos

    // Mostrar mensaje de espera
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Esperando que actives el GPS...")),
    );

    // Esperar en bucle hasta que se active el GPS o se acabe el tiempo
    while (!(await Geolocator.isLocationServiceEnabled())) {
      await Future.delayed(Duration(seconds: intervalo));
      tiempoEsperado += intervalo;

      if (tiempoEsperado >= timeoutSegundos) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No se activó el GPS a tiempo.")),
        );
        return false;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("GPS activado correctamente ✅")),
    );
    return true;
  }

  Future<Position?> obtenerUltimaPosicionConocida() async {
    Position? posicion = posGPSJASEC;
    try {
      posicion = await Geolocator.getLastKnownPosition();

      if (posicion != null) {
        posicion = posicion;
      }
    } catch (e) {
      Log.escribir('Error GPS,  ${e.toString()}');
      return posGPSJASEC;
    }
    return posicion;
  }
}
