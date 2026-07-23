import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jasec/class/crudsolicitud.dart';
import 'package:jasec/class/listasprecargadas.dart';
import 'package:jasec/model/vmsolicitud.dart';
import 'package:jasec/screen/archivossolicitud.dart';
import 'package:jasec/screen/frmevaluacionrequisitostecnicos.dart';
import 'package:jasec/screen/frmvinculacionusuariored.dart';
import 'package:jasec/screen/screen.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:jasec/utilidades/utilidades.dart';
import 'package:jasec/widget/barramensaje.dart';
import 'package:jasec/widget/widget.dart';

class HistorialAtencionSolicitud extends StatefulWidget {
  final String codPoste;
  final String numero_orden_trabajo;
  final String estado;

  const HistorialAtencionSolicitud({
    super.key,
    required this.codPoste,
    required this.numero_orden_trabajo,
    required this.estado,
  });

  @override
  State<HistorialAtencionSolicitud> createState() =>
      _HistorialAtencionSolicitudState();
}

class _HistorialAtencionSolicitudState
    extends State<HistorialAtencionSolicitud> {
  ListasPrecargadas listasPrecargadas = ListasPrecargadas();

  final Map<String, TextEditingController> txtEditControllers = {};

  bool _loadingCanton = false;
  bool _loadingDistrito = false;
  bool _loadingTipoServicio = false;

  bool cargosolicitud = false;

  File? imagen;

  int idTipoSolicitudSelecionado = 0;
  int idTipoServicioSelecionado = 0;
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

  String luminaria =
      (perfilUsuario == PerfilUsuario.AlumbradoPublicoLuminaria) ? "S" : "N";

  String numero_orden_trabajo = "";

  String estado = "";

  String codPoste = "";

  // ignore: non_constant_identifier_names
  String cod_solicitud = "";

  int? panelSeleccionado;
  List<bool> _isExpandedList = [true, false, false, false, false, false];
  String? selectedValue;

  List<Map<String, dynamic>> mapProvincia = [];
  List<Map<String, dynamic>> mapCanton = [];
  List<Map<String, dynamic>> mapDistrito = [];
  List<Map<String, dynamic>> mapTipoServicio = [];
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

  double wancho = 50, halto = 50;
  double bwidth = 200, bheight = 150;

  Map<String, dynamic> mapSolicitud = {
    "cod_solicitud": "",
    "numero_orden_trabajo": "",
    "numero_ticket": "",
    "tipo_solicitud": "",
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
    "cod_poste": "",
    "usuario_insert": usuarioLogin,
    "fecha_insert": "",
    "ind_luminaria": "N",
    "ind_servicio_tecnico": "S",
    "estado": ""
  };

  @override
  void initState() {
    codPoste = widget.codPoste.toString();

    numero_orden_trabajo = widget.numero_orden_trabajo.toString();
    estado = widget.estado.toString();

    mapSolicitud['numero_orden_trabajo'] = numero_orden_trabajo;
    mapSolicitud['estado'] = estado;

    // mapEstadoOT.add({'cod_estado_orden': 1, 'desc_estado_orden': estado});

    for (var key in mapSolicitud.keys) {
      txtEditControllers[key] =
          TextEditingController(text: mapSolicitud[key]?.toString() ?? "");
    }

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!cargosolicitud) {
      traerSolicitud(widget.codPoste.toString(), luminaria).then((obj) async {
        await cargarTipoServicios();

        await cargarUbicacion();

        setState(() {});
      });
    }
  }

  @override
  void dispose() async {
    for (var controller in txtEditControllers.values) {
      controller.dispose();
    }
    super.dispose();

    /*if (mapSolicitud.isNotEmpty) {
      guardarSolicitud().then((R) {
        setState(() {});
      });
    }*/
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
                      habilitado: false,
                      controlador: txtEditControllers['numero_orden_trabajo'],
                      textoEtiqueta: lblnoordentrabajo,
                      propiedadFormulario: "numero_orden_trabajo",
                      valorFormulario: mapSolicitud)),
              Espacio(alto: 10),
              Expanded(
                  child: (!_loadingTipoServicio)
                      ? progresoCirculo()
                      : ListaSeleccion(
                          tamanoFuente: tamanoFuente8px,
                          textoEtiqueta: lbltiposervicio,
                          mapaDatos: mapTipoServicio,
                          idKey: "cod_tipo_servicio",
                          nameKey: "des_tipo_servicio",
                          selectedValue: (idTipoServicioSelecionado > 0)
                              ? idTipoServicioSelecionado
                              : null,
                          onChanged: (int? value) {
                            setState(() {
                              idTipoServicioSelecionado = value!;
                              mapSolicitud["cod_tipo_servicio"] = '$value';
                              print(value);
                            });
                          })),
              Espacio(alto: 10),
              Expanded(
                  child: ListaSeleccion(
                      textoEtiqueta: lblclaseservicio,
                      mapaDatos: mapClaseServicio,
                      idKey: "ID_CLASE_SERVICIO",
                      nameKey: "NOMBRE_CLASE_SERVICIO",
                      selectedValue: idClaseServicio,
                      onChanged: (int? value) {
                        setState(() {
                          idClaseServicio = value!;
                          mapSolicitud["ID_CLASE_SERVICIO"] = '$value';
                          print(value);
                        });
                      })),
              Espacio(alto: 10),
              Expanded(
                child: Expanded(
                    child: TextBoxForm(
                        habilitado: false,
                        texto: estado,
                        textoEtiqueta: lblestadoOT,
                        propiedadFormulario: "estado_orden",
                        valorFormulario: mapSolicitud)),
              ),
              Espacio(alto: 10),
              Expanded(
                  child: TextBoxForm(
                      controlador: txtEditControllers['fecha_insert'],
                      textoEtiqueta: lblfechasolicitud,
                      propiedadFormulario: "fecha_insert",
                      valorFormulario: mapSolicitud)),
            ],
          ),
          Espacio(alto: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextBoxForm(
                    controlador: txtEditControllers['observacion'],
                    lineas: 5,
                    tipo: TextInputType.multiline,
                    textoEtiqueta: lblobservaciones,
                    propiedadFormulario: "observacion",
                    valorFormulario: mapSolicitud),
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
                        AdjuntosSolicitud(llave: cod_solicitud),
                        lblarchivoadjuntoSolicitud);
                  }),
              Espacio(ancho: 50),
              /*
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
                      onTap: () {
                        adjuntarVideo();
                      },
                    ),
                    PopupMenuItem<String>(
                      value: lblarchivo,
                      child: Icon(Icons.file_open),
                      onTap: () {
                        adjuntarArchivo();
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
            */
            ],
          ),
          Espacio(alto: 10),
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(5),
              child: ExpansionPanelList(
                elevation: 2,
                expandedHeaderPadding: EdgeInsets.zero,
                expansionCallback: (index, isExpanded) {
                  setState(() {
                    _isExpandedList[index] = !_isExpandedList[index];

                    panelSeleccionado =
                        (panelSeleccionado == index) ? null : index;
                  });
                },
                children: [
                  // Panel 1: Datos del Solicitante
                  ExpansionPanel(
                    highlightColor: colorAzulSecundario,
                    backgroundColor: colorAcua,
                    headerBuilder: (context, isExpanded) {
                      String titulo = lbldatossolicitante +
                          '( Solicitud: ${mapSolicitud['numero_ticket']})';
                      return tituloExpansionPanel(titulo);
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
                                        txtEditControllers['identificacion'],
                                    textoEtiqueta:
                                        lblidentificaciondequienreporta,
                                    tipo: TextInputType.text,
                                    propiedadFormulario: 'identificacion',
                                    valorFormulario: mapSolicitud),
                              ),
                              Espacio(alto: 10),
                              Expanded(
                                child: TextBoxForm(
                                    controlador: txtEditControllers['nombre'],
                                    textoEtiqueta: lblnombereporta,
                                    tipo: TextInputType.text,
                                    propiedadFormulario: 'nombre',
                                    valorFormulario: mapSolicitud),
                              ),
                              Espacio(alto: 10),
                              Expanded(
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
                              ),
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

                  // Panel 2: Información Adicional
                  ExpansionPanel(
                    backgroundColor: colorAcua,
                    headerBuilder: (context, isExpanded) {
                      return tituloExpansionPanel(lblUbicacionSolicitada);
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
                              Espacio(ancho: 10),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    TextBoxForm(
                                      lectura: true,
                                      textoEtiqueta: lblnoposte,
                                      tipo: TextInputType.text,
                                      propiedadFormulario: 'cod_poste',
                                      valorFormulario: mapSolicitud,
                                      controlador:
                                          txtEditControllers['cod_poste'],
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
                                        /* Expanded(
                                          child: Boton(
                                              textoEtiqueta: lblhistorial,
                                              colorFondo: colorAzulPrimario,
                                              colorTexto: colorBlanco,
                                              onPressed: () {},
                                              tamanoFuente: tamanoFuente8px,
                                              bordenRedondeado: 10,
                                              tipoFuente: FontWeight.bold),
                                        ),
                                        Espacio(alto: 10),*/
                                        Expanded(
                                            child: Boton(
                                                textoEtiqueta: lblinstalado,
                                                colorFondo: colorAzulPrimario,
                                                colorTexto: colorBlanco,
                                                onPressed: () {},
                                                onLongPress: () {},
                                                tamanoFuente: tamanoFuente8px,
                                                bordenRedondeado: 10,
                                                tipoFuente: FontWeight.bold))
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

                  //Panel 3:
                  ExpansionPanel(
                    highlightColor: colorAzulSecundario,
                    backgroundColor: colorAcua,
                    headerBuilder: (context, isExpanded) {
                      return tituloExpansionPanel(lblfacturacion);
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
                                    textoEtiqueta: lblnumerocliente,
                                    mapaDatos: mapClientes,
                                    idKey: "ID_CLIENTE",
                                    nameKey: "NOMBRE_CLIENTE",
                                    selectedValue: idCantonSeleccionado,
                                    onChanged: (valor) {
                                      setState(() {
                                        idClienteSeleccionado = valor!;
                                      });
                                    }),
                              ),
                              Espacio(alto: 10),
                              Expanded(
                                child: ListaSeleccion(
                                    textoEtiqueta: lblpueblo,
                                    mapaDatos: mapPueblo,
                                    idKey: "ID_PUEBLO",
                                    nameKey: "NOMBRE_PUEBLO",
                                    selectedValue: idPuebloSeleccionado,
                                    onChanged: (valor) {
                                      setState(() {
                                        idPuebloSeleccionado = valor!;
                                      });
                                    }),
                              ),
                              Espacio(alto: 10),
                              Expanded(
                                child: TextBoxForm(
                                  textoEtiqueta: lblciclo,
                                  tipo: TextInputType.text,
                                  propiedadFormulario: 'CICLO',
                                  valorFormulario: mapSolicitud,
                                ),
                              ),
                            ],
                          ),
                          Espacio(alto: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: ListaSeleccion(
                                    textoEtiqueta: lbltarifa,
                                    mapaDatos: mapTarifa,
                                    idKey: "ID_TARIFA",
                                    nameKey: "NOMBRE_TARIFA",
                                    selectedValue: idTarifaSeleccionada,
                                    onChanged: (valor) {
                                      setState(() {
                                        idTarifaSeleccionada = valor!;
                                      });
                                    }),
                              ),
                              Espacio(alto: 10),
                              Expanded(
                                child: ListaSeleccion(
                                    textoEtiqueta: lblnodeposito,
                                    mapaDatos: mapNoDeposito,
                                    idKey: "ID_DEPOSITO",
                                    nameKey: "NOMBRE_DEPOSITO",
                                    selectedValue: idNoDepositoSeleccionada,
                                    onChanged: (valor) {
                                      setState(() {
                                        idNoDepositoSeleccionada = valor!;
                                      });
                                    }),
                              ),
                              Espacio(alto: 10),
                              Expanded(
                                child: TextBoxForm(
                                  textoEtiqueta: lblmonto,
                                  tipo: TextInputType.number,
                                  propiedadFormulario: 'MONTO',
                                  valorFormulario: mapSolicitud,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    isExpanded: _isExpandedList[2],
                  ),

                  //Panel 4:
                  ExpansionPanel(
                    highlightColor: colorAzulSecundario,
                    backgroundColor: colorAcua,
                    headerBuilder: (context, isExpanded) {
                      return tituloExpansionPanel(lblatencioncuenta);
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
                                    idKey: "ID_TIPO_ATENCION",
                                    nameKey: "NOMBRE_TIPO_ATENCION",
                                    selectedValue: idTipoAtencionSeleccionado,
                                    onChanged: (valor) {
                                      setState(() {
                                        idTipoAtencionSeleccionado = valor!;
                                      });
                                    }),
                              ),
                              Espacio(alto: 10),
                              Expanded(
                                child: ListaSeleccion(
                                    textoEtiqueta: lbltipocuenta,
                                    mapaDatos: mapTipoCuenta,
                                    idKey: "ID_TIPO_CUENTA",
                                    nameKey: "NOMBRE_TIPO_CUENTA",
                                    selectedValue: idTipoCuentaSeleccionado,
                                    onChanged: (valor) {
                                      setState(() {
                                        idTipoCuentaSeleccionado = valor!;
                                      });
                                    }),
                              ),
                              Espacio(alto: 10),
                              Expanded(
                                child: TextBoxForm(
                                  textoEtiqueta: lblnocuenta,
                                  tipo: TextInputType.text,
                                  propiedadFormulario: 'NO_CUENTA',
                                  valorFormulario: mapSolicitud,
                                ),
                              ),
                            ],
                          ),
                          Espacio(alto: 10),
                        ],
                      ),
                    ),
                    isExpanded: _isExpandedList[3],
                  ),

                  //Panel 5:
                  ExpansionPanel(
                    highlightColor: colorAzulSecundario,
                    backgroundColor: colorAcua,
                    headerBuilder: (context, isExpanded) {
                      return tituloExpansionPanel(lbllocalizacion);
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
                                    textoEtiqueta: lblcalle,
                                    mapaDatos: mapCalle,
                                    idKey: "ID_CALLE",
                                    nameKey: "NOMBRE_CALLE",
                                    selectedValue: idCalleSeleccionado,
                                    onChanged: (valor) {
                                      setState(() {
                                        idCalleSeleccionado = valor!;
                                      });
                                    }),
                              ),
                              Espacio(alto: 10),
                              Expanded(
                                child: ListaSeleccion(
                                    textoEtiqueta: lblcuentaN,
                                    mapaDatos: mapCuenta,
                                    idKey: "ID_CUENTA",
                                    nameKey: "NOMBRE_CUENTA",
                                    selectedValue: idCuentaSeleccionado,
                                    onChanged: (valor) {
                                      setState(() {
                                        idCuentaSeleccionado = valor!;
                                      });
                                    }),
                              ),
                              Espacio(alto: 10),
                              Expanded(
                                child: TextBoxForm(
                                  textoEtiqueta: lblgeocodigo,
                                  tipo: TextInputType.text,
                                  propiedadFormulario: 'GEOCODIGO',
                                  valorFormulario: mapSolicitud,
                                ),
                              ),
                              Espacio(alto: 10),
                              Expanded(
                                child: TextBoxForm(
                                  textoEtiqueta: lblnoposte,
                                  tipo: TextInputType.text,
                                  propiedadFormulario: 'CODIGO_POSTE',
                                  valorFormulario: mapSolicitud,
                                ),
                              ),
                            ],
                          ),
                          Espacio(alto: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: ListaSeleccion(
                                    textoEtiqueta: lblnruta,
                                    mapaDatos: mapRuta,
                                    idKey: "ID_RUTA",
                                    nameKey: "NOMBRE_RUTA",
                                    selectedValue: idRutaSeleccionado,
                                    onChanged: (valor) {
                                      setState(() {
                                        idRutaSeleccionado = valor!;
                                      });
                                    }),
                              ),
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
                      return Center(
                        child: tituloExpansionPanel(lblformularios),
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
                                          FrmEvaluacionRequisitosTecnicos(
                                              "1", cod_solicitud),
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
                                          FrmEvaluacionRequisitosTecnicos(
                                              "5", cod_solicitud),
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
                ],
              ),
            ),
          ),
          Espacio(alto: 25),
          /*
          Row(
            children: [
              Expanded(
                  child: Boton(
                textoEtiqueta: lblchekin,
                colorFondo: colorAzulPrimario,
                colorTexto: colorBlanco,
                onPressed: () {},
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
                    BarraMensaje clsMensaje = BarraMensaje(context);

                    clsMensaje.Mensaje(
                        "Ubicación actual, Latitude: ${PosGPSGlobal!.latitude.toString()} , Longitud ${PosGPSGlobal!.longitude.toString()}");
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
                  String IdSolicitud =
                      mapSolicitud['cod_solicitud']!.toString();
                  var respuesta =
                      await dialogoSolicitudNoEfectiva(context, IdSolicitud);
                  if (respuesta == true) {
                    MostrarWidgetEnDialogo(
                        context,
                        FrmSolicitudNoEfectiva(IdSolicitud),
                        lblmotivoderechazo);
                  }
                },
              )),
              Espacio(alto: 10),
              Expanded(
                  child: Boton(
                textoEtiqueta: lblefectiva,
                colorFondo: colorVerdePrimario,
                colorTexto: colorBlanco,
                onPressed: () {},
              ))
            ],
          )
       */
        ],
      ),
    );
  }

  Future<void> adjuntarImagen() async {
    DialogoProgreso(context, lblprocesando, lblprocesando, Icons.network_check,
        widget: Center(
            child: SizedBox(width: 200, height: 200, child: progresoCirculo())),
        cerrar: false);
    try {
      await cargarFotografiaSolicitud(cod_solicitud,
              origenFotografia: ImageSource.camera)
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
      await cargarVideoSolicitud(cod_solicitud).then((resp) async {
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
      await cargarVideoSolicitud(cod_solicitud).then((resp) async {
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
        cargarDistrito().then((distrito) {
          setState(() {});
        });
      });
    });
  }

  Future<void> cargarTipoServicios() async {
    //Listado de provincias
    await listasPrecargadas.listaTipoServicio(alumbrado: luminaria).then(
      (tiposervicio) {
        setState(() {
          mapTipoServicio =
              tiposervicio.items!.map((item) => item.toJson()).toList();
          _loadingTipoServicio = true;
        });
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

  Future<void> traerSolicitud(String codPoste, String luminaria) async {
    CrudSolicitud crudSolicitud = CrudSolicitud();

    await crudSolicitud.traerUtimaSolicitudAtendida(codPoste).then((resp) {
      setState(() {
        ItemSolicitud item = resp.items![0];
        mapSolicitud = item.toJson();
        cod_solicitud = mapSolicitud['cod_solicitud'].toString();
        mapSolicitud['estado'] = estado;
        mapSolicitud['numero_orden_trabajo'] = numero_orden_trabajo;

        //Cargamos el listado de controles de texto para los textformeditFiel
        mapSolicitud.forEach((key, value) {
          if (txtEditControllers.containsKey(key)) {
            txtEditControllers[key]!.text = value?.toString() ?? '';
          }
        });

        idTipoServicioSelecionado = mapSolicitud["tipo_solicitud"];

        idProvinciaSeleccionado = mapSolicitud["cod_provincia"];
        idCantonSeleccionado = mapSolicitud["cod_canton"];
        idDistritoSeleccionado = mapSolicitud["cod_distrito"];

        cargosolicitud = true;
      });
    });
  }

  /* Future<VmRespuestaPost> guardarSolicitud() async {
    VmRespuestaPost vm = VmRespuestaPost();
    CrudSolicitud cls = CrudSolicitud();

    if (mapSolicitud['cod_solicitud'] != "") {
      await cls.actualizarSolicitud(mapSolicitud).then(
        (resp) {
          if (resp.idInsertado! > 0) {
            BarraMensaje(context).Mensaje(lblinformacionactualizada);
            vm = resp;
          }
        },
      );
    }

    return vm;
  }*/
}
