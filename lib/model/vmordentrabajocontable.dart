import 'dart:convert';

VmOrdenTrabajoContable vmOrdenTrabajoContableFromJson(String str) =>
    VmOrdenTrabajoContable.fromJson(json.decode(str));

String vmOrdenTrabajoContableToJson(VmOrdenTrabajoContable data) =>
    json.encode(data.toJson());

class VmOrdenTrabajoContable {
  List<ItemOrdenTRabajoContable>? items;

  VmOrdenTrabajoContable({
    this.items,
  });

  factory VmOrdenTrabajoContable.fromJson(Map<String, dynamic> json) =>
      VmOrdenTrabajoContable(
        items: json["items"] == null
            ? []
            : List<ItemOrdenTRabajoContable>.from(json["items"]!
                .map((x) => ItemOrdenTRabajoContable.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "items": items == null
            ? []
            : List<dynamic>.from(items!.map((x) => x.toJson())),
      };
}

class ItemOrdenTRabajoContable {
  int? codOtc;
  String? desOtc;
  int? mes;
  int? anno;
  String? indLuminarias;
  String? indServicioTecnico;
  String? ordenTrabajoEspecial;

  ItemOrdenTRabajoContable({
    this.codOtc,
    this.desOtc,
    this.mes,
    this.anno,
    this.indLuminarias,
    this.indServicioTecnico,
    this.ordenTrabajoEspecial,
  });

  factory ItemOrdenTRabajoContable.fromJson(Map<String, dynamic> json) =>
      ItemOrdenTRabajoContable(
        codOtc: json["cod_otc"],
        desOtc: json["des_otc"],
        mes: json["mes"],
        anno: json["anno"],
        indLuminarias: json["ind_luminarias"],
        indServicioTecnico: json["ind_servicio_tecnico"],
        ordenTrabajoEspecial: json["orden_trabajo_especial"],
      );

  Map<String, dynamic> toJson() => {
        "cod_otc": codOtc,
        "des_otc": desOtc,
        "mes": mes,
        "anno": anno,
        "ind_luminarias": indLuminarias,
        "ind_servicio_tecnico": indServicioTecnico,
        "orden_trabajo_especial": ordenTrabajoEspecial,
      };
}
