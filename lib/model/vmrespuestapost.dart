import 'dart:convert';

VmRespuestaPost vmRespuestaPostFromJson(String str) =>
    VmRespuestaPost.fromJson(json.decode(str));

String vmRespuestaPostToJson(VmRespuestaPost data) =>
    json.encode(data.toJson());

class VmRespuestaPost {
  String? status;
  String? mensaje;
  int? idInsertado;

  VmRespuestaPost({
    this.status,
    this.mensaje,
    this.idInsertado,
  });

  factory VmRespuestaPost.fromJson(Map<String, dynamic> json) =>
      VmRespuestaPost(
        status: json["status"],
        mensaje: json["mensaje"],
        idInsertado: json["id_insertado"],
      );

  Map<String, dynamic> toJson() => {
        "status": status ?? '',
        "mensaje": mensaje ?? '',
        "id_insertado": idInsertado ?? 0,
      };
}
