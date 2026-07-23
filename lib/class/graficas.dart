import 'dart:convert';
import 'package:jasec/class/log.dart';
import 'package:jasec/model/model.dart';
import 'package:jasec/model/vmgraficabarras.dart';
import 'package:jasec/model/vmgraficadona.dart';
import 'package:jasec/model/vmgraficaporcentaje.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:jasec/class/apirest.dart';
import 'package:http/http.dart' as httpx;

class Graficas {
  ApiRest api = ApiRest();

  Future<VmGraficaBarras> traerGraficaBarras() async {
    VmGraficaBarras vm = VmGraficaBarras();
    if (!conexionInternet) {
      vm = vmGraficaBarrasFromJson(listadosdblocal.first.siarGraficaBarras!);
    }
    TockenOrds? tk = await api.TokenApi();
    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print("error al obtener el token en traerGraficaBarras ,${tk.error}");
      return vm;
    }

    Map<String, dynamic> parametros = {
      "cuadrilla": codCuadrillaUsaurio.toString(),
      "luminaria": luminaria
    };

    final url = Uri.parse('$protocolo://$urlbase${suburl}graficabarras')
        .replace(queryParameters: parametros);

    try {
      final response = await httpx.get(
        url,
        headers: headersConsumoApi(tk.accessToken!),
      );

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        vm = vmGraficaBarrasFromJson(decoded);

        print('Respuesta API , traerGraficaBarras: ${decoded}');
      } else {
        print(
            'Error en la API, traerGraficaBarras: ${utf8.decode(response.bodyBytes)}');
        return vm;
      }
    } catch (e) {
      print('Ocurrió un error: $e');
      Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
    }

    return vm;
  }

  Future<VmGraficaDona> traerGraficaDonas() async {
    VmGraficaDona vm = VmGraficaDona(items: []);
    if (!conexionInternet) {
      vm = vmGraficaDonaFromJson(listadosdblocal.first.siarGraficaDona!);
    }
    TockenOrds? tk = await api.TokenApi();
    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print("error al obtener el token en traerGraficaDonas ,${tk.error}");
      return vm;
    }

    Map<String, dynamic> parametros = {
      "cuadrilla": codCuadrillaUsaurio.toString(),
      "luminaria": luminaria
    };

    final url = Uri.parse('$protocolo://$urlbase${suburl}graficadona')
        .replace(queryParameters: parametros);

    try {
      final response = await httpx.get(
        url,
        headers: headersConsumoApi(tk.accessToken!),
      );

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        vm = vmGraficaDonaFromJson(decoded);

        print('Respuesta API , traerGraficaDonas: ${decoded}');
      } else {
        print(
            'Error en la API, traerGraficaDonas: ${utf8.decode(response.bodyBytes)}');
        return vm;
      }
    } catch (e) {
      print('Ocurrió un error: $e');
      Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
    }

    return vm;
  }

  Future<VmGraficaPorcentaje> traerGraficaPorcentaje() async {
    VmGraficaPorcentaje vm = VmGraficaPorcentaje();
    if (!conexionInternet) {
      vm = vmGraficaPorcentajeFromJson(
          listadosdblocal.first.siarGraficaPorcentaje!);
    }
    TockenOrds? tk = await api.TokenApi();
    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print("error al obtener el token en traerGraficaPorcentaje ,${tk.error}");
      return vm;
    }

    Map<String, dynamic> parametros = {
      "cuadrilla": codCuadrillaUsaurio.toString(),
      "luminaria": luminaria
    };

    final url = Uri.parse('$protocolo://$urlbase${suburl}graficaporcentaje')
        .replace(queryParameters: parametros);

    try {
      final response = await httpx.get(
        url,
        headers: headersConsumoApi(tk.accessToken!),
      );

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        vm = vmGraficaPorcentajeFromJson(decoded);

        print('Respuesta API , traerGraficaPorcentaje: ${decoded}');
      } else {
        print(
            'Error en la API, traerGraficaPorcentaje: ${utf8.decode(response.bodyBytes)}');
        return vm;
      }
    } catch (e) {
      print('Ocurrió un error: $e');
      Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
    }

    return vm;
  }
}
