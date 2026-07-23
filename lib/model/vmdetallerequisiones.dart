import 'dart:convert';

VmDetalleRequisiciones vmDetalleRequisicionesFromJson(String str) =>
    VmDetalleRequisiciones.fromJson(json.decode(str));

String vmDetalleRequisicionesToJson(VmDetalleRequisiciones data) =>
    json.encode(data.toJson());

class VmDetalleRequisiciones {
  List<ItemDetalleRequisiones>? items;

  VmDetalleRequisiciones({
    this.items,
  });

  factory VmDetalleRequisiciones.fromJson(Map<String, dynamic> json) =>
      VmDetalleRequisiciones(
        items: json["items"] == null
            ? []
            : List<ItemDetalleRequisiones>.from(
                json["items"]!.map((x) => ItemDetalleRequisiones.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "items": items == null
            ? []
            : List<dynamic>.from(items!.map((x) => x.toJson())),
      };
}

class ItemDetalleRequisiones {
  int? codDetRequisiciones;
  int? codRequisiciones;
  String? codProducto;
  int? cantidad;
  int? existencia;
  String? usuarioInsert;
  DateTime? fechaInsert;
  String? nomProducto;

  ItemDetalleRequisiones(
      {this.codDetRequisiciones,
      this.codRequisiciones,
      this.codProducto,
      this.cantidad,
      this.existencia,
      this.usuarioInsert,
      this.fechaInsert,
      this.nomProducto});

  factory ItemDetalleRequisiones.fromJson(Map<String, dynamic> json) =>
      ItemDetalleRequisiones(
          codDetRequisiciones: json["cod_det_requisiciones"],
          codRequisiciones: json["cod_requisiciones"],
          codProducto: json["cod_producto"],
          cantidad: json["cantidad"],
          existencia: json["existencia"],
          usuarioInsert: json["usuario_insert"],
          fechaInsert: json["fecha_insert"] == null
              ? null
              : DateTime.parse(json["fecha_insert"]),
          nomProducto: json["nom_producto"]);

  Map<String, dynamic> toJson() => {
        "cod_det_requisiciones": codDetRequisiciones,
        "cod_requisiciones": codRequisiciones,
        "cod_producto": codProducto,
        "cantidad": cantidad,
        "existencia": existencia,
        "usuario_insert": usuarioInsert,
        "fecha_insert": fechaInsert?.toIso8601String(),
        "nom_producto": nomProducto
      };
}
