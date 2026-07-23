// To parse this JSON data, do
//
//     final vmEstadoOrdenTrabajo = vmEstadoOrdenTrabajoFromJson(jsonString);

import 'dart:convert';

VmEstadoOrdenTrabajo vmEstadoOrdenTrabajoFromJson(String str) => VmEstadoOrdenTrabajo.fromJson(json.decode(str));

String vmEstadoOrdenTrabajoToJson(VmEstadoOrdenTrabajo data) => json.encode(data.toJson());

class VmEstadoOrdenTrabajo {
    List<Item>? items;
    First? first;

    VmEstadoOrdenTrabajo({
        this.items,
        this.first,
    });

    factory VmEstadoOrdenTrabajo.fromJson(Map<String, dynamic> json) => VmEstadoOrdenTrabajo(
        items: json["items"] == null ? [] : List<Item>.from(json["items"]!.map((x) => Item.fromJson(x))),
        first: json["first"] == null ? null : First.fromJson(json["first"]),
    );

    Map<String, dynamic> toJson() => {
        "items": items == null ? [] : List<dynamic>.from(items!.map((x) => x.toJson())),
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
    int? codEstadoOrden;
    String? desEstado;
    String? indLuminarias;
    String? indServicioTecnico;

    Item({
        this.codEstadoOrden,
        this.desEstado,
        this.indLuminarias,
        this.indServicioTecnico,
    });

    factory Item.fromJson(Map<String, dynamic> json) => Item(
        codEstadoOrden: json["cod_estado_orden"],
        desEstado: json["des_estado"],
        indLuminarias: json["ind_luminarias"],
        indServicioTecnico: json["ind_servicio_tecnico"],
    );

    Map<String, dynamic> toJson() => {
        "cod_estado_orden": codEstadoOrden,
        "des_estado": desEstado,
        "ind_luminarias": indLuminarias,
        "ind_servicio_tecnico": indServicioTecnico,
    };
}