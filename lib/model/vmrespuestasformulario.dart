// To parse this JSON data, do
//
//     final vmRespuestaFormulario = vmRespuestaFormularioFromJson(jsonString);

import 'dart:convert';

VmRespuestaSujeridas vmRespuestaFormularioFromJson(String str) =>
    VmRespuestaSujeridas.fromJson(json.decode(str));

String vmRespuestaFormularioToJson(VmRespuestaSujeridas data) =>
    json.encode(data.toJson());

class VmRespuestaSujeridas {
  List<Item>? items;
  First? first;

  VmRespuestaSujeridas({
    this.items,
    this.first,
  });

  factory VmRespuestaSujeridas.fromJson(Map<String, dynamic> json) =>
      VmRespuestaSujeridas(
        items: json["items"] == null
            ? []
            : List<Item>.from(json["items"]!.map((x) => Item.fromJson(x))),
        first: json["first"] == null ? null : First.fromJson(json["first"]),
      );

  Map<String, dynamic> toJson() => {
        "items": items == null
            ? []
            : List<dynamic>.from(items!.map((x) => x.toJson())),
        "first": first?.toJson(),
      };
}

class First {
  String? ref;

  First({
    this.ref,
  });

  factory First.fromJson(Map<String, dynamic> json) => First(
        ref: json["\u0024ref"],
      );

  Map<String, dynamic> toJson() => {
        "\u0024ref": ref,
      };
}

class Item {
  int? codRespuetaGrupoPreguntas;
  String? desRespuetaGrupoPreguntas;

  Item({
    this.codRespuetaGrupoPreguntas,
    this.desRespuetaGrupoPreguntas,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        codRespuetaGrupoPreguntas: json["cod_respuesta_grupo_preguntas"],
        desRespuetaGrupoPreguntas: json["des_respuesta_grupo_preguntas"],
      );

  Map<String, dynamic> toJson() => {
        "cod_respuesta_grupo_preguntas": codRespuetaGrupoPreguntas,
        "des_respuesta_grupo_preguntas": desRespuetaGrupoPreguntas,
      };
}
