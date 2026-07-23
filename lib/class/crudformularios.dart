import 'dart:convert';

import 'package:jasec/class/log.dart';
import 'package:jasec/db/db.dart';
import 'package:jasec/model/model.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:jasec/class/apirest.dart';
import 'package:http/http.dart' as httpx;

class CrudFormularios {
  ApiRest api = ApiRest();

  Future<bool> guardarRespuestasFormulario(
      List<Map<String, dynamic>> mapFormulario,
      {String solicitud = "",
      String formulario = ""}) async {
    if (!conexionInternet) {
      final bd = db.instance;
      var existe = await bd
          .obtenerRegistrosWhere("SIAR_DET_FORMULARIO_RESPUESTA", condiciones: {
        "COD_SOLICITUD": solicitud,
        "COD_FORMULARIO": formulario
      });

      Map<String, dynamic> datos = {
        "COD_SOLICITUD": solicitud,
        "COD_FORMULARIO": formulario,
        "JSON": jsonEncode(mapFormulario)
      };

      //Actualizar respuestas
      if (existe.isNotEmpty) {
        datos["POST_PUT"] = "PUT";
        var r = await bd.actualizar(
            "SIAR_DET_FORMULARIO_RESPUESTA", datos, "COD_SOLICITUD", solicitud,
            condicionesExtras: {"COD_FORMULARIO": formulario});
        if (r > 0) {
          return true;
        }
      } else {
        //Registro guardado por primera vez
        datos["POST_PUT"] = "POST";
        var r = await bd.insertar(datos, "SIAR_DET_FORMULARIO_RESPUESTA");
        if (r > 0) {
          return true;
        }
      }
    }

    TockenOrds? tk = await api.TokenApi();
    bool respuesta = true;
    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print(
          "error al obtener el token en CrudFormularios-guardarRespuestasFormulario ,${tk.error}");
      return false;
    }

    final url =
        Uri.parse('$protocolo://$urlbase${suburl}formulariorespuesta/0/0');
    try {
      List<Map<String, dynamic>> json = [];

      for (var p in mapFormulario) {
        Map<String, dynamic> x = {
          "cod_formulario": p['cod_formulario'] ?? 0,
          "cod_solicitud": p['cod_solicitud'] ?? 0,
          "cod_grupo_preguntas": p['cod_grupo_preguntas'] ?? 0,
          "cod_det_preguntas": p['cod_det_preguntas'] ?? 0,
          "respuesta": p['respuesta'] ?? "",
        };

        json.add(x);
      }

      final response = await httpx.post(
        url,
        headers: headersConsumoApi(tk.accessToken!),
        body: jsonEncode(json),
      );

      tk.bitacoraHTTP(response);

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        respuesta = true;
        print('Respuesta API , guardarRespuestasFormulario: ${decoded}');
      } else {
        print(
            'Error en la API , guardarRespuestasFormulario: ${utf8.decode(response.bodyBytes)}');
        respuesta = false;
      }
    } catch (e) {
      print('Ocurrió un error: $e');
      respuesta = false;
      Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
    }

    return respuesta;
  }

  Future<VmFormulario> traerDatosFormulario(
      String solicitud, String formulario) async {
    VmFormulario vm = VmFormulario(items: []);

    if (!conexionInternet) {
      var bd = db.instance;

      var data = await bd.obtenerRegistrosWhere("SIAR_DET_FORMULARIO_RESPUESTA",
          condiciones: {
            "COD_SOLICITUD": solicitud,
            "COD_FORMULARIO": formulario
          });

      if (data.isNotEmpty) {
        final fila = data[0];
        final json = fila['JSON'];
        vm = vmFormularioFromJson('{"items":$json}');
      }

      return vm;
    }

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
}
