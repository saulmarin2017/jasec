// To parse this JSON data, do
//
//     final vmMedidores = vmMedidoresFromJson(jsonString);

import 'dart:convert';

VmMedidores vmMedidoresFromJson(String str) =>
    VmMedidores.fromJson(json.decode(str));

String vmMedidoresToJson(VmMedidores data) => json.encode(data.toJson());

class VmMedidores {
  List<ItemMedidores>? items;
  bool? hasMore;
  int? limit;
  int? offset;
  int? count;
  List<Link>? links;

  VmMedidores({
    this.items,
    this.hasMore,
    this.limit,
    this.offset,
    this.count,
    this.links,
  });

  factory VmMedidores.fromJson(Map<String, dynamic> json) => VmMedidores(
        items: json["items"] == null
            ? []
            : List<ItemMedidores>.from(
                json["items"]!.map((x) => ItemMedidores.fromJson(x))),
        hasMore: json["hasMore"],
        limit: json["limit"],
        offset: json["offset"],
        count: json["count"],
        links: json["links"] == null
            ? []
            : List<Link>.from(json["links"]!.map((x) => Link.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "items": items == null
            ? []
            : List<dynamic>.from(items!.map((x) => x.toJson())),
        "hasMore": hasMore,
        "limit": limit,
        "offset": offset,
        "count": count,
        "links": links == null
            ? []
            : List<dynamic>.from(links!.map((x) => x.toJson())),
      };
}

class ItemMedidores {
  int? codMedidor;
  String? nombrePrograma;
  String? tipoMedidor;
  String? formaMedidor;
  String? marca;
  String? usuarioInsert;
  DateTime? fechaInsert;
  String? indLuminaria;
  String? indServicioTecnico;

  ItemMedidores({
    this.codMedidor,
    this.nombrePrograma,
    this.tipoMedidor,
    this.formaMedidor,
    this.marca,
    this.usuarioInsert,
    this.fechaInsert,
    this.indLuminaria,
    this.indServicioTecnico,
  });

  factory ItemMedidores.fromJson(Map<String, dynamic> json) => ItemMedidores(
        codMedidor: json["cod_medidor"],
        nombrePrograma: json["nombre_programa"],
        tipoMedidor: json["tipo_medidor"],
        formaMedidor: json["forma_medidor"],
        marca: json["marca"],
        usuarioInsert: json["usuario_insert"],
        fechaInsert: json["fecha_insert"] == null
            ? null
            : DateTime.parse(json["fecha_insert"]),
        indLuminaria: json["ind_luminaria"],
        indServicioTecnico: json["ind_servicio_tecnico"],
      );

  Map<String, dynamic> toJson() => {
        "cod_medidor": codMedidor,
        "nombre_programa": nombrePrograma,
        "tipo_medidor": tipoMedidor,
        "forma_medidor": formaMedidor,
        "marca": marca,
        "usuario_insert": usuarioInsert,
        "fecha_insert": fechaInsert?.toIso8601String(),
        "ind_luminaria": indLuminaria,
        "ind_servicio_tecnico": indServicioTecnico,
      };
}

class Link {
  String? rel;
  String? href;

  Link({
    this.rel,
    this.href,
  });

  factory Link.fromJson(Map<String, dynamic> json) => Link(
        rel: json["rel"],
        href: json["href"],
      );

  Map<String, dynamic> toJson() => {
        "rel": rel,
        "href": href,
      };
}
