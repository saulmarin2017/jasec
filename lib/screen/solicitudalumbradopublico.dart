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
import 'package:jasec/model/vmsolicitud.dart';
import 'package:jasec/model/vmsolicitudmaterial.dart';
import 'package:jasec/model/vmtiposolicitud.dart';
import 'package:jasec/screen/archivossolicitud.dart';
import 'package:jasec/screen/listadomaterialesposte.dart';
import 'package:jasec/screen/agregarmaterialessolicitud.dart';
import 'package:jasec/screen/solicitudnoefectiva.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:jasec/utilidades/utilidades.dart';
import 'package:jasec/widget/barramensaje.dart';
import 'package:jasec/widget/lineahoritzontal.dart';
import 'package:jasec/widget/widget.dart';

class SolicitudAlumbradoPublico extends StatefulWidget {
  final String codSolicitud;
  final String codOrdenTrabajo;
  final String modo;
  final String codPoste;

  const SolicitudAlumbradoPublico(
      {super.key,
      required this.codSolicitud,
      required this.modo,
      required this.codOrdenTrabajo,
      this.codPoste = ""});

  @override
  State<SolicitudAlumbradoPublico> createState() =>
      _SolicitudAlumbradoPublicoState();
}

class _SolicitudAlumbradoPublicoState extends State<SolicitudAlumbradoPublico> {
  ListasPrecargadas listasPrecargadas = ListasPrecargadas();

  final _formKey = GlobalKey<FormState>();

  final Map<String, TextEditingController> txtEditControllers = {};

  bool _loadingCanton = false;
  bool _loadingDistrito = false;
  bool _loadingTipoSolicitud = false;

  bool _cargosolicitud = false;

  File? imagen;

  int idTipoServicioSelecionado = 0;
  int idProvinciaSeleccionado = 0;
  int idCantonSeleccionado = 0;
  int idDistritoSeleccionado = 0;
  int idTipoAtencionSeleccionado = 0;
  int idTipoSolicitudSeleccionado = 0;
  int idTipoCuenta = 0;
  int idCuentaGasto = 0;
  int idOrdenTrabajoContable = 0;

  String cod_solicitud = "";
  String posteSeleccionado = "";

  final List<bool> _expanded = [true, false, false, false, false];

  List<Map<String, dynamic>> mapTipoServicio = [];
  List<Map<String, dynamic>> mapTipoAtencion = [];
  List<Map<String, dynamic>> mapTipoSolicitud = [];
  List<Map<String, dynamic>> mapProvincia = [];
  List<Map<String, dynamic>> mapCanton = [];
  List<Map<String, dynamic>> mapDistrito = [];
  List<Map<String, dynamic>> mapTipoCuenta = [];
  List<Map<String, dynamic>> mapTOC = [];
  List<Map<String, dynamic>> mapCuentaGasto = [];
  VmPoste mapPostes = VmPoste();

  Map<String, dynamic> mapSolicitud = {
    "cod_orden_trabajo": "",
    "cod_solicitud": "",
    "numero_ticket": "",
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
    "ind_servicio_tecnico": "N"
  };

  VmSolicitudMateriales vmMaterialesRetirados = VmSolicitudMateriales();
  VmSolicitudMateriales vmMaterialesInsertados = VmSolicitudMateriales();

  @override
  void initState() {
    if (widget.codSolicitud.isNotEmpty && widget.codSolicitud != "0") {
      cod_solicitud = widget.codSolicitud;
    }

    super.initState();

    for (var key in mapSolicitud.keys) {
      txtEditControllers[key] =
          TextEditingController(text: mapSolicitud[key]?.toString() ?? "");
    }
  }

