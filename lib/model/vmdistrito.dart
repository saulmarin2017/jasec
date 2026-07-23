// To parse this JSON data, do
//
//     final vmDistrito = vmDistritoFromJson(jsonString);

import 'dart:convert';

VmDistrito vmDistritoFromJson(String str) =>
    VmDistrito.fromJson(json.decode(str));

String vmDistritoToJson(VmDistrito data) => json.encode(data.toJson());

class VmDistrito {
  List<ItemDistrito>? items;
  FirstDistrito? first;

  VmDistrito({
    this.items,
    this.first,
  });

  factory VmDistrito.fromJson(Map<String, dynamic> json) => VmDistrito(
        items: json["items"] == null
            ? []
            : List<ItemDistrito>.from(
                json["items"]!.map((x) => ItemDistrito.fromJson(x))),
        first: json["first"] == null
            ? null
            : FirstDistrito.fromJson(json["first"]),
      );

  Map<String, dynamic> toJson() => {
        "items": items == null
            ? []
            : List<dynamic>.from(items!.map((x) => x.toJson())),
        "first": first?.toJson(),
      };
}

class FirstDistrito {
  String? ref;

  FirstDistrito({
    this.ref,
  });

  factory FirstDistrito.fromJson(Map<String, dynamic> json) => FirstDistrito(
        ref: json["\u0024ref"],
      );

  Map<String, dynamic> toJson() => {
        "\u0024ref": ref,
      };
}

class ItemDistrito {
  String? idProvincia;
  String? idCanton;
  String? idDistrito;
  String? nombreDistrito;

  ItemDistrito({
    this.idProvincia,
    this.idCanton,
    this.idDistrito,
    this.nombreDistrito,
  });

  factory ItemDistrito.fromJson(Map<String, dynamic> json) => ItemDistrito(
        idProvincia: json["id_provincia"].toString(),
        idCanton: json["id_canton"].toString(),
        idDistrito: json["id_distrito"].toString(),
        nombreDistrito: json["nombre_distrito"],
      );

  Map<String, dynamic> toJson() => {
        "id_provincia": idProvincia,
        "id_canton": idCanton,
        "id_distrito": idDistrito,
        "nombre_distrito": nombreDistrito,
      };
}
