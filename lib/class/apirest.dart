import 'dart:convert';

import 'package:jasec/class/log.dart';
import 'package:jasec/model/model.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:http/http.dart' as httpx;

class ApiRest {
  Future<TockenOrds?> TokenApi() async {
    if (conexionInternet) {
      if (tokenOrds != null && !tokenOrds!.isExpired) {
        return tokenOrds!;
      }

      TockenOrds tk = TockenOrds();

      try {
        final url = Uri.parse('$protocolo://$urlbase/ords/siar/oauth/token');

        final response = await httpx.post(
          url,
          headers: headersToken,
          body: {'grant_type': 'client_credentials'},
        );

        if (response.statusCode == 200) {
          final json = jsonDecode(response.body);
          tokenOrds = TockenOrds.fromJson(json);
          await Log.escribir('Renovo TK:${json}');
          return tokenOrds!;

          //tk = tockenOrdsFromJson(response.body);
          //return tk;
        } else {
          tk.error = response.body;
          return tk;
        }
      } catch (e) {
        await Log.escribir('Error, ApiRest-TokenApi:${e.toString()} ');
        print('Ocurrió un error: $e');
        tk.error = e.toString();
        return tk;
      }
    } else {
      return null;
    }
  }
}
