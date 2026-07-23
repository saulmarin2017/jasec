import 'dart:convert';

VmCanton vmCantonFromJson(String str) => VmCanton.fromJson(json.decode(str));

String vmCantonToJson(VmCanton data) => json.encode(data.toJson());

class VmCanton {
  List<ItemCanton>? items;
  First? first;

  VmCanton({
    this.items,
    this.first,
  });

  factory VmCanton.fromJson(Map<String, dynamic> json) => VmCanton(
        items: json["items"] == null
            ? []
            : List<ItemCanton>.from(
                json["items"]!.map((x) => ItemCanton.fromJson(x))),
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

class ItemCanton {
  String? idProvincia;
  String? idCanton;
  String? nombreCanton;

  ItemCanton({
    this.idProvincia,
    this.idCanton,
    this.nombreCanton,
  });

  factory ItemCanton.fromJson(Map<String, dynamic> json) => ItemCanton(
        idProvincia: json["id_provincia"].toString(),
        idCanton: json["id_canton"].toString(),
        nombreCanton: json["nombre_canton"],
      );

  Map<String, dynamic> toJson() => {
        "id_provincia": idProvincia,
        "id_canton": idCanton,
        "nombre_canton": nombreCanton,
      };
}
