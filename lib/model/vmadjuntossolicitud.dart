// To parse this JSON data, do
//
//     final vmAdjuntosSolicitud = vmAdjuntosSolicitudFromJson(jsonString);

import 'dart:convert';

List<VmAdjuntosSolicitud> vmAdjuntosSolicitudFromJson(String str) =>
    List<VmAdjuntosSolicitud>.from(
        json.decode(str).map((x) => VmAdjuntosSolicitud.fromJson(x)));

String vmAdjuntosSolicitudToJson(List<VmAdjuntosSolicitud> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class VmAdjuntosSolicitud {
  String? codSolicitudDocumento;
  String? codSolicitud;
  String? filename;
  String? mimetype;
  DateTime? fechaInsert;
  String? usuarioInsert;

  VmAdjuntosSolicitud({
    this.codSolicitudDocumento,
    this.codSolicitud,
    this.filename,
    this.mimetype,
    this.fechaInsert,
    this.usuarioInsert,
  });

  factory VmAdjuntosSolicitud.fromJson(Map<String, dynamic> json) =>
      VmAdjuntosSolicitud(
        codSolicitudDocumento: json["cod_solicitud_documento"],
        codSolicitud: json["cod_solicitud"],
        filename: json["filename"],
        mimetype: json["mimetype"],
        fechaInsert: json["fecha_insert"] == null
            ? null
            : DateTime.parse(json["fecha_insert"]),
        usuarioInsert: json["usuario_insert"],
      );

  Map<String, dynamic> toJson() => {
        "cod_solicitud_documento": codSolicitudDocumento,
        "cod_solicitud": codSolicitud,
        "filename": filename,
        "mimetype": mimetype,
        "fecha_insert": fechaInsert?.toIso8601String(),
        "usuario_insert": usuarioInsert,
      };
}
