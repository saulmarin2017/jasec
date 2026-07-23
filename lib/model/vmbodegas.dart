import 'dart:convert';

VmBodegas vmBodegasFromJson(String str) => VmBodegas.fromJson(json.decode(str));

String vmBodegasToJson(VmBodegas data) => json.encode(data.toJson());

class VmBodegas {
  List<ItemBodegas>? items;

  VmBodegas({
    this.items,
  });

  factory VmBodegas.fromJson(Map<String, dynamic> json) => VmBodegas(
        items: json["items"] == null
            ? []
            : List<ItemBodegas>.from(
                json["items"]!.map((x) => ItemBodegas.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "items": items == null
            ? []
            : List<dynamic>.from(items!.map((x) => x.toJson())),
      };
}

class ItemBodegas {
  int? codBodega;
  String? desBodega;
  int? ubicacion;
  String? tipoBodega;

  ItemBodegas({
    this.codBodega,
    this.desBodega,
    this.ubicacion,
    this.tipoBodega,
  });

  factory ItemBodegas.fromJson(Map<String, dynamic> json) => ItemBodegas(
        codBodega: json["cod_bodega"],
        desBodega: json["des_bodega"],
        ubicacion: json["ubicacion"],
        tipoBodega: json["tipo_bodega"],
      );

  Map<String, dynamic> toJson() => {
        "cod_bodega": codBodega,
        "des_bodega": desBodega,
        "ubicacion": ubicacion,
        "tipo_bodega": tipoBodega,
      };
}
