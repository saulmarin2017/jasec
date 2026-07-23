import 'dart:convert';
import 'package:jasec/class/log.dart';
import 'package:jasec/model/model.dart';
import 'package:jasec/model/vmdetalletransferencia.dart';
import 'package:jasec/model/vmrequisiciones.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:jasec/class/apirest.dart';
import 'package:http/http.dart' as httpx;

class CrudTransferencias {
  ApiRest api = ApiRest();
  //Encabezados
  Future<VmRespuestaPost> guardarTransferencia(
      Map<String, dynamic> mapRequisicion) async {
    TockenOrds? tk = await api.TokenApi();
    VmRespuestaPost respuesta = VmRespuestaPost();
    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print("error al obtener el token en guardarRequisicion, ${tk.error}");
      return respuesta;
    }

    final url =
        Uri.parse('$protocolo://$urlbase${suburl}transferenciamateriales');

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

  Future<VmRespuestaPost> eliminarTransferencia(
      Map<String, dynamic> mapTransferencia) async {
    TockenOrds? tk = await api.TokenApi();
    VmRespuestaPost respuesta = VmRespuestaPost();
    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print("error al obtener el token en eliminarTransferencia, ${tk.error}");
      return respuesta;
    }

    final url =
        Uri.parse('$protocolo://$urlbase${suburl}transferenciamateriales');

    List<Map<String, dynamic>> json = [];
    json.add(mapTransferencia);

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
        print('Respuesta API , eliminarTransferencia: ${decoded}');
      } else {
        print(
            'Error en la API , eliminarTransferencia: ${utf8.decode(response.bodyBytes)}');
        respuesta = respuesta;
      }
    } catch (e) {
      print('Ocurrió un error: $e');
      Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
      respuesta = respuesta;
    }

    return respuesta;
  }

  Future<VmRespuestaPost> actualizarTransferencia(
      Map<String, dynamic> mapTransferencia) async {
    TockenOrds? tk = await api.TokenApi();
    VmRespuestaPost respuesta = VmRespuestaPost();
    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print(
          "error al obtener el token en ActualizarTransferencia, ${tk.error}");
      return respuesta;
    }

    final url =
        Uri.parse('$protocolo://$urlbase${suburl}transferenciamateriales');

    List<Map<String, dynamic>> json = [];
    json.add(mapTransferencia);

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
        print('Respuesta API , actualizarTransferencia: ${decoded}');
      } else {
        print(
            'Error en la API , actualizarTransferencia: ${utf8.decode(response.bodyBytes)}');
        respuesta = respuesta;
      }
    } catch (e) {
      print('Ocurrió un error: $e');
      Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
      respuesta = respuesta;
    }

    return respuesta;
  }

  Future<VmRequisiciones> traerTransferecia(String codEncTransferencia) async {
    VmRequisiciones vm = VmRequisiciones();
    TockenOrds? tk = await api.TokenApi();
    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print(
          "error al obtener el token en CrudFormularios-traerRequisicion ,${tk.error}");
      return vm;
    }

    Map<String, dynamic> parametros = {
      "cod_requisiciones": codEncTransferencia,
      "luminaria": luminaria
    };

    final url =
        Uri.parse('$protocolo://$urlbase${suburl}transferenciamateriales')
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

  //Detalles
  Future<VmRespuestaPost> guardarDetalleTransferencia(
      List<Map<String, dynamic>> mapDetalleRequisiones) async {
    TockenOrds? tk = await api.TokenApi();
    VmRespuestaPost respuesta = VmRespuestaPost();
    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print(
          "error al obtener el token en detalletransferenciasmateriales, ${tk.error}");
      return respuesta;
    }

    final url = Uri.parse(
        '$protocolo://$urlbase${suburl}detalletransferenciasmateriales');

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
        print('Respuesta API , detalletransferenciasmateriales: ${decoded}');
      } else {
        print(
            'Error en la API , detalletransferenciasmateriales: ${utf8.decode(response.bodyBytes)}');
        respuesta = respuesta;
      }
    } catch (e) {
      print('Ocurrió un error: $e');
      Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
      respuesta = respuesta;
    }

    return respuesta;
  }

  Future<VmRespuestaPost> eliminarDetalleTransferencia(
      Map<String, dynamic> mapDetalleRequisiciones) async {
    TockenOrds? tk = await api.TokenApi();
    VmRespuestaPost respuesta = VmRespuestaPost();
    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print(
          "error al obtener el token en detalletransferenciasmateriales, ${tk.error}");
      return respuesta;
    }

    final url = Uri.parse(
        '$protocolo://$urlbase${suburl}detalletransferenciasmateriales');

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
        print('Respuesta API , detalletransferenciasmateriales: ${decoded}');
      } else {
        print(
            'Error en la API , detalletransferenciasmateriales: ${utf8.decode(response.bodyBytes)}');
        respuesta = respuesta;
      }
    } catch (e) {
      print('Ocurrió un error: $e');
      Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
      respuesta = respuesta;
    }

    return respuesta;
  }

  Future<VmRespuestaPost> actualizarDetalleTransferencia(
      List<Map<String, dynamic>> mapDetalleRequisiones) async {
    TockenOrds? tk = await api.TokenApi();
    VmRespuestaPost respuesta = VmRespuestaPost();
    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print(
          "error al obtener el token en detalletransferenciasmateriales, ${tk.error}");
      return respuesta;
    }

    final url = Uri.parse(
        '$protocolo://$urlbase${suburl}detalletransferenciasmateriales');

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
        print('Respuesta API , detalletransferenciasmateriales: ${decoded}');
      } else {
        print(
            'Error en la API , detalletransferenciasmateriales: ${utf8.decode(response.bodyBytes)}');
        respuesta = respuesta;
      }
    } catch (e) {
      print('Ocurrió un error:${e.toString()} ');
      Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
      respuesta = respuesta;
    }

    return respuesta;
  }

  Future<VmDetalleTransferencia> traerDetalleTransferencia(
      String codEncTransferencia, String bodegaorigen) async {
    VmDetalleTransferencia vm = VmDetalleTransferencia();
    TockenOrds? tk = await api.TokenApi();
    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print(
          "error al obtener el token en CrudRequisiciones-traerDetalleTransferencia ,${tk.error}");
      return vm;
    }

    Map<String, dynamic> parametros = {
      "cod_enc_materiales": codEncTransferencia,
      "bodega": bodegaorigen
    };

    final url = Uri.parse(
            '$protocolo://$urlbase${suburl}detalletransferenciasmateriales')
        .replace(queryParameters: parametros);
    try {
      final response = await httpx.get(
        url,
        headers: headersConsumoApi(tk.accessToken!),
      );

      tk.bitacoraHTTP(response);

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        vm = vmDetalleTransferenciaFromJson(decoded);
        print('Respuesta API , traerDetalleTransferencia: ${decoded}');
      } else {
        print(
            'Error en la API, traerDetalleTransferencia: ${utf8.decode(response.bodyBytes)}');
        return vm;
      }
    } catch (e) {
      print('Ocurrió un error: $e');
      Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
    }

    return vm;
  }
}
