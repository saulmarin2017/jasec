// To parse this JSON data, do
//
//     final vmOrdenTrabajo = vmOrdenTrabajoFromJson(jsonString);

import 'dart:convert';

VmOrdenTrabajo vmOrdenTrabajoFromJson(String str) =>
    VmOrdenTrabajo.fromJson(json.decode(str));

String vmOrdenTrabajoToJson(VmOrdenTrabajo data) => json.encode(data.toJson());

class VmOrdenTrabajo {
  List<ItemOrdenTrabajo>? items;

  VmOrdenTrabajo({
    this.items,
  });

  factory VmOrdenTrabajo.fromJson(Map<String, dynamic> json) => VmOrdenTrabajo(
        items: json["items"] == null
            ? []
            : List<ItemOrdenTrabajo>.from(
                json["items"]!.map((x) => ItemOrdenTrabajo.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "items": items == null
            ? []
            : List<dynamic>.from(items!.map((x) => x.toJson())),
      };
}

class ItemOrdenTrabajo {
  int? codOrdenTrabajo;
  int? ordenRuta;
  String? numeroOrdenTrabajo;
  int? codCuadrilla;
  String? estado;
  DateTime? fechaApertura;
  DateTime? fechaCierre;
  String? usuarioInsert;
  DateTime? fechaInsert;
  String? indLuminaria;
  String? indServicioTecnico;
  String? vehiculo;
  String? solicitudesasignadas;
  String? solicitudesregistradas;

  ItemOrdenTrabajo(
      {this.codOrdenTrabajo,
      this.ordenRuta,
      this.numeroOrdenTrabajo,
      this.codCuadrilla,
      this.estado,
      this.fechaApertura,
      this.fechaCierre,
      this.usuarioInsert,
      this.fechaInsert,
      this.indLuminaria,
      this.indServicioTecnico,
      this.vehiculo,
      this.solicitudesasignadas,
      this.solicitudesregistradas});

  factory ItemOrdenTrabajo.fromJson(Map<String, dynamic> json) =>
      ItemOrdenTrabajo(
        codOrdenTrabajo: json["cod_orden_trabajo"],
        ordenRuta: json["orden_ruta"],
        numeroOrdenTrabajo: json["numero_orden_trabajo"],
        codCuadrilla: json["cod_cuadrilla"],
        estado: json["estado"],
        fechaApertura: json["fecha_apertura"] == null
            ? null
            : DateTime.parse(json["fecha_apertura"]),
        fechaCierre: json["fecha_cierre"] == null
            ? null
            : DateTime.parse(json["fecha_cierre"]),
        usuarioInsert: json["usuario_insert"],
        fechaInsert: json["fecha_insert"] == null
            ? null
            : DateTime.parse(json["fecha_insert"]),
        indLuminaria: json["ind_luminaria"],
        indServicioTecnico: json["ind_servicio_tecnico"],
        vehiculo: json["vehiculo"],
        solicitudesasignadas: json["solicitudes_asignadas"].toString(),
        solicitudesregistradas: json["solicitudes_registradas"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "cod_orden_trabajo": codOrdenTrabajo,
        "orden_ruta": ordenRuta,
        "numero_orden_trabajo": numeroOrdenTrabajo,
        "cod_cuadrilla": codCuadrilla,
        "estado": estado,
        "fecha_apertura": fechaApertura?.toIso8601String(),
        "fecha_cierre": fechaCierre,
        "usuario_insert": usuarioInsert,
        "fecha_insert": fechaInsert?.toIso8601String(),
        "ind_luminaria": indLuminaria,
        "ind_servicio_tecnico": indServicioTecnico,
        "vehiculo": vehiculo,
        "solicitudes_asignadas": solicitudesasignadas,
        "solicitudes_registradas": solicitudesregistradas
      };
}
