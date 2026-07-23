// To parse this JSON data, do
//
//     final vmSolicitud = vmSolicitudFromJson(jsonString);

import 'dart:convert';

VmSolicitud vmSolicitudFromJson(String str) =>
    VmSolicitud.fromJson(json.decode(str));
VmSolicitud vmSolicitudFromJsonMayusculas(String str) =>
    VmSolicitud.fromJsonMayusculas(json.decode(str));

String vmSolicitudToJson(VmSolicitud data) => json.encode(data.toJson());

class VmSolicitud {
  List<ItemSolicitud>? items;

  VmSolicitud({
    this.items,
  });

  factory VmSolicitud.fromJson(Map<String, dynamic> json) => VmSolicitud(
        items: json["items"] == null
            ? []
            : List<ItemSolicitud>.from(
                json["items"]!.map((x) => ItemSolicitud.fromJson(x))),
      );

  factory VmSolicitud.fromJsonMayusculas(Map<String, dynamic> json) =>
      VmSolicitud(
        items: json["items"] == null
            ? []
            : List<ItemSolicitud>.from(
                json["items"]!.map((x) => ItemSolicitud.fromJsonMayusculas(x))),
      );

  Map<String, dynamic> toJson() => {
        "items": items == null
            ? []
            : List<dynamic>.from(items!.map((x) => x.toJson())),
      };
}

class ItemSolicitud {
  int? codDetOrdenTrabajo;
  int? codOrdenTrabajo;
  int? codSolicitud;
  String? numeroTicket;
  String? tnNumOt;
  String? numeroOrdenTrabajo;
  int? codTipoServicio;
  int? codTipoAtencion;
  int? codCuentaGasto;
  int? codOtc;
  int? tipoSolicitud;
  String? desTtipoSolicitudST;
  String? observacion;
  String? desTipoSolicitud;
  String? desTipoAtencion;
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
  String? usuarioInsert;
  DateTime? fechaInsert;
  String? indLuminaria;
  String? indServicioTecnico;
  String? estado;
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
  String? latitud;
  String? longitud;

  ItemSolicitud(
      {this.codDetOrdenTrabajo,
      this.codOrdenTrabajo,
      this.codSolicitud,
      this.numeroTicket,
      this.tnNumOt,
      this.numeroOrdenTrabajo,
      this.codTipoServicio,
      this.codTipoAtencion,
      this.codCuentaGasto,
      this.codOtc,
      this.tipoSolicitud,
      this.observacion,
      this.desTipoSolicitud,
      this.desTtipoSolicitudST,
      this.desTipoAtencion,
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
      this.usuarioInsert,
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
      this.tnNumDeposito,
      this.latitud,
      this.longitud});

  factory ItemSolicitud.fromJson(Map<String, dynamic> json) => ItemSolicitud(
        codDetOrdenTrabajo: json["cod_det_orden_trabajo"],
        codOrdenTrabajo: json["cod_orden_trabajo"],
        codSolicitud: json["cod_solicitud"],
        numeroTicket: json["numero_ticket"],
        tnNumOt: json["tn_num_ot"],
        numeroOrdenTrabajo: json["numero_orden_trabajo"],
        codTipoServicio: json["cod_tipo_servicio"],
        codTipoAtencion: json["cod_tipo_atencion"] == null
            ? null
            : int.tryParse(json["cod_tipo_atencion"].toString()),
        codCuentaGasto: json["cod_cuenta_gasto"] == null
            ? null
            : int.tryParse(json["cod_cuenta_gasto"].toString()),
        codOtc: json["cod_otc"] == null
            ? null
            : int.tryParse(json["cod_otc"].toString()),
        tipoSolicitud: json["tipo_solicitud"] == null
            ? null
            : int.tryParse(json["tipo_solicitud"].toString()),
        desTtipoSolicitudST: json["des_tipo_solicitud_st"] ?? '',
        observacion: json["observacion"],
        desTipoSolicitud: json["des_tipo_solicitud"],
        desTipoAtencion: json["des_tipo_atencion"],
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
        usuarioInsert: json["usuario_insert"],
        fechaInsert: json["fecha_insert"] == null
            ? null
            : DateTime.parse(json["fecha_insert"]),
        indLuminaria: json["ind_luminaria"],
        indServicioTecnico: json["ind_servicio_tecnico"],
        estado: json["estado"],
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
        latitud: json["latitud"] ?? "",
        longitud: json["longitud"] ?? "",
      );

