class ListadosDBlocal {
  int? rowid;
  String? siarTipoSolicitud;
  String? siarTipoSolicitudST;
  String? siarTipoServicio;
  String? siarTipoAtencion;
  String? siarMotivosRechazo;
  String? siarProvincia;
  String? siarCanton;
  String? siarDistrito;
  String? fechaActualizacion;
  String? usuario;
  String? siarCuentaGasto;
  String? siarOtc;
  String? siarPoste;
  String? siarOrdenTrabajo;
  String? siarProducto;
  String? siarMinimoInventario;
  String? siarBodega;
  String? siarGraficaDona;
  String? siarGraficaPorcentaje;
  String? siarGraficaBarras;
  String? siarUsuarios;
  String? siarFormularios;
  String? siarRespuestasSujeridas;
  String? siarMedidores;

  ListadosDBlocal(
      {this.rowid,
      this.siarTipoSolicitud,
      this.siarTipoSolicitudST,
      this.siarTipoServicio,
      this.siarTipoAtencion,
      this.siarMotivosRechazo,
      this.siarProvincia,
      this.siarCanton,
      this.siarDistrito,
      this.fechaActualizacion,
      this.usuario,
      this.siarCuentaGasto,
      this.siarOtc,
      this.siarPoste,
      this.siarOrdenTrabajo,
      this.siarProducto,
      this.siarMinimoInventario,
      this.siarBodega,
      this.siarGraficaDona,
      this.siarGraficaPorcentaje,
      this.siarGraficaBarras,
      this.siarUsuarios,
      this.siarFormularios,
      this.siarRespuestasSujeridas,
      this.siarMedidores});

  // Para convertir de Map (de la base) a modelo
  factory ListadosDBlocal.fromMap(Map<String, dynamic> json) => ListadosDBlocal(
      rowid: json['ROWID'],
      siarTipoSolicitud: json['SIAR_TIPO_SOLICITUD'],
      siarTipoSolicitudST: json['SIAR_TIPO_SOLICITUD_ST'],
      siarTipoServicio: json['SIAR_TIPO_SERVICIO'],
      siarTipoAtencion: json['SIAR_TIPO_ATENCION'],
      siarMotivosRechazo: json['SIAR_MOTIVOS_RECHAZO'],
      siarProvincia: json['SIAR_PROVINCIA'],
      siarCanton: json['SIAR_CANTON'],
      siarDistrito: json['SIAR_DISTRITO'],
      fechaActualizacion: json['FECHA_ACTUALIZACION'],
      usuario: json['USUARIO'],
      siarCuentaGasto: json['SIAR_CUENTA_GASTO'],
      siarOtc: json['SIAR_OTC'],
      siarPoste: json['SIAR_POSTE'],
      siarOrdenTrabajo: json['SIAR_ORDEN_TRABAJO'],
      siarProducto: json['SIAR_PRODUCTO'],
      siarMinimoInventario: json['SIAR_MINIMO_INVENTARIO'],
      siarBodega: json['SIAR_BODEGA'],
      siarGraficaDona: json['SIAR_GRAFICA_DONA'],
      siarGraficaBarras: json['SIAR_GRAFICA_BARRAS'],
      siarGraficaPorcentaje: json['SIAR_GRAFICA_PORCENTAJE'],
      siarUsuarios: json['SIAR_USUARIOS'],
      siarFormularios: json['SIAR_FORMULARIOS'],
      siarRespuestasSujeridas: json['SIAR_RESPUESTAS_SUJERIDAS'],
      siarMedidores: json['SIAR_MEDIDOR']);

  // Para convertir de modelo a Map (para insertar/actualizar)
  Map<String, dynamic> toMap() => {
        if (rowid != null) 'ROWID': rowid,
        'SIAR_TIPO_SOLICITUD': siarTipoSolicitud,
        'SIAR_TIPO_SOLICITUD_ST': siarTipoSolicitudST,
        'SIAR_TIPO_SERVICIO': siarTipoServicio,
        'SIAR_TIPO_ATENCION': siarTipoAtencion,
        'SIAR_MOTIVOS_RECHAZO': siarMotivosRechazo,
        'SIAR_PROVINCIA': siarProvincia,
        'SIAR_CANTON': siarCanton,
        'SIAR_DISTRITO': siarDistrito,
        'FECHA_ACTUALIZACION': fechaActualizacion,
        'USUARIO': usuario,
        'SIAR_CUENTA_GASTO': siarCuentaGasto,
        'SIAR_OTC': siarOtc,
        'SIAR_POSTE': siarPoste,
        'SIAR_ORDEN_TRABAJO': siarOrdenTrabajo,
        'SIAR_PRODUCTO': siarProducto,
        'SIAR_MINIMO_INVENTARIO': siarMinimoInventario,
        'SIAR_BODEGA': siarBodega,
        'SIAR_GRAFICA_DONA': siarGraficaDona,
        'SIAR_GRAFICA_BARRAS': siarGraficaBarras,
        'SIAR_GRAFICA_PORCENTAJE': siarGraficaPorcentaje,
        'SIAR_USUARIOS': siarUsuarios,
        'SIAR_FORMULARIOS': siarFormularios,
        'SIAR_RESPUESTAS_SUJERIDAS': siarRespuestasSujeridas,
        'SIAR_MEDIDOR': siarMedidores
      };
}
