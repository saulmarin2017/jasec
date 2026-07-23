import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:jasec/class/autenticacion.dart';
import 'package:jasec/class/crudformularios.dart';
import 'package:jasec/class/crudmateriales.dart';
import 'package:jasec/class/crudnotificaciones.dart';
import 'package:jasec/class/crudordenestrabajo.dart';
import 'package:jasec/class/crudproducto.dart';
import 'package:jasec/class/crudrequisiciones.dart';
import 'package:jasec/class/crudsolicitud.dart';
import 'package:jasec/class/graficas.dart';
import 'package:jasec/class/listasprecargadas.dart';
import 'package:jasec/class/log.dart';
import 'package:jasec/db/db.dart';
import 'package:jasec/model/model.dart';
import 'package:jasec/model/vmlistadosdblocal.dart';
import 'package:jasec/model/vmnotificaciones.dart';
import 'package:jasec/model/vmtareas.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:jasec/utilidades/utilidades.dart';
import 'package:jasec/widget/barramensaje.dart';
import 'package:jasec/widget/lineahoritzontal.dart';
import 'package:jasec/widget/widget.dart';

// ignore: must_be_immutable
class Sincronizacion extends StatefulWidget {
  Sincronizacion({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _Sincronizacion createState() => _Sincronizacion();
}

class _Sincronizacion extends State<Sincronizacion> {
  VmNotificacion notificacionesFiltradas = VmNotificacion();
  VmNotificacion notificaciones = VmNotificacion();

  final ScrollController _scrollController = ScrollController();

  List<vmTareas> mapListaTareas = [];

  @override
  void initState() {
    super.initState();

    // Espera un frame y luego hace scroll al final
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await cargarUltimaSincronizacion();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                Row(
                  spacing: 10,
                  children: [
                    Espacio(ancho: 50),
                    Expanded(
                        child: ElevatedButton.icon(
                            label: Etiqueta(texto: lbleliminar),
                            onPressed: () async {
                              var continua = await DialogoConfirmacion(
                                  context,
                                  lblconfirme,
                                  "Esta seguro que desea volver a crear el archivo de datos local.");
                              if (continua!) {
                                if (conexionInternet) {
                                  final dbx = db.instance;
                                  //Si da error de camo no creado, eliminamos la base de datos
                                  await dbx.borrarBD().then((r) {
                                    BarraMensaje(context).Mensaje(
                                        lblprocesofinalizado,
                                        colorFondo: colorAmarrillo,
                                        colorFuente: colorBlanco);
                                  });

                                  await setPreferencia(lblSincronizacion, "");

                                  await cargarUltimaSincronizacion();

                                  setState(() {});

                                  /*Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (context) => Login()),
                                    (Route<dynamic> route) => false,
                                  );*/
                                } else {
                                  BarraMensaje(context).Mensaje(
                                      "Para eliminar el archivo de datos local debe estar conectado a internet, ya que el archivo se debe crear nuevamente con los datos básicos.",
                                      colorFondo: colorRojoPrimario,
                                      colorFuente: colorBlanco);
                                }
                              }
                            },
                            icon: Icon(
                              Icons.warning,
                              color: colorRojoPrimario,
                            ))),
                    Expanded(
                      child: ElevatedButton.icon(
                          icon: Icon(
                            Icons.download,
                            color: colorVerdeSecundario,
                          ),
                          label: Etiqueta(texto: lbldescargardatos),
                          onPressed: () async {
                            if (conexionInternet) {
                              await descargarBaseJasec();
                            } else {
                              BarraMensaje(context).Mensaje(
                                  lbldebetenerconexioninternet,
                                  colorFondo: colorRojoPrimario,
                                  colorFuente: colorBlanco);
                            }
                          }),
                    ),
                    Expanded(
                      child: ElevatedButton.icon(
                          icon: Icon(
                            Icons.copy,
                            color: colorAmarrillo,
                          ),
                          label: Etiqueta(texto: lblcopiaseguridad),
                          onPressed: () async {
                            final bd = db.instance;
                            await bd.exportarBD().then((r) {
                              BarraMensaje(context).Mensaje(
                                  lblprocesofinalizado,
                                  colorFondo: colorAmarrillo,
                                  colorFuente: colorBlanco);
                            });
                          }),
                    ),
                    Expanded(
                      child: ElevatedButton.icon(
                          icon: Icon(
                            Icons.upload,
                            color: colorAmarrillo,
                          ),
                          label: Etiqueta(texto: lblcargardatos),
                          onPressed: () async {
                            if (conexionInternet) {
                              await cargarBaseJasec();
                            } else {
                              BarraMensaje(context).Mensaje(
                                  lbldebetenerconexioninternet,
                                  colorFondo: colorRojoPrimario,
                                  colorFuente: colorBlanco);
                            }
                          }),
                    ),
                    Espacio(ancho: 50)
                  ],
                ),
                LineaHorizontal(
                  color: colorAzulPrimario,
                ),
                (mapListaTareas.isNotEmpty)
                    ? DataTable(
                        sortAscending: true,
                        columns: const [
                          DataColumn(
                            label: Etiqueta(
                              texto: lbldescripciondelproceso,
                              tamanoFuente: tamanoFuenteSecundaria,
                              tipo: FontWeight.bold,
                            ),
                          ),
                          DataColumn(
                            label: Etiqueta(
                              texto: lblfecha,
                              tamanoFuente: tamanoFuenteSecundaria,
                              tipo: FontWeight.bold,
                            ),
                          ),
                          DataColumn(
                            label: Etiqueta(
                              texto: lblestado,
                              tamanoFuente: tamanoFuenteSecundaria,
                              tipo: FontWeight.bold,
                            ),
                          ),
                        ],
                        rows: List.generate(mapListaTareas.length, (index) {
                          final m = mapListaTareas[index];
                          return DataRow(
                            cells: [
                              DataCell(Etiqueta(
                                texto: m.descripcion.toString(),
                                color: colorNegro,
                                tamanoFuente: tamanoFuenteSecundaria,
                              )),
                              DataCell(Etiqueta(
                                texto: m.fechaHora.toString(),
                                color: colorNegro,
                                tamanoFuente: tamanoFuenteSecundaria,
                              )),
                              DataCell((m.estado == "EJECUTADA")
                                  ? Icon(
                                      Icons.done,
                                      size: 30,
                                      color: colorVerdePrimario,
                                    )
                                  : Icon(
                                      Icons.close,
                                      size: 30,
                                      color: colorRojoPrimario,
                                    )),
                            ],
                          );
                        }).toList(),
                      )
                    : Text(""),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void agregarFila(String tabla) {
    setState(() {
      mapListaTareas.add(
          vmTareas.crear(descripcion: tabla, url: tabla, estado: "EJECUTADA"));

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  //Descarga información de base de datos JASEC
  Future<void> descargarBaseJasec() async {
    ListasPrecargadas listas = ListasPrecargadas();
    CrudSolicitud solicitud = CrudSolicitud();
    CrudOrdenesTrabajo ordenesTrabajo = CrudOrdenesTrabajo();
    CrudMateriales crudMateriales = CrudMateriales();
    CrudProducto crudproducto = CrudProducto();
    Graficas graficas = Graficas();
    Autenticacion autenticacion = Autenticacion();

    //Loading minetras autentica
    DialogoProgreso(context, lblprocesando, lblprocesando, Icons.network_check,
        widget: Center(
            child: SizedBox(width: 200, height: 200, child: progresoCirculo())),
        cerrar: false);
    try {
      final bd = db.instance;

      mapListaTareas.clear();

      agregarFila(
          "-PROCESO INICIADO (CUADRILLA: $codCuadrillaUsaurio USUARIO:$usuarioLogin )");

      var existe = await bd.verificarBD();
      if (!existe) {
        await bd.database;
      } //Verificamos si el registro existe antes de realizar los update
      await bd.obtenerRegistros("LISTADOS").then((lista) {
        if (lista.isEmpty) {
          Map<String, dynamic> mapi = {"USUARIO": usuarioLogin};
          bd.insertar(mapi, "LISTADOS");
        }
      });

      BarraMensaje(context).Mensaje(lblprocesoiniciado,
          colorFondo: colorVerdeSecundario, colorFuente: colorBlanco);

      //SIAR_TIPO_SERVICIO
      await listas.listaTipoServicio(alumbrado: luminaria).then((r) async {
        Map<String, dynamic> mapUpdateTipoServicio = {
          "SIAR_TIPO_SERVICIO": jsonEncode(r.toJson())
        };

        await bd
            .actualizar("LISTADOS", mapUpdateTipoServicio, "ROWID", 1)
            .then((x) {
          agregarFila("SIAR_TIPO_SERVICIO");
        });
      });

      //SIAR_TIPO_ATENCION
      await listas.listaTipoAtencion(alumbrado: luminaria).then((r) async {
        Map<String, dynamic> mapUpdateTipoAtencion = {
          "SIAR_TIPO_ATENCION": jsonEncode(r.toJson())
        };

        await bd
            .actualizar("LISTADOS", mapUpdateTipoAtencion, "ROWID", 1)
            .then((x) {
          agregarFila("SIAR_TIPO_ATENCION");
        });
      });

      //SIAR_TIPO_SOLICITUD
      await listas.listaTipoSolicitud(alumbrado: luminaria).then((r) async {
        Map<String, dynamic> map = {
          "SIAR_TIPO_SOLICITUD": jsonEncode(r.toJson())
        };

        await bd.actualizar("LISTADOS", map, "ROWID", 1).then((x) {
          agregarFila("SIAR_TIPO_SOLICITUD");
        });
      });

      //SIAR_TIPO_SOLICITUD_ST
      await listas.listaTipoSolicitudST().then((r) async {
        Map<String, dynamic> map = {
          "SIAR_TIPO_SOLICITUD_ST": jsonEncode(r.toJson())
        };

        Log.escribir('MAP SIAR_TIPO_SOLICITUD_ST, ${jsonEncode(r.toJson())}');

        await bd.actualizar("LISTADOS", map, "ROWID", 1).then((x) {
          agregarFila("SIAR_TIPO_SOLICITUD_ST");
        });
      });

      //SIAR_MOTIVOS_RECHAZO
      await listas.listaMotivosRechazo(alumbrado: luminaria).then((r) async {
        Map<String, dynamic> map = {
          "SIAR_MOTIVOS_RECHAZO": jsonEncode(r.toJson())
        };

        await bd.actualizar("LISTADOS", map, "ROWID", 1).then((x) {
          agregarFila("SIAR_MOTIVOS_RECHAZO");
        });
      });

      //SIAR_CUENTA_GASTO
      await solicitud.traerCuentaGasto().then((r) async {
        Map<String, dynamic> map = {
          "SIAR_CUENTA_GASTO": jsonEncode(r.toJson())
        };

        await bd.actualizar("LISTADOS", map, "ROWID", 1).then((x) {
          agregarFila("SIAR_CUENTA_GASTO");
        });
      });

      //SIAR_OTC
      await solicitud.traerOrdenTrabajoContable().then((r) async {
        Map<String, dynamic> map = {"SIAR_OTC": jsonEncode(r.toJson())};

        await bd.actualizar("LISTADOS", map, "ROWID", 1).then((x) {
          agregarFila("SIAR_OTC");
        });
      });

      //SIAR_PROVINCIA
      await listas.listaProvincias().then((r) async {
        Map<String, dynamic> map = {"SIAR_PROVINCIA": jsonEncode(r.toJson())};

        await bd.actualizar("LISTADOS", map, "ROWID", 1).then((x) {
          agregarFila("SIAR_PROVINCIA");
        });
      });

      //SIAR_CANTON
      await listas.listaCanton("0").then((r) async {
        Map<String, dynamic> map = {"SIAR_CANTON": jsonEncode(r.toJson())};

        await bd.actualizar("LISTADOS", map, "ROWID", 1).then((x) {
          agregarFila("SIAR_CANTON");
        });
      });

      //SIAR_DISTRITO
      await listas.listaDistrito("0", "0").then((r) async {
        Map<String, dynamic> map = {"SIAR_DISTRITO": jsonEncode(r.toJson())};

        await bd.actualizar("LISTADOS", map, "ROWID", 1).then((x) {
          agregarFila("SIAR_DISTRITO");
        });
      });

      //SIAR_POSTE
      await listas.listaPostes().then((r) async {
        Map<String, dynamic> map = {"SIAR_POSTE": jsonEncode(r.toJson())};

        await bd.actualizar("LISTADOS", map, "ROWID", 1).then((x) {
          agregarFila("SIAR_POSTE");
        });
      });

      //SIAR_ORDEN_TRABAJO
      await ordenesTrabajo.traerOrdenesTrabajo(luminaria).then((r) async {
        Map<String, dynamic> map = {
          "SIAR_ORDEN_TRABAJO": jsonEncode(r.toJson())
        };

        await bd.actualizar("LISTADOS", map, "ROWID", 1).then((x) {
          agregarFila("SIAR_ORDEN_TRABAJO");
        });
      });

      //SIAR_SOLICITUDES_CUADRILLA
      await solicitud.traerSolicitudesCuadrilla().then((r) async {
        for (var m in r.items!) {
          Map<String, dynamic> x = {
            "COD_SOLICITUD": m.codSolicitud,
            "COD_ORDEN_TRABAJO": m.codOrdenTrabajo,
            "JSON": jsonEncode(m.toJson()),
            "POST_PUT": "PUT",
            "USUARIO_INSERT": m.usuarioInsert,
            "FECHA_CREACION": m.fechaInsert!.toIso8601String(),
            "ESTADO": "PENDIEINTE"
          };

          await bd.insertar(x, "SIAR_SOLICITUDES");
        }
      });

      //SIAR_SOLICITUD_MATERIALES
      await crudMateriales.materialesCuadrilla().then((r) async {
        bd.eliminar("SIAR_SOLICITUD_MATERIALES", "COD_SOLICITUD", "AEIOU12345",
            operador: "!=");

        for (var m in r.items!) {
          Map<String, dynamic> x = {
            "COD_SOLICITUD_MATERIAL": m.codSolicitudMaterial,
            "COD_SOLICITUD": m.codSolicitud,
            "CANTIDAD": m.cantidad.toString(),
            "INSTALADOS": m.instalados,
            "POST_PUT": "PUT",
            "COD_POSTE": m.codPoste,
            "OBSERVACIONES": m.observaciones,
            "COD_SIAR_PRODUCTO": m.codSiarProducto,
            "VERIFICADO": m.verificado,
            "USUARIO_INSERT": m.usuarioInsert,
            "FECHA_INSERT": m.fechaInsert!.toIso8601String(),
            "ESTADO": "PENDIEINTE"
          };

          await bd.insertar(x, "SIAR_SOLICITUD_MATERIALES");
        }
      });

      //SIAR_PRODUCTO
      await crudproducto.traerProductos().then((r) async {
        Map<String, dynamic> map = {"SIAR_PRODUCTO": jsonEncode(r.toJson())};

        await bd.actualizar("LISTADOS", map, "ROWID", 1).then((x) {
          agregarFila("SIAR_PRODUCTO");
        });
      });

      //SIAR_MINIMO_INVENTARIO
      await crudproducto.traerMinimoInventario().then((r) async {
        Map<String, dynamic> map = {
          "SIAR_MINIMO_INVENTARIO": jsonEncode(r.toJson())
        };

        await bd.actualizar("LISTADOS", map, "ROWID", 1).then((x) {
          agregarFila("SIAR_MINIMO_INVENTARIO");
        });
      });

      //SIAR_BODEGA
      await crudproducto.traerBodegas().then((r) async {
        Map<String, dynamic> map = {"SIAR_BODEGA": jsonEncode(r.toJson())};

        await bd.actualizar("LISTADOS", map, "ROWID", 1).then((x) {
          agregarFila("SIAR_BODEGA");
        });
      });

      //SIAR_GRAFICA_DONA
      await graficas.traerGraficaDonas().then((r) async {
        Map<String, dynamic> map = {
          "SIAR_GRAFICA_DONA": jsonEncode(r.toJson())
        };

        await bd.actualizar("LISTADOS", map, "ROWID", 1).then((x) {
          agregarFila("SIAR_GRAFICA_DONA");
        });
      });

      //SIAR_GRAFICA_PORCENTAJE
      await graficas.traerGraficaPorcentaje().then((r) async {
        Map<String, dynamic> map = {
          "SIAR_GRAFICA_PORCENTAJE": jsonEncode(r.toJson())
        };

        await bd.actualizar("LISTADOS", map, "ROWID", 1).then((x) {
          agregarFila("SIAR_GRAFICA_PORCENTAJE");
        });
      });

      //SIAR_GRAFICA_BARRAS
      await graficas.traerGraficaBarras().then((r) async {
        Map<String, dynamic> map = {
          "SIAR_GRAFICA_BARRAS": jsonEncode(r.toJson())
        };

        await bd.actualizar("LISTADOS", map, "ROWID", 1).then((x) {
          agregarFila("SIAR_GRAFICA_BARRAS");
        });
      });

      //SIAR_USUARIOS
      await autenticacion.usuarios().then((r) async {
        Map<String, dynamic> map = {"SIAR_USUARIOS": jsonEncode(r.toJson())};

        await bd.actualizar("LISTADOS", map, "ROWID", 1).then((x) {
          agregarFila("SIAR_USUARIOS");
        });
      });

      //SIAR_FORMULARIO
      await listas.preguntasFormulario('').then((r) async {
        Map<String, dynamic> map = {"SIAR_FORMULARIOS": jsonEncode(r.toJson())};
        await bd.actualizar("LISTADOS", map, "ROWID", 1).then((x) {
          agregarFila("SIAR_FORMULARIOS");
        });
      });

      //SIAR_MEDIDOR
      await listas.listaMedidores().then((r) async {
        Map<String, dynamic> map = {"SIAR_MEDIDOR": jsonEncode(r.toJson())};
        await bd.actualizar("LISTADOS", map, "ROWID", 1).then((x) {
          agregarFila("SIAR_MEDIDOR");
        });
      });

      //SIAR_RESPUESTAS_SUJERIDAS
      await listas.respuestasSujeridas().then((r) async {
        Map<String, dynamic> map = {
          "SIAR_RESPUESTAS_SUJERIDAS": jsonEncode(r.toJson())
        };
        await bd.actualizar("LISTADOS", map, "ROWID", 1).then((x) {
          agregarFila("SIAR_RESPUESTAS_SUJERIDAS");
        });
      });

      //Si el log esta hbilitado se crea una copia de la db en las descargas del dispositivo dentro de la carpeta siar
      if (registrarLog) {
        await bd.exportarBD();
      }

      //Recuperamos los datos de los listados fijos
      var data = await bd.obtenerRegistros("LISTADOS");

      //variable global de listados globales estaticos
      listadosdblocal = data.map((d) => ListadosDBlocal.fromMap(d)).toList();

      //Log finaliza evento de sincronizacion
      agregarFila(
          "_-***** PROCESO FINALIZADO ***** -_ (CUADRILLA: $codCuadrillaUsaurio USUARIO:$usuarioLogin )");
      await setPreferencia(lblSincronizacion, jsonEncode(mapListaTareas));

      BarraMensaje(context).Mensaje(lblprocesofinalizado,
          colorFondo: colorVerdeSecundario, colorFuente: colorBlanco);
    } catch ($e) {
      Navigator.of(context).pop();
    } finally {
      // Siempre cerrar el loading
      Navigator.of(context).pop();
    }
  }

  //Carga informacion a base de datos JASEC
  Future<void> cargarBaseJasec() async {
    if (conexionInternet) {
      try {
        //Loading minetras autentica
        DialogoProgreso(
            context, lblprocesando, lblprocesando, Icons.network_check,
            widget: Center(
                child: SizedBox(
                    width: 200, height: 200, child: progresoCirculo())),
            cerrar: false);

        await cargarSolicitudesLocal();
        await cargarMaterialesSolicitudesLocal();
        await cargarRequisiciones();
        await cargarDetalleRequisiciones();
        await cargarRespuestasFormulario();
        await cargarDocumentosAdjuntos();
        await cargarTiemposAtencion();

        BarraMensaje(context).Mensaje(lblprocesofinalizado,
            colorFondo: colorVerdeSecundario, colorFuente: colorBlanco);
      } catch ($e) {
        Navigator.of(context).pop();
      } finally {
        // Siempre cerrar el loading
        Navigator.of(context).pop();
      }
    } else {
      BarraMensaje(context).Mensaje(
          "Debe estar conectado a internet para continuar.",
          colorFondo: colorRojoPrimario,
          colorFuente: colorBlanco);
    }
  }

  Future<void> cargarUltimaSincronizacion() async {
    //Recuperamos el kilometraje inicial de la jornada
    await getPreferencia(lblSincronizacion).then((map) async {
      if (map != "") {
        List<dynamic> listaMap = jsonDecode(map);
        setState(() {
          mapListaTareas = listaMap
              .map((e) => vmTareas.fromJson(e as Map<String, dynamic>))
              .toList();
        });
      }
    });
  }

  Future<void> actualizarEstadoNotificacion(String codNotificacion) async {
    CrudNotificaciones notificaciones = CrudNotificaciones();
    await notificaciones
        .actualizarEstadoNotificacion(codNotificacion)
        .then((r) async {
      await cargarNoficaciones();
    });
  }

  Future<VmNotificacion> cargarNoficaciones() async {
    CrudNotificaciones listado = CrudNotificaciones();
    VmNotificacion vm = VmNotificacion();

    //Loading minetras autentica
    DialogoProgreso(context, lblprocesando, lblprocesando, Icons.network_check,
        widget: Center(
            child: SizedBox(width: 200, height: 200, child: progresoCirculo())),
        cerrar: false);
    try {
      notificaciones = await listado.notificacionesPENDIENTES();

      if (notificaciones.items!.isNotEmpty) {
        if (notificaciones.items != null) {
          notificacionesFiltradas.items = notificaciones.items!
              .map((item) => ItemNotificacion(
                  codCuadrilla: item.codCuadrilla,
                  codNotificacion: item.codNotificacion,
                  descripcion: item.descripcion,
                  fecha: item.fecha,
                  estado: item.estado))
              .toList();

          notificacionesFiltradas.items!
              .toList()
              .sort((a, b) => b.codCuadrilla!.compareTo(a.codCuadrilla!));

          setState(() {});
        }
      }
    } catch ($e) {
      Navigator.of(context).pop();
    } finally {
      // Siempre cerrar el loading
      Navigator.of(context).pop();
    }

    return vm;
  }

  //Procesos para sincronzar a jasec
  Future<void> cargarSolicitudesLocal() async {
    try {
      final bd = db.instance;

      CrudSolicitud crudSolicitud = CrudSolicitud();

      var solicitudesLocales = await bd
          .obtenerRegistrosISNULL("SIAR_SOLICITUDES", campo: "ESTADO_TRASLADO");
      if (solicitudesLocales.isNotEmpty) {
        Map<String, dynamic> confirmacionEnvio = {
          "ESTADO": "ENVIADA",
          "USUARIO_TRASLADO": usuarioLogin,
          "FECHA_TRASLADO": DateTime.now().toIso8601String(),
          "ESTADO_TRASLADO": "PROCESADA"
        };

        for (var fila in solicitudesLocales) {
          //Sincroninza solicitudes, nuevas(post) o modificadas(put)
          if (fila["POST_PUT"] == "POST") {
            await crudSolicitud
                .guardarSolicitud(jsonDecode(fila["JSON"]))
                .then((r) {
              //Actualizamos el ID de solicitud por el generado en jasec
              confirmacionEnvio['COD_SOLICITUD'] = r.idInsertado.toString();
              bd.actualizar("SIAR_SOLICITUDES", confirmacionEnvio,
                  "COD_SOLICITUD", fila["COD_SOLICITUD"]);

              //Actualizamos materiales con el ID de solicitud generado en jasec
              Map<String, dynamic> map = {
                "COD_SOLICITUD": r.idInsertado.toString()
              };

              //Actualizamos el codigo en la solicitud y en los documentos adjuntos de la solicitud
              bd.actualizar("SIAR_SOLICITUD_MATERIALES", map, "COD_SOLICITUD",
                  fila["COD_SOLICITUD"]);

              bd.actualizar("SIAR_SOLICITUD_DOCUMENTO", map, "COD_SOLICITUD",
                  fila["COD_SOLICITUD"]);

              bd.actualizar("SIAR_DET_FORMULARIO_RESPUESTA", map,
                  "COD_SOLICITUD", fila["COD_SOLICITUD"]);
            });
          } else if (fila["POST_PUT"] == "PUT") {
            Log.escribir(jsonEncode(fila["JSON"]));
            await crudSolicitud
                .actualizarSolicitud(jsonDecode(fila["JSON"]))
                .then((r) {
              bd.actualizar("SIAR_SOLICITUDES", confirmacionEnvio,
                  "COD_SOLICITUD", fila["COD_SOLICITUD"]);
            });
          }
        }
      }
    } catch ($e) {
      Log.escribir($e.toString());
    }
  }

  Future<void> cargarMaterialesSolicitudesLocal() async {
    try {
      final bd = db.instance;

      CrudMateriales crudMateriales = CrudMateriales();

      var ds = await bd.obtenerRegistrosISNULL("SIAR_SOLICITUD_MATERIALES",
          campo: "ESTADO_TRASLADO");

      List<Map<String, dynamic>> mapMaterialesPost = [];

      if (ds.isNotEmpty) {
        for (var d in ds) {
          print(
              'HTTP:${d["POST_PUT"]} - ID:${d["COD_SOLICITUD_MATERIAL"] ?? 0} JSON: ${d["CANTIDAD"] ?? 0}');
          //Map Materiales
          Map<String, dynamic> confirmacionEnvio = {
            "ESTADO": "ENVIADA",
            "USUARIO_TRASLADO": usuarioLogin,
            "FECHA_TRASLADO": DateTime.now().toIso8601String(),
            "ESTADO_TRASLADO": "PROCESADA"
          };

          if (d["POST_PUT"] == "PUT") {
            continue;
          }

          if (d["POST_PUT"] == "POST") {
            Map<String, dynamic> registro = {
              "cod_solicitud": d["COD_SOLICITUD"],
              "cod_solicitud_material": d["COD_SOLICITUD_MATERIAL"],
              "cod_siar_producto": d["COD_SIAR_PRODUCTO"],
              "cantidad": d["CANTIDAD"],
              "cod_poste": d["COD_POSTE"],
              "observaciones": d["OBSERVACIONES"],
              "instalados": d["INSTALADOS"],
              "usuario_insert": usuarioLogin
            };
            mapMaterialesPost.add(registro);
            //registro.clear();
          } else if (d["POST_PUT"] == "DELETE") {
            await crudMateriales
                .eliminarSolicitudMaterialesInstalados(
                    d["COD_SOLICITUD_MATERIAL"].toString())
                .then((u) {
              bd.actualizar("SIAR_SOLICITUD_MATERIALES", confirmacionEnvio,
                  "COD_SOLICITUD_MATERIAL", d["COD_SOLICITUD_MATERIAL"]);
            });
          }
        }

        if (mapMaterialesPost.isNotEmpty) {
          //Enviamos los que se crearon en modo offline
          await crudMateriales
              .solicitudMaterialesInstalados(mapMaterialesPost)
              .then((u) async {
            for (var d in mapMaterialesPost) {
              Map<String, dynamic> map = {
                "COD_SOLICITUD_MATERIAL": d["cod_solicitud_material"],
                "ESTADO": "ENVIADA",
                "USUARIO_TRASLADO": usuarioLogin,
                "FECHA_TRASLADO": DateTime.now().toIso8601String(),
                "ESTADO_TRASLADO": "PROCESADA"
              };

              await bd.actualizar("SIAR_SOLICITUD_MATERIALES", map,
                  "COD_SOLICITUD_MATERIAL", d["cod_solicitud_material"]);
            }
          });
        }
      }
    } catch ($e) {
      print($e.toString());
      Log.escribir($e.toString());
    }
  }

  Future<void> cargarRequisiciones() async {
    try {
      final bd = db.instance;

      CrudRequisiciones crudRequisiciones = CrudRequisiciones();

      var ds = await bd.obtenerRegistrosISNULL("SIAR_REQUISICION",
          campo: "ESTADO_TRASLADO");

      if (ds.isNotEmpty) {
        for (var d in ds) {
          print(
              'HTTP:${d["POST_PUT"]} - ID:${d["COD_REQUISICIONES"] ?? 0} BODEGA: ${d["COD_BODEGA"] ?? 0}');

          if (d["POST_PUT"] == "POST") {
            if (jsonDecode(d['JSON']).isNotEmpty) {
              //Enviamos los que se crearon en modo offline
              await crudRequisiciones
                  .guardarRequisicion(jsonDecode(d['JSON']))
                  .then((u) async {
                Map<String, dynamic> map = {
                  "COD_REQUISICIONES": u.idInsertado,
                  "ESTADO": "ENVIADA",
                  "USUARIO_TRASLADO": usuarioLogin,
                  "FECHA_TRASLADO": DateTime.now().toIso8601String(),
                  "ESTADO_TRASLADO": "PROCESADA"
                };

                Map<String, dynamic> mapDet = {
                  "COD_REQUISICIONES": u.idInsertado
                };

                await bd.actualizar("SIAR_REQUISICION", map,
                    "COD_REQUISICIONES", d['COD_REQUISICIONES']);

                await bd.actualizar("SIAR_DETALLE_REQUISICION", mapDet,
                    "COD_REQUISICIONES", d['COD_REQUISICIONES']);
              });
            }
          }
        }
      }
    } catch ($e) {
      print($e.toString());
      Log.escribir($e.toString());
    }
  }

  Future<void> cargarDetalleRequisiciones() async {
    try {
      final bd = db.instance;

      CrudRequisiciones crudRequisiciones = CrudRequisiciones();

      var ds = await bd.obtenerRegistrosISNULL("SIAR_DETALLE_REQUISICION",
          campo: "ESTADO_TRASLADO");

      List<Map<String, dynamic>> mapDetalleRequisiciones = [];

      if (ds.isNotEmpty) {
        //Preparamos el listado de detalles
        for (var detReq in ds) {
          print(
              'HTTP:${detReq["POST_PUT"]} - ID:${detReq["COD_REQUISICIONES"] ?? 0} BODEGA: ${detReq["COD_DET_REQUISICIONES"] ?? 0}');

          if (detReq["POST_PUT"] == "POST") {
            Map<String, dynamic> registro = {
              "cod_requisiciones": detReq["COD_REQUISICIONES"],
              "cod_producto": detReq["COD_PRODUCTO"],
              "cantidad": detReq["CANTIDAD"],
              "usuario_insert": usuarioLogin
            };
            mapDetalleRequisiciones.add(registro);
          }
        }

        //Guardamos los item en linea
        await crudRequisiciones
            .guardarDetalleRequisicion(mapDetalleRequisiciones)
            .then((u) async {
          //Agrupamos las requisiciones que se enviaron en los detalles
          List<String> listaCodRequisiciones = mapDetalleRequisiciones
              .map((item) => item['cod_requisiciones'].toString())
              .toSet()
              .toList();

          var bd = await db.instance.database;

          //Actualizamos el estado a los detalles en modo local offline
          await bd.transaction((txn) async {
            for (var codRequisiciones in listaCodRequisiciones) {
              try {
                Map<String, dynamic> map = {
                  "COD_REQUISICIONES": codRequisiciones,
                  "ESTADO": "ENVIADA",
                  "USUARIO_TRASLADO": usuarioLogin,
                  "FECHA_TRASLADO": DateTime.now().toIso8601String(),
                  "ESTADO_TRASLADO": "PROCESADA"
                };

                await txn.update("SIAR_DETALLE_REQUISICION", map,
                    where: "COD_REQUISICIONES = ?",
                    whereArgs: [codRequisiciones]);
              } catch ($e) {
                Log.escribir($e.toString());
              }
            }
          });
        });
      }
    } catch ($e) {
      print($e.toString());
      Log.escribir($e.toString());
    }
  }

  Future<void> cargarRespuestasFormulario() async {
    try {
      final bd = db.instance;

      CrudFormularios crudFormularios = CrudFormularios();

      var ds = await bd.obtenerRegistrosISNULL("SIAR_DET_FORMULARIO_RESPUESTA",
          campo: "ESTADO_TRASLADO");

      List<Map<String, dynamic>> mapRespuestasFromulariosPOST = [];
      // List<Map<String, dynamic>> mapRespuestasFromulariosPUT = [];

      if (ds.isNotEmpty) {
        //Preparamos el listado de detalles
        for (var respuesta in ds) {
          print(
              'HTTP:${respuesta["POST_PUT"]} - FORMULARIO:${respuesta["ROWID"] ?? 0} SOLICITUD: ${respuesta["COD_SOLICITUD"] ?? 0}');

          var respuestas = jsonDecode(respuesta["JSON"]);

          if (respuesta["POST_PUT"] == "POST") {
            mapRespuestasFromulariosPOST =
                List<Map<String, dynamic>>.from(respuestas);
          } else if (respuesta["POST_PUT"] == "PUT") {
            // mapRespuestasFromulariosPUT =
            //     List<Map<String, dynamic>>.from(respuestas);
          }
        }

        //Guardamos los item en linea
        await crudFormularios
            .guardarRespuestasFormulario(mapRespuestasFromulariosPOST)
            .then((u) async {
          //Agrupamos las requisiciones que se enviaron en los detalles
          List<String> listaSolicitudes = mapRespuestasFromulariosPOST
              .map((item) => item['cod_solicitud'].toString())
              .toSet()
              .toList();

          var bd = await db.instance.database;

          //Actualizamos el estado a los detalles en modo local offline
          await bd.transaction((txn) async {
            for (var solicitud in listaSolicitudes) {
              try {
                Map<String, dynamic> map = {
                  "USUARIO_TRASLADO": usuarioLogin,
                  "FECHA_TRASLADO": DateTime.now().toIso8601String(),
                  "ESTADO_TRASLADO": "PROCESADA"
                };

                await txn.update("SIAR_DET_FORMULARIO_RESPUESTA", map,
                    where: "COD_SOLICITUD = ?", whereArgs: [solicitud]);
              } catch ($e) {
                Log.escribir($e.toString());
              }
            }
          });
        });
      }
    } catch ($e) {
      print($e.toString());
      Log.escribir($e.toString());
    }
  }

  Future<void> cargarDocumentosAdjuntos() async {
    try {
      final bd = db.instance;

      CrudSolicitud crudSolicitud = CrudSolicitud();

      var ds = await bd.obtenerRegistrosISNULL("SIAR_SOLICITUD_DOCUMENTO",
          campo: "ESTADO_TRASLADO");

      if (ds.isNotEmpty) {
        for (var documento in ds) {
          if (documento["POST_PUT"] == "POST") {
            crudSolicitud.cargarArchivoSolicitud(
                documento["COD_SOLICITUD"].toString(),
                documento["FILENAME"],
                documento["DOCUMENTO"] as Uint8List,
                documento["MIMETYPE"]);
          }
        }

        //Agrupamos las solicitudes que se enviaron
        List<String> listaSolicitudes =
            ds.map((item) => item['COD_SOLICITUD'].toString()).toSet().toList();

        var bd = await db.instance.database;

        //Actualizamos el estado a los documentos en modo local offline
        await bd.transaction((txn) async {
          for (var solicitud in listaSolicitudes) {
            try {
              Map<String, dynamic> map = {
                "USUARIO_TRASLADO": usuarioLogin,
                "FECHA_TRASLADO": DateTime.now().toIso8601String(),
                "ESTADO_TRASLADO": "PROCESADA"
              };

              await txn.update("SIAR_SOLICITUD_DOCUMENTO", map,
                  where: "COD_SOLICITUD = ?", whereArgs: [solicitud]);
            } catch ($e) {
              Log.escribir($e.toString());
            }
          }
        });
      }
    } catch ($e) {
      print($e.toString());
      Log.escribir($e.toString());
    }
  }

  Future<void> cargarTiemposAtencion() async {
    try {
      final bdx = db.instance;

      CrudSolicitud crudSolicitud = CrudSolicitud();
      VmRespuestaPost respuestaPost = VmRespuestaPost();

      var dsPost = await bdx.obtenerRegistrosISNULL("SIAR_TIEMPO_ATENCION",
          campo: "ESTADO_TRASLADO");

      // Filtrar solo los POST
      List<Map<String, dynamic>> posts = dsPost
          .where((item) => item["POST_PUT"].toString().toUpperCase() == "POST")
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      List<Map<String, dynamic>> tiempos = [];

      if (posts.isNotEmpty) {
        //Procesamos los registros POST
        for (var tiempo in posts) {
          if (tiempo["POST_PUT"] == "POST") {
            respuestaPost = await crudSolicitud
                .guardarInicioTiempoAtencion(jsonDecode(tiempo["JSON"]));

            if (respuestaPost.idInsertado! > 0) {
              tiempos.add({
                "COD_TIEMPO_ATENCION": tiempo["COD_TIEMPO_ATENCION"],
                "COD_TIEMPO_ATENCION_SIAR": respuestaPost.idInsertado
              });
            }
          }
        }

        //ACTUALIZAMOS EN DB
        var bd = await db.instance.database;

        //Actualizamos el estado a los documentos en modo local offline
        await bd.transaction((txn) async {
          for (var tmp in tiempos) {
            try {
              Map<String, dynamic> map = {
                "COD_TIEMPO_ATENCION": tmp["COD_TIEMPO_ATENCION_SIAR"],
                "USUARIO_TRASLADO": usuarioLogin,
                "FECHA_TRASLADO": DateTime.now().toIso8601String(),
                "ESTADO_TRASLADO": "PENDIENTE"
              };

              var udp = await txn.update("SIAR_TIEMPO_ATENCION", map,
                  where: "COD_TIEMPO_ATENCION = ?",
                  whereArgs: [tmp["COD_TIEMPO_ATENCION"]]);
              udp = udp;
            } catch ($e) {
              Log.escribir($e.toString());
            }
          }
        });

        tiempos = [];

        //Recuperamos los PUT , PREVIAMENTE MODIFICADOS
        var dsput = await bdx.obtenerRegistrosWhere("SIAR_TIEMPO_ATENCION",
            condiciones: {"ESTADO_TRASLADO": "PENDIENTE"});

        // Filtrar PUT
        List<Map<String, dynamic>> puts = dsput
            .where((item) => (item["JSON_PUT"] ?? "").isNotEmpty)
            .map((e) => Map<String, dynamic>.from(e))
            .toList();

        //Procesamos los registros PUT
        for (var p in puts) {
          if ((p["JSON_PUT"] ?? "").isNotEmpty) {
            Map<String, dynamic> jsonmapdb = jsonDecode(p["JSON_PUT"]);
            jsonmapdb["cod_tiempo_atencion"] = p["COD_TIEMPO_ATENCION"];

            respuestaPost =
                await crudSolicitud.actualizarFinTiempoAtencion(jsonmapdb);
            if (respuestaPost.idInsertado! > 0) {
              tiempos.add({
                "COD_TIEMPO_ATENCION": p["COD_TIEMPO_ATENCION"],
                "COD_TIEMPO_ATENCION_SIAR": respuestaPost.idInsertado
              });
            }
          }
        }

        //Actualizamos el estado a los documentos en modo local offline
        await bd.transaction((txn) async {
          for (var tmp in tiempos) {
            try {
              Map<String, dynamic> map = {
                "USUARIO_TRASLADO": usuarioLogin,
                "FECHA_TRASLADO": DateTime.now().toIso8601String(),
                "ESTADO_TRASLADO": "PROCESADA"
              };

              await txn.update("SIAR_TIEMPO_ATENCION", map,
                  where: "COD_TIEMPO_ATENCION = ?",
                  whereArgs: [tmp["COD_TIEMPO_ATENCION"]]);
            } catch ($e) {
              Log.escribir($e.toString());
            }
          }
        });
      }
    } catch ($e) {
      print($e.toString());
      Log.escribir($e.toString());
    }
  }
}
