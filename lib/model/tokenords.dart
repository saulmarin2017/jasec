import 'dart:convert';

import 'package:http/http.dart' as httpx;
import 'package:jasec/class/log.dart';
import 'package:jasec/utilidades/publico.dart';

TockenOrds tockenOrdsFromJson(String str) =>
    TockenOrds.fromJson(json.decode(str));

String tockenOrdsToJson(TockenOrds data) => json.encode(data.toJson());

class TockenOrds {
  String? accessToken;
  String? tokenType;
  DateTime? expiresIn;
  String? error;

  TockenOrds({this.accessToken, this.tokenType, this.expiresIn, this.error});

  bool get isExpired => DateTime.now().isAfter(expiresIn!);

  factory TockenOrds.fromJson(Map<String, dynamic> json) => TockenOrds(
      accessToken: json["access_token"],
      tokenType: json["token_type"],
      expiresIn: DateTime.now().add(Duration(seconds: json['expires_in'])),
      error: json["error"]);

  Map<String, dynamic> toJson() => {
        "access_token": accessToken,
        "token_type": tokenType,
        "expires_in": expiresIn,
      };

  void bitacoraHTTP(httpx.Response response) async {
    if (registrarLog) {
      await Log.escribir(
          '➡️ REQUEST: ${response.request!.method} ${response.request!.url}\n');
      await Log.escribir('HEADERS: ${response.request!.headers}\n');

      await Log.escribir(
          '✅ RESPONSE [${response.statusCode}]: ${response.request!.url}\n');
      await Log.escribir('BODY RESPONSE: ${utf8.decode(response.bodyBytes)}\n');
    }
  }
}
