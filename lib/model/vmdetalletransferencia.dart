// To parse this JSON data, do
//
//     final vmDetalleTransferencia = vmDetalleTransferenciaFromJson(jsonString);

import 'dart:convert';

VmDetalleTransferencia vmDetalleTransferenciaFromJson(String str) =>
    VmDetalleTransferencia.fromJson(json.decode(str));

String vmDetalleTransferenciaToJson(VmDetalleTransferencia data) =>
    json.encode(data.toJson());

class VmDetalleTransferencia {
  List<ItemDetalleTransferencia>? items;

  VmDetalleTransferencia({
    this.items,
  });

  factory VmDetalleTransferencia.fromJson(Map<String, dynamic> json) =>
      VmDetalleTransferencia(
        items: json["items"] == null
            ? []
            : List<ItemDetalleTransferencia>.from(json["items"]!
                .map((x) => ItemDetalleTransferencia.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "items": items == null
            ? []
            : List<dynamic>.from(items!.map((x) => x.toJson())),
      };
}

class ItemDetalleTransferencia {
  int? codDetMateriales;
  int? codEncMateriales;
  String? codProducto;
  String? usuarioInsert;
  DateTime? fechaInsert;
  int? cantidad;
  int? existencia;
  dynamic observaciones;
  String? nomProducto;

  ItemDetalleTransferencia({
    this.codDetMateriales,
    this.codEncMateriales,
    this.codProducto,
    this.usuarioInsert,
    this.fechaInsert,
    this.cantidad,
    this.existencia,
    this.observaciones,
    this.nomProducto,
  });

  factory ItemDetalleTransferencia.fromJson(Map<String, dynamic> json) =>
      ItemDetalleTransferencia(
        codDetMateriales: json["cod_det_materiales"],
        codEncMateriales: json["cod_enc_materiales"],
        codProducto: json["cod_producto"],
        usuarioInsert: json["usuario_insert"],
        fechaInsert: json["fecha_insert"] == null
            ? null
            : DateTime.parse(json["fecha_insert"]),
        cantidad: json["cantidad"],
        existencia: json["existencia"],
        observaciones: json["observaciones"],
        nomProducto: json["nom_producto"],
      );

  Map<String, dynamic> toJson() => {
        "cod_det_materiales": codDetMateriales,
        "cod_enc_materiales": codEncMateriales,
        "cod_producto": codProducto,
        "usuario_insert": usuarioInsert,
        "fecha_insert": fechaInsert?.toIso8601String(),
        "cantidad": cantidad,
        "existencia": existencia,
        "observaciones": observaciones,
        "nom_producto": nomProducto,
      };
}
