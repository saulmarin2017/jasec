// To parse this JSON data, do
//
//     final vmSolicitudesOrdenTrabajo = vmSolicitudesOrdenTrabajoFromJson(jsonString);

import 'dart:convert';

VmSolicitudesOrdenTrabajo vmSolicitudesOrdenTrabajoFromJson(String str) =>
    VmSolicitudesOrdenTrabajo.fromJson(json.decode(str));

String vmSolicitudesOrdenTrabajoToJson(VmSolicitudesOrdenTrabajo data) =>
    json.encode(data.toJson());

class VmSolicitudesOrdenTrabajo {
  List<ItemSolicitudesOrdenTrabajo>? items;

  VmSolicitudesOrdenTrabajo({
    this.items,
  });

  factory VmSolicitudesOrdenTrabajo.fromJson(Map<String, dynamic> json) =>
      VmSolicitudesOrdenTrabajo(
        items: json["items"] == null
            ? []
            : List<ItemSolicitudesOrdenTrabajo>.from(json["items"]!
                .map((x) => ItemSolicitudesOrdenTrabajo.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "items": items == null
            ? []
            : List<dynamic>.from(items!.map((x) => x.toJson())),
      };
}

class ItemSolicitudesOrdenTrabajo {
  int? codDetOrdenTrabajo;
  int? codOrdenTrabajo;
  String? estado;
  String? usuarioInsert;
  int? codSolicitud;
  String? tipoSolicitud;
  String? desTipoSolicitud;
  String? desTipoSolicitudSt;
  String? numeroTicket;
  String? tnNumOt;
  String? codTipoServicio;
  String? codTipoAtencion;
  String? desTipoAtencion;
  String? observacion;
  String? identificacion;
  String? nombre;
  String? primerApellido;
  String? segundoApellido;
  String? telefono1;
  String? telefono2;
  String? telefono3;
  String? email;
  int? codProvincia;
  int? codCanton;
  int? codDistrito;
  String? otrasSenas;
  String? codPoste;
  DateTime? fechaInsert;
  String? indLuminaria;
  String? indServicioTecnico;
  String? localizacion;
  String? codPueblo;
  String? tnNumCliente;
  String? codCiclo;
  String? tcCalleManzana;
  String? tcNumCuenta;
  String? tcNumRuta;
  String? tnMontoDep;
  String? tnNumDeposito;
  String? tcCodTarifa;

  ItemSolicitudesOrdenTrabajo(
      {this.codDetOrdenTrabajo,
      this.codOrdenTrabajo,
      this.usuarioInsert,
      this.codSolicitud,
      this.desTipoSolicitud,
      this.desTipoSolicitudSt,
      this.tipoSolicitud,
      this.numeroTicket,
      this.tnNumOt,
      this.codTipoServicio,
      this.codTipoAtencion,
      this.desTipoAtencion,
      this.observacion,
      this.identificacion,
      this.nombre,
      this.primerApellido,
      this.segundoApellido,
      this.telefono1,
      this.telefono2,
      this.telefono3,
      this.email,
      this.codProvincia,
      this.codCanton,
      this.codDistrito,
      this.otrasSenas,
      this.codPoste,
      this.fechaInsert,
      this.indLuminaria,
      this.indServicioTecnico,
      this.estado,
      this.localizacion,
      this.codPueblo,
      this.tnNumCliente,
      this.codCiclo,
      this.tcCalleManzana,
      this.tcCodTarifa,
      this.tcNumCuenta,
      this.tcNumRuta,
      this.tnMontoDep,
      this.tnNumDeposito});

  factory ItemSolicitudesOrdenTrabajo.fromJson(Map<String, dynamic> json) =>
      ItemSolicitudesOrdenTrabajo(
        codDetOrdenTrabajo: json["cod_det_orden_trabajo"],
        codOrdenTrabajo: json["cod_orden_trabajo"],
        usuarioInsert: json["usuario_insert"],
        codSolicitud: json["cod_solicitud"],
        tipoSolicitud: json["tipo_solicitud"].toString(),
        desTipoSolicitud: json["des_tipo_solicitud"],
        desTipoSolicitudSt: json["des_tipo_solicitud_st"],
        numeroTicket: json["numero_ticket"],
        tnNumOt: json["tn_num_ot"],
        codTipoServicio: json["cod_tipo_servicio"].toString(),
        codTipoAtencion: json["cod_tipo_atencion"].toString(),
        desTipoAtencion: json["des_tipo_atencion"].toString(),
        observacion: json["observacion"],
        identificacion: json["identificacion"],
        nombre: json["nombre"],
        primerApellido: json["primer_apellido"],
        segundoApellido: json["segundo_apellido"],
        telefono1: json["telefono_1"],
        telefono2: json["telefono_2"],
        telefono3: json["telefono_3"],
        email: json["email"],
        codProvincia: json["cod_provincia"] == null
            ? null
            : int.tryParse(json["cod_provincia"].toString()),
        codCanton: json["cod_canton"] == null
            ? null
            : int.tryParse(json["cod_canton"].toString()),
        codDistrito: json["cod_distrito"] == null
            ? null
            : int.tryParse(json["cod_distrito"].toString()),
        otrasSenas: json["otras_senas"],
        codPoste: json["cod_poste"],
        fechaInsert: json["fecha_insert"] == null
            ? null
            : DateTime.parse(json["fecha_insert"]),
        indLuminaria: json["ind_luminaria"],
        indServicioTecnico: json["ind_servicio_tecnico"],
        estado: json['estado'],
        localizacion: json["localizacion"],
        codCiclo: json["cod_ciclo"],
        codPueblo: json["cod_pueblo"],
        tnNumCliente: json["tn_num_cliente"],
        tcCalleManzana: json["tc_calle_manzana"],
        tcNumCuenta: json["tc_num_cuenta"],
        tcNumRuta: json["tc_num_ruta"],
        tnMontoDep: json["tn_monto_dep"],
        tnNumDeposito: json["tn_num_deposito"],
        tcCodTarifa: json["tc_cod_tarifa"],
      );

  Map<String, dynamic> toJson() => {
        "cod_det_orden_trabajo": codDetOrdenTrabajo,
        "cod_orden_trabajo": codOrdenTrabajo,
        "usuario_insert": usuarioInsert,
        "cod_solicitud": codSolicitud,
        "tipo_solicitud": tipoSolicitud,
        "des_tipo_solicitud": desTipoSolicitud,
        "des_tipo_solicitud_st": desTipoSolicitudSt,
        "numero_ticket": numeroTicket,
        "tn_num_ot": tnNumOt,
        "cod_tipo_servicio": codTipoServicio,
        "cod_tipo_atencion": codTipoAtencion,
        "des_tipo_atencion": desTipoAtencion,
        "observacion": observacion,
        "identificacion": identificacion,
        "nombre": nombre,
        "primer_apellido": primerApellido,
        "segundo_apellido": segundoApellido,
        "telefono_1": telefono1,
        "telefono_2": telefono2,
        "telefono_3": telefono3,
        "email": email,
        "cod_provincia": codProvincia,
        "cod_canton": codCanton,
        "cod_distrito": codDistrito,
        "otras_senas": otrasSenas,
        "cod_poste": codPoste,
        "fecha_insert": fechaInsert?.toIso8601String(),
        "fecha_creacion": fechaInsert?.toIso8601String(),
        "ind_luminaria": indLuminaria,
        "ind_servicio_tecnico": indServicioTecnico,
        "estado": estado,
        "localizacion": localizacion,
        "cod_ciclo": codCiclo,
        "cod_pueblo": codPueblo,
        "tn_num_cliente": tnNumCliente,
        "tc_calle_manzana": tcCalleManzana,
        "tc_num_cuenta": tcNumCuenta,
        "tc_num_ruta": tcNumRuta,
        "tn_monto_dep": tnMontoDep,
        "tn_num_deposito": tnNumDeposito,
        "tc_cod_tarifa": tcCodTarifa
      };
}
