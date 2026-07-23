import 'dart:convert';

import 'package:jasec/class/log.dart';
import 'package:jasec/class/red.dart';
import 'package:jasec/db/db.dart';
import 'package:jasec/model/model.dart';
import 'package:jasec/model/vmmarcamodelo.dart';
import 'package:jasec/model/vmmedidores.dart';
import 'package:jasec/model/vmposte.dart';
import 'package:jasec/model/vmrespuestasformulario.dart';
import 'package:jasec/model/vmtipoatencion.dart';
import 'package:jasec/model/vmtiposolicitud.dart';
import 'package:jasec/model/vmtiposolicitudst.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:jasec/class/apirest.dart';
import 'package:http/http.dart' as httpx;

class ListasPrecargadas {
  ApiRest api = ApiRest();
  Red red = Red();
  final bd = db.instance;

  Future<VmProvincia> listaProvincias() async {
    if (!conexionInternet) {
      return vmProvinciaFromJson(listadosdblocal.first.siarProvincia!);
    }
    TockenOrds? tk = await api.TokenApi();
    VmProvincia vmProvincia = VmProvincia();
    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print(
          "error al obtener el token en ListasPrecargadas-listaProvincias ,${tk.error}");
      return vmProvincia;
    }

    final url = Uri.parse('$protocolo://$urlbase${suburl}provincia');
    try {
      final response = await httpx.get(
        url,
        headers: headersConsumoApi(tk.accessToken!),
      );

      tk.bitacoraHTTP(response);

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        vmProvincia = vmProvinciaFromJson(decoded);
        print('Respuesta API , Provincias: ${response.body}');
      } else {
        print('Error en la API: ${response.body}');
      }
    } catch (e) {
      print('Ocurrió un error: $e');
      Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
    }

    return vmProvincia;
  }

  Future<VmCanton> listaCanton(String idProvincia) async {
    VmCanton vm = VmCanton(items: []);
    if (!conexionInternet) {
      var datos = vmCantonFromJson(listadosdblocal.first.siarCanton!);

      final itemsFiltrados = (datos.items ?? [])
          .where((d) => d.idProvincia == idProvincia)
          .toList();
      vm.items!.addAll(itemsFiltrados);

      return vm;
    }
    TockenOrds? tk = await api.TokenApi();

    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print(
          "error al obtener el token en ListasPrecargadas-listacanton ,${tk.error}");
      return vm;
    }

    final url = Uri.parse('$protocolo://$urlbase${suburl}canton/$idProvincia');
    //.replace(queryParameters: parametros);

    try {
      //Map<String, String> parametros = {'id_provincia': id_provincia};

      final response = await httpx.get(
        url,
        headers: headersConsumoApi(tk.accessToken!),
      );

      tk.bitacoraHTTP(response);

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        vm = vmCantonFromJson(decoded);
        print('Respuesta API, Canton: ${response.body}');
      } else {
        print('Error en la API: ${response.body}');
      }
    } catch (e) {
      print('Ocurrió un error: $e');
      Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
    }

    return vm;
  }

  Future<VmDistrito> listaDistrito(String idProvincia, String idCanton) async {
    VmDistrito vm = VmDistrito(items: []);
    if (!conexionInternet) {
      var datos = vmDistritoFromJson(listadosdblocal.first.siarDistrito!);

      final itemsFiltrados = (datos.items ?? [])
          .where((d) => d.idProvincia == idProvincia && d.idCanton == idCanton)
          .toList();
      vm.items!.addAll(itemsFiltrados);

      return vm;
    }
    TockenOrds? tk = await api.TokenApi();

    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print(
          "error al obtener el token en ListasPrecargadas-listacanton ,${tk.error}");
      return vm;
    }

    final url = Uri.parse(
        '$protocolo://$urlbase${suburl}distrito/$idProvincia/$idCanton');

    try {
      final response = await httpx.get(
        url,
        headers: headersConsumoApi(tk.accessToken!),
      );

      tk.bitacoraHTTP(response);

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        vm = vmDistritoFromJson(decoded);
        print('Respuesta API, Distrito: ${response.body}');
      } else {
        print('Error en la API: ${response.body}');
      }
    } catch (e) {
      print('Ocurrió un error: $e');
      Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
    }

    return vm;
  }

  Future<VmFormulario> preguntasFormulario(String idformulario) async {
    TockenOrds? tk = await api.TokenApi();
    VmFormulario vm = VmFormulario(items: []);
    if (!conexionInternet) {
      if (idformulario.isNotEmpty) {
        var datos =
            vmFormularioFromJson(listadosdblocal.first.siarFormularios!);
        final itemsFiltrados = (datos.items ?? [])
            .where((d) => d.codFormulario == int.parse(idformulario))
            .toList();
        vm.items!.addAll(itemsFiltrados);

        return vm;
      } else {
        return vmFormularioFromJson(listadosdblocal.first.siarFormularios!);
      }
    }

    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print(
          "error al obtener el token en ListasPrecargadas-pregutnasFormulario ,${tk.error}");
      return vm;
    }
    Map<String, dynamic> map = {
      "id_formulario": idformulario,
    };

    final url = Uri.parse('$protocolo://$urlbase${suburl}formularios')
        .replace(queryParameters: map);

    try {
      final response = await httpx.get(
        url,
        headers: headersConsumoApi(tk.accessToken!),
      );

      tk.bitacoraHTTP(response);

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        vm = vmFormularioFromJson(decoded);
        print('Respuesta API, Fromularios: ${decoded}');
      } else {
        print('Error en la API: ${response.body}');
      }
    } catch (e) {
      print('Ocurrió un error: $e');
      Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
    }

    return vm;
  }

  Future<VmRespuestaSujeridas> respuestasSujeridas() async {
    TockenOrds? tk = await api.TokenApi();
    VmRespuestaSujeridas vm = VmRespuestaSujeridas();
    if (!conexionInternet) {
      return vmRespuestaFormularioFromJson(
          listadosdblocal.first.siarRespuestasSujeridas!);
    }

    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print(
          "error al obtener el token en ListasPrecargadas-respuestasSujeridas ,${tk.error}");
      return vm;
    }

    final url = Uri.parse('$protocolo://$urlbase${suburl}respuestassujeridas');

    try {
      final response = await httpx.get(
        url,
        headers: headersConsumoApi(tk.accessToken!),
      );

      tk.bitacoraHTTP(response);

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        vm = vmRespuestaFormularioFromJson(decoded);
        print('Respuesta API, Fromularios: ${response.body}');
      } else {
        print('Error en la API: ${response.body}');
      }
    } catch (e) {
      print('Ocurrió un error: $e');
      Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
    }

    return vm;
  }

  Future<VmTipoServicio> listaTipoServicio({String alumbrado = 'S'}) async {
    VmTipoServicio vm = VmTipoServicio();

    if (!conexionInternet) {
      return vmTipoServicioFromJson(listadosdblocal.first.siarTipoServicio!);
    }

    TockenOrds? tk = await api.TokenApi();

    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print(
          "error al obtener el token en ListasPrecargadas-Servicio ,${tk.error}");
      return vm;
    }

    final url = Uri.parse('$protocolo://$urlbase${suburl}tiposervicio');

    try {
      final response = await httpx.get(
        url,
        headers: headersConsumoApi(tk.accessToken!),
      );

      tk.bitacoraHTTP(response);

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        vm = vmTipoServicioFromJson(decoded);
        print('Respuesta API , Tipo Servicio: ${response.body}');
      } else {
        print('Error en la API: ${response.body}');
      }
    } catch (e) {
      print('Ocurrió un error: $e');
      Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
    }

    return vm;
  }

  Future<VmTipoSolicitud> listaTipoSolicitud({String alumbrado = 'S'}) async {
    VmTipoSolicitud vm = VmTipoSolicitud();
    if (!conexionInternet) {
      if (alumbrado == "S") {
        return vmTipoSolicitudFromJson(
            listadosdblocal.first.siarTipoSolicitud!);
      } else {
        return vmTipoSolicitudFromJson(
            listadosdblocal.first.siarTipoSolicitudST!);
      }
    }

    TockenOrds? tk = await api.TokenApi();

    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print(
          "error al obtener el token en ListasPrecargadas-listaTipoSolicitud ,${tk.error}");
      return vm;
    }

    final url =
        Uri.parse('$protocolo://$urlbase${suburl}tiposolicitud/$alumbrado');

    try {
      final response = await httpx.get(
        url,
        headers: headersConsumoApi(tk.accessToken!),
      );

      tk.bitacoraHTTP(response);

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);

        vm = vmTipoSolicitudFromJson(decoded);

        print('Respuesta API , Tipo Soicitud: ${response.body}');
      } else {
        print('Error en la API: ${response.body}');
      }
    } catch (e) {
      print('Ocurrió un error: $e');
      Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
      return vm;
    }

    return vm;
  }

  Future<VmTipoSolicitudSt> listaTipoSolicitudST() async {
    VmTipoSolicitudSt vm = VmTipoSolicitudSt(items: []);

    if (!conexionInternet) {
      return vmTipoSolicitudFromJsonSt(
          listadosdblocal.first.siarTipoSolicitudST!);
    }

    TockenOrds? tk = await api.TokenApi();

    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print(
          "error al obtener el token en ListasPrecargadas-listaTipoSolicitudST ,${tk.error}");
      return vm;
    }

    final url = Uri.parse('$protocolo://$urlbase${suburl}tiposolicitudst');

    try {
      final response = await httpx.get(
        url,
        headers: headersConsumoApi(tk.accessToken!),
      );

      tk.bitacoraHTTP(response);

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        Log.escribir('Tipos de solicitude: ${url.toString()} ,  ${decoded}');
        vm = vmTipoSolicitudFromJsonSt(decoded);
        print('Respuesta API , Tipo Soicitud: ${response.body}');
      } else {
        print('Error en la API: ${response.body}');
      }
    } catch (e) {
      print('Ocurrió un error: $e');
      Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
      return vm;
    }

    return vm;
  }

  Future<VmTipoAtencion> listaTipoAtencion({String alumbrado = 'S'}) async {
    VmTipoAtencion vm = VmTipoAtencion();
    if (!conexionInternet) {
      return vmTipoAtencionFromJson(listadosdblocal.first.siarTipoAtencion!);
    }

    TockenOrds? tk = await api.TokenApi();

    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print(
          "error al obtener el token en ListasPrecargadas-listaTipoAtencion ,${tk.error}");
      return vm;
    }

    final url =
        Uri.parse('$protocolo://$urlbase${suburl}tipoatencion/$alumbrado');
    try {
      final response = await httpx.get(
        url,
        headers: headersConsumoApi(tk.accessToken!),
      );

      tk.bitacoraHTTP(response);

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        vm = vmTipoAtencionFromJson(decoded);
        print('Respuesta API , Tipo Atencion: ${response.body}');
      } else {
        print('Error en la API: ${response.body}');
      }
    } catch (e) {
      print('Ocurrió un error: $e');
      Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
    }

    return vm;
  }

  Future<VmMotivosRechazo> listaMotivosRechazo({String alumbrado = 'S'}) async {
    VmMotivosRechazo vm = VmMotivosRechazo();
    if (!conexionInternet) {
      return vmMotivosRechazoFromJson(
          listadosdblocal.first.siarMotivosRechazo!);
    }

    TockenOrds? tk = await api.TokenApi();

    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print(
          "error al obtener el token en ListasPrecargadas-listaTipoSolicitud ,${tk.error}");
      return vm;
    }

    final url =
        Uri.parse('$protocolo://$urlbase${suburl}motivorechazo/$alumbrado');

    try {
      final response = await httpx.get(
        url,
        headers: headersConsumoApi(tk.accessToken!),
      );

      tk.bitacoraHTTP(response);

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        vm = vmMotivosRechazoFromJson(decoded);
        print('Respuesta API , Motivos de rechazo: ${response.body}');
      } else {
        print('Error en la API: ${response.body}');
      }
    } catch (e) {
      print('Ocurrió un error: $e');
      Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
    }

    return vm;
  }

  Future<VmMarcoModelo> listaMarcaModelo() async {
    TockenOrds? tk = await api.TokenApi();
    VmMarcoModelo vmMarcaModelo = VmMarcoModelo();
    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print(
          "error al obtener el token en ListasPrecargadas-listaMarcaModelo ,${tk.error}");
      return vmMarcaModelo;
    }

    final url = Uri.parse('$protocolo://$urlbase${suburl}marcamodelo');

    try {
      final response = await httpx.get(
        url,
        headers: headersConsumoApi(tk.accessToken!),
      );

      tk.bitacoraHTTP(response);

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        vmMarcaModelo = vmMarcoModeloFromJson(decoded);
        print('Respuesta API , Marca Modelo: ${response.body}');
      } else {
        print('Error en la API: ${response.body}');
      }
    } catch (e) {
      print('Ocurrió un error: $e');
      Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
    }

    return vmMarcaModelo;
  }

  Future<VmMedidores> listaMedidores() async {
    TockenOrds? tk = await api.TokenApi();
    VmMedidores vmMarcaModelo = VmMedidores(items: []);
    if (!conexionInternet) {
      return vmMedidoresFromJson(listadosdblocal.first.siarMedidores!);
    }

    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print(
          "error al obtener el token en ListasPrecargadas-listaMarcaModelo ,${tk.error}");
      return vmMarcaModelo;
    }

    final url =
        Uri.parse('$protocolo://$urlbase${suburl}medidoresmodelos/$luminaria');

    try {
      final response = await httpx.get(
        url,
        headers: headersConsumoApi(tk.accessToken!),
      );

      tk.bitacoraHTTP(response);

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        vmMarcaModelo = vmMedidoresFromJson(decoded);
        print('Respuesta API , Medidores: ${response.body}');
      } else {
        print('Error en la API: ${response.body}');
      }
    } catch (e) {
      print('Ocurrió un error: $e');
      Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
    }

    return vmMarcaModelo;
  }

  Future<VmPoste> listaPostes({String codPoste = ""}) async {
    if (!conexionInternet) {
      return vmPosteFromJson(listadosdblocal.first.siarPoste!);
    }
    TockenOrds? tk = await api.TokenApi();
    VmPoste vm = VmPoste();
    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print("error al obtener el token en listaPostes,${tk.error}");
      return vm;
    }

    Map<String, dynamic> map = {
      "cod_poste": codPoste,
    };

    final url = Uri.parse('$protocolo://$urlbase${suburl}poste')
        .replace(queryParameters: map);

    try {
      final response = await httpx.get(
        url,
        headers: headersConsumoApi(tk.accessToken!),
      );

      tk.bitacoraHTTP(response);

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        vm = vmPosteFromJson(decoded);
        print('Respuesta API, Poste: ${response.body}');
      } else {
        print('Error en la API: ${response.body}');
      }
    } catch (e) {
      print('Ocurrió un error: $e');
      Log.escribir('Error ${url.toString()} ,  ${e.toString()}');
    }

    return vm;
  }
}
