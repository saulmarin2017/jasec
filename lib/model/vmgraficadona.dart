// To parse this JSON data, do
//
//     final vmGraficaDona = vmGraficaDonaFromJson(jsonString);

import 'dart:convert';

VmGraficaDona vmGraficaDonaFromJson(String str) =>
    VmGraficaDona.fromJson(json.decode(str));

String vmGraficaDonaToJson(VmGraficaDona data) => json.encode(data.toJson());

class VmGraficaDona {
  List<ItemGraficaDona>? items;

  VmGraficaDona({
    this.items,
  });

  factory VmGraficaDona.fromJson(Map<String, dynamic> json) => VmGraficaDona(
        items: json["items"] == null
            ? []
            : List<ItemGraficaDona>.from(
                json["items"]!.map((x) => ItemGraficaDona.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "items": items == null
            ? []
            : List<dynamic>.from(items!.map((x) => x.toJson())),
      };
}

class ItemGraficaDona {
  int? pendientes;
  int? atendidas;

  ItemGraficaDona({
    this.pendientes,
    this.atendidas,
  });

  factory ItemGraficaDona.fromJson(Map<String, dynamic> json) =>
      ItemGraficaDona(
        pendientes: json["pendientes"],
        atendidas: json["atendidas"],
      );

  Map<String, dynamic> toJson() => {
        "pendientes": pendientes,
        "atendidas": atendidas,
      };
}
