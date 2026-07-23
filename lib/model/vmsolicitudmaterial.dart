import 'dart:convert';

VmSolicitudMateriales vmSolicitudMaterialesFromJson(String str) =>
    VmSolicitudMateriales.fromJson(json.decode(str));

String vmSolicitudMaterialesToJson(VmSolicitudMateriales data) =>
    json.encode(data.toJson());

class VmSolicitudMateriales {
  List<ItemSolicitudMateriales>? items;

  VmSolicitudMateriales({
    this.items,
  });

  factory VmSolicitudMateriales.fromJson(Map<String, dynamic> json) =>
      VmSolicitudMateriales(
        items: json["items"] == null
            ? []
            : List<ItemSolicitudMateriales>.from(
                json["items"]!.map((x) => ItemSolicitudMateriales.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "items": items == null
            ? []
            : List<dynamic>.from(items!.map((x) => x.toJson())),
      };
}

class ItemSolicitudMateriales {
  int? codSolicitudMaterial;
  int? codSolicitud;
  String? codSiarProducto;
  String? nomProducto;
  int? cantidad;
  int? verificado;
  String? estado;
  String? codPoste;
  String? instalados;
  DateTime? fechaInsert;
  String? fechaIns;
  String? usuarioInsert;
  String? observaciones;

  ItemSolicitudMateriales(
      {this.codSolicitudMaterial,
      this.codSolicitud,
      this.codSiarProducto,
      this.nomProducto,
      this.cantidad,
      this.verificado,
      this.estado,
      this.instalados,
      this.fechaInsert,
      this.fechaIns,
      this.usuarioInsert,
      this.codPoste,
      this.observaciones});

  factory ItemSolicitudMateriales.fromJson(Map<String, dynamic> json) =>
      ItemSolicitudMateriales(
          codSolicitudMaterial: json["cod_solicitud_material"],
          codSolicitud: json["cod_solicitud"],
          codSiarProducto: json["cod_siar_producto"],
          nomProducto: json["nom_producto"],
          cantidad: json["cantidad"],
          verificado: json["verificado"] ?? 0,
          instalados: json["instalados"],
          estado: json["estado"],
          fechaInsert: json["fecha_insert"] == null
              ? null
              : DateTime.parse(json["fecha_insert"]),
          usuarioInsert: json["usuario_insert"],
          codPoste: json["cod_poste"],
          observaciones: json["observaciones"]);

  factory ItemSolicitudMateriales.fromJsonMayusculas(
          Map<String, dynamic> json) =>
      ItemSolicitudMateriales(
          codSolicitudMaterial: json["COD_SOLICITUD_MATERIAL"],
          codSolicitud: int.tryParse(json["COD_SOLICITUD"].toString()),
          codSiarProducto: json["COD_SIAR_PRODUCTO"],
          cantidad: json["CANTIDAD"],
          verificado: json["VERIFICADO"] ?? 0,
          instalados: json["INSTALADOS"],
          estado: json["ESTADO"],
          codPoste: json["COD_POSTE"],
          fechaIns: json["FECHA_INSERT"],
          usuarioInsert: json["USUARIO_INSERT"],
          observaciones: json["OBSERVACIONES"]);

  Map<String, dynamic> toJson() => {
        "cod_solicitud_material": codSolicitudMaterial,
        "cod_solicitud": codSolicitud,
        "cod_siar_producto": codSiarProducto,
        "nom_producto": nomProducto,
        "cantidad": cantidad,
        "verificado": verificado,
        "estado": estado,
        "instalados": instalados,
        "fecha_insert": fechaInsert?.toIso8601String(),
        "usuario_insert": usuarioInsert,
        "cod_poste": codPoste,
        "observaciones": observaciones
      };
}
