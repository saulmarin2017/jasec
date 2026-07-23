import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jasec/class/crudsolicitud.dart';
import 'package:jasec/model/vmproducto.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:jasec/widget/barramensaje.dart';
import 'package:jasec/widget/etiqueta.dart';
import 'package:jasec/widget/lineahoritzontal.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as httpx;
import 'package:jasec/class/log.dart';

double alturaUtil(BuildContext context) {
  final double alturaPantalla = MediaQuery.of(context).size.height;
  final double alturaBarraEstado = MediaQuery.of(context).padding.top;
  final double alturaAppBar =
      kToolbarHeight; // Altura estándar de AppBar (56.0)

  return alturaPantalla - alturaBarraEstado - alturaAppBar;
}

double anchoUtil(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

Widget Espacio({double alto = 0, double ancho = 0}) {
  if (alto == 0) {
    alto = altoBox;
    ancho = anchoBox;
  }
  if (ancho == 0) {
    ancho = alto;
  }

  return SizedBox(
    height: alto,
    width: ancho,
  );
}

Future<dynamic> getPreferencia(String nombreCampo) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  return prefs.getString(nombreCampo) ?? '';
}

Future<void> setPreferencia(String nombreCampo, String valor) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  prefs.setString(nombreCampo, valor);
}

enum PerfilUsuario { AlumbradoPublicoLuminaria, ServicioTecnico }

enum EstadosSolicitudes { REG, EFE, NOE }

enum EstadosOrdenesTrabajo { CRE, ASI, CER }

enum EstadosRequisiciones { APL, REG, REC, ENV }

enum EstadosOperacionesMateriales { APL, REG, REC }

String DescripcionEstado(String estado) {
  String descripcion = estado;
  switch (estado) {
    case "REG":
      descripcion = "REGISTRADA";
      break;
    case "EFE":
      descripcion = "EFECTIVA";
      break;
    case "NOE":
      descripcion = "NO EFECTIVA";
      break;
    case "CRE":
      descripcion = "CREADA";
      break;
    case "ASI":
      descripcion = "ASIGNADA";
      break;
    case "CER":
      descripcion = "CERRADA";
      break;
    case "APL":
      descripcion = "APLICADA";
      break;
    case "REC":
      descripcion = "RECHAZADA";
      break;
    case "ENV":
      descripcion = "ENVIADA";
      break;
  }

  return descripcion;
}

Future<bool> cargarFotografiaSolicitud(String codsolicitud,
    {ImageSource origenFotografia = ImageSource.camera,
    String nombreSujerido = ""}) async {
  bool resp = false;
  String nombreArchivo = "";
  final picker = ImagePicker();

  final imagen = await picker.pickImage(source: origenFotografia);

  if (imagen != null) {
    final Uint8List datos = await imagen.readAsBytes();

    // ✅ Detectar mime-type desde extensión
    final String? mimeType = lookupMimeType(imagen.path);

    if (nombreSujerido.isEmpty) {
      nombreArchivo = imagen.name;
    } else {
      nombreArchivo = "$nombreSujerido.${getExtensionFromMimeType(mimeType)}";
    }

    CrudSolicitud cls = CrudSolicitud();
    resp = await cls.cargarArchivoSolicitud(
        codsolicitud, nombreArchivo, datos, mimeType);
  } else {
    resp = false;
  }

  return resp;
}

Future<bool> cargarVideoSolicitud(String codsolicitud,
    {ImageSource origenFotografia = ImageSource.gallery,
    String nombreSujerido = ""}) async {
  bool respuesta = false;
  String nombreArchivo = "";
  final picker = ImagePicker();
  final video = await picker.pickVideo(source: origenFotografia);
  if (video != null) {
    // ✅ Leer como bytes
    final Uint8List datos = await video.readAsBytes();

    // ✅ Detectar mime-type desde extensión
    final String? mimeType = lookupMimeType(video.path);

    if (nombreSujerido.isEmpty) {
      nombreArchivo = video.name;
    } else {
      nombreArchivo = "$nombreSujerido.${getExtensionFromMimeType(mimeType)}";
    }

    CrudSolicitud cls = CrudSolicitud();
    respuesta = await cls.cargarArchivoSolicitud(
        codsolicitud, nombreArchivo, datos, mimeType);
  } else {
    respuesta = false;
  }
  return respuesta;
}

Future<bool> cargarArchivoSolicitud(String codsolicitud) async {
  bool resp = false;
  final archivo = await FilePicker.platform.pickFiles(
    withData: true, // Esto nos da Uint8List directo
  );

  if (archivo != null) {
    final obj = archivo.files.single;

    CrudSolicitud cls = CrudSolicitud();
    final String? mimeType = lookupMimeType(obj.name);
    final Uint8List? datos = obj.bytes;

    resp = await cls.cargarArchivoSolicitud(
        codsolicitud, obj.name, datos, mimeType);
  } else {
    resp = false;
  }

  return resp;
}

