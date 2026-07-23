// To parse this JSON data, do
//
//     final vmGraficaBarras = vmGraficaBarrasFromJson(jsonString);

import 'dart:convert';

VmGraficaBarras vmGraficaBarrasFromJson(String str) =>
    VmGraficaBarras.fromJson(json.decode(str));

String vmGraficaBarrasToJson(VmGraficaBarras data) =>
    json.encode(data.toJson());

class VmGraficaBarras {
  List<ItemGraficaBarras>? items;

  VmGraficaBarras({
    this.items,
  });

  factory VmGraficaBarras.fromJson(Map<String, dynamic> json) =>
      VmGraficaBarras(
        items: json["items"] == null
            ? []
            : List<ItemGraficaBarras>.from(
                json["items"]!.map((x) => ItemGraficaBarras.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "items": items == null
            ? []
            : List<dynamic>.from(items!.map((x) => x.toJson())),
      };
}

class ItemGraficaBarras {
  int? registradas;
  int? efectivas;
  int? noefectivas;

  ItemGraficaBarras({
    this.registradas,
    this.efectivas,
    this.noefectivas,
  });

  factory ItemGraficaBarras.fromJson(Map<String, dynamic> json) =>
      ItemGraficaBarras(
        registradas: json["registradas"],
        efectivas: json["efectivas"],
        noefectivas: json["noefectivas"],
      );

  Map<String, dynamic> toJson() => {
        "registradas": registradas,
        "efectivas": efectivas,
        "noefectivas": noefectivas,
      };
}
