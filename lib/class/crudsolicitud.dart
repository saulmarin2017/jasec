import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:jasec/class/log.dart';
import 'package:jasec/class/red.dart';
import 'package:jasec/db/db.dart';
import 'package:jasec/model/model.dart';
import 'package:jasec/model/vmadjuntossolicitud.dart';
import 'package:jasec/model/vmcuentagasto.dart';
import 'package:jasec/model/vmordentrabajocontable.dart';
import 'package:jasec/model/vmsolicitud.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:jasec/class/apirest.dart';
import 'package:http/http.dart' as httpx;
import 'package:jasec/utilidades/utilidades.dart';

class CrudSolicitud {
  ApiRest api = ApiRest();
  Red red = Red();

  Future<VmRespuestaPost> guardarSolicitud(
      Map<String, dynamic> mapFormulario) async {
    TockenOrds? tk = await api.TokenApi();
    VmRespuestaPost respuesta = VmRespuestaPost();
    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print(
          "error al obtener el token en CrudSolicitudLuminaria-guardarSolicitudLuminaria, ${tk.error}");
      return respuesta;
    }

    final url = Uri.parse('$protocolo://$urlbase${suburl}solicitud');

    List<Map<String, dynamic>> json = [];
    json.add(mapFormulario);
    try {
      final response = await httpx.post(
        url,
        headers: headersConsumoApi(tk.accessToken!),
        body: jsonEncode(json),
      );

      tk.bitacoraHTTP(response);

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        respuesta = vmRespuestaPostFromJson(decoded);
        print('Respuesta API , guardarSolicitud: ${decoded}');
      } else {
        print(
            'Error en la API , guardarSolicitud: ${utf8.decode(response.bodyBytes)}');
        respuesta = respuesta;
      }
    } catch (e) {
      print('Ocurrió un error: $e');
      Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
      respuesta = respuesta;
    }

    return respuesta;
  }

  Future<VmRespuestaPost> actualizarSolicitud(
      Map<String, dynamic> mapFormulario) async {
    TockenOrds? tk = await api.TokenApi();
    VmRespuestaPost respuesta = VmRespuestaPost();
    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print(
          "error al obtener el token en CrudSolicitudLuminaria-actualizarSolicitud, ${tk.error}");
      return respuesta;
    }

    final url = Uri.parse('$protocolo://$urlbase${suburl}solicitud');

    List<Map<String, dynamic>> json = [];
    json.add(mapFormulario);

    try {
      final response = await httpx.put(
        url,
        headers: headersConsumoApi(tk.accessToken!),
        body: jsonEncode(json),
      );

      Log.escribir('UPDATE SOLICITUD : ${json.toString()}');

      tk.bitacoraHTTP(response);

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        respuesta = vmRespuestaPostFromJson(decoded);
        print('Respuesta API , actualizarSolicitud: ${decoded}');
      } else {
        print(
            'Error en la API , actualizarSolicitud: ${utf8.decode(response.bodyBytes)}');
        respuesta = respuesta;
      }
    } catch (e) {
      print('Ocurrió un error: $e');
      Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
      respuesta = respuesta;
    }

    return respuesta;
  }

  Future<VmFormulario> traerDatosFormulario(
      String solicitud, String formulario) async {
    VmFormulario vm = VmFormulario();
    TockenOrds? tk = await api.TokenApi();
    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print(
          "error al obtener el token en CrudFormularios-traerDatosFormulario ,${tk.error}");
      return vm;
    }

    final url = Uri.parse(
        '$protocolo://$urlbase${suburl}formulariorespuesta/$solicitud/$formulario');

    try {
      final response = await httpx.get(
        url,
        headers: headersConsumoApi(tk.accessToken!),
      );

      tk.bitacoraHTTP(response);
      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        vm = vmFormularioFromJson(decoded);
        print('Respuesta API , traerDatosFormulario: ${decoded}');
      } else {
        print(
            'Error en la API, traerDatosFormulario: ${utf8.decode(response.bodyBytes)}');
        return vm;
      }
    } catch (e) {
      print('Ocurrió un error: $e');
      Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
    }

    return vm;
  }

  Future<bool> cargarArchivoSolicitud(String codsolicitud, String nombrearchivo,
      Uint8List? archivo, String? mimetype) async {
    if (!conexionInternet) {
      final bd = db.instance;
      Map<String, dynamic> datos = {
        "COD_SOLICITUD": codsolicitud,
        "FILENAME": nombrearchivo,
        "MIMETYPE": mimetype,
        "DOCUMENTO": archivo,
        "POST_PUT": "POST",
        "FECHA_INSERT": DateTime.now().toIso8601String(),
        "USUARIO_INSERT": usuarioLogin
      };

      var r = await bd.insertar(datos, "SIAR_SOLICITUD_DOCUMENTO");
      if (r > 0) {
        return true;
      } else {
        return false;
      }
    }

    TockenOrds? tk = await api.TokenApi();
    bool respuesta = true;

    if (tk!.error != null) {
      print(
          "Error al obtener el token en CrudSolicitudLuminaria-archivoAdjuntoSolicitud ,${tk.error}");
      return false;
    }

    Map<String, dynamic> parametros = {
      "cod_solicitud": codsolicitud,
      "usuario": usuarioLogin,
      "nombre_archivo": nombrearchivo,
      "mime_type": mimetype,
    };

    final url =
        Uri.parse('$protocolo://$urlbase${suburl}archivoadjuntosolicitud')
            .replace(queryParameters: parametros);

    //?cod_solicitud=38&usuario=adminapp&nombre_archivo=Formualario rechaso completado.pdf&mime_type=application/pdf

    Map<String, String>? headers(String accessToken) {
      return {
        'Content-Type': mimetype ?? "",
        'Authorization': 'Bearer $accessToken',
      };
    }

    try {
      final response = await httpx.post(
        url,
        headers: headers(tk.accessToken!),
        body: archivo,
      );

      // tk.bitacoraHTTP(response);

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);

        var res = jsonDecode(decoded);

        // Validamos el campo "status"
        if (res['status'] == 1) {
          respuesta = true;
        } else {
          respuesta = false;
        }

        print('Respuesta API , archivoAdjuntoSolicitud: ${decoded}');
      } else {
        print(
            'Error en la API , archivoAdjuntoSolicitud: ${response.request!.url}');
        respuesta = false;
      }
    } catch (e) {
      print('Ocurrió un error en archivoAdjuntoSolicitud: $e');
      Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
      respuesta = false;
    }

    return respuesta;
  }

  Future<List<VmAdjuntosSolicitud>> descargarListaArchivosAdjuntos(
      String codSolicitud) async {
    List<VmAdjuntosSolicitud> vm = [];
    if (!conexionInternet) {
      var bd = db.instance;
      var documentosAdjuntosLocal = await bd.obtenerRegistros(
          "SIAR_SOLICITUD_DOCUMENTO",
          campo: "COD_SOLICITUD",
          valor: codSolicitud);

      List<VmAdjuntosSolicitud> listadoArchivos = [];

      for (var f in documentosAdjuntosLocal) {
        DateTime? fechaInsert = f["FECHA_INSERT"] != null
            ? DateTime.parse(f["FECHA_INSERT"])
            : null;
        VmAdjuntosSolicitud archivo = VmAdjuntosSolicitud();
        archivo.codSolicitudDocumento = f["COD_SOLICITUD_DOCUMENTO"].toString();
        archivo.codSolicitud = f["COD_SOLICITUD"].toString();
        archivo.filename = f["FILENAME"];
        archivo.mimetype = f["MIMETYPE"];
        archivo.fechaInsert = fechaInsert;
        archivo.usuarioInsert = f["USUARIO_INSERT"];

        listadoArchivos.add(archivo);
      }

      var json = jsonEncode(listadoArchivos);

      vm = vmAdjuntosSolicitudFromJson(json);

      return vm;
    }

    TockenOrds? tk = await api.TokenApi();

    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print(
          "error al obtener el token en crudsolicitud-descargarListaArchivosAdjuntos ,${tk.error}");
      return vm;
    }

    Map<String, dynamic> parametros = {"cod_solicitud": codSolicitud};

    final url =
        Uri.parse('$protocolo://$urlbase${suburl}archivoadjuntosolicitud')
            .replace(queryParameters: parametros);

    try {
      final response = await httpx.get(
        url,
        headers: headersConsumoApi(tk.accessToken!),
      );

      tk.bitacoraHTTP(response);

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        vm = vmAdjuntosSolicitudFromJson(decoded);
        print('Respuesta API , descargarArchivosSolicitud: ${decoded}');
      } else {
        print(
            'Error en la API, descargarArchivosSolicitud: ${utf8.decode(response.bodyBytes)}');
        return vm;
      }
    } catch (e) {
      print('Ocurrió un error: $e');
      Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
    }

    return vm;
  }

  Future<String> descargarArchivoAdjuntoSolicitud(
      String codSolicitud, String codSolicitudDocumento) async {
    if (!conexionInternet) {
      String patch = "";
      var bd = db.instance;
      var fila = await bd.obtenerRegistrosWhere("SIAR_SOLICITUD_DOCUMENTO",
          condiciones: {
            "COD_SOLICITUD": codSolicitud,
            "COD_SOLICITUD_DOCUMENTO": codSolicitudDocumento
          });

      Uint8List fileBytes = fila.first['DOCUMENTO'] as Uint8List;

      final ext = getExtensionFromMimeType(fila.first['MIMETYPE']);

      // Guardar el archivo usando flutter_cache_manager
      final cacheManager = DefaultCacheManager();
      final file = await cacheManager.putFile(
          codSolicitud + codSolicitudDocumento, fileBytes,
          fileExtension: ext);

      // patch = file.path;

      patch = await renombrarArchivo(
          file, '$codSolicitud$codSolicitudDocumento.$ext');

      return patch;
    }

    TockenOrds? tk = await api.TokenApi();
    String patch = "";
    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print(
          "error al obtener el token en CrudFormularios-traerDatosFormulario ,${tk.error}");
      return patch;
    }

    //cod_solicitud_documento NULO o VACIO, para que devuelva el arcivo en binario,
    //si cod_solicitud_documento y cod_solicitud, contienen valor , se trae el listado de archivos adjuntos a la solicitud
    Map<String, dynamic> parametros = {
      "cod_solicitud": codSolicitud,
      "cod_solicitud_documento": codSolicitudDocumento
    };

    final url =
        Uri.parse('$protocolo://$urlbase${suburl}archivoadjuntosolicitud')
            .replace(queryParameters: parametros);

    try {
      final response = await httpx.get(
        url,
        headers: headersConsumoApi(tk.accessToken!),
      );
      // tk.bitacoraHTTP(response);

      if (response.statusCode == 200) {
        Uint8List fileBytes = response.bodyBytes;

        final mimeType =
            response.headers['content-type'] ?? 'application/octet-stream';
        final ext = getExtensionFromMimeType(mimeType);

        // Guardar el archivo usando flutter_cache_manager
        final cacheManager = DefaultCacheManager();
        final file = await cacheManager.putFile(
            codSolicitud + codSolicitudDocumento, fileBytes,
            fileExtension: ext);

        // patch = file.path;

        patch = await renombrarArchivo(
            file, codSolicitud + codSolicitudDocumento + '.' + ext);

        print('Respuesta API , descargarArchivoSolicitud: ${patch}');
      } else {
        print(
            'Error en la API, descargarArchivoSolicitud: ${response.request!.url}');
        return patch;
      }
    } catch (e) {
      Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
      print('Ocurrió un error: $e');
    }

    return patch;
  }

  Future<VmRespuestaPost> elimimnarArchivoAdjuntoSolicitud(
      String codSolicitudDocumento) async {
    VmRespuestaPost vm = VmRespuestaPost(idInsertado: 0);
    if (!conexionInternet) {
      var bd = db.instance;
      vm.idInsertado = await bd.eliminar("SIAR_SOLICITUD_DOCUMENTO",
          "COD_SOLICITUD_DOCUMENTO", codSolicitudDocumento);

      return vm;
    }

    TockenOrds? tk = await api.TokenApi();

    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print(
          "error al obtener el token en CrudSolicitud-elimimnarArchivoAdjuntoSolicitud ,${tk.error}");
      return vm;
    }

    //cod_solicitud_documento NULO o VACIO, para que devuelva el arcivo en binario,
    //si cod_solicitud_documento y cod_solicitud, contienen valor , se trae el listado de archivos adjuntos a la solicitud
    Map<String, dynamic> parametros = {
      "cod_solicitud_documento": codSolicitudDocumento
    };

    List<Map<String, dynamic>> json = [];
    json.add(parametros);

    final url =
        Uri.parse('$protocolo://$urlbase${suburl}archivoadjuntosolicitud')
            .replace(queryParameters: parametros);

    try {
      final response = await httpx.delete(
        url,
        headers: headersConsumoApi(tk.accessToken!),
        body: jsonEncode(json),
      );

      tk.bitacoraHTTP(response);

      if (response.statusCode == 200) {
        print('Respuesta API , eliminarArchivoSolicitud');
      } else {
        print(
            'Error en la API, eliminarArchivoSolicitud: ${utf8.decode(response.bodyBytes)}');
        return vm;
      }
    } catch (e) {
      print('Ocurrió un error: $e');
      Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
      return vm;
    }

    return vm;
  }

  Future<VmSolicitud> traerSolicitud(
      String codsolicitud, String luminaria) async {
    VmSolicitud vm = VmSolicitud(items: []);

    if (!conexionInternet) {
      var bd = db.instance;
      var solicitudLocal = await bd.obtenerRegistros("SIAR_SOLICITUDES",
          campo: "COD_SOLICITUD", valor: codsolicitud);

      List<ItemSolicitud> todasLasSolicitudes = [];

      int i = 0;
      for (final fila in solicitudLocal) {
        i = i + 1;
        final Map<String, dynamic> map = json.decode(fila['JSON']);
        final item = ItemSolicitud.fromJson(map);
        todasLasSolicitudes.add(item);
      }

      vm = VmSolicitud(items: todasLasSolicitudes.toList());
      return vm;
    }

    TockenOrds? tk = await api.TokenApi();
    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print(
          "error al obtener el token en CrudSolicitud-traerSolicitud ,${tk.error}");
      return vm;
    }

    Map<String, dynamic> parametros = {
      "cod_solicitud": codsolicitud,
      "luminaria": luminaria
    };

    final url = Uri.parse('$protocolo://$urlbase${suburl}solicitud')
        .replace(queryParameters: parametros);

    try {
      final response = await httpx.get(
        url,
        headers: headersConsumoApi(tk.accessToken!),
      );

      tk.bitacoraHTTP(response);

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        vm = vmSolicitudFromJson(decoded);
        print('Respuesta API , traerSolicitud: ${decoded}');
      } else {
        print(
            'Error en la API, traerSolicitud: ${utf8.decode(response.bodyBytes)}');
        return vm;
      }
    } catch (e) {
      print('Ocurrió un error: $e');
      Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
    }

    return vm;
  }

  //Solo para sincronizar las solicitudes de la cuadrilla asociada al usuario
  Future<VmSolicitud> traerSolicitudesCuadrilla() async {
    VmSolicitud vm = VmSolicitud();
    TockenOrds? tk = await api.TokenApi();
    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print(
          "error al obtener el token en CrudSolicitud-traerSolicitud ,${tk.error}");
      return vm;
    }

    Map<String, dynamic> parametros = {
      "cod_cuadrilla": codCuadrillaUsaurio.toString(),
      "luminaria": luminaria
    };

    final url = Uri.parse('$protocolo://$urlbase${suburl}solicitudescuadrilla')
        .replace(queryParameters: parametros);

    try {
      final response = await httpx.get(
        url,
        headers: headersConsumoApi(tk.accessToken!),
      );

      tk.bitacoraHTTP(response);

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        vm = vmSolicitudFromJson(decoded);
        print('Respuesta API , traerSolicitudesCuadrilla: ${decoded}');
      } else {
        print(
            'Error en la API, traerSolicitudesCuadrilla: ${utf8.decode(response.bodyBytes)}');
        return vm;
      }
    } catch (e) {
      print('Ocurrió un error: $e');
      Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
    }

    return vm;
  }

  Future<VmSolicitud> traerUtimaSolicitudAtendida(String codPoste) async {
    VmSolicitud vm = VmSolicitud();
    TockenOrds? tk = await api.TokenApi();
    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print(
          "error al obtener el token en CrudSolicitud-traerUtimaSolicitudAtendida ,${tk.error}");
      return vm;
    }

    Map<String, dynamic> parametros = {
      "cod_poste": codPoste,
      "luminaria": luminaria
    };

    final url =
        Uri.parse('$protocolo://$urlbase${suburl}ultimasolicitudatendida')
            .replace(queryParameters: parametros);

    try {
      final response = await httpx.get(
        url,
        headers: headersConsumoApi(tk.accessToken!),
      );

      tk.bitacoraHTTP(response);

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        vm = vmSolicitudFromJson(decoded);
        print('Respuesta API , traerUtimaSolicitudAtendida: ${decoded}');
      } else {
        print(
            'Error en la API, traerUtimaSolicitudAtendida: ${utf8.decode(response.bodyBytes)}');
        return vm;
      }
    } catch (e) {
      print('Ocurrió un error: $e');
      Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
    }

    return vm;
  }

  Future<VmRespuestaPost> guardarInicioTiempoAtencion(
      Map<String, dynamic> mapFormulario) async {
    VmRespuestaPost respuesta = VmRespuestaPost();

    if (!conexionInternet) {
      var codTiempoAtencion = generarNumeroAleatorio();
      final bd = db.instance;
      Map<String, dynamic> datos = {
        "COD_TIEMPO_ATENCION": codTiempoAtencion,
        "COD_SOLICITUD": mapFormulario["cod_solicitud"],
        "JSON": jsonEncode(mapFormulario),
        "POST_PUT": "POST"
      };

      respuesta.idInsertado = await bd.insertar(datos, "SIAR_TIEMPO_ATENCION");
      setPreferencia(mapFormulario["cod_solicitud"], codTiempoAtencion);

      return respuesta;
    }

    TockenOrds? tk = await api.TokenApi();

    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print(
          "error al obtener el token en CrudSolicitud-guardarTiempoAtencionInicio, ${tk.error}");
      return respuesta;
    }

    final url = Uri.parse('$protocolo://$urlbase${suburl}tiemposolicitud');

    List<Map<String, dynamic>> json = [];
    json.add(mapFormulario);

    try {
      final response = await httpx.post(
        url,
        headers: headersConsumoApi(tk.accessToken!),
        body: jsonEncode(json),
      );

      tk.bitacoraHTTP(response);

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        respuesta = vmRespuestaPostFromJson(decoded);
        print('Respuesta API , guardarTiempoAtencionInicio: ${decoded}');
      } else {
        print(
            'Error en la API , guardarTiempoAtencionInicio: ${utf8.decode(response.bodyBytes)}');
        respuesta = respuesta;
      }
    } catch (e) {
      print('Ocurrió un error: $e');
      Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
      respuesta = respuesta;
    }

    return respuesta;
  }

  Future<VmRespuestaPost> actualizarFinTiempoAtencion(
      Map<String, dynamic> mapFormulario) async {
    VmRespuestaPost respuesta = VmRespuestaPost();

    if (!conexionInternet) {
      final bd = db.instance;
      String codTiempoAtencion =
          await getPreferencia(mapFormulario["cod_solicitud"]);

      Map<String, dynamic> datos = {"JSON_PUT": jsonEncode(mapFormulario)};

      respuesta.idInsertado = await bd.actualizar("SIAR_TIEMPO_ATENCION", datos,
          "COD_TIEMPO_ATENCION", codTiempoAtencion);
      setPreferencia(mapFormulario["cod_solicitud"], '');

      return respuesta;
    }

    TockenOrds? tk = await api.TokenApi();
    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print(
          "error al obtener el token en crudsolicitud-actualizarFinTiempoAtencion, ${tk.error}");
      return respuesta;
    }

    final url = Uri.parse('$protocolo://$urlbase${suburl}tiemposolicitud');

    List<Map<String, dynamic>> json = [];
    json.add(mapFormulario);

    try {
      final response = await httpx.put(
        url,
        headers: headersConsumoApi(tk.accessToken!),
        body: jsonEncode(json),
      );

      tk.bitacoraHTTP(response);

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        respuesta = vmRespuestaPostFromJson(decoded);
        print('Respuesta API , actualizarFinTiempoAtencion: ${decoded}');
      } else {
        print(
            'Error en la API , actualizarFinTiempoAtencion: ${utf8.decode(response.bodyBytes)}');
        respuesta = respuesta;
      }
    } catch (e) {
      print('Ocurrió un error: $e');
      Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
      respuesta = respuesta;
    }

    return respuesta;
  }

  Future<VmRespuestaPost> actualizarEstadoSolicitud(
      Map<String, dynamic> mapFormulario) async {
    VmRespuestaPost res = VmRespuestaPost();

    if (!conexionInternet) {
      //Instancia de base de datos local
      final bd = db.instance;
      int r = 0;
      //Recuperamos los datos de los listados fijos
      var data = await bd.obtenerRegistros("SIAR_SOLICITUDES",
          campo: "COD_SOLICITUD", valor: mapFormulario["cod_solicitud"]);

      Map<String, dynamic> mapUpdate = {};

      mapUpdate = jsonDecode(data.first['JSON']);

      mapUpdate["estado"] = mapFormulario["estado"];

      Map<String, dynamic> datos = {"JSON": jsonEncode(mapUpdate)};

      r = await bd.actualizar("SIAR_SOLICITUDES", datos, "COD_SOLICITUD",
          mapFormulario["cod_solicitud"]);

      res.idInsertado = r;
      res.mensaje = "Insert Local";
      res.status = "ok";

      return res;
    }

    TockenOrds? tk = await api.TokenApi();
    VmRespuestaPost respuesta = VmRespuestaPost();
    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print(
          "error al obtener el token en CrudOrdenesTrabajo-actualizarEstadoSolicitud, ${tk.error}");
      return respuesta;
    }

    final url = Uri.parse('$protocolo://$urlbase${suburl}estadosolicitud');

    List<Map<String, dynamic>> json = [];
    json.add(mapFormulario);

    try {
      final response = await httpx.post(
        url,
        headers: headersConsumoApi(tk.accessToken!),
        body: jsonEncode(json),
      );

      tk.bitacoraHTTP(response);

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        respuesta = vmRespuestaPostFromJson(decoded);
        print('Respuesta API , actualizarEstadoSolicitud: ${decoded}');
      } else {
        print(
            'Error en la API , actualizarEstadoSolicitud: ${utf8.decode(response.bodyBytes)}');
      }
    } catch (e) {
      print('Ocurrió un error: $e');
      Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
      return respuesta;
    }

    return respuesta;
  }

  Future<VmRespuestaPost> guardarMotivosRechazoSolicitud(
      Map<String, dynamic> mapFormulario) async {
    TockenOrds? tk = await api.TokenApi();
    VmRespuestaPost respuesta = VmRespuestaPost();
    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print(
          "error al obtener el token en crudsolicitu-insertarmotivosrechazosolicitud, ${tk.error}");
      return respuesta;
    }

    final url =
        Uri.parse('$protocolo://$urlbase${suburl}solicitudmotivosrechazo');

    List<Map<String, dynamic>> json = [];
    json.add(mapFormulario);

    try {
      final response = await httpx.post(
        url,
        headers: headersConsumoApi(tk.accessToken!),
        body: jsonEncode(json),
      );

      tk.bitacoraHTTP(response);

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        respuesta = vmRespuestaPostFromJson(decoded);
        print('Respuesta API , insertarmotivosrechazosolicitud: ${decoded}');
      } else {
        print(
            'Error en la API , insertarmotivosrechazosolicitud: ${utf8.decode(response.bodyBytes)}');
      }
    } catch (e) {
      print('Ocurrió un error: $e');
      Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
      return respuesta;
    }

    return respuesta;
  }

  Future<VmCuentaGasto> traerCuentaGasto() async {
    VmCuentaGasto vm = VmCuentaGasto();

    if (!conexionInternet) {
      return vmCuentaGastoFromJson(listadosdblocal.first.siarCuentaGasto!);
    }

    TockenOrds? tk = await api.TokenApi();
    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print("error al obtener el token en traerCuentaGasto ,${tk.error}");
      return vm;
    }

    final url = Uri.parse('$protocolo://$urlbase${suburl}cuentagasto');

    try {
      final response = await httpx.get(
        url,
        headers: headersConsumoApi(tk.accessToken!),
      );

      tk.bitacoraHTTP(response);

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        vm = vmCuentaGastoFromJson(decoded);
        print('Respuesta API , traerCuentaGasto: ${decoded}');
      } else {
        print(
            'Error en la API, traerCuentaGasto: ${utf8.decode(response.bodyBytes)}');
        return vm;
      }
    } catch (e) {
      print('Ocurrió un error: $e');
      Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
    }

    return vm;
  }

  Future<VmOrdenTrabajoContable> traerOrdenTrabajoContable() async {
    if (!conexionInternet) {
      return vmOrdenTrabajoContableFromJson(listadosdblocal.first.siarOtc!);
    }
    VmOrdenTrabajoContable vm = VmOrdenTrabajoContable();
    TockenOrds? tk = await api.TokenApi();
    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print(
          "error al obtener el token en traerOrdenTrabajoContable ,${tk.error}");
      return vm;
    }

    final url = Uri.parse('$protocolo://$urlbase${suburl}ordentrabajocontable');

    try {
      final response = await httpx.get(
        url,
        headers: headersConsumoApi(tk.accessToken!),
      );

      tk.bitacoraHTTP(response);

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        vm = vmOrdenTrabajoContableFromJson(decoded);
        print('Respuesta API , traerOrdenTrabajoContable: ${decoded}');
      } else {
        print(
            'Error en la API, traerOrdenTrabajoContable: ${utf8.decode(response.bodyBytes)}');
        return vm;
      }
    } catch (e) {
      Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
      print('Ocurrió un error: $e');
    }

    return vm;
  }
}
