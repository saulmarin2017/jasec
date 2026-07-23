import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jasec/class/crudmateriales.dart';
import 'package:jasec/class/crudsolicitud.dart';
import 'package:jasec/class/gps.dart';
import 'package:jasec/class/listasprecargadas.dart';
import 'package:jasec/class/log.dart';
import 'package:jasec/db/db.dart';
import 'package:jasec/model/vmordentrabajo.dart';
import 'package:jasec/model/vmposte.dart';
import 'package:jasec/model/vmrespuestapost.dart';
import 'package:jasec/model/vmsolicitud.dart';
import 'package:jasec/model/vmsolicitudmaterial.dart';
import 'package:jasec/model/vmtiposolicitud.dart';
import 'package:jasec/screen/archivossolicitud.dart';
import 'package:jasec/screen/frmevaluacionrequisitostecnicosdesglosado.dart';
import 'package:jasec/screen/frmsolicitudnoefectiva.dart';
import 'package:jasec/screen/frmvinculacionusuariored.dart';
import 'package:jasec/screen/listadomaterialesposte.dart';
//import 'package:jasec/screen/historialatencionsolicitud.dart';
import 'package:jasec/screen/screen.dart';
import 'package:jasec/screen/agregarmaterialessolicitud.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:jasec/utilidades/utilidades.dart';
import 'package:jasec/widget/barramensaje.dart';
import 'package:jasec/widget/lineahoritzontal.dart';
import 'package:jasec/widget/widget.dart';

class AtencionSolicitudServicioTecnico extends StatefulWidget {
  final String codSolicitud;
  final String numeroOrdenTrabajo;
  final String estado;
  final String codPoste;

  const AtencionSolicitudServicioTecnico({
    super.key,
    required this.codSolicitud,
    required this.numeroOrdenTrabajo,
    required this.estado,
    this.codPoste = "",
  });

  @override
  State<AtencionSolicitudServicioTecnico> createState() =>
      _AtencionSolicitudServicioTecnicoState();
}

