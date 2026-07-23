import 'dart:convert';

VmCantidadNotificacion vmCantidadNotificacionFromJson(String str) =>
    VmCantidadNotificacion.fromJson(json.decode(str));

String vmCantidadNotificacionToJson(VmCantidadNotificacion data) =>
    json.encode(data.toJson());

class VmCantidadNotificacion {
  List<ItemExisteNotificaciones>? items;

  VmCantidadNotificacion({
    this.items,
  });

  factory VmCantidadNotificacion.fromJson(Map<String, dynamic> json) =>
      VmCantidadNotificacion(
        items: json["items"] == null
            ? []
            : List<ItemExisteNotificaciones>.from(json["items"]!
                .map((x) => ItemExisteNotificaciones.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "items": items == null
            ? []
            : List<dynamic>.from(items!.map((x) => x.toJson())),
      };
}

class ItemExisteNotificaciones {
  int? notificaciones;

  ItemExisteNotificaciones({
    this.notificaciones,
  });

  factory ItemExisteNotificaciones.fromJson(Map<String, dynamic> json) =>
      ItemExisteNotificaciones(
        notificaciones: json["notificaciones"],
      );

  Map<String, dynamic> toJson() => {
        "notificaciones": notificaciones,
      };
}
