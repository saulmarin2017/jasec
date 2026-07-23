import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jasec/class/crudsolicitud.dart';
import 'package:jasec/class/listasprecargadas.dart';
import 'package:jasec/screen/archivossolicitud.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:jasec/utilidades/utilidades.dart';
import 'package:jasec/widget/barramensaje.dart';
import 'package:jasec/widget/widget.dart';

class HistorialSolicitudAlumbradoPublico extends StatefulWidget {
  final String codPoste;

  const HistorialSolicitudAlumbradoPublico({super.key, required this.codPoste});

  @override
  State<HistorialSolicitudAlumbradoPublico> createState() =>
      _HistorialSolicitudAlumbradoPublicoState();
}

class _HistorialSolicitudAlumbradoPublicoState
    extends State<HistorialSolicitudAlumbradoPublico> {
  ListasPrecargadas listasPrecargadas = ListasPrecargadas();

  final Map<String, TextEditingController> txtEditControllers = {};

  bool _loadingCanton = false;
  bool _loadingDistrito = false;
  bool _loadingTipoServicio = false;

  bool _cargosolicitud = false;

  File? imagen;

  int idTipoSolicitudSelecionado = 0;
  int idProvinciaSeleccionado = 0;
  int idCantonSeleccionado = 0;
  int idDistritoSeleccionado = 0;

  String cod_solicitud = "";

  final List<bool> _expanded = [false, false];

  List<Map<String, dynamic>> mapTipoServicio = [];
  List<Map<String, dynamic>> mapProvincia = [];
  List<Map<String, dynamic>> mapCanton = [];
  List<Map<String, dynamic>> mapDistrito = [];

  String luminaria =
      (perfilUsuario == PerfilUsuario.AlumbradoPublicoLuminaria) ? "S" : "N";

  Map<String, dynamic> mapSolicitud = {
    "cod_orden": "",
    "cod_solicitud": "",
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
    "ind_luminaria": "S",
    "ind_servicio_tecnico": "N",
    "estado": "REGISTRADA"
  };

  @override
  void initState() {
    if (widget.codPoste.isNotEmpty) {
      widget.codPoste;
    }

    super.initState();

    for (var key in mapSolicitud.keys) {
      txtEditControllers[key] =
          TextEditingController(text: mapSolicitud[key]?.toString() ?? "");
    }

    cargarTipoSolicitud();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();

    if (!_cargosolicitud) {
      traerSolicitud(widget.codPoste, luminaria).then((obj) async {
        await cargarUbicacion();
      });
    } else {
      cargarProvincia();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cod_solicitud.isEmpty) {
      return Center(
          child: Etiqueta(
        texto: lblNoData,
        color: colorRojoPrimario,
      ));
    }

    return Padding(
      padding: EdgeInsets.all(5),
      child: Form(
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(
                  flex: 1,
                  child: TextBoxForm(
                    controlador: txtEditControllers['numero_ticket'],
                    textoEtiqueta: lblTicket,
                    tipo: TextInputType.text,
                    negrilla: FontWeight.bold,
                    propiedadFormulario: 'numero_ticket',
                    valorFormulario: mapSolicitud,
                    texto: mapSolicitud['numero_ticket'],
                  )),
              Espacio(alto: 10),
              Expanded(
                flex: 2,
                child: SizedBox(
                    child: _loadingTipoServicio
                        ? progresoCirculo()
                        : ListaSeleccion(
                            tamanoFuente: tamanoFuente12px,
                            textoEtiqueta: lbltiposervicio,
                            mapaDatos: mapTipoServicio,
                            idKey: "cod_tipo_servicio",
                            nameKey: "des_tipo_servicio",
                            selectedValue: (idTipoSolicitudSelecionado > 0)
                                ? idTipoSolicitudSelecionado
                                : null,
                            onChanged: (int? value) {
                              setState(() {
                                idTipoSolicitudSelecionado = value!;
                                mapSolicitud["cod_tipo_servicio"] = '$value';
                              });
                            })),
              )
            ]),
            Espacio(alto: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: TextBoxForm(
                        controlador: txtEditControllers['observacion'],
                        textoEtiqueta: lblobservaciones,
                        lineas: 5,
                        tipo: TextInputType.multiline,
                        propiedadFormulario: 'observacion',
                        valorFormulario: mapSolicitud))
              ],
            ),
            Espacio(alto: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    flex: 2, child: Etiqueta(texto: lblarchivoseleccionado)),
                Espacio(ancho: 50),
                (cod_solicitud.isNotEmpty)
                    ? Boton(
                        textoEtiqueta: lblveradjuntos,
                        colorTexto: colorVerdeSecundario,
                        onPressed: () async {
                          MostrarWidgetEnDialogo(
                              context,
                              AdjuntosSolicitud(llave: cod_solicitud),
                              lblarchivoadjuntoSolicitud);
                        })
                    : Text(''),
                /* Espacio(ancho: 50),
                Expanded(
                  child: (cod_solicitud.isEmpty)
                      ? Text("")
                      : PopupMenuButton<String>(
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
                              onTap: () {
                                adjuntarImagen();
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
                                  borderRadius: BorderRadius.circular(
                                      0), // Bordes redondeados
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
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(5),
                child: ExpansionPanelList(
                  elevation: 2,
                  expandedHeaderPadding: EdgeInsets.zero,
                  expansionCallback: (index, isExpanded) {
                    setState(() {
                      _expanded[index] = !_expanded[index];
                    });
                  },
                  children: [
                    // Panel 1: Datos del Solicitante
                    ExpansionPanel(
                      highlightColor: colorAzulSecundario,
                      backgroundColor: colorAcua,
                      headerBuilder: (context, isExpanded) {
                        return ListTile(
                          title: Etiqueta(
                            texto: lbldatossolicitante,
                            tipo: FontWeight.bold,
                            color: colorBlanco,
                            tamanoFuente: tamanoFuenteDefecto,
                          ),
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
                                        txtEditControllers['identificacion'],
                                    textoEtiqueta:
                                        lblidentificaciondequienreporta,
                                    tipo: TextInputType.text,
                                    propiedadFormulario: 'identificacion',
                                    valorFormulario: mapSolicitud,
                                  ),
                                ),
                                Espacio(alto: 10),
                                Expanded(
                                  child: TextBoxForm(
                                    controlador: txtEditControllers['nombre'],
                                    textoEtiqueta: lblnombereporta,
                                    tipo: TextInputType.text,
                                    propiedadFormulario: 'nombre',
                                    valorFormulario: mapSolicitud,
                                  ),
                                ),
                                Espacio(alto: 10),
                                Expanded(
                                  child: TextBoxForm(
                                    controlador:
                                        txtEditControllers['primer_apellido'],
                                    textoEtiqueta: lblprimerapellido,
                                    tipo: TextInputType.name,
                                    propiedadFormulario: 'primer_apellido',
                                    valorFormulario: mapSolicitud,
                                  ),
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
                                    controlador:
                                        txtEditControllers['telefono_1'],
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
                                    controlador:
                                        txtEditControllers['telefono_2'],
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
                                    controlador:
                                        txtEditControllers['telefono_3'],
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
                      isExpanded: _expanded[0],
                    ),

                    // Panel 2: Información Adicional
                    ExpansionPanel(
                      backgroundColor: colorAcua,
                      headerBuilder: (context, isExpanded) {
                        return ListTile(
                          title: Etiqueta(
                            texto: lblUbicacionSolicitada,
                            tipo: FontWeight.bold,
                            color: colorBlanco,
                            tamanoFuente: tamanoFuenteDefecto,
                          ),
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
                                              cargarDistrito().then((r) {
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
                            Espacio(alto: 25),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: TextBoxForm(
                                      controlador:
                                          txtEditControllers['otras_senas'],
                                      textoEtiqueta: lblreferenciaubicacion,
                                      lineas: 4,
                                      tipo: TextInputType.multiline,
                                      propiedadFormulario: 'otras_senas',
                                      valorFormulario: mapSolicitud),
                                ),
                                Espacio(ancho: 100),
                                Expanded(
                                  flex: 1,
                                  child: TextBoxForm(
                                    lectura: true,
                                    controlador:
                                        txtEditControllers['cod_poste'],
                                    textoEtiqueta: lblnoposte,
                                    tipo: TextInputType.text,
                                    propiedadFormulario: 'cod_poste',
                                    valorFormulario: mapSolicitud,
                                  ),
                                ),
                              ],
                            ),
                            Espacio(ancho: 50),
                          ],
                        ),
                      ),
                      isExpanded: _expanded[1],
                    ),
                  ],
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              spacing: 10,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Spacer(),
                Expanded(
                    child: Boton(
                  textoEtiqueta: lblcancelar,
                  colorTexto: colorBlanco,
                  onPressed: () {
                    Navigator.popAndPushNamed(context, "inicio", arguments: {
                      lblopcionprincipal: 1,
                      lblnombreopcion: lblMenu,
                      lblllave: 0,
                      lblimagenopcion: urlimagendefecto
                    });
                  },
                )),
                /*Expanded(
                    child: Boton(
                  textoEtiqueta: lblguardar,
                  colorTexto: colorBlanco,
                  onPressed: () async {
                    //Loading minetras autentica
                    DialogoProgreso(context, lblprocesando, lblprocesando,
                        Icons.network_check,
                        widget: SizedBox(
                          width: 100,
                          height: 150,
                          child: Loading(),
                        ),
                        cerrar: false);

                    try {
                      await guardarSolicitud();
                    } finally {
                      Navigator.of(context).pop();
                    }
                  },
                )),
                Espacio(alto: 10),*/
              ],
            ),
            Espacio(alto: 25),
          ],
        ),
      ),
    );
  }

  void adjuntarImagen() async {
    //Loading minetras autentica
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
      // Siempre cerrar el loading
      Navigator.of(context).pop();
    }
  }

  void adjuntarArchivo() async {
    //Loading minetras autentica
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
      // Siempre cerrar el loading
      Navigator.of(context).pop();
    }
  }

  void adjuntarVideo() async {
    //Loading minetras autentica
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
      // Siempre cerrar el loading
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

  Future<void> cargarTipoSolicitud() async {
    //Listado de Tipos de Solicitud/Servicio
    await listasPrecargadas.listaTipoServicio(alumbrado: luminaria).then(
      (tiposervicio) {
        setState(() {
          mapTipoServicio =
              tiposervicio.items!.map((item) => item.toJson()).toList();
          _loadingTipoServicio = false;
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
        if (resp.items!.isNotEmpty) {
          mapSolicitud = resp.items![0].toJson();

          cod_solicitud = mapSolicitud['cod_solicitud'].toString();

          //Cargamos el listado de controles de texto para los textformeditFiel
          mapSolicitud.forEach((key, value) {
            if (txtEditControllers.containsKey(key)) {
              txtEditControllers[key]!.text = value?.toString() ?? '';
            }
          });

          idTipoSolicitudSelecionado = mapSolicitud["tipo_solicitud"];

          idProvinciaSeleccionado = mapSolicitud["cod_provincia"];
          idCantonSeleccionado = mapSolicitud["cod_canton"];
          idDistritoSeleccionado = mapSolicitud["cod_distrito"];
        }
      });

      _cargosolicitud = true;
    });
  }

  Future<void> guardarSolicitud() async {
    CrudSolicitud cls = CrudSolicitud();

    if (cod_solicitud.isEmpty) {
      await cls.guardarSolicitud(mapSolicitud).then(
        (resp) {
          if (resp.idInsertado! > 0) {
            setState(() {
              cod_solicitud = resp.idInsertado.toString();
              mapSolicitud['cod_solicitud'] = cod_solicitud;
            });
          }
        },
      );

      //Luego de crear la solicitud de alumbrado publico nos vamos a las ordenes de trabajo
      Navigator.popAndPushNamed(context, "inicio", arguments: {
        lblopcionprincipal: 4,
        lblnombreopcion: lblordenestrabajo,
        lblllave: 0,
        lblimagenopcion: urlimagenordenes
      });
    } else {
      await cls.actualizarSolicitud(mapSolicitud).then(
        (resp) {
          if (resp.idInsertado! > 0) {
            BarraMensaje(context).Mensaje(lblinformacionactualizada);
          }
        },
      );
    }

    //return vm;
  }
}
