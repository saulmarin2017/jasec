// To parse this JSON data, do
//
//     final vmTipoAtencion = vmTipoAtencionFromJson(jsonString);

import 'dart:convert';

VmTipoAtencion vmTipoAtencionFromJson(String str) =>
    VmTipoAtencion.fromJson(json.decode(str));

String vmTipoAtencionToJson(VmTipoAtencion data) => json.encode(data.toJson());

class VmTipoAtencion {
  List<Item>? items;

  VmTipoAtencion({
    this.items,
  });

  factory VmTipoAtencion.fromJson(Map<String, dynamic> json) => VmTipoAtencion(
        items: json["items"] == null
            ? []
            : List<Item>.from(json["items"]!.map((x) => Item.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "items": items == null
            ? []
            : List<dynamic>.from(items!.map((x) => x.toJson())),
      };
}

class Item {
  String? codTipoAtencion;
  String? desTipoAtencion;

  Item({
    this.codTipoAtencion,
    this.desTipoAtencion,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        codTipoAtencion: json["cod_tipo_atencion"].toString(),
        desTipoAtencion: json["des_tipo_atencion"],
      );

  Map<String, dynamic> toJson() => {
        "cod_tipo_atencion": codTipoAtencion,
        "des_tipo_atencion": desTipoAtencion,
      };
}