Future<String> renombrarArchivo(File original, String nuevoNombre) async {
  final nuevoPath = p.join(original.parent.path, nuevoNombre);
  final renombrado = await original.rename(nuevoPath);
  return renombrado.path;
}

String generarNumeroAleatorio() {
  final random = Random();
  String numero = '';
  for (int i = 0; i < 5; i++) {
    numero += random
        .nextInt(i == 0 ? 9 : 5)
        .toString(); // Primer dígito no puede ser 0
  }
  return numero;
}

String getExtensionFromMimeType(String? mimeType) {
  final map = {
    // Documentos
    'application/pdf': 'pdf',
    'application/msword': 'doc',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document':
        'docx',
    'application/vnd.ms-excel': 'xls',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet': 'xlsx',
    'text/plain': 'txt',
    'application/rtf': 'rtf',

    // Imágenes
    'image/jpeg': 'jpg',
    'image/png': 'png',
    'image/gif': 'gif',
    'image/bmp': 'bmp',
    'image/webp': 'webp',
    'image/svg+xml': 'svg',
    'image/tiff': 'tiff',

    // Audio
    'audio/mpeg': 'mp3',
    'audio/wav': 'wav',
    'audio/ogg': 'ogg',
    'audio/aac': 'aac',
    'audio/flac': 'flac',
    'audio/mp4': 'm4a',

    // Video
    'video/mp4': 'mp4',
    'video/x-msvideo': 'avi',
    'video/x-matroska': 'mkv',
    'video/webm': 'webm',
    'video/quicktime': 'mov',
    'video/mpeg': 'mpeg',

    // Comprimidos
    'application/zip': 'zip',
    'application/x-rar-compressed': 'rar',
    'application/x-7z-compressed': '7z',
    'application/gzip': 'gz',

    // Otros
    'application/json': 'json',
    'application/xml': 'xml',
    'application/octet-stream': 'bin',
  };

  return map[mimeType] ?? 'bin'; // Valor por defecto si no se encuentra
}

Widget titulo(String titulo, {double tamanoFuente = tamanoFuenteSubTitulo}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      LineaHorizontal(),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5, bottom: 5),
            child: Etiqueta(
              texto: titulo.toUpperCase(),
              tamanoFuente: tamanoFuente,
              tipo: FontWeight.bold,
            ),
          )
        ],
      ),
      LineaHorizontal(),
    ],
  );
}

Widget tituloExpansionPanel(String texto,
    {double tamanoFuente = tamanoFuente14px}) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 16),
    height: 25, // por ejemplo, 32 px
    alignment: Alignment.centerLeft,
    child: Etiqueta(
      texto: texto,
      tipo: FontWeight.bold,
      color: colorBlanco,
      tamanoFuente: tamanoFuente,
    ),
  );
}

late VmProducto listaProductos = VmProducto();

