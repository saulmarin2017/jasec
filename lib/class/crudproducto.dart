import 'dart:convert';
import 'package:jasec/class/log.dart';
import 'package:jasec/model/model.dart';
import 'package:jasec/model/vmbodegas.dart';
import 'package:jasec/model/vmminimosinventario.dart';
import 'package:jasec/model/vmproducto.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:jasec/class/apirest.dart';
import 'package:http/http.dart' as httpx;
import 'package:jasec/utilidades/utilidades.dart';

class CrudProducto {
  ApiRest api = ApiRest();

  Future<VmProducto> traerProductos({String bodegaExistencia = ""}) async {
    VmProducto vm = VmProducto(items: []);
    if (!conexionInternet) {
      return vmProductoFromJson(listadosdblocal.first.siarProducto!);
    } else {
      TockenOrds? tk = await api.TokenApi();
      //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
      if (tk!.error != null) {
        print(
            "error al obtener el token en CrudProducto-traerProductos ,${tk.error}");
        return vm;
      }

      if (esAdmin()) {
        bodegaExistencia = "";
      } else {
        bodegaExistencia = codBodegaUsuario.toString();
      }

      Map<String, dynamic> parametros = {"bodega": bodegaExistencia};

      final url = Uri.parse('$protocolo://$urlbase${suburl}producto')
          .replace(queryParameters: parametros);

      try {
        final response = await httpx.get(
          url,
          headers: headersConsumoApi(tk.accessToken!),
        );

        tk.bitacoraHTTP(response);

        if (response.statusCode == 200) {
          final decoded = utf8.decode(response.bodyBytes);
          vm = vmProductoFromJson(decoded);
          listaProductos = vm;
          print('Respuesta API , traerProductos: ${decoded}');
        } else {
          print(
              'Error en la API, traerProductos: ${utf8.decode(response.bodyBytes)}');
          return vm;
        }
      } catch (e) {
        print('Ocurrió un error: $e');
        Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
      }

      return vm;
    }
  }

  Future<VmMinimosInventario> traerMinimoInventario(
      {String bodegaExistencia = ""}) async {
    VmMinimosInventario vm = VmMinimosInventario(items: []);

    if (!conexionInternet) {
      return vmMinimosInventarioFromJson(
          listadosdblocal.first.siarMinimoInventario!);
    } else {
      TockenOrds? tk = await api.TokenApi();
      Uri url;
      //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
      if (tk!.error != null) {
        print(
            "error al obtener el token en traerMinimoInventario ,${tk.error}");
        return vm;
      }

      if (esAdmin()) {
        bodegaExistencia = "";
      } else {
        bodegaExistencia = codBodegaUsuario.toString();
      }

      Map<String, dynamic> parametros = {"bodega": bodegaExistencia};

      if (bodegaExistencia.isNotEmpty) {
        url = Uri.parse('$protocolo://$urlbase${suburl}minimoinventario')
            .replace(queryParameters: parametros);
      } else {
        url = Uri.parse('$protocolo://$urlbase${suburl}minimoinventario');
      }

      try {
        final response = await httpx.get(
          url,
          headers: headersConsumoApi(tk.accessToken!),
        );

        tk.bitacoraHTTP(response);

        if (response.statusCode == 200) {
          final decoded = utf8.decode(response.bodyBytes);
          vm = vmMinimosInventarioFromJson(decoded);

          print('Respuesta API , traerMinimoInventario: ${decoded}');
        } else {
          print(
              'Error en la API, traerMinimoInventario: ${utf8.decode(response.bodyBytes)}');
          return vm;
        }
      } catch (e) {
        print('Ocurrió un error: $e');
        Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
      }

      return vm;
    }
  }

  Future<VmBodegas> traerBodegas() async {
    VmBodegas vm = VmBodegas();
    if (!conexionInternet) {
      return vmBodegasFromJson(listadosdblocal.first.siarBodega!);
    }
    TockenOrds? tk = await api.TokenApi();
    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print(
          "error al obtener el token en CrudProducto-traerBodegas ,${tk.error}");
      return vm;
    }

    Map<String, dynamic> parametros = {"luminaria": luminaria};

    final url = Uri.parse('$protocolo://$urlbase${suburl}bodegas')
        .replace(queryParameters: parametros);

    try {
      final response = await httpx.get(
        url,
        headers: headersConsumoApi(tk.accessToken!),
      );

      tk.bitacoraHTTP(response);

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        vm = vmBodegasFromJson(decoded);
        print('Respuesta API , traerBodegas: ${decoded}');
      } else {
        print(
            'Error en la API, traerBodegas: ${utf8.decode(response.bodyBytes)}');
        return vm;
      }
    } catch (e) {
      Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
      print('Ocurrió un error: $e');
    }

    return vm;
  }
}
