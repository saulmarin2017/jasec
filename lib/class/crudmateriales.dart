import 'dart:convert';
import 'package:jasec/class/log.dart';
import 'package:jasec/db/db.dart';
import 'package:jasec/model/model.dart';
import 'package:jasec/model/vmproducto.dart';
import 'package:jasec/model/vmsolicitudmaterial.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:jasec/class/apirest.dart';
import 'package:http/http.dart' as httpx;

class CrudMateriales {
  ApiRest api = ApiRest();

  Future<VmSolicitudMateriales> traerMaterialesSolicitud(
      String codsolicitud, String instalados, String codPoste) async {
    VmSolicitudMateriales vm = VmSolicitudMateriales(items: []);
    if (!conexionInternet) {
      var bd = db.instance;
      var data = await bd.obtenerRegistros("SIAR_SOLICITUD_MATERIALES",
          campo: "COD_SOLICITUD", valor: codsolicitud);

      var datafilter = data.where(
          (w) => w['INSTALADOS'] == instalados && w['ESTADO'] != "ELIMINADO");

      if (datafilter.isEmpty) {
        vm.items != [];
        return vm;
      }

      var productos = vmProductoFromJson(listadosdblocal.first.siarProducto!);

      datafilter.forEach((x) {
        var r = ItemSolicitudMateriales.fromJsonMayusculas(x);
        var p = productos.items!
            .where((w) => w.codSiarProducto == r.codSiarProducto)
            .first;

        r.nomProducto = p.nomProducto;
        r.fechaInsert = DateTime.now();
        vm.items!.add(r);
      });

      return vm;
    }

    TockenOrds? tk = await api.TokenApi();
    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print(
          "error al obtener el token en CrudMateriales-traerSolicitudMateriales ,${tk.error}");
      return vm;
    }

    Map<String, dynamic> parametros = {
      "cod_solicitud": codsolicitud,
      "instalados": instalados,
      "cod_poste": codPoste
    };

    final url = Uri.parse('$protocolo://$urlbase${suburl}solicitudmateriales')
        .replace(queryParameters: parametros);

