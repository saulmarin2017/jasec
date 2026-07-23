// To parse this JSON data, do
//
//     final vmProducto = vmProductoFromJson(jsonString);

import 'dart:convert';

VmProducto vmProductoFromJson(String str) =>
    VmProducto.fromJson(json.decode(str));

String vmProductoToJson(VmProducto data) => json.encode(data.toJson());

class VmProducto {
  List<ItemProducto>? items;

  VmProducto({
    this.items,
  });

  factory VmProducto.fromJson(Map<String, dynamic> json) => VmProducto(
        items: json["items"] == null
            ? []
            : List<ItemProducto>.from(
                json["items"]!.map((x) => ItemProducto.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "items": items == null
            ? []
            : List<dynamic>.from(items!.map((x) => x.toJson())),
      };
}

class ItemProducto {
  String? codSiarProducto;
  String? nomProducto;
  int? costo;
  int? cantidad;
  int? existencia;

  ItemProducto(
      {this.codSiarProducto,
      this.nomProducto,
      this.costo,
      this.existencia,
      this.cantidad});

  factory ItemProducto.fromJson(Map<String, dynamic> json) => ItemProducto(
        codSiarProducto: json["cod_siar_producto"],
        nomProducto: json["nom_producto"],
        costo: json["costo"],
        cantidad: json["cantidad"],
        existencia: json["existencia"],
      );

  Map<String, dynamic> toJson() => {
        "cod_siar_producto": codSiarProducto,
        "nom_producto": nomProducto,
        "costo": costo,
        "cantidad": cantidad,
        "existencia": existencia,
      };
}
