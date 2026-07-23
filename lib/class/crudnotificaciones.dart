import 'dart:convert';
import 'package:jasec/class/log.dart';
import 'package:jasec/model/model.dart';
import 'package:jasec/model/vmnotificaciones.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:jasec/class/apirest.dart';
import 'package:http/http.dart' as httpx;

class CrudNotificaciones {
  ApiRest api = ApiRest();

  Future<int> cantidadNotificacionesPENDIENTES() async {
    if (!conexionInternet) {
      return 0;
    }
    TockenOrds? tk = await api.TokenApi();
    int count = 0;
    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print(
          "error al obtener el token en cantidadNotificaciones - PENDIENTES ,${tk.error}");
      return 0;
    }

    Map<String, dynamic> parametros = {"cod_cuadrilla": '$codCuadrillaUsaurio'};

    final url = Uri.parse('$protocolo://$urlbase${suburl}existenotificaciones')
        .replace(queryParameters: parametros);

    try {
      final response = await httpx.get(
        url,
        headers: headersConsumoApi(tk.accessToken!),
      );

      tk.bitacoraHTTP(response);

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);

        Map<String, dynamic> jsonData = json.decode(decoded);

        // Accedemos a la lista "items"
        List<dynamic> items = jsonData['items'];

        count = items[0]['notificaciones'];

        print('Respuesta API , Tipo Servicio: ${response.body}');
      } else {
        print('Error en la API: ${response.body}');
      }
    } catch (e) {
      print('Ocurrió un error $url : $e');
      Log.escribir('Error ejecutando ${url.toString()} ,  ${e.toString()}');
    }

    return count;
  }

  Future<VmNotificacion> notificacionesPENDIENTES() async {
    //0= Listado de notificaciones
    //1= Cantidad de notificaciones
    TockenOrds? tk = await api.TokenApi();
    VmNotificacion vm = VmNotificacion();
    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print("error al obtener el token en listaNotificaciones ,${tk.error}");
      return vm;
    }

    Map<String, dynamic> parametros = {"cod_cuadrilla": '$codCuadrillaUsaurio'};

    final url = Uri.parse('$protocolo://$urlbase${suburl}notificacion')
        .replace(queryParameters: parametros);

    try {
      final response = await httpx.get(
        url,
        headers: headersConsumoApi(tk.accessToken!),
      );

      tk.bitacoraHTTP(response);

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        vm = vmNotificacionFromJson(decoded);
        print('Respuesta API , Tipo Servicio: ${response.body}');
      } else {
        print('Error en la API: ${response.body}');
      }
    } catch (e) {
      print('Ocurrió un error: $e');
      Log.escribir('Error ejecutando ${url.toString()} ,  ${e.toString()}');
    }

    return vm;
  }

  Future<VmRespuestaPost> actualizarEstadoNotificacion(
      String codNotificacion) async {
    TockenOrds? tk = await api.TokenApi();
    VmRespuestaPost respuesta = VmRespuestaPost();
    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print(
          "error al obtener el token en actualizarEstadoNotiicacion, ${tk.error}");
      return respuesta;
    }

    final url = Uri.parse('$protocolo://$urlbase${suburl}notificacion');

    try {
      List<Map<String, dynamic>> json = [];
      Map<String, dynamic> map = {
        "cod_notificacion": '$codNotificacion',
        "estado": "VISTA"
      };

      json.add(map);

      final response = await httpx.put(
        url,
        headers: headersConsumoApi(tk.accessToken!),
        body: jsonEncode(json),
      );

      tk.bitacoraHTTP(response);

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        respuesta = vmRespuestaPostFromJson(decoded);
        print('Respuesta API , actualizarEstadoNotiicacion: ${decoded}');
      } else {
        print(
            'Error en la API , actualizarEstadoNotiicacion: ${utf8.decode(response.bodyBytes)}');
        respuesta = respuesta;
      }
    } catch (e) {
      print('Ocurrió un error: $e');
      respuesta = respuesta;
      Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
    }

    return respuesta;
  }
}
