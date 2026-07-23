import 'dart:io';
import 'package:path/path.dart' as p;

class Log {
  // Cambia esta ruta según tu sistema operativo o propósito
  static String _getStaticFilePath() {
    final now = DateTime.now();
    final nombreArcivo =
        'LOG_SIAR_${now.toIso8601String().substring(0, 10)}.txt';
    return p.join('/sdcard/Download/siar', nombreArcivo);
  }

  static Future<void> escribir(String descripcionEvento) async {
    //Solo si la bandera esta marcada en menu-configuracion-habilitar registro de log, se escribe de lo contrario no se registra el log
    //if (!registrarLog) {
    //  return;
    //}

    final direccionArchivo = _getStaticFilePath();

    // Asegura que el directorio exista
    final logDir = Directory(p.dirname(direccionArchivo));
    if (!await logDir.exists()) {
      await logDir.create(recursive: true);
    }

    final archivo = File(direccionArchivo);
    final fecha = DateTime.now();
    final fechaHoraEvento = fecha.toIso8601String();
    final evento = '$fechaHoraEvento - $descripcionEvento\n';

    await archivo.writeAsString(evento, mode: FileMode.append, flush: true);
  }

  static Future<String> leer() async {
    final filePath = _getStaticFilePath();
    final file = File(filePath);
    if (await file.exists()) {
      return await file.readAsString();
    }
    return 'Log vacío.';
  }

  static Future<void> limpiar() async {
    final filePath = _getStaticFilePath();
    final file = File(filePath);
    if (await file.exists()) {
      await file.writeAsString('');
    }
  }
}
