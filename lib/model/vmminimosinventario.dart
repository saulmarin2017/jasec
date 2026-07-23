import 'dart:convert';

VmMinimosInventario vmMinimosInventarioFromJson(String str) =>
    VmMinimosInventario.fromJson(json.decode(str));

String vmMinimosInventarioToJson(VmMinimosInventario data) =>
    json.encode(data.toJson());

class VmMinimosInventario {
  List<ItemMinimoInventario>? items;

  VmMinimosInventario({
    this.items,
  });

  factory VmMinimosInventario.fromJson(Map<String, dynamic> json) =>
      VmMinimosInventario(
        items: json["items"] == null
            ? []
            : List<ItemMinimoInventario>.from(
                json["items"]!.map((x) => ItemMinimoInventario.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "items": items == null
            ? []
            : List<dynamic>.from(items!.map((x) => x.toJson())),
      };
}

class ItemMinimoInventario {
  int? codMinimoInventario;
  String? codProducto;
  int? codBodega;
  String? nomProducto;
  int? minimo;
  int? existencia;

  ItemMinimoInventario({
    this.codMinimoInventario,
    this.codProducto,
    this.codBodega,
    this.nomProducto,
    this.minimo,
    this.existencia,
  });

  factory ItemMinimoInventario.fromJson(Map<String, dynamic> json) =>
      ItemMinimoInventario(
        codMinimoInventario: json["cod_minimo_inventario"],
        codProducto: json["cod_producto"],
        codBodega: json["cod_bodega"],
        nomProducto: json["nom_producto"],
        minimo: json["minimo"],
        existencia: json["existencia"],
      );

  Map<String, dynamic> toJson() => {
        "cod_minimo_inventario": codMinimoInventario,
        "cod_producto": codProducto,
        "cod_bodega": codBodega,
        "nom_producto": nomProducto,
        "minimo": minimo,
        "existencia": existencia,
      };
}
