import 'dart:convert';

import 'package:jasec/class/log.dart';
import 'package:jasec/model/model.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:http/http.dart' as httpx;
import 'package:jasec/utilidades/utilidades.dart';

class Autenticacion {
  Future<TockenOrds?> obtenerToken() async {
    if (tokenOrds != null && !tokenOrds!.isExpired) {
      return tokenOrds!;
    }
    final url = Uri.parse('$protocolo://$urlbase/ords/siar/oauth/token');
    //await LogHelper.writeLog('Peticion a:$url');
    var response;

    try {
      response = await httpx.post(
        url,
        headers: headersToken,
        body: {'grant_type': 'client_credentials'},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        tokenOrds = TockenOrds.fromJson(json);
        return tokenOrds!;
      } else {
        print('Error al obtener el token: ${response.body}');
        return null;
      }
    } catch (e) {
      await Log.escribir("Error al obtener el obtenerToken: $e");
      return TockenOrds(error: e.toString());
    }
  }

  Future<TockenOrds?> obtenerToken_old() async {
    TockenOrds tk = TockenOrds();

    final url = Uri.parse('$protocolo://$urlbase/ords/siar/oauth/token');
    //await LogHelper.writeLog('Peticion a:$url');
    var response;
    try {
      response = await httpx.post(
        url,
        headers: headersToken,
        body: {'grant_type': 'client_credentials'},
      );

      if (response.statusCode == 200) {
        await Log.escribir('Response:${response.body}');
        tk = tockenOrdsFromJson(response.body);
        return tk;
      } else {
        print('Error al obtener el token: ${response.body}');
        return null;
      }
    } catch (e) {
      await Log.escribir("Error al obtener el obtenerToken: $e");
      return TockenOrds(error: e.toString());
    }
  }

  Future<VmUsuario> loginAPI(String usuario, String clave) async {
    VmUsuario vm = VmUsuario(items: []);

    /*
    Verificamos que exista conexion al backend
  */
    var conexionInternet = await conexionBackEnd();

    if (!conexionInternet) {
      if (listadosdblocal.isNotEmpty) {
        var datos = vmUsuarioFromJson(listadosdblocal.first.siarUsuarios!);

        var itemsFiltrados = (datos.items ?? [])
            .where((d) => d.nombreUsuario == usuario)
            .toList();
        vm.items!.addAll(itemsFiltrados);
        return vm;
      } else {
        await Log.escribir(
            "Error en loginAPI: No existen listadosdblocales, no se puede autenticar");
      }
      return vm;
    }

    TockenOrds? tk = await obtenerToken();

    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      await Log.escribir("Error en loginAPI: ${tk.error}");
      print("Error al obtener el token en Autenticacion-loginAPI ,${tk.error}");
      return VmUsuario(error: tk.error);
    }

    try {
      final url =
          Uri.parse('$protocolo://$urlbase${suburl}seguridad/$usuario/$clave');

      final response = await httpx.get(
        url,
        headers: headersConsumoApi(tk.accessToken!),
      );

      tk.bitacoraHTTP(response);

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        vm = vmUsuarioFromJson(decoded);

        print('Respuesta API , loginAPI: ${decoded}');
      } else {
        print('Error en la API, loginAPI: ${utf8.decode(response.bodyBytes)}');
        return vm;
      }
    } catch (e) {
      await Log.escribir("Error en loginAPI: $e");
      print('Ocurrió un error, loginAPI: $e');
      return vm;
    }

    return vm;
  }

  Future<VmUsuario> usuarios() async {
    VmUsuario vm = VmUsuario();
    TockenOrds? tk = await obtenerToken();

    //Si no tenemos respuesta del backend o tenemos error, salimos de la funcion
    if (tk!.error != null) {
      print("Error al obtener el token en Autenticacion-usuarios ,${tk.error}");
      return VmUsuario(error: tk.error);
    }

    try {
      final url = Uri.parse('$protocolo://$urlbase${suburl}usuarios');

      final response = await httpx.get(
        url,
        headers: headersConsumoApi(tk.accessToken!),
      );
      tk.bitacoraHTTP(response);

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        vm = vmUsuarioFromJson(decoded);
        print('Respuesta API , usuarios: ${decoded}');
      } else {
        print('Error en la API, usuarios: ${utf8.decode(response.bodyBytes)}');
        return vm;
      }
    } catch (e) {
      await Log.escribir("Error en usuarios: $e");
      print('Ocurrió un error, usuarios: $e');
      return vm;
    }

    return vm;
  }

  Future<void> consumirApi() async {
    TockenOrds? tk = await obtenerToken();
    if (tk!.accessToken == null) return;

    final url = Uri.parse('http://$urlbase${suburl}empinfo/');

    final response = await httpx.get(
      url,
      headers: headersConsumoApi(tk.accessToken!),
    );

    tk.bitacoraHTTP(response);

    if (response.statusCode == 200) {
      print('Respuesta API: ${response.body}');
    } else {
      print('Error en la API: ${response.body}');
    }
  }

  Future<bool> cambiarClave(String nuevaClave) async {
    TockenOrds? tk = await obtenerToken();
    bool respuesta = true;

    if (tk!.error != null) {
      print(
          "error al obtener el token en autenticacion-cambiarClave ,${tk.error}");
      return false;
    }

    try {
      final url = Uri.parse('$protocolo://$urlbase${suburl}cambiarclave');

      Map<String, dynamic> json = {
        "cod_usuario": idUsuarioLogin ?? 0,
        "contrasena": nuevaClave
      };

      var jsonx = "[${jsonEncode(json)}]";

      final response = await httpx.post(
        url,
        headers: headersConsumoApi(tk.accessToken!),
        body: jsonx,
      );

      tk.bitacoraHTTP(response);

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);

        var res = jsonDecode(decoded);

        // Validamos el campo "status"
        if (res['status'] == 1) {
          respuesta = true;
        } else {
          respuesta = false;
        }

        print('Respuesta API , cambiarClave: ${decoded}');
      } else {
        print(
            'Error en la API , cambiarClave: ${utf8.decode(response.bodyBytes)}');
        respuesta = false;
      }
    } catch (e) {
      await Log.escribir("Error en cambiarClave: $e");
      print('Ocurrió un error en cambiarClave: $e');
      respuesta = false;
    }

    return respuesta;
  }
}
