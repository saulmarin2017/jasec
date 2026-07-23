// To parse this JSON data, do
//
//     final vmPoste = vmPosteFromJson(jsonString);

import 'dart:convert';

VmPoste vmPosteFromJson(String str) => VmPoste.fromJson(json.decode(str));

String vmPosteToJson(VmPoste data) => json.encode(data.toJson());

class VmPoste {
  List<ItemPoste>? items;

  VmPoste({
    this.items,
  });

  factory VmPoste.fromJson(Map<String, dynamic> json) => VmPoste(
        items: json["items"] == null
            ? []
            : List<ItemPoste>.from(
                json["items"]!.map((x) => ItemPoste.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "items": items == null
            ? []
            : List<dynamic>.from(items!.map((x) => x.toJson())),
      };
}

class ItemPoste {
  String? numeroPoste;
  String? latitud;
  String? longitud;

  ItemPoste({
    this.numeroPoste,
    this.latitud,
    this.longitud,
  });

  factory ItemPoste.fromJson(Map<String, dynamic> json) => ItemPoste(
        numeroPoste: json["numero_poste"].toString(),
        latitud: json["latitud"].toString(),
        longitud: json["longitud"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "numero_poste": numeroPoste,
        "latitud": latitud,
        "longitud": longitud,
      };
}
