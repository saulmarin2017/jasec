import 'dart:convert';

VmTipoSolicitudSt vmTipoSolicitudFromJsonSt(String str) =>
    VmTipoSolicitudSt.fromJson(json.decode(str));

String vmTipoSolicitudToJsonSt(VmTipoSolicitudSt data) =>
    json.encode(data.toJson());

class VmTipoSolicitudSt {
  List<ItemTipoSolicitud>? items;

  VmTipoSolicitudSt({
    this.items,
  });

  factory VmTipoSolicitudSt.fromJson(Map<String, dynamic> json) =>
      VmTipoSolicitudSt(
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
  String? codTipoSolicitud;
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
