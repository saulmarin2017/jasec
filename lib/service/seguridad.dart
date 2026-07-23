import 'package:flutter/material.dart';

class SeguridadServicio with ChangeNotifier {
  bool cargando = false;
  bool completado = false;

  SeguridadServicio() {
    //
  }
/*
  Future<UsuarioVM> registrar(Map<String, dynamic> map) async {
    UsuarioVM obj = UsuarioVM();
    cargando = true;
    final uri = Uri.http(urlbase, '/public/api/registrar', map);
    print(map);
    try {
      final resp = await httpx.post(uri);
      obj = UsuarioVM.fromJson(resp.body);
      completado = true;
    } catch (e) {
      print('Error : $e.toString()');
    }

    cargando = false;
    notifyListeners();

    return obj;
  }

  Future<UsuarioVM> login(Map<String, dynamic> map) async {
    UsuarioVM obj = UsuarioVM();
    cargando = true;

    final uri = Uri.http(urlbase, '/public/api/login', map);

    try {
      final resp = await httpx.post(uri);
      obj = UsuarioVM.fromJson(resp.body);
      print(uri);
      print(resp.body);
      completado = true;
    } catch (e) {
      obj.error = e.toString();
      print('Error: $e.toString()');
    }

    cargando = false;
    notifyListeners();

    return obj;
  }

  Future<UsuarioVM> logout(Map<String, dynamic> map) async {
    UsuarioVM obj = UsuarioVM();
    cargando = true;

    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: tokenBackend,
      HttpHeaders.contentTypeHeader: tipoAplicacion,
      HttpHeaders.acceptHeader: tipoAplicacion
    };

    final uri = Uri.http(urlbase, '/public/api/logout', map);

    try {
      final resp = await httpx.post(uri, headers: headers);
      if (resp.statusCode == 200) {
        completado = true;
      }
    } catch (e) {
      obj.error = e.toString();
      print('Error: $e.toString()');
    }

    cargando = false;
    notifyListeners();

    return obj;
  }*/
}