class _AtencionSolicitudServicioTecnicoState
    extends State<AtencionSolicitudServicioTecnico> {
  ListasPrecargadas listasPrecargadas = ListasPrecargadas();

  final Map<String, TextEditingController> txtEditControllers = {};

  bool _loadingCanton = false;
  bool _loadingDistrito = false;
  bool _loadingTipoServicio = false;

  bool cargosolicitud = false;

  File? imagen;

  String idTiposolicitudSelecionada = "";
  int idClaseServicio = 0;
  int idEstadoOrdenServicio = 0;
  int idProvinciaSeleccionado = 0;
  int idCantonSeleccionado = 0;
  int idClienteSeleccionado = 0;
  int idPuebloSeleccionado = 0;
  int idTarifaSeleccionada = 0;
  int idNoDepositoSeleccionada = 0;
  int idDistritoSeleccionado = 0;
  int idTipoAtencionSeleccionado = 0;
  int idTipoCuentaSeleccionado = 0;
  int idCalleSeleccionado = 0;
  int idCuentaSeleccionado = 0;
  int idRutaSeleccionado = 0;
  int idOrdenTrabajoContable = 0;
  int idCuentaGasto = 0;

  String numero_orden_trabajo = "";
  VmPoste mapPostes = VmPoste();

  String estado = "";

  String posteSeleccionado = "";
  // ignore: non_constant_identifier_names
  String cod_solicitud = "";

  int? panelSeleccionado;
  List<bool> _isExpandedList = [
    true,
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];
  String? selectedValue;

  List<Map<String, dynamic>> mapProvincia = [];
  List<Map<String, dynamic>> mapCanton = [];
  List<Map<String, dynamic>> mapDistrito = [];
  List<Map<String, dynamic>> mapTipoServicio = [];
  List<String> mapTipoSolicitud = [];
  List<Map<String, dynamic>> mapClaseServicio = [];
  List<Map<String, dynamic>> mapEstadoOT = [];
  List<Map<String, dynamic>> mapClientes = [];
  List<Map<String, dynamic>> mapPueblo = [];
  List<Map<String, dynamic>> mapTarifa = [];
  List<Map<String, dynamic>> mapNoDeposito = [];
  List<Map<String, dynamic>> mapTipoAtencion = [];
  List<Map<String, dynamic>> mapTipoCuenta = [];
  List<Map<String, dynamic>> mapCalle = [];
  List<Map<String, dynamic>> mapCuenta = [];
  List<Map<String, dynamic>> mapRuta = [];
  List<Map<String, dynamic>> mapTOC = [];
  List<Map<String, dynamic>> mapCuentaGasto = [];

  double wancho = 50, halto = 50;
  double bwidth = 200, bheight = 150;

  ItemPoste posteActual = ItemPoste();

  Map<String, dynamic> mapSolicitud = {
    "cod_solicitud": "",
    "numero_orden_trabajo": "",
    "numero_ticket": "",
    "tipo_servicio": "",
    "tipo_atencion": "",
    "observacion": "",
    "identificacion": "",
    "nombre": "",
    "primer_apellido": "",
    "segundo_apellido": "",
    "telefono_1": "",
    "telefono_2": "",
    "telefono_3": "",
    "email": "",
    "cod_provincia": "",
    "cod_canton": "",
    "cod_distrito": "",
    "otras_senas": "",
    "cod_poste": "SIN ASIGNAR",
    "fecha_insert": "",
    "localizacion": "",
    "cod_ciclo": "",
    "cod_pueblo": "",
    "tn_num_cliente": "",
    "tc_calle_manzana": "",
    "tc_num_cuenta": "",
    "tc_num_ruta": "",
    "tn_monto_dep": "",
    "tn_num_deposito": "",
    "tc_cod_tarifa": "",
    "des_tipo_solicitud_st": ""
  };

  VmSolicitudMateriales vmMaterialesRetirados = VmSolicitudMateriales();
  VmSolicitudMateriales vmMaterialesInsertados = VmSolicitudMateriales();

  @override
  void initState() {
    super.initState();
    Log.escribir(
        "SOLICITUD ${widget.codSolicitud.toString()} , ORDEN ${widget.numeroOrdenTrabajo.toString()}, ESTADO:${widget.estado.toString()} ");

    cod_solicitud = widget.codSolicitud.toString();
    numero_orden_trabajo = widget.numeroOrdenTrabajo.toString();
    estado = widget.estado.toString();

    mapSolicitud['numero_orden_trabajo'] = numero_orden_trabajo;
    mapSolicitud['estado_orden'] = estado;

    // mapEstadoOT.add({'cod_estado_orden': 1, 'desc_estado_orden': estado});

    for (var key in mapSolicitud.keys) {
      txtEditControllers[key] =
          TextEditingController(text: mapSolicitud[key]?.toString() ?? "");
    }
    txtEditControllers[lblgeocodigo] = TextEditingController(text: "");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!cargosolicitud) {
      if (widget.codPoste.isEmpty) {
        traerSolicitud(widget.codSolicitud.toString(), luminaria)
            .then((obj) async {
          await iniciarSolicitud();
        });
      } else {
        Log.escribir("ULTIMA SOLICITUD POSTE: ${widget.codPoste}");
        traerUltimaSolicitud(widget.codPoste).then((obj) async {
          await iniciarSolicitud();
        });
      }
    }
  }

  @override
  void dispose() async {
    for (var controller in txtEditControllers.values) {
      controller.dispose();
    }
    super.dispose();

    if (mapSolicitud.isNotEmpty) {
      if (mapSolicitud['estado'] == EstadosSolicitudes.REG.name) {
        await guardarSolicitud().then((R) {
          // setState(() {});
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                  child: TextBoxForm(
                      tamanoFuente: tamanoFuente10px,
                      negrilla: FontWeight.bold,
                      habilitado: false,
                      controlador: txtEditControllers['numero_orden_trabajo'],
                      textoEtiqueta: lblnoot,
                      propiedadFormulario: "numero_orden_trabajo",
                      valorFormulario: mapSolicitud)),
              Espacio(alto: 10),
              Expanded(
                  flex: 2,
                  child: (!_loadingTipoServicio)
                      ? progresoCirculo()
                      : ListaSeleccionTexto(
                          opciones: mapTipoSolicitud,
                          tamanofuente: tamanoFuente8px,
                          valorSeleccionado: idTiposolicitudSelecionada,
                          onChanged: (String? r) {
                            setState(() {
                              idTiposolicitudSelecionada = r!;
                              mapSolicitud["des_tipo_solicitud_st"] = r;
                              Log.escribir(
                                  'TIPO DE SOLICITUD SELECCINADO: $idTiposolicitudSelecionada');
                            });
                          },
                        )),
              Espacio(alto: 10),
              Expanded(
                child: TextBoxForm(
                    tamanoFuente: tamanoFuente10px,
                    negrilla: FontWeight.bold,
                    habilitado: false,
                    texto: DescripcionEstado(estado),
                    textoEtiqueta: lblestado,
                    propiedadFormulario: "estado_orden",
                    valorFormulario: mapSolicitud),
              ),
              Espacio(alto: 10),
              Expanded(
                  child: TextBoxForm(
                      tamanoFuente: tamanoFuente10px,
                      negrilla: FontWeight.bold,
                      controlador: txtEditControllers['fecha_insert'],
                      textoEtiqueta: lblfechasolicitud,
                      tipo: TextInputType.text,
                      propiedadFormulario: "fecha_insert",
                      valorFormulario: mapSolicitud)),
            ],
          ),
          Espacio(alto: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                child: TextBoxForm(
                    controlador: txtEditControllers['observacion'],
                    lineas: 5,
                    tipo: TextInputType.multiline,
                    textoEtiqueta: lblobservaciones,
                    propiedadFormulario: "observacion",
                    valorFormulario: mapSolicitud),
              ),
              Espacio(alto: 10),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    TextBoxForm(
                        controlador: txtEditControllers['localizacion'],
                        tipo: TextInputType.text,
                        textoEtiqueta: lbllocalizacion,
                        propiedadFormulario: "localizacion",
                        valorFormulario: mapSolicitud),
                    Espacio(alto: 10),
                    TextBoxForm(
                        controlador: txtEditControllers['cod_pueblo'],
                        tipo: TextInputType.text,
                        textoEtiqueta: lblpueblo,
                        propiedadFormulario: "cod_pueblo",
                        valorFormulario: mapSolicitud)
                  ],
                ),
              )
            ],
          ),
          Espacio(alto: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(flex: 2, child: Etiqueta(texto: lblarchivoseleccionado)),
              Espacio(ancho: 50),
              Boton(
                  textoEtiqueta: lblveradjuntos,
                  colorTexto: colorVerdeSecundario,
                  onPressed: () async {
                    MostrarWidgetEnDialogo(
                        context,
                        AdjuntosSolicitud(
                            llave: widget.codSolicitud.toString()),
                        "$lblarchivoadjuntoSolicitud (Solicitud ${widget.codSolicitud.toString()})");
                  }),
              Espacio(ancho: 50),
              Expanded(
                child: PopupMenuButton<String>(
                  onSelected: (value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Etiqueta(texto: lblaceptar)),
                    );
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: lblImagen,
                      child: Icon(Icons.camera_alt),
                      onTap: () async {
                        await adjuntarImagen();
                      },
                    ),
                    PopupMenuItem<String>(
                      value: lblvideo,
                      child: Icon(Icons.video_call),
                      onTap: () async {
                        await adjuntarVideo();
                      },
                    ),
                    PopupMenuItem<String>(
                      value: lblarchivo,
                      child: Icon(Icons.file_open),
                      onTap: () async {
                        await adjuntarArchivo();
                      },
                    ),
                  ],
                  child: ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            colorAzulPrimario, // Color del fondo del botón
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(0), // Bordes redondeados
                        ),
                      ), // Se maneja internamente el clic
                      child: Etiqueta(
                        texto: lbladjunto,
                        color: colorBlanco,
                      )),
                ),
              ),
            ],
          ),
          Espacio(alto: 10),
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(5),
              child: ExpansionPanelList(
                elevation: 2,
                expandedHeaderPadding: EdgeInsets.zero,
                expansionCallback: (index, isExpanded) async {
                  setState(() {
                    _isExpandedList[index] = !_isExpandedList[index];

                    panelSeleccionado =
                        (panelSeleccionado == index) ? null : index;

                    //Al expandir la seccion buscamos el poste correspondiente a la solicitud en base al dato almacenado en la DB
                    /* posteActual = mapPostes.items!
                        .where((w) => w.numeroPoste == posteSeleccionado)
                        .first;*/
                    txtEditControllers[lblgeocodigo]!.text =
                        "${mapSolicitud['latitud']},${mapSolicitud['longitud']}";
                  });

                  //Se carga la data al expandirse la seccion Materiales Retirados
                  if (index == 6 && _isExpandedList[index]) {
                    vmMaterialesRetirados = await traerSolicitudMateriales(
                        cod_solicitud, "N", mapSolicitud['cod_poste']);
                    setState(() {});
                  }

                  //Se carga la data al exandirse la seccion Materiales Instalados
                  if (index == 7 && _isExpandedList[index]) {
                    vmMaterialesInsertados = await traerSolicitudMateriales(
                        cod_solicitud, "S", mapSolicitud['cod_poste']);
                    setState(() {});
                  }
                },
                children: [
                  // Panel 0: Datos del Solicitante
                  ExpansionPanel(
                    highlightColor: colorAzulSecundario,
                    backgroundColor: colorAcua,
                    headerBuilder: (context, isExpanded) {
                      return GestureDetector(
                        child: tituloExpansionPanel(lbldatossolicitante),
                        onTap: () {
                          setState(() {
                            _isExpandedList[0] = !_isExpandedList[0];
                          });
                        },
                      );
                    },
                    body: Container(
                      padding: EdgeInsets.all(10),
                      color: colorBlanco,
                      child: Wrap(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 1,
                                child: TextBoxForm(
                                    controlador:
                                        txtEditControllers['identificacion'],
                                    textoEtiqueta:
                                        lblidentificaciondequienreporta,
                                    tipo: TextInputType.text,
                                    propiedadFormulario: 'identificacion',
                                    valorFormulario: mapSolicitud),
                              ),
                              Espacio(alto: 10),
                              Expanded(
                                flex: 2,
                                child: TextBoxForm(
                                    controlador: txtEditControllers['nombre'],
                                    textoEtiqueta: lblnombereporta,
                                    tipo: TextInputType.text,
                                    propiedadFormulario: 'nombre',
                                    valorFormulario: mapSolicitud),
                              ),
                              Espacio(alto: 10),
                              /*Expanded(
                                child: TextBoxForm(
                                    controlador:
                                        txtEditControllers['primer_apellido'],
                                    textoEtiqueta: lblprimerapellido,
                                    tipo: TextInputType.name,
                                    propiedadFormulario: 'primer_apellido',
                                    valorFormulario: mapSolicitud),
                              ),
                              Espacio(alto: 10),
                              Expanded(
                                child: TextBoxForm(
                                  controlador:
                                      txtEditControllers['segundo_apellido'],
                                  textoEtiqueta: lblsegundoapellido,
                                  tipo: TextInputType.name,
                                  propiedadFormulario: 'segundo_apellido',
                                  valorFormulario: mapSolicitud,
                                ),
                              ),*/
                            ],
                          ),
                          Espacio(alto: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: TextBoxForm(
                                  controlador: txtEditControllers['telefono_1'],
                                  textoEtiqueta: lbltelefono,
                                  tipo: TextInputType.phone,
                                  propiedadFormulario: 'telefono_1',
                                  valorFormulario: mapSolicitud,
                                  icono: Icons.phone,
                                ),
                              ),
                              Espacio(alto: 10),
                              Expanded(
                                child: TextBoxForm(
                                  controlador: txtEditControllers['telefono_2'],
                                  textoEtiqueta: lbltelefono,
                                  tipo: TextInputType.phone,
                                  propiedadFormulario: 'telefono_2',
                                  valorFormulario: mapSolicitud,
                                  icono: Icons.phone,
                                ),
                              ),
                              Espacio(alto: 10),
                              Expanded(
                                child: TextBoxForm(
                                  controlador: txtEditControllers['telefono_3'],
                                  textoEtiqueta: lbltelefono,
                                  tipo: TextInputType.phone,
                                  propiedadFormulario: 'telefono_3',
                                  valorFormulario: mapSolicitud,
                                  icono: Icons.phone,
                                ),
                              ),
                              Espacio(alto: 10),
                              Expanded(
                                child: TextBoxForm(
                                  controlador: txtEditControllers['email'],
                                  textoEtiqueta: lblcorreo,
                                  tipo: TextInputType.emailAddress,
                                  propiedadFormulario: 'email',
                                  valorFormulario: mapSolicitud,
                                  icono: Icons.email,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    isExpanded: _isExpandedList[0],
                  ),

                  // Panel 1: Información Adicional
                  ExpansionPanel(
                    backgroundColor: colorAcua,
                    headerBuilder: (context, isExpanded) {
                      return GestureDetector(
                        child: tituloExpansionPanel(lblUbicacionSolicitada),
                        onTap: () {
                          setState(() {
                            _isExpandedList[1] = !_isExpandedList[1];
                          });
                        },
                      );
                    },
                    body: Container(
                      padding: EdgeInsets.all(10),
                      color: colorBlanco,
                      child: Wrap(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  child: ListaSeleccion(
                                textoEtiqueta: lblprovincia,
                                mapaDatos: mapProvincia,
                                selectedValue: (idProvinciaSeleccionado > 0)
                                    ? idProvinciaSeleccionado
                                    : null,
                                idKey: "id_provincia",
                                nameKey: "nombre_provincia",
                                onChanged: (value) {
                                  idProvinciaSeleccionado = value!;
                                  mapSolicitud["cod_provincia"] = '$value';

                                  setState(() {
                                    idCantonSeleccionado = 0;
                                    idDistritoSeleccionado = 0;
                                    mapCanton = [];
                                    mapDistrito = [];
                                    _loadingCanton = true;
                                  });

                                  cargarCanton().then((obj) {
                                    setState(() {});
                                  });
                                },
                              )),
                              Espacio(alto: 25),
                              Expanded(
                                  child: _loadingCanton
                                      ? progresoCirculo()
                                      : ListaSeleccion(
                                          textoEtiqueta: lblcanton,
                                          mapaDatos: mapCanton,
                                          selectedValue:
                                              (idCantonSeleccionado > 0)
                                                  ? idCantonSeleccionado
                                                  : null,
                                          idKey: "id_canton",
                                          nameKey: "nombre_canton",
                                          onChanged: (int? value) {
                                            idCantonSeleccionado = value!;
                                            mapSolicitud["cod_canton"] =
                                                '$value';

                                            setState(() {
                                              idDistritoSeleccionado = 0;
                                              mapDistrito = [];
                                              _loadingDistrito = true;
                                            });
                                            cargarDistrito().then((oj) {
                                              setState(() {});
                                            });
                                          },
                                        )),
                              Espacio(alto: 25),
                              Expanded(
                                  child: _loadingDistrito
                                      ? progresoCirculo()
                                      : ListaSeleccion(
                                          tamanoFuente: tamanoFuente8px,
                                          textoEtiqueta: lbldistrito,
                                          mapaDatos: mapDistrito,
                                          idKey: "id_distrito",
                                          nameKey: "nombre_distrito",
                                          selectedValue:
                                              (idDistritoSeleccionado > 0)
                                                  ? idDistritoSeleccionado
                                                  : null,
                                          onChanged: (int? value) {
                                            idDistritoSeleccionado = value!;
                                            mapSolicitud["cod_distrito"] =
                                                '$value';
                                          })),
                            ],
                          ),
                          Espacio(alto: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: TextBoxForm(
                                  controlador:
                                      txtEditControllers['otras_senas'],
                                  textoEtiqueta: lblreferenciaubicacion,
                                  lineas: 4,
                                  tipo: TextInputType.multiline,
                                  propiedadFormulario: 'otras_senas',
                                  valorFormulario: mapSolicitud,
                                ),
                              ),
                              Espacio(ancho: 5),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Expanded(
                                            flex: 2,
                                            child: (mapPostes.items != null)
                                                ? ListaSeleccionTexto(
                                                    tamanofuente:
                                                        tamanoFuente10px,
                                                    opciones: mapPostes.items!
                                                        .where((item) =>
                                                            item.numeroPoste !=
                                                            null)
                                                        .map((item) =>
                                                            item.numeroPoste!)
                                                        .toSet()
                                                        .toList(),
                                                    valorSeleccionado:
                                                        posteSeleccionado,
                                                    onChanged: (String?
                                                        nuevaRespuesta) {
                                                      setState(() {
                                                        mapSolicitud[
                                                                'cod_poste'] =
                                                            nuevaRespuesta;
                                                      });
                                                    },
                                                  )
                                                : Etiqueta(texto: lblposte)),
                                        Expanded(
                                            flex: 1,
                                            child: (mapPostes.items != null)
                                                ? IconButton(
                                                    onPressed: () async {
                                                      double lat = double.parse(
                                                          mapSolicitud[
                                                              'latitud']);
                                                      double lon = double.parse(
                                                          mapSolicitud[
                                                              'longitud']);
                                                      await abrirURLGPS(
                                                          lat, lon);
                                                    },
                                                    icon: Icon(
                                                      Icons.map,
                                                      color:
                                                          colorAzulSecundario,
                                                    ))
                                                : Text("")),
                                      ],
                                    ),
                                    Espacio(alto: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                            child: TextBoxForm(
                                                textoEtiqueta:
                                                    lblfechareactivacion,
                                                propiedadFormulario:
                                                    "FECHA_REACTIVACION",
                                                valorFormulario: mapSolicitud)),
                                        Espacio(alto: 10),
                                        Expanded(
                                            child: TextBoxForm(
                                                textoEtiqueta: lbltotalrechazos,
                                                propiedadFormulario:
                                                    "TOTAL_RECHAZOS",
                                                valorFormulario: mapSolicitud)),
                                        Espacio(alto: 10),
                                        (conexionInternet)
                                            ? Expanded(
                                                child: Boton(
                                                    textoEtiqueta: lblhistorial,
                                                    colorFondo:
                                                        colorAzulPrimario,
                                                    colorTexto: colorBlanco,
                                                    onPressed: () {
                                                      Navigator.popAndPushNamed(
                                                          context, "inicio",
                                                          arguments: {
                                                            lblopcionprincipal:
                                                                4.2, //Carga la ultima solicitud atendida al poste
                                                            lblnombreopcion:
                                                                lblhistorial,
                                                            lblllave:
                                                                '${mapSolicitud['cod_solicitud']}',
                                                            "numero_orden_trabajo":
                                                                numero_orden_trabajo,
                                                            "estado": estado,
                                                            "cod_poste":
                                                                '${mapSolicitud["cod_poste"]}',
                                                            lblimagenopcion:
                                                                urlimagensolicitud
                                                          });

                                                      /*Widget widget = Expanded(
                                                    child: Container(
                                                  color: colorBlanco,
                                                  width: double
                                                      .infinity, // Se adapta al ancho del padre
                                                  child: SingleChildScrollView(
                                                    child: Column(children: [
                                                      HistorialAtencionSolicitud(
                                                        cod_solicitud:
                                                            cod_solicitud,
                                                        numero_orden_trabajo:
                                                            numero_orden_trabajo,
                                                        estado: estado,
                                                      )
                                                    ]),
                                                  ),
                                                ));

                                                MostrarWidgetEnDialogo(context,
                                                    widget, lblhistorial);
                                               */
                                                    },
                                                    tamanoFuente:
                                                        tamanoFuente8px,
                                                    bordenRedondeado: 10,
                                                    tipoFuente:
                                                        FontWeight.bold),
                                              )
                                            : Text(""),
                                        Espacio(alto: 10),
                                        (conexionInternet)
                                            ? Expanded(
                                                child: Boton(
                                                    textoEtiqueta: lblinstalado,
                                                    colorFondo:
                                                        colorAzulPrimario,
                                                    colorTexto: colorBlanco,
                                                    onPressed: () {
                                                      Log.escribir(
                                                          "MATERIALES INSTALADOS CLICK");
                                                      MostrarWidgetEnDialogo(
                                                          context,
                                                          ListadoMaterialesPoste(
                                                              cod_solicitud,
                                                              "S",
                                                              mapSolicitud[
                                                                  'cod_poste']),
                                                          "Materiales instalados (${mapSolicitud['cod_poste']})");
                                                    },
                                                    onLongPress: () {},
                                                    tamanoFuente:
                                                        tamanoFuente8px,
                                                    bordenRedondeado: 10,
                                                    tipoFuente:
                                                        FontWeight.bold))
                                            : Text("")
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Espacio(ancho: 10),
                        ],
                      ),
                    ),
                    isExpanded: _isExpandedList[1],
                  ),

                  //Panel 2:
                  ExpansionPanel(
                    highlightColor: colorAzulSecundario,
                    backgroundColor: colorAcua,
                    headerBuilder: (context, isExpanded) {
                      return GestureDetector(
                        child: tituloExpansionPanel(lblfacturacion),
                        onTap: () {
                          setState(() {
                            _isExpandedList[2] = !_isExpandedList[2];
                          });
                        },
                      );
                    },
                    body: Container(
                      padding: EdgeInsets.all(10),
                      color: colorBlanco,
                      child: Wrap(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: TextBoxForm(
                                  controlador:
                                      txtEditControllers['tn_num_cliente'],
                                  tipo: TextInputType.text,
                                  textoEtiqueta: lblnumerocliente,
                                  propiedadFormulario: "tn_num_cliente",
                                  valorFormulario: mapSolicitud,
                                  negrilla: FontWeight.bold,
                                  habilitado: false,
                                ),
                              ),
                              Espacio(alto: 10),
                              Expanded(
                                child: TextBoxForm(
                                  controlador: txtEditControllers['cod_pueblo'],
                                  tipo: TextInputType.text,
                                  textoEtiqueta: lblpueblo,
                                  propiedadFormulario: "cod_pueblo",
                                  valorFormulario: mapSolicitud,
                                  negrilla: FontWeight.bold,
                                  habilitado: false,
                                ),
                              ),
                              Espacio(alto: 10),
                              Expanded(
                                child: TextBoxForm(
                                  controlador: txtEditControllers['cod_ciclo'],
                                  tipo: TextInputType.text,
                                  textoEtiqueta: lblciclo,
                                  propiedadFormulario: "cod_ciclo",
                                  valorFormulario: mapSolicitud,
                                  negrilla: FontWeight.bold,
                                  habilitado: false,
                                ),
                              ),
                            ],
                          ),
                          Espacio(alto: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: TextBoxForm(
                                  controlador:
                                      txtEditControllers['tc_cod_tarifa'],
                                  tipo: TextInputType.text,
                                  textoEtiqueta: lbltarifa,
                                  propiedadFormulario: "tc_cod_tarifa",
                                  valorFormulario: mapSolicitud,
                                  negrilla: FontWeight.bold,
                                  habilitado: false,
                                ),
                              ),
                              Espacio(alto: 10),
                              Expanded(
                                child: TextBoxForm(
                                  controlador:
                                      txtEditControllers['tn_num_deposito'],
                                  tipo: TextInputType.text,
                                  textoEtiqueta: lblnodeposito,
                                  propiedadFormulario: "tn_num_deposito",
                                  valorFormulario: mapSolicitud,
                                  negrilla: FontWeight.bold,
                                  habilitado: false,
                                ),
                              ),
                              Espacio(alto: 10),
                              Expanded(
                                child: TextBoxForm(
                                  controlador:
                                      txtEditControllers['tn_monto_dep'],
                                  tipo: TextInputType.text,
                                  textoEtiqueta: lblmonto,
                                  propiedadFormulario: "tn_monto_dep",
                                  valorFormulario: mapSolicitud,
                                  negrilla: FontWeight.bold,
                                  habilitado: false,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    isExpanded: _isExpandedList[2],
                  ),

                  //Panel 3:
                  ExpansionPanel(
                    highlightColor: colorAzulSecundario,
                    backgroundColor: colorAcua,
                    headerBuilder: (context, isExpanded) {
                      return GestureDetector(
                        child: tituloExpansionPanel(lblatencioncuenta),
                        onTap: () {
                          setState(() {
                            _isExpandedList[3] = !_isExpandedList[3];
                          });
                        },
                      );
                    },
                    body: Container(
                      padding: EdgeInsets.all(10),
                      color: colorBlanco,
                      child: Wrap(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: ListaSeleccion(
                                    textoEtiqueta: lbltipoinstalacion,
                                    mapaDatos: mapTipoAtencion,
                                    idKey: "cod_tipo_atencion",
                                    nameKey: "des_tipo_atencion",
                                    selectedValue:
                                        (idTipoAtencionSeleccionado > 0)
                                            ? idTipoAtencionSeleccionado
                                            : null,
                                    onChanged: (valor) {
                                      setState(() {
                                        idTipoAtencionSeleccionado = valor!;
                                        mapSolicitud["cod_tipo_atencion"] =
                                            valor.toString();
                                      });
                                    }),
                              ),
                              Espacio(alto: 10),
                              Expanded(
                                  child: ListaSeleccion(
                                textoEtiqueta: lblcuentagasto,
                                mapaDatos: mapCuentaGasto,
                                selectedValue:
                                    (idCuentaGasto > 0) ? idCuentaGasto : null,
                                idKey: "cod_cuenta_gasto",
                                nameKey: "des_cuenta_gasto",
                                onChanged: (value) {
                                  idCuentaGasto = value!;
                                  mapSolicitud["cod_cuenta_gasto"] = '$value';
                                },
                              )),
                              Espacio(alto: 25),
                              Expanded(
                                  child: ListaSeleccion(
                                textoEtiqueta: lblnootc,
                                mapaDatos: mapTOC,
                                selectedValue: (idOrdenTrabajoContable > 0)
                                    ? idOrdenTrabajoContable
                                    : null,
                                idKey: "cod_otc",
                                nameKey: "des_otc",
                                onChanged: (value) {
                                  idOrdenTrabajoContable = value!;
                                  mapSolicitud["cod_otc"] = '$value';
                                },
                              )),
                            ],
                          ),
                          Espacio(alto: 10),
                        ],
                      ),
                    ),
                    isExpanded: _isExpandedList[3],
                  ),

                  //Panel 4:
                  ExpansionPanel(
                    highlightColor: colorAzulSecundario,
                    backgroundColor: colorAcua,
                    headerBuilder: (context, isExpanded) {
                      return GestureDetector(
                        child: tituloExpansionPanel(lbllocalizacion),
                        onTap: () {
                          setState(() {
                            _isExpandedList[4] = !_isExpandedList[4];
                          });
                        },
                      );
                    },
                    body: Container(
                      padding: EdgeInsets.all(10),
                      color: colorBlanco,
                      child: Wrap(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            spacing: 10,
                            children: [
                              Expanded(
                                child: TextBoxForm(
                                  controlador:
                                      txtEditControllers['localizacion'],
                                  tipo: TextInputType.text,
                                  textoEtiqueta: lbllocalizacion,
                                  propiedadFormulario: "localizacion",
                                  valorFormulario: mapSolicitud,
                                  negrilla: FontWeight.bold,
                                  habilitado: false,
                                ),
                              ),
                              ElevatedButton.icon(
                                  onPressed: () async {
                                    GPS gps = GPS(context);

                                    if (await gps.exigirGPSYPermisos()) {
                                      mapSolicitud['latitud'] =
                                          PosGPSGlobal!.latitude.toString();
                                      mapSolicitud['longitud'] =
                                          PosGPSGlobal!.longitude.toString();
                                    }

                                    txtEditControllers[lblgeocodigo]!.text =
                                        '${PosGPSGlobal!.latitude} ${PosGPSGlobal!.longitude}';
                                  },
                                  label: Etiqueta(texto: lblgeolocalizar)),
                              Expanded(
                                child: TextBoxForm(
                                  controlador: txtEditControllers[lblgeocodigo],
                                  tamanoFuente: tamanoFuente10px,
                                  textoEtiqueta: lblgeocodigo,
                                  tipo: TextInputType.text,
                                  propiedadFormulario: lblgeocodigo,
                                ),
                              ),
                              Expanded(
                                child: TextBoxForm(
                                  controlador: txtEditControllers['cod_poste'],
                                  textoEtiqueta: lblnoposte,
                                  tipo: TextInputType.text,
                                  propiedadFormulario: 'cod_poste',
                                  valorFormulario: mapSolicitud,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    isExpanded: _isExpandedList[4],
                  ),

                  //Panel 5:
                  ExpansionPanel(
                    highlightColor: colorAzulSecundario,
                    backgroundColor: colorAcua,
                    headerBuilder: (context, isExpanded) {
                      return GestureDetector(
                        child: Center(
                          child: tituloExpansionPanel(lblformularios),
                        ),
                        onTap: () {
                          setState(() {
                            _isExpandedList[5] = !_isExpandedList[5];
                          });
                        },
                      );
                    },
                    body: Container(
                      padding: EdgeInsets.all(10),
                      color: colorBlanco,
                      child: Wrap(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: GestureDetector(
                                    onLongPress: () {},
                                    onTap: () {
                                      MostrarWidgetEnDialogo(
                                          context,
                                          FrmEvaluacionRequisitosTecnicosDesglosado(
                                              "1",
                                              cod_solicitud,
                                              mapSolicitud['cod_poste']),
                                          lblevaluacionrequisitostecnicos
                                              .toUpperCase());
                                    },
                                    child: Container(
                                      width: bwidth,
                                      height: bheight,
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1, color: colorNegro),
                                        color:
                                            colorGrisSecundario, // Color de fondo
                                        borderRadius: BorderRadius.circular(
                                            10), // Bordes redondeados opcionales
                                      ),
                                      child: Column(
                                        children: [
                                          Image.asset(
                                            'assets/images/evaluar.png', // Ruta de tu imagen
                                            width:
                                                wancho, // Tamaño de la imagen
                                            height: halto,
                                          ),
                                          Etiqueta(
                                              tamanoFuente: tamanoFuente10px,
                                              texto:
                                                  lblevaluacionrequisitostecnicos,
                                              alinear: TextAlign.center,
                                              tipo: FontWeight.bold,
                                              color: colorNegro),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Espacio(alto: 10),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: GestureDetector(
                                    onLongPress: () {},
                                    onTap: () {
                                      MostrarWidgetEnDialogo(
                                          context,
                                          FrmDatosSistemaMedicionResidencial(
                                              cod_solicitud),
                                          lbldatossistemamedicionresidencial
                                              .toUpperCase());
                                    },
                                    child: Container(
                                      width: bwidth,
                                      height: bheight,
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1, color: colorNegro),
                                        color:
                                            colorGrisSecundario, // Color de fondo
                                        borderRadius: BorderRadius.circular(
                                            10), // Bordes redondeados opcionales
                                      ),
                                      child: Column(
                                        children: [
                                          Image.asset(
                                            'assets/images/residencia.png', // Ruta de tu imagen
                                            width:
                                                wancho, // Tamaño de la imagen
                                            height: halto,
                                          ),
                                          Etiqueta(
                                              tamanoFuente: tamanoFuente10px,
                                              texto:
                                                  lbldatossistemamedicionresidencial,
                                              alinear: TextAlign.center,
                                              tipo: FontWeight.bold,
                                              color: colorNegro),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Espacio(alto: 10),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: GestureDetector(
                                    onLongPress: () {},
                                    onTap: () {
                                      Log.escribir(
                                          'Clic en FrmDatosSistemaMedicionIndustrial $cod_solicitud a $lbldatossistemamedicionindustrial');
                                      MostrarWidgetEnDialogo(
                                          context,
                                          FrmDatosSistemaMedicionIndustrial(
                                              cod_solicitud),
                                          lbldatossistemamedicionindustrial
                                              .toUpperCase());
                                    },
                                    child: Container(
                                      width: bwidth,
                                      height: bheight,
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1, color: colorNegro),
                                        color:
                                            colorGrisSecundario, // Color de fondo
                                        borderRadius: BorderRadius.circular(
                                            10), // Bordes redondeados opcionales
                                      ),
                                      child: Column(
                                        children: [
                                          Image.asset(
                                            'assets/images/industrial.png', // Ruta de tu imagen
                                            width:
                                                wancho, // Tamaño de la imagen
                                            height: halto,
                                          ),
                                          Etiqueta(
                                              tamanoFuente: tamanoFuente10px,
                                              texto: lbldatosmedicionindustrial,
                                              alinear: TextAlign.center,
                                              tipo: FontWeight.bold,
                                              color: colorNegro),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Espacio(alto: 10),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: GestureDetector(
                                    onLongPress: () {},
                                    onTap: () {
                                      MostrarWidgetEnDialogo(
                                          context,
                                          FrmVinculacionUsuarioRed(
                                              cod_solicitud),
                                          lblviculacionusuariored
                                              .toUpperCase());
                                    },
                                    child: Container(
                                      width: bwidth,
                                      height: bheight,
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1, color: colorNegro),
                                        color:
                                            colorGrisSecundario, // Color de fondo
                                        borderRadius: BorderRadius.circular(
                                            10), // Bordes redondeados opcionales
                                      ),
                                      child: Column(
                                        children: [
                                          Image.asset(
                                            'assets/images/vinculacion.png', // Ruta de tu imagen
                                            width:
                                                wancho, // Tamaño de la imagen
                                            height: halto,
                                          ),
                                          Etiqueta(
                                              tamanoFuente: tamanoFuente10px,
                                              texto: lblviculacionusuariored,
                                              alinear: TextAlign.center,
                                              tipo: FontWeight.bold,
                                              color: colorNegro),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Espacio(alto: 10),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: GestureDetector(
                                    onLongPress: () {},
                                    onTap: () {
                                      MostrarWidgetEnDialogo(
                                          context,
                                          FrmEvaluacionRequisitosTecnicosDesglosado(
                                              "5",
                                              cod_solicitud,
                                              mapSolicitud['cod_poste']),
                                          lblinspeccionespecial.toUpperCase());
                                    },
                                    child: Container(
                                      width: bwidth,
                                      height: bheight,
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1, color: colorNegro),
                                        color:
                                            colorGrisSecundario, // Color de fondo
                                        borderRadius: BorderRadius.circular(
                                            10), // Bordes redondeados opcionales
                                      ),
                                      child: Column(
                                        children: [
                                          Image.asset(
                                            'assets/images/inspeccion.png', // Ruta de tu imagen
                                            width:
                                                wancho, // Tamaño de la imagen
                                            height: halto,
                                          ),
                                          Etiqueta(
                                            tamanoFuente: tamanoFuente10px,
                                            texto: lblinspeccionespecial,
                                            alinear: TextAlign.center,
                                            tipo: FontWeight.bold,
                                            color: colorNegro,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Espacio(alto: 10)
                            ],
                          ),
                        ],
                      ),
                    ),
                    isExpanded: _isExpandedList[5],
                  ),

                  //Panel 6:
                  ExpansionPanel(
                    backgroundColor: colorAcua,
                    headerBuilder: (context, isExpanded) {
                      return ListTile(
                        dense: true,
                        title: Etiqueta(
                          texto: lblmaterialesretirados,
                          tipo: FontWeight.bold,
                          color: colorBlanco,
                          tamanoFuente: tamanoFuenteDefecto,
                        ),
                        onTap: () {
                          setState(() {
                            _isExpandedList[6] = !_isExpandedList[6];
                          });
                        },
                      );
                    },
                    body: Container(
                        padding: EdgeInsets.all(10),
                        color: colorBlanco,
                        child: Column(
                          children: [
                            ElevatedButton.icon(
                              label: Etiqueta(texto: lblagregar),
                              onPressed: () async {
                                if (mapSolicitud['cod_poste'].isEmpty) {
                                  BarraMensaje(context)
                                      .Mensaje(lblnoseasignadocodigoposte);
                                  return;
                                }

                                await MostrarWidgetEnDialogo(
                                    context,
                                    AgregarMaterialesSolicitud(cod_solicitud,
                                        "N", mapSolicitud['cod_poste']),
                                    lblretirarmateriales);
                                setState(() {
                                  _isExpandedList[3] = false;
                                });
                              },
                              icon: Icon(
                                Icons.remove,
                                color: colorRojoPrimario,
                              ),
                            ),
                            LineaHorizontal(
                              color: colorAzulSecundario,
                            ),
                            solicitudMaterial(vmMaterialesRetirados),
                          ],
                        )),
                    isExpanded: _isExpandedList[6],
                  ),

                  //Panel 7:
                  ExpansionPanel(
                    backgroundColor: colorAcua,
                    headerBuilder: (context, isExpanded) {
                      return ListTile(
                        dense: true,
                        title: Etiqueta(
                          texto: lblmaterialesinstalados,
                          tipo: FontWeight.bold,
                          color: colorBlanco,
                          tamanoFuente: tamanoFuenteDefecto,
                        ),
                        onTap: () {
                          setState(() {
                            _isExpandedList[7] = !_isExpandedList[7];
                          });
                        },
                      );
                    },
                    body: Container(
                        padding: EdgeInsets.all(10),
                        color: colorBlanco,
                        child: Column(
                          children: [
                            ElevatedButton.icon(
                                onPressed: () async {
                                  if (mapSolicitud['cod_poste'].isEmpty) {
                                    BarraMensaje(context).Mensaje(
                                        lblnoseasignadocodigoposte,
                                        colorFuente: colorVerdePrimario);
                                    return;
                                  }
                                  await MostrarWidgetEnDialogo(
                                      context,
                                      AgregarMaterialesSolicitud(cod_solicitud,
                                          "S", mapSolicitud['cod_poste']),
                                      lblmaterialesinstalados);
                                  setState(() {
                                    _isExpandedList[7] = false;
                                  });
                                },
                                label: Etiqueta(texto: lblagregar),
                                icon: Icon(
                                  Icons.add,
                                  color: colorVerdeSecundario,
                                )),
                            LineaHorizontal(
                              color: colorAzulSecundario,
                            ),
                            solicitudMaterial(vmMaterialesInsertados),
                          ],
                        )),
                    isExpanded: _isExpandedList[7],
                  )
                ],
              ),
            ),
          ),
          Espacio(alto: 25),
          Row(
            children: [
              Expanded(
                  child: Boton(
                textoEtiqueta: lblchekin,
                colorFondo: colorAzulPrimario,
                colorTexto: colorBlanco,
                onPressed: () async {
                  if (await existeChekin()) {
                    BarraMensaje(context).Mensaje(lblchekinprevio,
                        colorFondo: colorAmarrillo, colorFuente: colorBlanco);
                    return;
                  } else {
                    await chekIn();
                  }
                },
              )),
              Espacio(alto: 10),
              Expanded(
                  child: Boton(
                textoEtiqueta: lblgeolocalizar,
                colorFondo: colorAcua,
                colorTexto: colorBlanco,
                onPressed: () async {
                  GPS gps = GPS(context);
                  if (await gps.exigirGPSYPermisos()) {
                    mapSolicitud['latitud'] = PosGPSGlobal!.latitude;
                    mapSolicitud['longitud'] = PosGPSGlobal!.longitude;
                  }
                },
              )),
              Spacer(),
              Expanded(
                  child: Boton(
                textoEtiqueta: lblnoefectiva,
                colorFondo: colorRojoPrimario,
                colorTexto: colorBlanco,
                onPressed: () async {
                  String idSolicitud =
                      mapSolicitud['cod_solicitud']!.toString();

                  await dialogoSolicitudNoEfectiva(context, idSolicitud)
                      .then((x) {
                    if (x == true) {
                      MostrarWidgetEnDialogo(
                          context,
                          FrmSolicitudNoEfectiva(idSolicitud),
                          lblmotivoderechazo);
                    }
                  });

                  await actualizarEstadoSolicitud(EstadosSolicitudes.NOE.name);
                },
              )),
              Espacio(alto: 10),
              Expanded(
                  child: Boton(
                textoEtiqueta: lblefectiva,
                colorFondo: colorVerdePrimario,
                colorTexto: colorBlanco,
                onPressed: () async {
                  await chekOut();
                  await actualizarEstadoSolicitud(EstadosSolicitudes.EFE.name);
                },
              ))
            ],
          )
        ],
      ),
    );
  }

  Future<void> iniciarSolicitud() async {
    try {
      await cargarTipoServicio().then((r) {
        _loadingTipoServicio = true;
      });
      Log.escribir("cargarTipoServicio");

      await cargarTipoSolicitud();
      Log.escribir("cargarTipoSolicitud");

      await cargarUbicacion();
      Log.escribir("cargarUbicacion");

      await cargarTipoAtencion();
      Log.escribir("cargarTipoAtencion");

      await cargarListaPostes();
      Log.escribir("cargarListaPostes");

      await cargarCuentaGasto();
      Log.escribir("cargarCuentaGasto");

      await cargarOrdenTrabajoContable();
      Log.escribir("cargarOrdenTrabajoContable");
    } catch (e) {
      Log.escribir("ERROR EN iniciarSolicitud ${e.toString()}");
    }

    setState(() {});
  }

  Widget solicitudMaterial(VmSolicitudMateriales mapSolicitudMateriales) {
    return (mapSolicitudMateriales.items is List)
        ? SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(
                  label: Etiqueta(
                    texto: lblcodigo,
                    tamanoFuente: tamanoFuente12px,
                    tipo: FontWeight.bold,
                  ),
                ),
                DataColumn(
                  label: Etiqueta(
                    texto: lbldescripcion,
                    tamanoFuente: tamanoFuente12px,
                    tipo: FontWeight.bold,
                  ),
                ),
                DataColumn(
                  label: Etiqueta(
                    texto: lblcantidad,
                    tamanoFuente: tamanoFuente12px,
                    tipo: FontWeight.bold,
                  ),
                ),
                DataColumn(
                  label: Etiqueta(
                    texto: lblobservaciones,
                    tamanoFuente: tamanoFuente12px,
                    tipo: FontWeight.bold,
                  ),
                ),
                DataColumn(
                  label: Etiqueta(
                    texto: lblfecha,
                    tamanoFuente: tamanoFuente12px,
                    tipo: FontWeight.bold,
                  ),
                ),
                DataColumn(
                  label: Etiqueta(
                    texto: lblUsuario,
                    tamanoFuente: tamanoFuente12px,
                    tipo: FontWeight.bold,
                  ),
                ),
                DataColumn(
                  label: Etiqueta(
                    texto: lbleliminar,
                    tamanoFuente: tamanoFuente12px,
                    tipo: FontWeight.bold,
                  ),
                ),
              ],
              rows: mapSolicitudMateriales.items!.map((m) {
                return DataRow(
                  cells: [
                    DataCell(Text(m.codSiarProducto.toString())),
                    DataCell(Text(m.nomProducto.toString())),
                    DataCell(Text(m.cantidad.toString())),
                    DataCell(Text(m.observaciones.toString())),
                    DataCell(Text(
                        m.fechaInsert!.toLocal().toString().split(' ')[0])),
                    DataCell(Text(m.usuarioInsert!)),
                    DataCell(IconButton(
                        onPressed: () async {
                          await eliminarSolicitudMateriales(
                              m.codSolicitudMaterial.toString());
                        },
                        icon: Icon(
                          Icons.delete,
                          color: colorRojoPrimario,
                        ))),
                  ],
                );
              }).toList(),
            ),
          )
        : Center(
            child: Etiqueta(
            texto: lblNoData,
            color: colorRojoPrimario,
          ));
  }

  Future<VmSolicitudMateriales> eliminarSolicitudMateriales(
      String codsolicitudmaterial) async {
    CrudMateriales cls = CrudMateriales();
    VmSolicitudMateriales vm = VmSolicitudMateriales();

    //Listado de ordenes
    await cls.eliminarSolicitudMaterialesInstalados(codsolicitudmaterial).then(
      (r) {
        if (r.idInsertado! > 0) {
          setState(() {
            _isExpandedList[6] = false;
            _isExpandedList[7] = false;
          });
          BarraMensaje(context)
              .Mensaje(lblregistroeliminado, colorFondo: colorVerdeSecundario);
        }
      },
    );

    return vm;
  }

  Future<void> actualizarEstadoSolicitud(String estado) async {
    Map<String, dynamic> map = {
      "cod_solicitud": cod_solicitud,
      "estado": estado
    };

    CrudSolicitud cls = CrudSolicitud();

    await cls.actualizarEstadoSolicitud(map).then((resp) {
      if (resp.idInsertado! > 0) {
        String estadoCompleto = DescripcionEstado(estado);
        Dialogo(context, lblconfiguracion,
            '$lblactualizoestadoSolicitud a $estadoCompleto', Icons.check);
        //BarraMensaje(context).Mensaje('$lblactualizoestadoSolicitud a $estado');
      }
    });
  }

  Future<void> chekIn() async {
    CrudSolicitud cls = CrudSolicitud();
    Map<String, dynamic> map = {
      "cod_solicitud": cod_solicitud,
      "cod_orden_trabajo": widget.numeroOrdenTrabajo,
      "desc_tiempo_atencion": "Inicio de mantenimiento, usuario:$usuarioLogin",
      "usuario_atencion": usuarioLogin
    };

    await cls.guardarInicioTiempoAtencion(map).then((resp) {
      if (resp.idInsertado! > 0) {
        setPreferencia(cod_solicitud, resp.idInsertado!.toString());
        BarraMensaje(context)
            .Mensaje(lblregistrochekin, colorFuente: colorVerdePrimario);
      }
    });
  }

  Future<void> chekOut() async {
    var codTiempoAtencion = await getPreferencia(cod_solicitud);

    if (codTiempoAtencion.isNotEmpty) {
      CrudSolicitud cls = CrudSolicitud();
      GPS gps = GPS(context);
      if (await gps.exigirGPSYPermisos()) {
        Map<String, dynamic> map = {
          "cod_solicitud": cod_solicitud,
          "cod_tiempo_atencion": codTiempoAtencion,
          "latitud": PosGPSGlobal!.latitude.toString(),
          "longitud": PosGPSGlobal!.longitude.toString(),
          "usuario_atencion": usuarioLogin
        };

        await cls.actualizarFinTiempoAtencion(map).then((resp) {
          if (resp.idInsertado! > 0) {
            setPreferencia(cod_solicitud, "");
            BarraMensaje(context)
                .Mensaje(lblactualizochekin, colorFuente: colorVerdePrimario);
          }
        });
      }
    }
  }

  Future<bool> existeChekin() async {
    var codTiempoAtencion = await getPreferencia(cod_solicitud);

    if (codTiempoAtencion.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> adjuntarImagen() async {
    DialogoProgreso(context, lblprocesando, lblprocesando, Icons.network_check,
        widget: Center(
            child: SizedBox(width: 200, height: 200, child: progresoCirculo())),
        cerrar: false);
    try {
      await cargarFotografiaSolicitud(cod_solicitud,
              origenFotografia: ImageSource.camera,
              nombreSujerido: "Solicitud$cod_solicitud")
          .then((resp) async {
        if (resp) {
          BarraMensaje(context).Mensaje(lblarchivoadjunto);
        } else {
          BarraMensaje(context).Mensaje(lblarchivonocargado,
              colorFondo: colorRojoPrimario, colorFuente: colorBlanco);
        }
      });
    } catch ($e) {
      Navigator.of(context).pop();
    } finally {
      Navigator.of(context).pop();
    }
  }

  Future<void> adjuntarArchivo() async {
    DialogoProgreso(context, lblprocesando, lblprocesando, Icons.network_check,
        widget: Center(
            child: SizedBox(width: 200, height: 200, child: progresoCirculo())),
        cerrar: false);
    try {
      await cargarArchivoSolicitud(cod_solicitud).then((resp) async {
        if (resp) {
          BarraMensaje(context).Mensaje(lblarchivoadjunto);
        } else {
          BarraMensaje(context).Mensaje(lblarchivonocargado,
              colorFondo: colorRojoPrimario, colorFuente: colorBlanco);
        }
      });
    } catch ($e) {
      Navigator.of(context).pop();
    } finally {
      Navigator.of(context).pop();
    }
  }

  Future<void> adjuntarVideo() async {
    DialogoProgreso(context, lblprocesando, lblprocesando, Icons.network_check,
        widget: Center(
            child: SizedBox(width: 200, height: 200, child: progresoCirculo())),
        cerrar: false);
    try {
      await cargarVideoSolicitud(cod_solicitud,
              nombreSujerido: "Solicitud$cod_solicitud")
          .then((resp) async {
        if (resp) {
          BarraMensaje(context).Mensaje(lblarchivoadjunto);
        } else {
          BarraMensaje(context).Mensaje(lblarchivonocargado,
              colorFondo: colorRojoPrimario, colorFuente: colorBlanco);
        }
      });
    } catch ($e) {
      Navigator.of(context).pop();
    } finally {
      Navigator.of(context).pop();
    }
  }

  Future<void> cargarUbicacion() async {
    await cargarProvincia().then((provincia) {
      cargarCanton().then((canton) {
        cargarDistrito().then((distrito) {});
      });
    });
  }

  Future<void> cargarTipoServicio() async {
    await listasPrecargadas.listaTipoServicio(alumbrado: luminaria).then(
      (tiposervicio) {
        mapTipoServicio =
            tiposervicio.items!.map((item) => item.toJson()).toList();
      },
    );
  }

  Future<void> cargarTipoSolicitud() async {
    Log.escribir('CARGANDO TIPO SOLICITUD');
    await listasPrecargadas.listaTipoSolicitudST().then(
      (tiposolicitud) {
        Log.escribir('RECIBIO:${tiposolicitud.items.toString()}');

        mapTipoSolicitud = tiposolicitud.items!
            .map((m) => m.desTipoSolicitud.toString())
            .toList();

        Log.escribir('LISTA:${mapTipoSolicitud.toString()}');
      },
    );
  }

  Future<void> cargarTipoAtencion() async {
    //Listado de provincias
    await listasPrecargadas.listaTipoAtencion(alumbrado: luminaria).then(
      (resp) {
        mapTipoAtencion = resp.items!.map((item) => item.toJson()).toList();
      },
    );
  }

  Future<void> cargarListaPostes() async {
    //Listado de tipos de solicitud
    await listasPrecargadas.listaPostes().then(
      (resp) {
        mapPostes = resp;
      },
    );
  }

  Future<void> cargarProvincia() async {
    //Listado de provincias
    await listasPrecargadas.listaProvincias().then(
      (provincias) {
        mapProvincia = provincias.items!.map((item) => item.toJson()).toList();
      },
    );
  }

  Future<void> cargarCanton() async {
    //Listado de Canton
    await listasPrecargadas
        .listaCanton(idProvinciaSeleccionado.toString())
        .then(
      (canton) {
        mapCanton = canton.items!.map((item) => item.toJson()).toList();
        mapDistrito = []; // Limpias distritos porque cambió el cantón
        // idCantonSeleccionado = 0; // Reset
        // idDistritoSeleccionado = 0; // Reset
        _loadingCanton = false;
      },
    );
  }

  Future<void> cargarDistrito() async {
    //Listado de distrito
    await listasPrecargadas
        .listaDistrito(
            idProvinciaSeleccionado.toString(), idCantonSeleccionado.toString())
        .then(
      (distrito) {
        mapDistrito = distrito.items!.map((item) => item.toJson()).toList();
        _loadingDistrito = false;
        //idDistritoSeleccionado = 0;
      },
    );
  }

  Future<void> traerSolicitud(String codsolicitud, String luminaria) async {
    CrudSolicitud crudSolicitud = CrudSolicitud();

    await crudSolicitud
        .traerSolicitud(codsolicitud, luminaria)
        .then((resp) async {
      Log.escribir('traerSolicitud:${resp.items!.toString()}');
      await procesarSolicitud(resp);
    });
  }

  Future<void> traerUltimaSolicitud(String codPoste) async {
    CrudSolicitud crudSolicitud = CrudSolicitud();

    await crudSolicitud.traerUtimaSolicitudAtendida(codPoste).then((resp) {
      procesarSolicitud(resp);
    });
  }

  Future<void> procesarSolicitud(VmSolicitud resp) async {
    Log.escribir('procesarSolicitud:${resp.items!.toString()}');
    setState(() {
      try {
        ItemSolicitud item = resp.items![0];
        mapSolicitud = item.toJson();

        mapSolicitud['estado'] = estado;
        mapSolicitud['numero_orden_trabajo'] = numero_orden_trabajo;

        //Cargamos el listado de controles de texto para los textformeditFiel
        mapSolicitud.forEach((key, value) {
          if (txtEditControllers.containsKey(key)) {
            txtEditControllers[key]!.text = value?.toString() ?? '';
          }
        });

        idTiposolicitudSelecionada =
            mapSolicitud["des_tipo_solicitud_st"] ?? '';

        Log.escribir(
            'TIPO SOLICITUD DB: ${mapSolicitud["des_tipo_solicitud_st"]})');

        idTipoAtencionSeleccionado = mapSolicitud["cod_tipo_atencion"] ?? 0;

        idProvinciaSeleccionado = mapSolicitud["cod_provincia"] ?? 0;
        idCantonSeleccionado = mapSolicitud["cod_canton"] ?? 0;
        idDistritoSeleccionado = mapSolicitud["cod_distrito"] ?? 0;
        idCuentaGasto = mapSolicitud["cod_cuenta_gasto"] ?? 0;
        idOrdenTrabajoContable = mapSolicitud["cod_otc"] ?? 0;

        posteSeleccionado = mapSolicitud["cod_poste"] ?? "SIN ASIGNAR";

        txtEditControllers[lblgeocodigo]!.text =
            '${mapSolicitud["latitud"] ?? ""},${mapSolicitud["longitud"] ?? ""}';

        if (txtEditControllers['fecha_insert'] != null) {
          if (txtEditControllers['fecha_insert']!.text != "") {
            txtEditControllers['fecha_insert']!.text = formatoFechaPantalla(
                fechaDateTime(
                    txtEditControllers['fecha_insert']!.text.toString()));
          }
        }

        cargosolicitud = true;
      } catch (e) {
        Log.escribir("Error en procesarSolicitud: ${e.toString()}");
      }
    });
  }

  Future<VmSolicitudMateriales> traerSolicitudMateriales(
      String codSolicitud, String instalados, String codPoste) async {
    CrudMateriales cls = CrudMateriales();
    VmSolicitudMateriales vm = VmSolicitudMateriales();

    //Listado de ordenes
    await cls.traerMaterialesSolicitud(codSolicitud, instalados, codPoste).then(
      (r) {
        if (r.items is List) {
          if (r.items!.isNotEmpty) {
            vm = r;
          }
        }
      },
    );

    return vm;
  }

  Future<VmRespuestaPost> guardarSolicitud() async {
    VmRespuestaPost vm = VmRespuestaPost(idInsertado: 0);

    //Las solicitudes de servicio tecnico solo se pueden editar , pero no crear , estas se crean en otro sistema
    if (!conexionInternet) {
      guardardblocal("PUT");
      return vm;
    }
    CrudSolicitud cls = CrudSolicitud();

    if (mapSolicitud['cod_solicitud'] != "") {
      await cls.actualizarSolicitud(mapSolicitud).then(
        (resp) {
          if (resp.idInsertado! > 0) {
            // BarraMensaje(context).Mensaje(lblinformacionactualizada);
            vm = resp;
          }
        },
      );
    }

    return vm;
  }

  Future<void> cargarCuentaGasto() async {
    CrudSolicitud producto = CrudSolicitud();
    //Listado de provincias
    await producto.traerCuentaGasto().then(
      (resp) {
        mapCuentaGasto = resp.items!.map((item) => item.toJson()).toList();
      },
    );
  }

  Future<void> cargarOrdenTrabajoContable() async {
    CrudSolicitud producto = CrudSolicitud();
    //Listado de provincias
    await producto.traerOrdenTrabajoContable().then(
      (resp) {
        mapTOC = resp.items!.map((item) => item.toJson()).toList();
      },
    );
  }

  Future<int> guardardblocal(String postput) async {
    final bd = db.instance;
    if (postput == "POST") {
      VmOrdenTrabajo ordenAsignada =
          vmOrdenTrabajoFromJson(listadosdblocal.first.siarOrdenTrabajo!);
      VmTipoSolicitud tipoSolicitud =
          vmTipoSolicitudFromJson(listadosdblocal.first.siarTipoSolicitud!);

      int idOrden = 0;
      String codSolicitudLocal = generarNumeroAleatorio();
      String desTipoAtencion = "";

      if (ordenAsignada.items!.isNotEmpty) {
        idOrden = ordenAsignada.items!
            .where((w) => w.estado == EstadosOrdenesTrabajo.ASI.name)
            .first
            .codOrdenTrabajo!;

        if (tipoSolicitud.items!.isNotEmpty) {
          desTipoAtencion = tipoSolicitud.items!
              .where((w) =>
                  w.codTipoSolicitud ==
                  int.parse(mapSolicitud['tipo_solicitud']))
              .first
              .desTipoSolicitud!;
        }

        mapSolicitud["cod_solicitud"] = int.parse(codSolicitudLocal);
        mapSolicitud["numero_ticket"] = 'LOCAL-$codSolicitudLocal';
        mapSolicitud["cod_orden_trabajo"] = idOrden;
        mapSolicitud['estado'] = EstadosSolicitudes.REG.name;
        mapSolicitud['fecha_insert'] = DateTime.now().toUtc().toIso8601String();
        mapSolicitud['des_tipo_solicitud'] = desTipoAtencion;
      }

      Map<String, dynamic> datos = {
        "COD_SOLICITUD": codSolicitudLocal,
        "COD_ORDEN_TRABAJO": idOrden,
        "JSON": jsonEncode(mapSolicitud),
        "POST_PUT": "POST",
        "ESTADO": "PENDIENTE",
        "USUARIO_INSERT": usuarioLogin
      };

      var r = await bd.insertar(datos, "SIAR_SOLICITUDES");
      if (r > 0) {
        //Solo si realiza el insert, se actualiza el no de solicitud
        cod_solicitud = codSolicitudLocal;
        return r;
      } else {
        return 0;
      }
    } else {
      Map<String, dynamic> datos = {"JSON": jsonEncode(mapSolicitud)};

      Log.escribir('GUARDAR SOLILCITUD OFFLINE: ' + mapSolicitud.toString());

      return bd.actualizar(
          "SIAR_SOLICITUDES", datos, "COD_SOLICITUD", cod_solicitud);
    }
  }
}
