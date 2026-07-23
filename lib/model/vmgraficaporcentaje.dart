// To parse this JSON data, do
//
//     final vmGraficaPorcentaje = vmGraficaPorcentajeFromJson(jsonString);

import 'dart:convert';

VmGraficaPorcentaje vmGraficaPorcentajeFromJson(String str) =>
    VmGraficaPorcentaje.fromJson(json.decode(str));

String vmGraficaPorcentajeToJson(VmGraficaPorcentaje data) =>
    json.encode(data.toJson());

class VmGraficaPorcentaje {
  List<ItemGraficaPorcentaje>? items;

  VmGraficaPorcentaje({
    this.items,
  });

  factory VmGraficaPorcentaje.fromJson(Map<String, dynamic> json) =>
      VmGraficaPorcentaje(
        items: json["items"] == null
            ? []
            : List<ItemGraficaPorcentaje>.from(
                json["items"]!.map((x) => ItemGraficaPorcentaje.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "items": items == null
            ? []
            : List<dynamic>.from(items!.map((x) => x.toJson())),
      };
}

class ItemGraficaPorcentaje {
  int? solicitudes;
  int? atendidas;

  ItemGraficaPorcentaje({
    this.solicitudes,
    this.atendidas,
  });

  factory ItemGraficaPorcentaje.fromJson(Map<String, dynamic> json) =>
      ItemGraficaPorcentaje(
        solicitudes: json["solicitudes"],
        atendidas: json["atendidas"],
      );

  Map<String, dynamic> toJson() => {
        "solicitudes": solicitudes,
        "atendidas": atendidas,
      };
}
