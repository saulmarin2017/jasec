// To parse this JSON data, do
//
//     final vmRequisiciones = vmRequisicionesFromJson(jsonString);

import 'dart:convert';

VmRequisiciones vmRequisicionesFromJson(String str) =>
    VmRequisiciones.fromJson(json.decode(str));

String vmRequisicionesToJson(VmRequisiciones data) =>
    json.encode(data.toJson());

class VmRequisiciones {
  List<ItemRequisiciones>? items;

  VmRequisiciones({
    this.items,
  });

  factory VmRequisiciones.fromJson(Map<String, dynamic> json) =>
      VmRequisiciones(
        items: json["items"] == null
            ? []
            : List<ItemRequisiciones>.from(
                json["items"]!.map((x) => ItemRequisiciones.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "items": items == null
            ? []
            : List<dynamic>.from(items!.map((x) => x.toJson())),
      };
}

class ItemRequisiciones {
  int? codRequisiciones;
  DateTime? fechaSolicitud;
  int? codBodega;
  String? indLuminarias;
  String? indServicioTecnico;
  String? nivel;
  String? estado;
  String? usuarioInsert;
  DateTime? fechaInsert;
  int? codCuadrilla;

  ItemRequisiciones({
    this.codRequisiciones,
    this.fechaSolicitud,
    this.codBodega,
    this.indLuminarias,
    this.indServicioTecnico,
    this.nivel,
    this.estado,
    this.usuarioInsert,
    this.fechaInsert,
    this.codCuadrilla,
  });

  factory ItemRequisiciones.fromJson(Map<String, dynamic> json) =>
      ItemRequisiciones(
        codRequisiciones: json["cod_requisiciones"],
        fechaSolicitud: json["fecha_solicitud"] == null
            ? null
            : DateTime.parse(json["fecha_solicitud"]),
        codBodega: json["cod_bodega"],
        indLuminarias: json["ind_luminarias"],
        indServicioTecnico: json["ind_servicio_tecnico"],
        nivel: json["nivel"],
        estado: json["estado"],
        usuarioInsert: json["usuario_insert"],
        fechaInsert: json["fecha_insert"] == null
            ? null
            : DateTime.parse(json["fecha_insert"]),
        codCuadrilla: json["cod_cuadrilla"],
      );

  Map<String, dynamic> toJson() => {
        "cod_requisiciones": codRequisiciones,
        "fecha_solicitud": fechaSolicitud?.toIso8601String(),
        "cod_bodega": codBodega,
        "ind_luminarias": indLuminarias,
        "ind_servicio_tecnico": indServicioTecnico,
        "nivel": nivel,
        "estado": estado,
        "usuario_insert": usuarioInsert,
        "fecha_insert": fechaInsert?.toIso8601String(),
        "cod_cuadrilla": codCuadrilla,
      };
}