    try {
      final response = await httpx.get(
        url,
        headers: headersConsumoApi(tk.accessToken!),
      );

      tk.bitacoraHTTP(response);

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        vm = vmSolicitudMaterialesFromJson(decoded);
        print('Respuesta API , traerSolicitudMateriales: ${decoded}');
      } else {
        print(
            'Error en la API, traerSolicitudMateriales: ${utf8.decode(response.bodyBytes)}');
        return vm;
      }
    } catch (e) {
      print('Ocurrió un error: $e');
      Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
    }

    return vm;
  }

  Future<VmSolicitudMateriales> materialesCuadrilla() async {
    VmSolicitudMateriales vm = VmSolicitudMateriales();
    TockenOrds? tk = await api.TokenApi();
    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print(
          "error al obtener el token en CrudMateriales-VmMaterialesCuadrilla ,${tk.error}");
      return vm;
    }

    Map<String, dynamic> parametros = {
      "cod_cuadrilla": codCuadrillaUsaurio.toString()
    };

    final url = Uri.parse('$protocolo://$urlbase${suburl}materialescuadrilla')
        .replace(queryParameters: parametros);

    try {
      final response = await httpx.get(
        url,
        headers: headersConsumoApi(tk.accessToken!),
      );

      tk.bitacoraHTTP(response);

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        vm = vmSolicitudMaterialesFromJson(decoded);
        print('Respuesta API , VmMaterialesCuadrilla: ${decoded}');
      } else {
        print(
            'Error en la API, VmMaterialesCuadrilla: ${utf8.decode(response.bodyBytes)}');
        return vm;
      }
    } catch (e) {
      print('Ocurrió un error: $e');
      Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
    }

    return vm;
  }

  Future<VmRespuestaPost> solicitudMaterialesInstalados(
      List<Map<String, dynamic>> mapMateriales) async {
    VmRespuestaPost vm = VmRespuestaPost();
    if (!conexionInternet) {
      final bd = db.instance;
      if (mapMateriales.isNotEmpty) {
        mapMateriales.forEach((map) async {
          map['POST_PUT'] = 'POST';
          map['FECHA_INSERT'] = '';
          vm.idInsertado = await bd.insertar(map, "SIAR_SOLICITUD_MATERIALES");
        });
      }
      return vm;
    } else {
      TockenOrds? tk = await api.TokenApi();
      //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
      if (tk!.error != null) {
        print(
            "error al obtener el token en CrudMateriales-solicitudMaterialesInstalados ,${tk.error}");
        return vm;
      }

      final url =
          Uri.parse('$protocolo://$urlbase${suburl}solicitudmateriales');

      try {
        final response = await httpx.post(url,
            headers: headersConsumoApi(tk.accessToken!),
            body: jsonEncode(mapMateriales));

        tk.bitacoraHTTP(response);

        if (response.statusCode == 200) {
          final decoded = utf8.decode(response.bodyBytes);
          vm = vmRespuestaPostFromJson(decoded);
          print('Respuesta API , solicitudMaterialesInstalados: ${decoded}');
        } else {
          print(
              'Error en la API, solicitudMaterialesInstalados: ${utf8.decode(response.bodyBytes)}');
          return vm;
        }
      } catch (e) {
        print('Ocurrió un error: $e');
        Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
      }

      return vm;
    }
  }

  Future<VmRespuestaPost> eliminarSolicitudMaterialesInstalados(
      String codsolicitudmaterial) async {
    VmRespuestaPost vm = VmRespuestaPost();
    if (!conexionInternet) {
      var bd = db.instance;
      Map<String, dynamic> map = {"ESTADO": "ELIMINADO", "POST_PUT": "DELETE"};
      vm.idInsertado = await bd.actualizar("SIAR_SOLICITUD_MATERIALES", map,
          "COD_SOLICITUD_MATERIAL", codsolicitudmaterial);
      return vm;
    }
    TockenOrds? tk = await api.TokenApi();
    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print(
          "error al obtener el token en CrudMateriales-deleteSolicitudMaterialesInstalados ,${tk.error}");
      return vm;
    }

    final url = Uri.parse('$protocolo://$urlbase${suburl}solicitudmateriales');
    List<Map<String, dynamic>> lista = [];
    Map<String, dynamic> mapMateriales = {
      "cod_solicitud_material": codsolicitudmaterial
    };
    lista.add(mapMateriales);

    try {
      final response = await httpx.delete(url,
          headers: headersConsumoApi(tk.accessToken!), body: jsonEncode(lista));

      tk.bitacoraHTTP(response);

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        vm = vmRespuestaPostFromJson(decoded);
        print(
            'Respuesta API , deleteSolicitudMaterialesInstalados: ${decoded}');
      } else {
        print(
            'Error en la API, deleteSolicitudMaterialesInstalados: ${utf8.decode(response.bodyBytes)}');
        return vm;
      }
    } catch (e) {
      print('Ocurrió un error: $e');
      Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
    }

    return vm;
  }

  Future<VmSolicitudMateriales> actualizarSolicitudMateriales(
      Map<String, dynamic> map) async {
    VmSolicitudMateriales vm = VmSolicitudMateriales();
    TockenOrds? tk = await api.TokenApi();
    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print(
          "error al obtener el token en CrudMateriales-actualizarSolicitudMateriales ,${tk.error}");
      return vm;
    }

    List<Map<String, dynamic>> lista = [];
    lista.add(map);
    final url = Uri.parse('$protocolo://$urlbase${suburl}solicitudmateriales');

    try {
      final response = await httpx.put(url,
          headers: headersConsumoApi(tk.accessToken!), body: jsonEncode(lista));

      tk.bitacoraHTTP(response);

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        vm = vmSolicitudMaterialesFromJson(decoded);
        print('Respuesta API , actualizarSolicitudMateriales: ${decoded}');
      } else {
        print(
            'Error en la API, actualizarSolicitudMateriales: ${utf8.decode(response.bodyBytes)}');
        return vm;
      }
    } catch (e) {
      print('Ocurrió un error: $e');
      Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
    }

    return vm;
  }
}