  factory ItemSolicitud.fromJsonMayusculas(Map<String, dynamic> json) =>
      ItemSolicitud(
        codDetOrdenTrabajo: json["COD_DET_ORDEN_TRABAJO"],
        codOrdenTrabajo: json["COD_ORDEN_TRABAJO"],
        codSolicitud: json["COD_SOLICITUD"],
        numeroTicket: json["NUMERO_TICKET"],
        tnNumOt: "TN_NUM_OT",
        numeroOrdenTrabajo: json["NUMERO_ORDEN_TRABAJO"],
        codTipoServicio: json["COD_TIPO_SERVICIO"],
        codTipoAtencion: json["COD_TIPO_ATENCION"],
        codCuentaGasto: json["COD_CUENTA_GASTO"],
        codOtc: json["COD_OTC"],
        tipoSolicitud: json["TIPO_SOLICITUD"],
        desTtipoSolicitudST: json["DES_TIPO_SOLICITUD_ST"],
        observacion: json["OBSERVACION"],
        desTipoSolicitud: json["DES_TIPO_SOLICITUD"],
        desTipoAtencion: json["DES_TIPO_ATENCION"],
        identificacion: json["IDENTIFICACION"],
        nombre: json["NOMBRE"],
        primerApellido: json["PRIMER_APELLIDO"],
        segundoApellido: json["SEGUNDO_APELLIDO"],
        telefono1: json["TELEFONO_1"],
        telefono2: json["TELEFONO_2"],
        telefono3: json["TELEFONO_3"],
        email: json["EMAIL"],
        codProvincia: json["COD_PROVINCIA"],
        codCanton: json["COD_CANTON"],
        codDistrito: json["COD_DISTRITO"],
        otrasSenas: json["OTRAS_SENAS"],
        codPoste: json["COD_POSTE"],
        usuarioInsert: json["USUARIO_INSERT"],
        fechaInsert: json["FECHA_INSERT"] == null
            ? null
            : DateTime.parse(json["FECHA_INSERT"]),
        indLuminaria: json["IND_LUMINARIA"],
        indServicioTecnico: json["IND_SERVICIO_TECNICO"],
        estado: json["ESTADO"],
        localizacion: json["LOCALIZACION"],
        codCiclo: json["COD_CICLO"],
        codPueblo: json["COD_PUEBLO"],
        tnNumCliente: json["TN_NUM_CLIENTE"],
        tcCalleManzana: json["TC_CALLE_MANZANA"],
        tcNumCuenta: json["TC_NUM_CUENTA"],
        tcNumRuta: json["TC_NUM_RUTA"],
        tnMontoDep: json["TN_MONTO_DEP"],
        tnNumDeposito: json["TN_NUM_DEPOSITO"],
        tcCodTarifa: json["TC_COD_TARIFA"],
        latitud: json["LATITUD"],
        longitud: json["LONGITUD"],
      );

  Map<String, dynamic> toJson() => {
        "cod_det_orden_trabajo": codDetOrdenTrabajo,
        "cod_orden_trabajo": codOrdenTrabajo,
        "cod_solicitud": codSolicitud,
        "numero_ticket": numeroTicket,
        "tn_num_ot": tnNumOt,
        "numero_orden_trabajo": numeroOrdenTrabajo,
        "cod_tipo_servicio": codTipoServicio,
        "cod_tipo_atencion": codTipoAtencion,
        "cod_cuenta_gasto": codCuentaGasto,
        "cod_otc": codOtc,
        "tipo_solicitud": tipoSolicitud,
        "des_tipo_solicitud_st": desTtipoSolicitudST,
        "observacion": observacion,
        "des_tipo_solicitud": desTipoSolicitud,
        "des_tipo_atencion": desTipoAtencion,
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
        "usuario_insert": usuarioInsert,
        "fecha_insert": fechaInsert?.toIso8601String(),
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
        "tc_cod_tarifa": tcCodTarifa,
        "latitud": latitud,
        "longitud": longitud,
      };
}
