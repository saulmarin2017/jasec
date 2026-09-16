import 'dart:io';

import 'package:jasec/utilidades/publico.dart';

/// HttpOverrides para la cadena SSL incompleta de ORDS (issuer intermedio).
///
/// Error típico en Android:
///   CERTIFICATE_VERIFY_FAILED: unable to get local issuer certificate
///
/// Mismo patrón que recursos_humanos / ruteo_app: solo [urlbase].
/// El resto de hosts sigue validándose. Quitar cuando JASEC envíe el intermedio.
class DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        return host == urlbase;
      };
  }
}
