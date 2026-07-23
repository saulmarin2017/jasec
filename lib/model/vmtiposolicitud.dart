import 'dart:convert';

VmTipoSolicitud vmTipoSolicitudFromJson(String str) =>
    VmTipoSolicitud.fromJson(json.decode(str));

String vmTipoSolicitudToJson(VmTipoSolicitud data) =>
    json.encode(data.toJson());

class VmTipoSolicitud {
  List<ItemTipoSolicitud>? items;

  VmTipoSolicitud({
    this.items,
  });

  factory VmTipoSolicitud.fromJson(Map<String, dynamic> json) =>
      VmTipoSolicitud(
        items: json["items"] == null
            ? []
            : List<ItemTipoSolicitud>.from(
                json["items"]!.map((x) => ItemTipoSolicitud.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "items": items == null
            ? []
            : List<dynamic>.from(items!.map((x) => x.toJson())),
      };
}

class ItemTipoSolicitud {
  int? codTipoSolicitud;
  String? desTipoSolicitud;

  ItemTipoSolicitud({
    this.codTipoSolicitud,
    this.desTipoSolicitud,
  });

  factory ItemTipoSolicitud.fromJson(Map<String, dynamic> json) =>
      ItemTipoSolicitud(
        codTipoSolicitud: json["cod_tipo_solicitud"],
        desTipoSolicitud: json["des_tipo_solicitud"],
      );

  Map<String, dynamic> toJson() => {
        "cod_tipo_solicitud": codTipoSolicitud,
        "des_tipo_solicitud": desTipoSolicitud,
      };
}
