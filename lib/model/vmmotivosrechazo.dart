// To parse this JSON data, do
//
//     final vmMotivosRechazo = vmMotivosRechazoFromJson(jsonString);

import 'dart:convert';

VmMotivosRechazo vmMotivosRechazoFromJson(String str) =>
    VmMotivosRechazo.fromJson(json.decode(str));

String vmMotivosRechazoToJson(VmMotivosRechazo data) =>
    json.encode(data.toJson());

class VmMotivosRechazo {
  List<ItemMotivoRechazo>? items;

  VmMotivosRechazo({
    this.items,
  });

  factory VmMotivosRechazo.fromJson(Map<String, dynamic> json) =>
      VmMotivosRechazo(
        items: json["items"] == null
            ? []
            : List<ItemMotivoRechazo>.from(
                json["items"]!.map((x) => ItemMotivoRechazo.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "items": items == null
            ? []
            : List<dynamic>.from(items!.map((x) => x.toJson())),
      };
}

class ItemMotivoRechazo {
  int? codMotivosRechazo;
  String? desMotivosRechazo;

  ItemMotivoRechazo({
    this.codMotivosRechazo,
    this.desMotivosRechazo,
  });

  factory ItemMotivoRechazo.fromJson(Map<String, dynamic> json) =>
      ItemMotivoRechazo(
        codMotivosRechazo: json["cod_motivos_rechazo"],
        desMotivosRechazo: json["des_motivos_rechazo"],
      );

  Map<String, dynamic> toJson() => {
        "cod_motivos_rechazo": codMotivosRechazo,
        "des_motivos_rechazo": desMotivosRechazo,
      };
}
