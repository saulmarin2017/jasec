// To parse this JSON data, do
//
//     final vmMarcoModelo = vmMarcoModeloFromJson(jsonString);

import 'dart:convert';

VmMarcoModelo vmMarcoModeloFromJson(String str) =>
    VmMarcoModelo.fromJson(json.decode(str));

String vmMarcoModeloToJson(VmMarcoModelo data) => json.encode(data.toJson());

class VmMarcoModelo {
  List<ItemMarcaModelo>? items;

  VmMarcoModelo({
    this.items,
  });

  factory VmMarcoModelo.fromJson(Map<String, dynamic> json) => VmMarcoModelo(
        items: json["items"] == null
            ? []
            : List<ItemMarcaModelo>.from(
                json["items"]!.map((x) => ItemMarcaModelo.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "items": items == null
            ? []
            : List<dynamic>.from(items!.map((x) => x.toJson())),
      };
}

class ItemMarcaModelo {
  int? codMarcaMedidor;
  String? desMarcaMedidor;
  int? codModeloMedidor;
  String? desModeloMedidor;

  ItemMarcaModelo({
    this.codMarcaMedidor,
    this.desMarcaMedidor,
    this.codModeloMedidor,
    this.desModeloMedidor,
  });

  factory ItemMarcaModelo.fromJson(Map<String, dynamic> json) =>
      ItemMarcaModelo(
        codMarcaMedidor: json["cod_marca_medidor"],
        desMarcaMedidor: json["des_marca_medidor"],
        codModeloMedidor: json["cod_modelo_medidor"],
        desModeloMedidor: json["des_modelo_medidor"],
      );

  Map<String, dynamic> toJson() => {
        "cod_marca_medidor": codMarcaMedidor,
        "des_marca_medidor": desMarcaMedidor,
        "cod_modelo_medidor": codModeloMedidor,
        "des_modelo_medidor": desModeloMedidor,
      };
}