Widget dialogoText(BuildContext context, String textoActual) {
  final TextEditingController controller = TextEditingController();
  controller.text = textoActual;

  return Dialog(
    backgroundColor: colorBlanco,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(1),
    ),
    elevation: 10,
    child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🟦 Encabezado
            Container(
              decoration: BoxDecoration(
                color: colorAzulSecundario,
              ),
              padding: EdgeInsets.all(10),
              width: double.infinity,
              child: Etiqueta(
                texto: lblobservaciones,
                color: colorBlanco,
                tipo: FontWeight.bold,
              ),
            ),

            Espacio(alto: 16),

            // 🔢 Campo de texto
            TextField(
              autofocus: true,
              controller: controller,
              keyboardType: TextInputType.multiline,
              maxLines: 4,
              minLines: 1,
              decoration: InputDecoration(
                labelText: lblobservaciones,
                prefixIcon: Icon(Icons.text_format, color: colorAzulSecundario),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),

            Espacio(alto: 20),

            // 🔘 Botones
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop("");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorGrisPrimario,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                  ),
                  child: Etiqueta(
                    texto: lblcancelar,
                    color: colorBlanco,
                  ),
                ),
                SizedBox(width: 10), // ⬅️ espacio horizontal entre botones
                ElevatedButton(
                  onPressed: () async {
                    final texto = controller.text.trim();
                    Navigator.of(context).pop(texto);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorAzulSecundario,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                  ),
                  child: Etiqueta(
                    texto: lblaceptar,
                    color: colorBlanco,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget dialogoCantidad(BuildContext context,
    {String cantidadActul = "", int existencia = 0}) {
  final TextEditingController controller = TextEditingController();
  controller.text = cantidadActul;

  return Dialog(
    backgroundColor: colorBlanco,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(1),
    ),
    elevation: 10,
    child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🟦 Encabezado
            Container(
              decoration: BoxDecoration(
                color: colorAzulSecundario,
              ),
              padding: EdgeInsets.all(10),
              width: double.infinity,
              child: Etiqueta(
                texto: lblingresecantidad,
                color: colorBlanco,
                tipo: FontWeight.bold,
              ),
            ),

            Espacio(alto: 16),

            // 🔢 Campo de texto
            TextField(
              autofocus: true,
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: lblcantidad,
                prefixIcon: Icon(Icons.pin, color: colorAzulSecundario),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),

            Espacio(alto: 20),

            // 🔘 Botones
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    double? x = 0.0;
                    Navigator.of(context).pop(x);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorGrisPrimario,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                  ),
                  child: Etiqueta(
                    texto: lblcancelar,
                    color: colorBlanco,
                  ),
                ),
                SizedBox(width: 10), // ⬅️ espacio horizontal entre botones
                ElevatedButton(
                  onPressed: () async {
                    final texto = controller.text.trim();
                    final cantidad = double.tryParse(texto);

                    if (cantidad == null || cantidad <= 0) {
                      BarraMensaje(context).Mensaje(lblingresecantidad,
                          colorFuente: colorBlanco,
                          colorFondo: colorRojoPrimario);

                      return;
                    }

                    if (existencia > 0) {
                      if (cantidad > existencia) {
                        BarraMensaje(context).Mensaje(
                            lblcantidadsuperaexistencia,
                            colorFuente: colorBlanco,
                            colorFondo: colorRojoPrimario);
                        controller.text = '';

                        return;
                      }
                    }

                    Navigator.of(context).pop(cantidad);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorAzulSecundario,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                  ),
                  child: Etiqueta(
                    texto: lblaceptar,
                    color: colorBlanco,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Future<DateTime?> campoFecha(BuildContext context) async {
  return await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: colorAzulClaro, // Encabezado y botones
                onPrimary: colorBlanco, // Texto del encabezado
                onSurface: Colors.black, // Texto general
              ),
              dialogBackgroundColor: colorAzulPrimario, // Fondo del diálogo
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor:
                      colorAzulSecundario, // Color de los botones (Cancelar/Aceptar)
                ),
              )),
          child: child!,
        );
      });
}

InputDecoration decoracionTextFieldCantidad() {
  return InputDecoration(
    labelStyle: TextStyle(
        color: colorNegro,
        fontWeight: FontWeight.bold,
        fontSize: tamanoFuente10px),
    border: OutlineInputBorder(),
    contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
    isDense: true,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(
          borderRadiusElevatedButton), // Aplica cuando el campo no está enfocado
      borderSide: BorderSide(color: colorAzulSecundario), // Color del borde
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: colorAzulClaro, width: 0),
      borderRadius: BorderRadius.circular(25),
    ),
  );
}

Future<void> abrirURLGPS(double lat, double lng) async {
  // Waze app URI
  final Uri wazeUri =
      Uri.parse('https://waze.com/ul?ll=$lat,$lng&navigate=yes');

  // Google Maps web fallback
  final Uri googleMapsUri =
      Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');

  // Intentar abrir Waze
  if (await canLaunchUrl(wazeUri)) {
    await launchUrl(wazeUri, mode: LaunchMode.externalApplication);
  } else {
    // Si no se puede abrir Waze, usar Google Maps
    await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
  }
}

bool esAdmin() {
  if (tipoUsuario != tipoUsuarioAdministrador) {
    return false;
  } else {
    return true;
  }
}

Future<bool> conexionBackEnd() async {
  try {
    var urxp = '$protocolo://$urlbase/';
    await Log.escribir('$protocolo://$urlbase/');

    final response =
        await httpx.get(Uri.parse(urxp)).timeout(const Duration(seconds: 60));

    await Log.escribir('URL Conexión: $urxp STC: ${response.statusCode}');

    if (response.statusCode == 200) {
      return true; // El backend responde OK
    } else {
      return false; // El backend respondió pero no con 200
    }
  } catch (ex) {
    await Log.escribir(ex.toString());
    return false; // Error: sin conexión o backend caído
  }
}

Future<bool> ping(String url) async {
  // Prueba real de conexión a internet
  bool r = false;
  try {
    final result = await InternetAddress.lookup(url);
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      r = true; // Hay conexión real a Internet
    }
  } on SocketException catch (_) {
    r = false; // No hay acceso real
  }

  return r;
}
