import 'dart:convert';
import 'package:jasec/class/log.dart';
import 'package:jasec/db/db.dart';
import 'package:jasec/model/model.dart';
import 'package:jasec/model/vmordentrabajo.dart';
import 'package:jasec/model/vmsolicitudesordentrabajo.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:jasec/class/apirest.dart';
import 'package:http/http.dart' as httpx;

class CrudOrdenesTrabajo {
  ApiRest api = ApiRest();

  Future<VmOrdenTrabajo> traerOrdenesTrabajo(String luminaria) async {
    if (!conexionInternet) {
      return vmOrdenTrabajoFromJson(listadosdblocal.first.siarOrdenTrabajo!);
    }
    VmOrdenTrabajo vm = VmOrdenTrabajo(items: []);
    TockenOrds? tk = await api.TokenApi();
    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print(
          "error al obtener el token en CrudOrdenesTrabajo-traerOrdenesTrabajo ,${tk.error}");
      return vm;
    }

    final url = Uri.parse(
        '$protocolo://$urlbase${suburl}ordentrabajo/$codCuadrillaUsaurio/$luminaria');

    try {
      final response = await httpx.get(
        url,
        headers: headersConsumoApi(tk.accessToken!),
      );

      tk.bitacoraHTTP(response);

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        vm = vmOrdenTrabajoFromJson(decoded);
        print('Respuesta API , traerOrdenesTrabajo: ${decoded}');
      } else {
        print(
            'Error en la API, traerOrdenesTrabajo: ${utf8.decode(response.bodyBytes)}');
        return vm;
      }
    } catch (e) {
      print('Ocurrió un error: $e');
      Log.escribir('Error ejecutando ${url.toString()} ,  ${e.toString()}');
      return vm;
    }

    return vm;
  }

  Future<VmSolicitudesOrdenTrabajo> traerSolicitudesOrdenesTrabajo(
      String luminaria, String codordentrabajo) async {
    VmSolicitudesOrdenTrabajo vm = VmSolicitudesOrdenTrabajo(items: []);

    if (!conexionInternet) {
      //Instancia de base de datos local
      final bd = db.instance;
      //Recuperamos los datos de los listados fijos
      var data = await bd.obtenerRegistros("SIAR_SOLICITUDES",
          campo: "COD_ORDEN_TRABAJO", valor: codordentrabajo);

      List<ItemSolicitudesOrdenTrabajo> todasLasSolicitudes = [];

      int i = 0;
      for (final fila in data) {
        i = i + 1;
        final Map<String, dynamic> map = jsonDecode(fila['JSON']);
        final item = ItemSolicitudesOrdenTrabajo.fromJson(map);
        todasLasSolicitudes.add(item);
      }

      vm = VmSolicitudesOrdenTrabajo(items: todasLasSolicitudes);
      return vm;
    }

    TockenOrds? tk = await api.TokenApi();
    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print(
          "error al obtener el token en CrudOrdenesTrabajo-traerSolicitudesOrdenesTrabajo ,${tk.error}");
      return vm;
    }

    Map<String, dynamic> parametros = {
      "luminaria": luminaria,
      "cod_orden_trabajo": codordentrabajo
    };

    final url =
        Uri.parse('$protocolo://$urlbase${suburl}solicitudesordentrabajo')
            .replace(queryParameters: parametros);

    try {
      final response = await httpx.get(
        url,
        headers: headersConsumoApi(tk.accessToken!),
      );

      tk.bitacoraHTTP(response);

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        vm = vmSolicitudesOrdenTrabajoFromJson(decoded);
        print('Respuesta API , traerSolicitudesOrdenesTrabajo: ${decoded}');
      } else {
        print(
            'Error en la API, traerSolicitudesOrdenesTrabajo: ${utf8.decode(response.bodyBytes)}');
        return vm;
      }
    } catch (e) {
      print('Ocurrió un error: $e');
      Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
    }

    return vm;
  }

  Future<VmRespuestaPost> guardarKilometrajeInicio(
      Map<String, dynamic> mapFormulario) async {
    TockenOrds? tk = await api.TokenApi();
    VmRespuestaPost respuesta = VmRespuestaPost();
    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print(
          "error al obtener el token en CrudSolicitudLuminaria-guardarSolicitudLuminaria, ${tk.error}");
      return respuesta;
    }

    final url = Uri.parse('$protocolo://$urlbase${suburl}kilometraje');

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
        print('Respuesta API , guardarKilometraje: ${decoded}');
      } else {
        print(
            'Error en la API , guardarKilometraje: ${utf8.decode(response.bodyBytes)}');
        respuesta = respuesta;
      }
    } catch (e) {
      print('Ocurrió un error: $e');
      respuesta = respuesta;
      Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
    }

    return respuesta;
  }

  Future<VmRespuestaPost> actualizarKilometrajeFin(
      Map<String, dynamic> mapFormulario) async {
    TockenOrds? tk = await api.TokenApi();
    VmRespuestaPost respuesta = VmRespuestaPost();
    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print(
          "error al obtener el token en crudordenestrabajo-actualizarKilometrajeFin, ${tk.error}");
      return respuesta;
    }

    final url = Uri.parse('$protocolo://$urlbase${suburl}kilometraje');

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
        print('Respuesta API , actualizarKilometrajeFin: ${decoded}');
      } else {
        print(
            'Error en la API , actualizarKilometrajeFin: ${utf8.decode(response.bodyBytes)}');
        respuesta = respuesta;
      }
    } catch (e) {
      print('Ocurrió un error: $e');
      respuesta = respuesta;
      Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
    }

    return respuesta;
  }

  Future<VmRespuestaPost> actualizarEstadoOrdenTrabajo(
      Map<String, dynamic> mapFormulario) async {
    TockenOrds? tk = await api.TokenApi();
    VmRespuestaPost respuesta = VmRespuestaPost();
    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print(
          "error al obtener el token en CrudOrdenesTrabajo-actualizarEstadoOrdenTrabajo, ${tk.error}");
      return respuesta;
    }

    final url = Uri.parse('$protocolo://$urlbase${suburl}estadoordentrabajo/S');

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
        print('Respuesta API , actualizarEstadoOrdenTrabajo: ${decoded}');
      } else {
        print(
            'Error en la API , actualizarEstadoOrdenTrabajo: ${utf8.decode(response.bodyBytes)}');
      }
    } catch (e) {
      print('Ocurrió un error: $e');
      Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
      return respuesta;
    }

    return respuesta;
  }
}
