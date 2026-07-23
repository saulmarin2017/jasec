// To parse this JSON data, do
//
//     final vmFormulario = vmFormularioFromJson(jsonString);

import 'dart:convert';

VmFormulario vmFormularioFromJson(String str) =>
    VmFormulario.fromJson(json.decode(str));

String vmFormularioToJson(VmFormulario data) => json.encode(data.toJson());

class VmFormulario {
  List<ItemFormulario>? items;
  FirstFormulario? first;

  VmFormulario({
    this.items,
    this.first,
  });

  factory VmFormulario.fromJson(Map<String, dynamic> json) => VmFormulario(
        items: json["items"] == null
            ? []
            : List<ItemFormulario>.from(
                json["items"]!.map((x) => ItemFormulario.fromJson(x))),
        first: json["first"] == null
            ? null
            : FirstFormulario.fromJson(json["first"]),
      );

  Map<String, dynamic> toJson() => {
        "items": items == null
            ? []
            : List<dynamic>.from(items!.map((x) => x.toJson())),
        "first": first?.toJson(),
      };
}

class FirstFormulario {
  String? ref;

  FirstFormulario({
    this.ref,
  });

  factory FirstFormulario.fromJson(Map<String, dynamic> json) =>
      FirstFormulario(
        ref: json["\u0024ref"],
      );

  Map<String, dynamic> toJson() => {
        "\u0024ref": ref,
      };
}

class ItemFormulario {
  int? codFormulario;
  String? desFormulario;
  int? codGrupoPreguntas;
  String? desGrupoPreguntas;
  int? ordenGrupo;
  int? codDetPreguntas;
  String? desDetGrupoPreguntas;
  int? ordenDetallePreguntas;
  int? codRespuestaGrupoPreguntas;
  String? tipoRespuesta;
  String? respuesta;
  int? codsolicitud;

  ItemFormulario(
      {this.codFormulario,
      this.desFormulario,
      this.codGrupoPreguntas,
      this.desGrupoPreguntas,
      this.ordenGrupo,
      this.codDetPreguntas,
      this.desDetGrupoPreguntas,
      this.ordenDetallePreguntas,
      this.codRespuestaGrupoPreguntas,
      this.tipoRespuesta,
      this.respuesta,
      this.codsolicitud});

  factory ItemFormulario.fromJson(Map<String, dynamic> json) => ItemFormulario(
        codFormulario: int.tryParse(json["cod_formulario"].toString()),
        desFormulario: json["des_formulario"]?.toString(),
        codGrupoPreguntas: int.tryParse(json["cod_grupo_preguntas"].toString()),
        desGrupoPreguntas: json["des_grupo_preguntas"]?.toString(),
        ordenGrupo: int.tryParse(json["orden_grupo"].toString()),
        codDetPreguntas: int.tryParse(json["cod_det_preguntas"].toString()),
        desDetGrupoPreguntas: json["des_det_grupo_preguntas"]?.toString(),
        ordenDetallePreguntas:
            int.tryParse(json["orden_detalle_preguntas"].toString()),
        codRespuestaGrupoPreguntas: json["cod_respuesta_grupo_preguntas"] ==
                null
            ? null
            : int.tryParse(json["cod_respuesta_grupo_preguntas"].toString()),
        tipoRespuesta: json["tipo_respuesta"]?.toString(),
        respuesta: json["respuesta"]?.toString(),
        codsolicitud: int.tryParse(json["cod_solicitud"].toString()),
      );

  Map<String, dynamic> toJson() => {
        "cod_formulario": codFormulario,
        "des_formulario": desFormulario,
        "cod_grupo_preguntas": codGrupoPreguntas,
        "des_grupo_preguntas": desGrupoPreguntas,
        "orden_grupo": ordenGrupo,
        "cod_det_preguntas": codDetPreguntas,
        "des_det_grupo_preguntas": desDetGrupoPreguntas,
        "orden_detalle_preguntas": ordenDetallePreguntas,
        "cod_respuesta_grupo_preguntas": codRespuestaGrupoPreguntas,
        "tipo_respuesta": tipoRespuesta,
        "respuesta": respuesta,
        "cod_solicitud": codsolicitud,
      };
}