  @override
  void dispose() {
    if (widget.modo != "A") {
      if (mapSolicitud['estado'] == EstadosSolicitudes.REG.name) {
        guardarSolicitud();
      }
    }

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_cargosolicitud && cod_solicitud.isNotEmpty) {
      if (widget.codPoste.isEmpty) {
        traerSolicitud(widget.codSolicitud, luminaria).then((obj) async {
          await cargarUbicacion().then((r) async {
            await procesarListados();
          });
        });
      } else {
        traerUltimaSolicitud(widget.codPoste).then((obj) async {
          await cargarUbicacion().then((r) async {
            await procesarListados();
          });
        });
      }
    } else {
      cargarProvincia().then((r) async {
        await procesarListados();
      });
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(
                  flex: 1,
                  child: TextBoxForm(
                    habilitado: false,
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
                    child: !_loadingTipoSolicitud
                        ? progresoCirculo()
                        : ListaSeleccion(
                            tamanoFuente: tamanoFuente12px,
                            textoEtiqueta: lbltiposolicitud,
                            mapaDatos: mapTipoSolicitud,
                            idKey: "cod_tipo_solicitud",
                            nameKey: "des_tipo_solicitud",
                            selectedValue: (idTipoSolicitudSeleccionado > 0)
                                ? idTipoSolicitudSeleccionado
                                : null,
                            onChanged: (int? value) {
                              setState(() {
                                idTipoSolicitudSeleccionado = value!;
                                mapSolicitud["tipo_solicitud"] = '$value';
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return '$lbltiposolicitud $lblcamporequerido';
                              }
                              return null;
                            },
                          )),
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
                (cod_solicitud.isNotEmpty && conexionInternet)
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
                Espacio(ancho: 50),
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
                          child: (conexionInternet)
                              ? ElevatedButton(
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
                                  ))
                              : Text(""),
                        ),
                ),
              ],
            ),
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(5),
                child: ExpansionPanelList(
                  elevation: 2,
                  expandedHeaderPadding: EdgeInsets.zero,
                  expansionCallback: (index, isExpanded) async {
                    setState(() {
                      _expanded[index] = !_expanded[index];
                    });

                    //Se carga la data al expandirse la seccion Materiales Retirados/ index=3
                    if (index == 3 && _expanded[index]) {
                      vmMaterialesRetirados = await traerMaterialesSolicitud(
                          cod_solicitud, "N", mapSolicitud['cod_poste']);
                      setState(() {});
                    }

                    //Se carga la data al exandirse la seccion Materiales Instalados
                    if (index == 4 && _expanded[index]) {
                      vmMaterialesInsertados = await traerMaterialesSolicitud(
                          cod_solicitud, "S", mapSolicitud['cod_poste']);
                      setState(() {});
                    }
                  },
                  children: listaPaneles(),
                ),
              ),
            ),
            (widget.modo == "A")
                ? Row(
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
                          Navigator.popAndPushNamed(context, "inicio",
                              arguments: {
                                lblopcionprincipal: 1,
                                lblnombreopcion: lblMenu,
                                lblllave: 0,
                                lblimagenopcion: urlimagendefecto
                              });
                        },
                      )),
                      Expanded(
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
                            if (_formKey.currentState!.validate()) {
                              await guardarSolicitud();
                            }
                          } finally {
                            Navigator.of(context).pop();
                          }
                        },
                      )),
                      Espacio(alto: 10),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                          child: Boton(
                        textoEtiqueta: lblchekin,
                        colorFondo: colorAzulPrimario,
                        colorTexto: colorBlanco,
                        onPressed: () async {
                          if (await existeChekin()) {
                            BarraMensaje(context).Mensaje(lblchekinprevio,
                                colorFondo: colorAmarrillo,
                                colorFuente: colorBlanco);
                            return;
                          } else {
                            await checkIn();
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
                                  abrirURLGPS(PosGPSGlobal!.latitude,
                                      PosGPSGlobal!.longitude);
                                }
                              })),
                      Spacer(),
                      Expanded(
                          child: Boton(
                        textoEtiqueta: lblnoefectiva,
                        colorFondo: colorRojoPrimario,
                        colorTexto: colorBlanco,
                        onPressed: () async {
                          String IdSolicitud =
                              mapSolicitud['cod_solicitud']!.toString();

                          await dialogoSolicitudNoEfectiva(context, IdSolicitud)
                              .then((x) {
                            BarraMensaje(context).Mensaje(
                                lblactualizomotivorechazo,
                                colorFuente: colorVerdePrimario);
                          });

                          await actualizarEstadoSolicitud(
                              EstadosSolicitudes.NOE.name);

                          /*MostrarWidgetEnDialogo(
                                context,
                                FrmSolicitudNoEfectiva(IdSolicitud),
                                lblmotivoderechazo);*/
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
                          await actualizarEstadoSolicitud(
                              EstadosSolicitudes.EFE.name);
                        },
                      ))
                    ],
                  ),
            Espacio(alto: 25),
          ],
        ),
      ),
    );
  }

  Future<void> checkIn() async {
    CrudSolicitud cls = CrudSolicitud();
    Map<String, dynamic> map = {
      "cod_solicitud": cod_solicitud,
      "cod_orden_trabajo": mapSolicitud["cod_orden_trabajo"],
      "desc_tiempo_atencion": "Inicio de mantenimiento"
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
    } else {
      BarraMensaje(context).Mensaje("Aun no se realiza el proceso de Chek In",
          colorFuente: colorRojoPrimario);
    }
  }

  Future<void> actualizarEstadoSolicitud(String estado) async {
    CrudSolicitud cls = CrudSolicitud();
    Map<String, dynamic> map = {
      "cod_solicitud": cod_solicitud,
      "estado": estado
    };

    await cls.actualizarEstadoSolicitud(map).then((resp) {
      if (resp.idInsertado! > 0) {
        BarraMensaje(context).Mensaje(lblactualizoestadoSolicitud);
      }
    });
  }

  Future<bool> existeChekin() async {
    var codTiempoAtencion = await getPreferencia(cod_solicitud);

    if (codTiempoAtencion.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  void adjuntarImagen() async {
    //Loading minetras autentica
    DialogoProgreso(context, lblprocesando, lblprocesando, Icons.network_check,
        widget: Center(
            child: SizedBox(width: 200, height: 200, child: progresoCirculo())),
        cerrar: false);
    try {
      await cargarFotografiaSolicitud(cod_solicitud,
              origenFotografia: ImageSource.camera,
              nombreSujerido: 'Solicitud$cod_solicitud')
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
      await cargarVideoSolicitud(cod_solicitud,
              nombreSujerido: 'Solicitud$cod_solicitud')
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

  Future<void> cargarUbicacion() async {
    await cargarProvincia().then((provincia) {
      cargarCanton().then((canton) {
        cargarDistrito().then((distrito) {
          setState(() {});
        });
      });
    });
  }

  Future<void> cargarTipoServicio() async {
    //Listado de Tipos de Solicitud/Servicio
    await listasPrecargadas.listaTipoServicio(alumbrado: luminaria).then(
      (tiposervicio) {
        mapTipoServicio =
            tiposervicio.items!.map((item) => item.toJson()).toList();
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

  Future<void> cargarTipoSolicitud() async {
    //Listado de tipos de solicitud
    await listasPrecargadas.listaTipoSolicitud(alumbrado: luminaria).then(
      (resp) {
        setState(() {
          mapTipoSolicitud = resp.items!.map((item) => item.toJson()).toList();
          _loadingTipoSolicitud = true;
        });
      },
    );
  }

  Future<void> cargarProvincia() async {
    //Listado de provincias
    await listasPrecargadas.listaProvincias().then(
      (provincias) {
        setState(() {
          mapProvincia =
              provincias.items!.map((item) => item.toJson()).toList();
        });
      },
    );
  }

  Future<void> cargarCanton() async {
    //Listado de Canton
    await listasPrecargadas
        .listaCanton(idProvinciaSeleccionado.toString())
        .then(
      (canton) {
        setState(() {
          mapCanton = canton.items!.map((item) => item.toJson()).toList();
          mapDistrito = []; // Limpias distritos porque cambió el cantón
          // idCantonSeleccionado = 0; // Reset
          // idDistritoSeleccionado = 0; // Reset
          _loadingCanton = false;
        });
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
        setState(() {
          mapDistrito = distrito.items!.map((item) => item.toJson()).toList();
          _loadingDistrito = false;
          //idDistritoSeleccionado = 0;
        });
      },
    );
  }

  Future<void> traerSolicitud(String codsolicitud, String luminaria) async {
    CrudSolicitud crudSolicitud = CrudSolicitud();

    await crudSolicitud
        .traerSolicitud(codsolicitud, luminaria)
        .then((resp) async {
      procesarSolicitud(resp);
    });
  }

  Future<void> procesarSolicitud(VmSolicitud resp) async {
    setState(() {
      mapSolicitud = resp.items![0].toJson();

      //Cargamos el listado de controles de texto para los textformeditFiel
      mapSolicitud.forEach((key, value) {
        if (txtEditControllers.containsKey(key)) {
          txtEditControllers[key]!.text = value?.toString() ?? '';
        }
      });

      idTipoServicioSelecionado = (mapSolicitud["cod_tipo_servicio"] ?? 0);
      idTipoAtencionSeleccionado = (mapSolicitud["cod_tipo_atencion"] ?? 0);
      idTipoSolicitudSeleccionado = (mapSolicitud["tipo_solicitud"] ?? 0);

      idProvinciaSeleccionado = mapSolicitud["cod_provincia"] ?? 0;
      idCantonSeleccionado = mapSolicitud["cod_canton"] ?? 0;
      idDistritoSeleccionado = mapSolicitud["cod_distrito"] ?? 0;

      posteSeleccionado = mapSolicitud["cod_poste"] ?? "";

      idCuentaGasto = mapSolicitud["cod_cuenta_gasto"] ?? 0;
      idOrdenTrabajoContable = mapSolicitud["cod_otc"] ?? 0;

      _cargosolicitud = true;
    });
  }

  Future<void> traerUltimaSolicitud(String codPoste) async {
    CrudSolicitud crudSolicitud = CrudSolicitud();

    await crudSolicitud.traerUtimaSolicitudAtendida(codPoste).then((resp) {
      procesarSolicitud(resp);
    });
  }

  Future<void> guardarSolicitud() async {
    CrudSolicitud cls = CrudSolicitud();

    if (cod_solicitud.isEmpty) {
      if (!conexionInternet) {
        await guardardblocal("POST");
        return;
      }

      await cls.guardarSolicitud(mapSolicitud).then(
        (resp) {
          if (resp.idInsertado! > 0) {
            if (widget.modo == "A") {
              setState(() {
                cod_solicitud = resp.idInsertado.toString();
                mapSolicitud['cod_solicitud'] = cod_solicitud;
                BarraMensaje(context).Mensaje(lblInformacionGuardadaSolicitud,
                    colorFondo: colorVerdeSecundario, colorFuente: colorBlanco);
                traerSolicitud(cod_solicitud, luminaria);
              });
            }
          }
        },
      );
    } else {
      if (!conexionInternet) {
        await guardardblocal("PUT");
        return;
      }
      await cls.actualizarSolicitud(mapSolicitud).then(
        (resp) {
          if (resp.idInsertado! > 0) {
            if (widget.modo == "A") {
              BarraMensaje(context).Mensaje(lblinformacionactualizada,
                  colorFondo: colorVerdeSecundario, colorFuente: colorBlanco);
            }
          }
        },
      );
    }

    //return vm;
  }

  Future<void> procesarListados() async {
    await cargarTipoAtencion();
    await cargarTipoServicio();
    await cargarTipoSolicitud();
    await cargarListaPostes();
    await cargarCuentaGasto();
    await cargarOrdenTrabajoContable();
    setState(() {});
  }

  List<ExpansionPanel> listaPaneles() {
    List<ExpansionPanel> list = [];

    if (widget.modo == "A") {
      // Panel 1: Datos del Solicitante
      list.add(ExpansionPanel(
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
                    flex: 1,
                    child: TextBoxForm(
                      controlador: txtEditControllers['identificacion'],
                      textoEtiqueta: lblidentificaciondequienreporta,
                      tipo: TextInputType.text,
                      propiedadFormulario: 'identificacion',
                      valorFormulario: mapSolicitud,
                      obligatorio: true,
                    ),
                  ),
                  Espacio(alto: 10),
                  Expanded(
                    flex: 2,
                    child: TextBoxForm(
                      controlador: txtEditControllers['nombre'],
                      textoEtiqueta: lblnombereporta,
                      tipo: TextInputType.text,
                      propiedadFormulario: 'nombre',
                      valorFormulario: mapSolicitud,
                      obligatorio: true,
                    ),
                  ),
                  Espacio(alto: 10),
                  /* Expanded(
                    child: TextBoxForm(                      
                      controlador: txtEditControllers['primer_apellido'],
                      textoEtiqueta: lblprimerapellido,
                      tipo: TextInputType.name,
                      propiedadFormulario: 'primer_apellido',
                      valorFormulario: mapSolicitud,
                    ),
                  ),
                  Espacio(alto: 10),
                  Expanded(
                    child: TextBoxForm(
                      controlador: txtEditControllers['segundo_apellido'],
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
        isExpanded: _expanded[0],
      ));

      // Panel 2: Información Adicional
      list.add(ExpansionPanel(
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
                    validator: (value) {
                      if (value == null) {
                        return '$lblprovincia $lblcamporequerido';
                      }
                      return null;
                    },
                  )),
                  Espacio(alto: 25),
                  Expanded(
                      child: _loadingCanton
                          ? progresoCirculo()
                          : ListaSeleccion(
                              textoEtiqueta: lblcanton,
                              mapaDatos: mapCanton,
                              selectedValue: (idCantonSeleccionado > 0)
                                  ? idCantonSeleccionado
                                  : null,
                              idKey: "id_canton",
                              nameKey: "nombre_canton",
                              onChanged: (int? value) {
                                idCantonSeleccionado = value!;
                                mapSolicitud["cod_canton"] = '$value';

                                setState(() {
                                  idDistritoSeleccionado = 0;
                                  mapDistrito = [];
                                  _loadingDistrito = true;
                                });
                                cargarDistrito().then((r) {
                                  setState(() {});
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return '$lblcanton $lblcamporequerido';
                                }
                                return null;
                              },
                            )),
                  Espacio(alto: 10),
                  Expanded(
                      child: _loadingDistrito
                          ? progresoCirculo()
                          : ListaSeleccion(
                              tamanoFuente: tamanoFuente8px,
                              textoEtiqueta: lbldistrito,
                              mapaDatos: mapDistrito,
                              idKey: "id_distrito",
                              nameKey: "nombre_distrito",
                              selectedValue: (idDistritoSeleccionado > 0)
                                  ? idDistritoSeleccionado
                                  : null,
                              onChanged: (int? value) {
                                idDistritoSeleccionado = value!;
                                mapSolicitud["cod_distrito"] = '$value';
                              },
                              validator: (value) {
                                if (value == null) {
                                  return '$lbldistrito $lblcamporequerido';
                                }
                                return null;
                              },
                            )),
                ],
              ),
              Espacio(alto: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextBoxForm(
                        controlador: txtEditControllers['otras_senas'],
                        textoEtiqueta: lblreferenciaubicacion,
                        lineas: 4,
                        tipo: TextInputType.multiline,
                        propiedadFormulario: 'otras_senas',
                        valorFormulario: mapSolicitud),
                  ),
                  Espacio(ancho: 100),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 200,
                        child: (mapPostes.items != null)
                            ? ListaSeleccionTexto(
                                textoEtiqueta: lblposte,
                                tamanofuente: tamanoFuente10px,
                                opciones: mapPostes.items!
                                    .where((item) => item.numeroPoste != null)
                                    .map((item) => item.numeroPoste!)
                                    .toSet()
                                    .toList(),
                                valorSeleccionado: posteSeleccionado,
                                onChanged: (String? nuevaRespuesta) {
                                  setState(() {
                                    mapSolicitud['cod_poste'] = nuevaRespuesta;
                                    posteSeleccionado = nuevaRespuesta!;
                                  });
                                },
                              )
                            : Etiqueta(
                                texto: lblposte,
                              ),
                      ),
                      if (cod_solicitud.isNotEmpty)
                        (conexionInternet)
                            ? Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  SizedBox(
                                    width: 80,
                                    child: Boton(
                                        textoEtiqueta: lblhistorial,
                                        colorFondo: colorAzulPrimario,
                                        colorTexto: colorBlanco,
                                        onPressed: () {
                                          Navigator.popAndPushNamed(
                                              context, "inicio",
                                              arguments: {
                                                lblopcionprincipal:
                                                    3, //Historial de la solicitud atendida
                                                lblnombreopcion: lblhistorial,
                                                lblllave:
                                                    '${mapSolicitud['cod_solicitud']}',
                                                "numero_orden_trabajo": widget
                                                    .codOrdenTrabajo
                                                    .toString(),
                                                "estado":
                                                    '${mapSolicitud['estado']}',
                                                "cod_poste":
                                                    '${mapSolicitud["cod_poste"]}',
                                                "modo": 'C',
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
                                        tamanoFuente: tamanoFuente8px,
                                        bordenRedondeado: 10,
                                        tipoFuente: FontWeight.bold),
                                  ),
                                  Espacio(alto: 5),
                                  SizedBox(
                                      width: 85,
                                      child: Boton(
                                          textoEtiqueta: lblinstalado,
                                          colorFondo: colorAzulPrimario,
                                          colorTexto: colorBlanco,
                                          onPressed: () {
                                            MostrarWidgetEnDialogo(
                                                context,
                                                ListadoMaterialesPoste(
                                                    cod_solicitud,
                                                    "S",
                                                    mapSolicitud['cod_poste']),
                                                "Materiales instalados (${mapSolicitud['cod_poste']})");
                                          },
                                          tamanoFuente: tamanoFuente8px,
                                          bordenRedondeado: 10,
                                          tipoFuente: FontWeight.bold))
                                ],
                              )
                            : Text("")
                    ],
                  )
                ],
              ),
              Espacio(ancho: 50),
            ],
          ),
        ),
        isExpanded: _expanded[1],
      ));
    } else {
      // Panel 1: Datos del Solicitante
      list.add(ExpansionPanel(
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
                      controlador: txtEditControllers['identificacion'],
                      textoEtiqueta: lblidentificaciondequienreporta,
                      tipo: TextInputType.text,
                      propiedadFormulario: 'identificacion',
                      valorFormulario: mapSolicitud,
                      obligatorio: true,
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
                      obligatorio: true,
                    ),
                  ),
                  Espacio(alto: 10),
                  /* Expanded(
                    child: TextBoxForm(
                      controlador: txtEditControllers['primer_apellido'],
                      textoEtiqueta: lblprimerapellido,
                      tipo: TextInputType.name,
                      propiedadFormulario: 'primer_apellido',
                      valorFormulario: mapSolicitud,
                    ),
                  ),
                  Espacio(alto: 10),
                  Expanded(
                    child: TextBoxForm(
                      controlador: txtEditControllers['segundo_apellido'],
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
        isExpanded: _expanded[0],
      ));

      // Panel 2: Información Adicional
      list.add(ExpansionPanel(
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
                    validator: (value) {
                      if (value == null) {
                        return '$lblprovincia $lblcamporequerido';
                      }
                      return null;
                    },
                  )),
                  Espacio(alto: 25),
                  Expanded(
                      child: _loadingCanton
                          ? progresoCirculo()
                          : ListaSeleccion(
                              textoEtiqueta: lblcanton,
                              mapaDatos: mapCanton,
                              selectedValue: (idCantonSeleccionado > 0)
                                  ? idCantonSeleccionado
                                  : null,
                              idKey: "id_canton",
                              nameKey: "nombre_canton",
                              onChanged: (int? value) {
                                idCantonSeleccionado = value!;
                                mapSolicitud["cod_canton"] = '$value';

                                setState(() {
                                  idDistritoSeleccionado = 0;
                                  mapDistrito = [];
                                  _loadingDistrito = true;
                                });
                                cargarDistrito().then((r) {
                                  setState(() {});
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return '$lblcanton $lblcamporequerido';
                                }
                                return null;
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
                              selectedValue: (idDistritoSeleccionado > 0)
                                  ? idDistritoSeleccionado
                                  : null,
                              onChanged: (int? value) {
                                idDistritoSeleccionado = value!;
                                mapSolicitud["cod_distrito"] = '$value';
                              },
                              validator: (value) {
                                if (value == null) {
                                  return '$lbldistrito $lblcamporequerido';
                                }
                                return null;
                              },
                            )),
                ],
              ),
              Espacio(alto: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextBoxForm(
                        controlador: txtEditControllers['otras_senas'],
                        textoEtiqueta: lblreferenciaubicacion,
                        lineas: 4,
                        tipo: TextInputType.multiline,
                        propiedadFormulario: 'otras_senas',
                        valorFormulario: mapSolicitud),
                  ),
                  Espacio(ancho: 100),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 200,
                        child: (mapPostes.items != null)
                            ? ListaSeleccionTexto(
                                textoEtiqueta: lblposte,
                                tamanofuente: tamanoFuente10px,
                                opciones: mapPostes.items!
                                    .where((item) => item.numeroPoste != null)
                                    .map((item) => item.numeroPoste!)
                                    .toSet()
                                    .toList(),
                                valorSeleccionado: posteSeleccionado,
                                onChanged: (String? nuevaRespuesta) {
                                  setState(() {
                                    mapSolicitud['cod_poste'] = nuevaRespuesta;
                                    posteSeleccionado = nuevaRespuesta!;
                                  });
                                },
                              )
                            : Etiqueta(
                                texto: lblposte,
                              ),
                      ),
                      if (cod_solicitud.isNotEmpty)
                        (conexionInternet)
                            ? Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  SizedBox(
                                    width: 80,
                                    child: Boton(
                                        textoEtiqueta: lblhistorial,
                                        colorFondo: colorAzulPrimario,
                                        colorTexto: colorBlanco,
                                        onPressed: () {
                                          Navigator.popAndPushNamed(
                                              context, "inicio",
                                              arguments: {
                                                lblopcionprincipal:
                                                    3, //Historial de la solicitud atendida
                                                lblnombreopcion: lblhistorial,
                                                lblllave:
                                                    '${mapSolicitud['cod_solicitud']}',
                                                "numero_orden_trabajo": widget
                                                    .codOrdenTrabajo
                                                    .toString(),
                                                "estado":
                                                    '${mapSolicitud['estado']}',
                                                "cod_poste":
                                                    '${mapSolicitud["cod_poste"]}',
                                                "modo": 'C',
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
                                        tamanoFuente: tamanoFuente8px,
                                        bordenRedondeado: 10,
                                        tipoFuente: FontWeight.bold),
                                  ),
                                  Espacio(alto: 5),
                                  SizedBox(
                                      width: 85,
                                      child: Boton(
                                          textoEtiqueta: lblinstalado,
                                          colorFondo: colorAzulPrimario,
                                          colorTexto: colorBlanco,
                                          onPressed: () async {
                                            await MostrarWidgetEnDialogo(
                                                context,
                                                ListadoMaterialesPoste(
                                                    cod_solicitud.toString(),
                                                    "S",
                                                    mapSolicitud['cod_poste']
                                                        .toString()),
                                                lblmaterialesinstalados);
                                          },
                                          tamanoFuente: tamanoFuente8px,
                                          bordenRedondeado: 10,
                                          tipoFuente: FontWeight.bold))
                                ],
                              )
                            : Text("")
                    ],
                  )
                ],
              ),
              Espacio(ancho: 50),
            ],
          ),
        ),
        isExpanded: _expanded[1],
      ));

      // Panel 3: Tipo de Cuenta
      list.add(ExpansionPanel(
        backgroundColor: colorAcua,
        headerBuilder: (context, isExpanded) {
          return ListTile(
            title: Etiqueta(
              texto: lblatencioncuenta,
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
                    textoEtiqueta: lbltipoinstalacion,
                    mapaDatos: mapTipoAtencion,
                    selectedValue: (idTipoAtencionSeleccionado > 0)
                        ? idTipoAtencionSeleccionado
                        : null,
                    idKey: "cod_tipo_atencion",
                    nameKey: "des_tipo_atencion",
                    onChanged: (value) {
                      idTipoAtencionSeleccionado = value!;
                      mapSolicitud["cod_tipo_atencion"] = '$value';
                    },
                  )),
                  Espacio(alto: 25),
                  Expanded(
                      child: ListaSeleccion(
                    textoEtiqueta: lblcuentagasto,
                    mapaDatos: mapCuentaGasto,
                    selectedValue: (idCuentaGasto > 0) ? idCuentaGasto : null,
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
            ],
          ),
        ),
        isExpanded: _expanded[2],
      ));

      // Panel 4: Materiales Retirados
      list.add(ExpansionPanel(
        backgroundColor: colorAcua,
        headerBuilder: (context, isExpanded) {
          return ListTile(
            title: Etiqueta(
              texto: lblmaterialesretirados,
              tipo: FontWeight.bold,
              color: colorBlanco,
              tamanoFuente: tamanoFuenteDefecto,
            ),
            onTap: () {
              setState(() {
                _expanded[3] = !_expanded[3];
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
                    Log.escribir("llamado a SolicitudMateriales");
                    MostrarWidgetEnDialogo(
                        context,
                        AgregarMaterialesSolicitud(
                            cod_solicitud, "N", mapSolicitud['cod_poste']),
                        lblretirarmateriales);
                    _expanded[3] = false;
                  },
                  icon: Icon(
                    Icons.add,
                    color: colorVerdeSecundario,
                  ),
                ),
                LineaHorizontal(
                  color: colorAzulSecundario,
                ),
                solicitudMaterial(vmMaterialesRetirados),
              ],
            )),
        isExpanded: _expanded[3],
      ));

      // Panel 5: Materiales instalados
      list.add(ExpansionPanel(
        backgroundColor: colorAcua,
        headerBuilder: (context, isExpanded) {
          return ListTile(
            title: Etiqueta(
              texto: lblmaterialesinstalados,
              tipo: FontWeight.bold,
              color: colorBlanco,
              tamanoFuente: tamanoFuenteDefecto,
            ),
            onTap: () {
              setState(() {
                _expanded[4] = !_expanded[4];
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
                    onPressed: () {
                      MostrarWidgetEnDialogo(
                          context,
                          AgregarMaterialesSolicitud(
                              cod_solicitud, "S", mapSolicitud['cod_poste']),
                          lblmaterialesinstalados);
                      _expanded[4] = false;
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
        isExpanded: _expanded[4],
      ));
    }

    return list;
  }

  Future<VmSolicitudMateriales> traerMaterialesSolicitud(
      String codSolicitud, String instalados, String codPoste) async {
    CrudMateriales cls = CrudMateriales();
    VmSolicitudMateriales vm = VmSolicitudMateriales();

    //Listado materiales de la solicitud
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

  Future<VmSolicitudMateriales> eliminarSolicitudMateriales(
      String codsolicitudmaterial) async {
    CrudMateriales cls = CrudMateriales();
    VmSolicitudMateriales vm = VmSolicitudMateriales();

    //Listado de ordenes
    await cls.eliminarSolicitudMaterialesInstalados(codsolicitudmaterial).then(
      (r) {
        if (r.idInsertado! > 0) {
          setState(() {
            _expanded[3] = false;
            _expanded[4] = false;
          });
          BarraMensaje(context)
              .Mensaje(lblregistroeliminado, colorFondo: colorVerdeSecundario);
        }
      },
    );

    return vm;
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
                    DataCell(Text(formatoFechaPantalla(m.fechaInsert!))),
                    DataCell(Text(m.usuarioInsert ?? "")),
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

      return bd.actualizar(
          "SIAR_SOLICITUDES", datos, "COD_SOLICITUD", cod_solicitud);
    }
  }
}
