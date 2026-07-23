import 'dart:convert';

VmNotificacion vmNotificacionFromJson(String str) =>
    VmNotificacion.fromJson(json.decode(str));

String vmNotificacionToJson(VmNotificacion data) => json.encode(data.toJson());

class VmNotificacion {
  List<ItemNotificacion>? items;

  VmNotificacion({
    this.items,
  });

  factory VmNotificacion.fromJson(Map<String, dynamic> json) => VmNotificacion(
        items: json["items"] == null
            ? []
            : List<ItemNotificacion>.from(
                json["items"]!.map((x) => ItemNotificacion.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "items": items == null
            ? []
            : List<dynamic>.from(items!.map((x) => x.toJson())),
      };
}

class ItemNotificacion {
  int? codNotificacion;
  String? descripcion;
  String? estado;
  DateTime? fecha;
  String? usuarioInsert;
  int? codCuadrilla;

  ItemNotificacion({
    this.codNotificacion,
    this.descripcion,
    this.estado,
    this.fecha,
    this.usuarioInsert,
    this.codCuadrilla,
  });

  factory ItemNotificacion.fromJson(Map<String, dynamic> json) =>
      ItemNotificacion(
        codNotificacion: json["cod_notificacion"],
        descripcion: json["descripcion"],
        estado: json["estado"],
        fecha: json["fecha"] == null ? null : DateTime.parse(json["fecha"]),
        usuarioInsert: json["usuario_insert"],
        codCuadrilla: json["cod_cuadrilla"],
      );

  Map<String, dynamic> toJson() => {
        "cod_notificacion": codNotificacion,
        "descripcion": descripcion,
        "estado": estado,
        "fecha": fecha?.toIso8601String(),
        "usuario_insert": usuarioInsert,
        "cod_cuadrilla": codCuadrilla,
      };
}
