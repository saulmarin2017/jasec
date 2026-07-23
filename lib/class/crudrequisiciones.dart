import 'dart:convert';
import 'package:jasec/class/log.dart';
import 'package:jasec/db/db.dart';
import 'package:jasec/model/model.dart';
import 'package:jasec/model/vmdetallerequisiones.dart';
import 'package:jasec/model/vmrequisiciones.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:jasec/class/apirest.dart';
import 'package:http/http.dart' as httpx;
import 'package:jasec/utilidades/utilidades.dart';

class CrudRequisiciones {
  ApiRest api = ApiRest();

  Future<VmRespuestaPost> guardarRequisicion(
      Map<String, dynamic> mapRequisicion) async {
    TockenOrds? tk = await api.TokenApi();
    VmRespuestaPost respuesta = VmRespuestaPost();
    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print("error al obtener el token en guardarRequisicion, ${tk.error}");
      return respuesta;
    }

    final url = Uri.parse('$protocolo://$urlbase${suburl}requisiciones');

    List<Map<String, dynamic>> json = [];
    json.add(mapRequisicion);

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
        print('Respuesta API , guardarRequisicion: ${decoded}');
      } else {
        print(
            'Error en la API , guardarRequisicion: ${utf8.decode(response.bodyBytes)}');
        respuesta = respuesta;
      }
    } catch (e) {
      print('Ocurrió un error: $e');
      Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
      respuesta = respuesta;
    }

    return respuesta;
  }

  Future<VmRespuestaPost> eliminarRequisicion(
      Map<String, dynamic> mapRequisiciones) async {
    TockenOrds? tk = await api.TokenApi();
    VmRespuestaPost respuesta = VmRespuestaPost();
    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print("error al obtener el token en eliminarRequisicion, ${tk.error}");
      return respuesta;
    }

    final url = Uri.parse('$protocolo://$urlbase${suburl}requisiciones');

    List<Map<String, dynamic>> json = [];
    json.add(mapRequisiciones);
    try {
      final response = await httpx.delete(
        url,
        headers: headersConsumoApi(tk.accessToken!),
        body: jsonEncode(json),
      );

      tk.bitacoraHTTP(response);

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        respuesta = vmRespuestaPostFromJson(decoded);
        print('Respuesta API , eliminarRequisicion: ${decoded}');
      } else {
        print(
            'Error en la API , eliminarRequisicion: ${utf8.decode(response.bodyBytes)}');
        respuesta = respuesta;
      }
    } catch (e) {
      print('Ocurrió un error: $e');
      Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
      respuesta = respuesta;
    }

    return respuesta;
  }

  Future<VmRespuestaPost> actualizarRequisicion(
      Map<String, dynamic> mapRequisiciones) async {
    TockenOrds? tk = await api.TokenApi();
    VmRespuestaPost respuesta = VmRespuestaPost();
    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print(
          "error al obtener el token en CrudRequisiciones-actualizarRequisicion, ${tk.error}");
      return respuesta;
    }

    final url = Uri.parse('$protocolo://$urlbase${suburl}requisiciones');

    List<Map<String, dynamic>> json = [];
    json.add(mapRequisiciones);

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
        print('Respuesta API , actualizarRequisicion: ${decoded}');
      } else {
        print(
            'Error en la API , actualizarRequisicion: ${utf8.decode(response.bodyBytes)}');
        respuesta = respuesta;
      }
    } catch (e) {
      print('Ocurrió un error: $e');
      Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
      respuesta = respuesta;
    }

    return respuesta;
  }

  Future<VmRespuestaPost> eliminarDetalleRequisicion(
      Map<String, dynamic> mapDetalleRequisiciones) async {
    VmRespuestaPost respuesta = VmRespuestaPost(idInsertado: 0);
    if (!conexionInternet) {
      int r = 0;
      var bd = db.instance;
      r = await bd.eliminar("SIAR_DETALLE_REQUISICION", "cod_det_requisiciones",
          mapDetalleRequisiciones['cod_det_requisiciones']);
      respuesta.idInsertado = r;

      return respuesta;
    }

    TockenOrds? tk = await api.TokenApi();

    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print(
          "error al obtener el token en CrudRequisiciones-eliminarDetalleRequisicion, ${tk.error}");
      return respuesta;
    }

    final url = Uri.parse('$protocolo://$urlbase${suburl}detallerequisiciones');

    List<Map<String, dynamic>> json = [];
    json.add(mapDetalleRequisiciones);
    try {
      final response = await httpx.delete(
        url,
        headers: headersConsumoApi(tk.accessToken!),
        body: jsonEncode(json),
      );

      tk.bitacoraHTTP(response);

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        respuesta = vmRespuestaPostFromJson(decoded);
        print('Respuesta API , eliminarDetalleRequisicion: ${decoded}');
      } else {
        print(
            'Error en la API , eliminarDetalleRequisicion: ${utf8.decode(response.bodyBytes)}');
        respuesta = respuesta;
      }
    } catch (e) {
      print('Ocurrió un error: $e');
      Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
      respuesta = respuesta;
    }

    return respuesta;
  }

  Future<VmRequisiciones> traerRequisicion(String codRequisiones) async {
    VmRequisiciones vm = VmRequisiciones();
    TockenOrds? tk = await api.TokenApi();
    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print(
          "error al obtener el token en CrudFormularios-traerRequisicion ,${tk.error}");
      return vm;
    }

    Map<String, dynamic> parametros = {
      "cod_requisiciones": codRequisiones,
      "luminaria": luminaria
    };

    final url = Uri.parse('$protocolo://$urlbase${suburl}requisiciones')
        .replace(queryParameters: parametros);

    try {
      final response = await httpx.get(
        url,
        headers: headersConsumoApi(tk.accessToken!),
      );

      tk.bitacoraHTTP(response);

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        vm = vmRequisicionesFromJson(decoded);
        print('Respuesta API , traerRequisicion: ${decoded}');
      } else {
        print(
            'Error en la API, traerRequisicion: ${utf8.decode(response.bodyBytes)}');
        return vm;
      }
    } catch (e) {
      print('Ocurrió un error: $e');
      Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
    }

    return vm;
  }

  Future<VmRespuestaPost> guardarDetalleRequisicion(
      List<Map<String, dynamic>> mapDetalleRequisiones) async {
    VmRespuestaPost respuesta = VmRespuestaPost();
    if (!conexionInternet) {
      final dbInstance = await db.instance.database;
      int r = 0;

      await dbInstance.transaction((txn) async {
        for (var map in mapDetalleRequisiones) {
          map["JSON"] = jsonEncode(map);
          map["POST_GET"] = "POST";
          await txn.insert("SIAR_DETALLE_REQUISICION", map);
          r++;
        }
      });

      respuesta.idInsertado = r;
      return respuesta;
    }

    TockenOrds? tk = await api.TokenApi();
    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print(
          "error al obtener el token en guardarDetalleRequisicion, ${tk.error}");
      return respuesta;
    }

    final url = Uri.parse('$protocolo://$urlbase${suburl}detallerequisiciones');

    try {
      final response = await httpx.post(
        url,
        headers: headersConsumoApi(tk.accessToken!),
        body: jsonEncode(mapDetalleRequisiones),
      );

      tk.bitacoraHTTP(response);

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        respuesta = vmRespuestaPostFromJson(decoded);
        print('Respuesta API , guardarDetalleRequisicion: ${decoded}');
      } else {
        print(
            'Error en la API , guardarDetalleRequisicion: ${utf8.decode(response.bodyBytes)}');
        respuesta = respuesta;
      }
    } catch (e) {
      Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
      print('Ocurrió un error: $e');
      respuesta = respuesta;
    }

    return respuesta;
  }

  Future<VmRespuestaPost> actualizarDetalleRequisicion(
      List<Map<String, dynamic>> mapDetalleRequisiones) async {
    VmRespuestaPost respuesta = VmRespuestaPost();
    if (!conexionInternet) {
      var bd = await db.instance.database;
      int x = 0;

      await bd.transaction((txn) async {
        for (var map in mapDetalleRequisiones) {
          Map<String, dynamic> m = {
            "JSON": jsonEncode(map),
            "cantidad": map["cantidad"]
          };

          await txn.update(
            "SIAR_DETALLE_REQUISICION", // tabla
            m, // valores a actualizar
            where: "cod_det_requisiciones = ?", // condición
            whereArgs: [map["cod_det_requisiciones"]], // valores para ?
          );
        }
      });

      respuesta.idInsertado = x;
      return respuesta;
    }
    TockenOrds? tk = await api.TokenApi();
    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print(
          "error al obtener el token en CrudRequisiciones-actualizarDetalleRequisicion, ${tk.error}");
      return respuesta;
    }

    final url = Uri.parse('$protocolo://$urlbase${suburl}detallerequisiciones');

    try {
      final response = await httpx.put(
        url,
        headers: headersConsumoApi(tk.accessToken!),
        body: jsonEncode(mapDetalleRequisiones),
      );

      tk.bitacoraHTTP(response);

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        respuesta = vmRespuestaPostFromJson(decoded);
        print('Respuesta API , actualizarDetalleRequisicion: ${decoded}');
      } else {
        print(
            'Error en la API , actualizarDetalleRequisicion: ${utf8.decode(response.bodyBytes)}');
        respuesta = respuesta;
      }
    } catch (e) {
      print('Ocurrió un error:${e.toString()} ');
      Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
      respuesta = respuesta;
    }

    return respuesta;
  }

  Future<VmDetalleRequisiciones> traerDetalleRequisicion(String codRequisiones,
      {String bodegaExistencia = ""}) async {
    VmDetalleRequisiciones vm = VmDetalleRequisiciones(items: []);

    TockenOrds? tk = await api.TokenApi();
    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print(
          "error al obtener el token en CrudRequisiciones-traerDetalleRequisicion ,${tk.error}");
      return vm;
    }

    if (esAdmin()) {
      bodegaExistencia = "";
    } else {
      bodegaExistencia = codBodegaUsuario!.toString();
    }

    Map<String, dynamic> parametros = {
      "cod_requisiciones": codRequisiones,
      "bodega": bodegaExistencia
    };

    final url = Uri.parse('$protocolo://$urlbase${suburl}detallerequisiciones')
        .replace(queryParameters: parametros);

    try {
      final response = await httpx.get(
        url,
        headers: headersConsumoApi(tk.accessToken!),
      );

      tk.bitacoraHTTP(response);

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        vm = vmDetalleRequisicionesFromJson(decoded);
        print('Respuesta API , traerDetalleRequisicion: ${decoded}');
      } else {
        print(
            'Error en la API, traerDetalleRequisicion: ${utf8.decode(response.bodyBytes)}');
        return vm;
      }
    } catch (e) {
      print('Ocurrió un error: $e');
      Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
    }

    return vm;
  }
}
