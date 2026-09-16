import 'dart:io';

import 'package:jasec/class/omitircertificadohttps.dart';
import 'package:jasec/utilidades/publico.dart';

/// Configura [HttpOverrides] en Android/iOS/desktop.
/// También en el APK release, limitado a [urlbase] (como recursos_humanos).
void setupHttpOverrides() {
  if (allowBadCertificates) {
    HttpOverrides.global = DevHttpOverrides();
  }
}
