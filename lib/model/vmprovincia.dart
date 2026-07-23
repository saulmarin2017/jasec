// To parse this JSON data, do
//
//     final vmProvincia = vmProvinciaFromJson(jsonString);

import 'dart:convert';

VmProvincia vmProvinciaFromJson(String str) =>
    VmProvincia.fromJson(json.decode(str));

String vmProvinciaToJson(VmProvincia data) => json.encode(data.toJson());

class VmProvincia {
  List<Item>? items;

  VmProvincia({
    this.items,
  });

  factory VmProvincia.fromJson(Map<String, dynamic> json) => VmProvincia(
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
  String? idProvincia;
  String? nombreProvincia;

  Item({
    this.idProvincia,
    this.nombreProvincia,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        idProvincia: json["id_provincia"].toString(),
        nombreProvincia: json["nombre_provincia"],
      );

  Map<String, dynamic> toJson() => {
        "id_provincia": idProvincia,
        "nombre_provincia": nombreProvincia,
      };
}
