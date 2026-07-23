// To parse this JSON data, do
//
//     final vmTipoSolicitud = vmTipoSolicitudFromJson(jsonString);

import 'dart:convert';

VmTipoServicio vmTipoServicioFromJson(String str) =>
    VmTipoServicio.fromJson(json.decode(str));

String vmTipoServicioToJson(VmTipoServicio data) => json.encode(data.toJson());

class VmTipoServicio {
  List<ItemTipoServicio>? items;

  VmTipoServicio({
    this.items,
  });

  factory VmTipoServicio.fromJson(Map<String, dynamic> json) => VmTipoServicio(
        items: json["items"] == null
            ? []
            : List<ItemTipoServicio>.from(
                json["items"]!.map((x) => ItemTipoServicio.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "items": items == null
            ? []
            : List<dynamic>.from(items!.map((x) => x.toJson())),
      };
}

class ItemTipoServicio {
  int? codTipoServicio;
  String? desTipoSolicitud;

  ItemTipoServicio({
    this.codTipoServicio,
    this.desTipoSolicitud,
  });

  factory ItemTipoServicio.fromJson(Map<String, dynamic> json) =>
      ItemTipoServicio(
        codTipoServicio: json["cod_tipo_servicio"],
        desTipoSolicitud: json["des_tipo_servicio"],
      );

  Map<String, dynamic> toJson() => {
        "cod_tipo_servicio": codTipoServicio,
        "des_tipo_servicio": desTipoSolicitud,
      };
}
