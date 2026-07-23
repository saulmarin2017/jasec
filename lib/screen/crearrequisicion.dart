import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jasec/class/crudproducto.dart';
import 'package:jasec/class/crudrequisiciones.dart';
import 'package:jasec/class/log.dart';
import 'package:jasec/db/db.dart';
import 'package:jasec/model/model.dart';
import 'package:jasec/model/vmdetallerequisiones.dart';
import 'package:jasec/model/vmproducto.dart';
import 'package:jasec/screen/agregarmaterialesrequisicion.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:jasec/utilidades/utilidades.dart';
import 'package:jasec/widget/barramensaje.dart';
import 'package:jasec/widget/widget.dart';

// ignore: must_be_immutable
class CrearRequisicion extends StatefulWidget {
  List<Map<String, dynamic>> produtosRecibidos;

  CrearRequisicion(this.produtosRecibidos, {super.key});

  @override
  State<CrearRequisicion> createState() => _CrearRequisicionState();
}

class _CrearRequisicionState extends State<CrearRequisicion> {
  int idTipoAtencion = 0;
  int idTipoCuenta = 0;
  int idMaterial = 0;
  bool botonVisibles = false;
  int? codRequisicion = 0;
  int idBodegaSeleccionada = 0;

  final List<bool> _expanded = [true, true];

  Map<String, String> mapSeleccion = {};

  List<Map<String, dynamic>> mapProductosSeleccionados = [];
  List<Map<String, dynamic>> mapBodegas = [];

  VmDetalleRequisiciones productosFiltrados = VmDetalleRequisiciones(items: []);
  VmDetalleRequisiciones productos = VmDetalleRequisiciones(items: []);

  final TextEditingController searchController = TextEditingController();
  final TextEditingController nivelController = TextEditingController();
  final TextEditingController fechaController = TextEditingController();

  bool cargandoBodegas = true;
  bool creoReq = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      cargarBodegas();

      if (!creoReq) {
        creoReq = true;
        if (widget.produtosRecibidos.isNotEmpty) {
          guardarRequisicion();
        }
      }
    });

    searchController.addListener(_filterData);
  }

  @override
  void dispose() {
    searchController.dispose(); // <-- esto falta

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var datos = productos.items ?? [];

    if (datos.isEmpty && codRequisicion == 0) {
      return progresoCirculo();
    }

    return Padding(
      padding: EdgeInsets.all(5),
      child: Form(
        child: Column(
          children: [
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
                            dense: true,
                            title: Etiqueta(
                              texto:
                                  '$lblagregarmateriales / $lblrequisicion (# ${codRequisicion ?? 0.toString()})',
                              tipo: FontWeight.bold,
                              color: colorBlanco,
                              tamanoFuente: tamanoFuente14px,
                            ));
                      },
                      body: Container(
                        padding: EdgeInsets.all(10),
                        color: colorBlanco,
                        child: Wrap(
                          children: [
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Expanded(
                                      flex: 1,
                                      child: TextBoxForm(
                                        controlador: nivelController,
                                        textoEtiqueta: lblNivel,
                                        tipo: TextInputType.text,
                                        negrilla: FontWeight.bold,
                                        propiedadFormulario: 'nivel',
                                      )),
                                  Espacio(alto: 10),
                                  Expanded(
                                    flex: 2,
                                    child: SizedBox(
                                        child: cargandoBodegas
                                            ? progresoCirculo()
                                            : ListaSeleccion(
                                                habilitado: false,
                                                tamanoFuente: tamanoFuente10px,
                                                textoEtiqueta: lblBodegaOrigen,
                                                mapaDatos: mapBodegas,
                                                idKey: "cod_bodega",
                                                nameKey: "des_bodega",
                                                selectedValue:
                                                    (idBodegaSeleccionada > 0)
                                                        ? idBodegaSeleccionada
                                                        : null,
                                                onChanged: (int? value) {
                                                  setState(() {
                                                    idBodegaSeleccionada =
                                                        value!;
                                                  });
                                                })),
                                  ),
                                  Espacio(alto: 10),
                                  Expanded(
                                      child: TextBoxForm(
                                    textoEtiqueta: lblfecha,
                                    controlador: fechaController,
                                    propiedadFormulario: '',
                                    tipo: TextInputType.datetime,
                                    onTap: () async {
                                      DateTime? piker =
                                          await campoFecha(context);

                                      if (piker != null) {
                                        setState(() {
                                          fechaController.text =
                                              formatoFechaPantalla(piker);
                                        });
                                      }
                                    },
                                  )),
                                  (codRequisicion! > 0 &&
                                          idBodegaSeleccionada > 0)
                                      ? IconButton(
                                          icon: Icon(
                                            Icons.add,
                                            color: colorVerdeSecundario,
                                            size: 30,
                                          ),
                                          onPressed: () async {
                                            if (idBodegaSeleccionada > 0) {
                                              await MostrarWidgetEnDialogo(
                                                      context,
                                                      AgregarMaterialesRequisicion(
                                                          codRequisicion
                                                              .toString(),
                                                          idBodegaSeleccionada
                                                              .toString()),
                                                      '$lblagregarmateriales Requisición (# $codRequisicion)')
                                                  .then((r) async {
                                                await cargarProductosRequisicion();

                                                setState(() {});
                                              });
                                            } else {
                                              BarraMensaje(context).Mensaje(
                                                  lbldebeseleccionarbodega,
                                                  colorFondo: colorAmarrillo,
                                                  colorFuente: colorBlanco);
                                              return;
                                            }
                                          },
                                        )
                                      : Text('')
                                ]),
                          ],
                        ),
                      ),
                      isExpanded: _expanded[0],
                    ),
                    // Panel 1: Datos del Solicitante
                    ExpansionPanel(
                      highlightColor: colorAzulSecundario,
                      backgroundColor: colorAcua,
                      headerBuilder: (context, isExpanded) {
                        return ListTile(
                          dense: true,
                          title: Etiqueta(
                            texto: lblmateriales,
                            tipo: FontWeight.bold,
                            color: colorBlanco,
                            tamanoFuente: tamanoFuente14px,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: anchoUtil(context) / 4,
                                height: 40,
                                child: TextBoxForm(
                                  controlador: searchController,
                                  propiedadFormulario: '',
                                  icono: Icons.search,
                                ),
                              ),
                              IconButton(
                                  onPressed: () {
                                    FocusScope.of(context).unfocus();
                                  },
                                  icon: Icon(Icons.keyboard_hide_outlined)),
                            ],
                          ),
                        );
                      },
                      body: Container(
                        padding: EdgeInsets.all(10),
                        color: colorBlanco,
                        child: Wrap(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                (productosFiltrados.items != null)
                                    ? Expanded(
                                        child: DataTable(
                                            columnSpacing: 15,
                                            columns: [
                                              DataColumn(
                                                  label: Etiqueta(
                                                texto: lblcodigo,
                                                tamanoFuente:
                                                    tamanoFuenteSecundaria,
                                                tipo: FontWeight.bold,
                                              )),
                                              DataColumn(
                                                  label: Etiqueta(
                                                texto: lblnombrematerial,
                                                tamanoFuente:
                                                    tamanoFuenteSecundaria,
                                                tipo: FontWeight.bold,
                                              )),
                                              DataColumn(
                                                  label: Etiqueta(
                                                texto: lblexistencia,
                                                tamanoFuente:
                                                    tamanoFuenteSecundaria,
                                                tipo: FontWeight.bold,
                                              )),
                                              DataColumn(
                                                  label: Etiqueta(
                                                texto: lblcantidad,
                                                tamanoFuente:
                                                    tamanoFuenteSecundaria,
                                                tipo: FontWeight.bold,
                                              )),
                                              DataColumn(
                                                  label: Center(
                                                child: Etiqueta(
                                                  texto: lblaccion,
                                                  tamanoFuente:
                                                      tamanoFuenteSecundaria,
                                                  tipo: FontWeight.bold,
                                                ),
                                              ))
                                            ],
                                            rows: List.generate(
                                              productosFiltrados.items!.length,
                                              (index) {
                                                var producto =
                                                    productosFiltrados
                                                        .items![index];

                                                return DataRow(
                                                  cells: [
                                                    DataCell(Etiqueta(
                                                      texto: producto
                                                              .codProducto ??
                                                          "",
                                                      color: colorNegro,
                                                      tamanoFuente:
                                                          tamanoFuenteSecundaria,
                                                    )),
                                                    DataCell(Etiqueta(
                                                      texto: producto
                                                              .nomProducto ??
                                                          "",
                                                      color: colorNegro,
                                                      tamanoFuente:
                                                          tamanoFuenteSecundaria,
                                                    )),
                                                    DataCell(Etiqueta(
                                                      texto: producto.existencia
                                                          .toString(),
                                                      color: colorNegro,
                                                      tamanoFuente:
                                                          tamanoFuenteSecundaria,
                                                    )),
                                                    DataCell(Etiqueta(
                                                      texto: producto.cantidad
                                                          .toString(),
                                                      color: colorNegro,
                                                      tamanoFuente:
                                                          tamanoFuenteSecundaria,
                                                    )),
                                                    DataCell(Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        IconButton(
                                                          icon: Icon(
                                                            Icons.edit,
                                                            color:
                                                                colorAmarrillo,
                                                          ),
                                                          onPressed: () async {
                                                            double? cantidad =
                                                                await showDialog<
                                                                    double>(
                                                              context: context,
                                                              builder: (context) =>
                                                                  dialogoCantidad(
                                                                      context,
                                                                      cantidadActul: producto
                                                                          .cantidad
                                                                          .toString()),
                                                            );

                                                            if (cantidad! > 0) {
                                                              await actualizarCantidadMaterial(
                                                                  producto
                                                                      .codDetRequisiciones,
                                                                  cantidad);

                                                              setState(() {});
                                                            }
                                                          },
                                                        ),
                                                        IconButton(
                                                          icon: Icon(
                                                            Icons.delete,
                                                            color:
                                                                colorRojoPrimario,
                                                          ),
                                                          onPressed: () async {
                                                            await eliminarMaterial(
                                                                producto
                                                                    .codDetRequisiciones);
                                                            setState(() {});
                                                          },
                                                        )
                                                      ],
                                                    )),
                                                  ],
                                                );
                                              },
                                            )),
                                      )
                                    : Center(
                                        child: Etiqueta(
                                        texto: lblNoData,
                                        color: colorRojoPrimario,
                                      ))
                              ],
                            )
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
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Spacer(),
                Expanded(
                    child: Boton(
                  textoEtiqueta: lblguardar,
                  bordenRedondeado: 50,
                  colorTexto: colorBlanco,
                  onPressed: () async {
                    if (codRequisicion! > 0) {
                      await actualizarRequisicion();
                    } else {
                      await crearRequisicion();
                    }
                  },
                )),
                Espacio(alto: 10),
                Expanded(
                    child: Boton(
                  textoEtiqueta: lblcancelar,
                  colorFondo: colorGrisPrimario,
                  colorTexto: colorBlanco,
                  bordenRedondeado: 50,
                  onPressed: () async {
                    bool? confirmacion = await DialogoConfirmacion(
                        context, lblconfirme, lblconfirmacancelaroperacion,
                        colorFonfoTitulo: colorRojoPrimario);
                    if (confirmacion!) {
                      await eliminarRequisicion().then((r) {
                        irConsultaInventario();
                      });
                    } else {
                      irConsultaInventario();
                    }
                  },
                )),
              ],
            )
          ],
        ),
      ),
    );
  }

  void irConsultaInventario() {
    Navigator.popAndPushNamed(context, "inicio", arguments: {
      lblopcionprincipal: 5.1, //Consulta de inventario
      lblnombreopcion: lblconsultadeinventario,
      lblllave: 0,
      lblimagenopcion: urlimagenmateriales
    });
  }

  Future<void> eliminarRequisicion() async {
    CrudRequisiciones crudrecquisiciones = CrudRequisiciones();
    VmRespuestaPost vm = VmRespuestaPost();

    //Loading minetras autentica
    DialogoProgreso(context, lblprocesando, lblprocesando, Icons.network_check,
        widget: Center(
            child: SizedBox(width: 200, height: 200, child: progresoCirculo())),
        cerrar: false);
    try {
      Map<String, dynamic> mapTransferencia = {
        "cod_requisiciones": codRequisicion
      };

      if (!conexionInternet) {
        final bd = db.instance;
        vm.idInsertado = await bd.eliminar(
            "SIAR_DETALLE_REQUISICION", "cod_requisiciones", codRequisicion);
        vm.idInsertado =
            await bd.eliminar("SIAR_REQUISICION", "rowid", codRequisicion);
        return;
      }

      vm = await crudrecquisiciones.eliminarRequisicion(mapTransferencia);

      if (vm.idInsertado != null) {
        if (vm.idInsertado! > 0) {}
      }
    } catch ($e) {
      Navigator.of(context).pop();
    } finally {
      Navigator.of(context).pop();
    }
  }

  void _filterData() {
    String query = searchController.text.toLowerCase();
    setState(() {
      if (query.isNotEmpty) {
        productosFiltrados.items = productos.items!.where((orden) {
          return orden.codProducto.toString().toLowerCase().contains(query) ||
              orden.nomProducto!.toLowerCase().contains(query);
        }).toList();
      } else {
        productosFiltrados.items = productos.items!.toList();
      }
    });
  }

  Future<void> guardarRequisicion() async {
    await crearRequisicion().then((r) async {
      if (codRequisicion! > 0) {
        await crearDetalleRequisicion().then((x) async {
          if (codRequisicion! > 0) {
            await cargarProductosRequisicion().then((x) {});
          }
        });
      }
    });

    setState(() {});
  }

  Future<void> cargarProductosRequisicion() async {
    if (!conexionInternet) {
      productos = await traerDetalleRequisicionLocal();
      productosFiltrados.items = productos.items!;
      return;
    }
    CrudRequisiciones requisiciones = CrudRequisiciones();

    //Loading minetras autentica
    DialogoProgreso(context, lblprocesando, lblprocesando, Icons.network_check,
        widget: Center(
            child: SizedBox(width: 200, height: 200, child: progresoCirculo())),
        cerrar: false);
    try {
      productos = await requisiciones
          .traerDetalleRequisicion(codRequisicion.toString());

      if (productos.items != null) {
        productosFiltrados.items = productos.items!
            .map((item) => ItemDetalleRequisiones(
                codDetRequisiciones: item.codDetRequisiciones,
                codProducto: item.codProducto,
                nomProducto: item.nomProducto,
                existencia: item.existencia,
                cantidad: item.cantidad))
            .toList();
      }
    } catch ($e) {
      Navigator.of(context).pop();
    } finally {
      // Siempre cerrar el loading
      Navigator.of(context).pop();
    }
  }

  Future<void> crearRequisicion() async {
    CrudRequisiciones crudrequisiones = CrudRequisiciones();
    VmRespuestaPost vm = VmRespuestaPost();
    DateTime fecha;
    String fechaDB = "";

    try {
      String fechaTexto = fechaController.text.trim();

      if (fechaTexto.isNotEmpty) {
        fecha = DateFormat("dd/MM/yyyy").parse(fechaTexto);
      } else {
        fecha = DateTime.now();
      }

      fechaDB = formatoFechaDB(fecha);

      Map<String, dynamic> mapRequisicion = {
        "fecha_solicitud": fechaDB,
        "cod_bodega": codBodegaUsuario,
        "nivel": nivelController.text,
        "ind_luminarias":
            (perfilUsuario == PerfilUsuario.AlumbradoPublicoLuminaria)
                ? "S"
                : "N",
        "ind_servicio_tecnico":
            (perfilUsuario == PerfilUsuario.ServicioTecnico) ? "S" : "N",
        "POST_PUT": "POST",
        "estado": EstadosRequisiciones.ENV.name,
        "usuario_insert": usuarioLogin,
        "cod_cuadrilla": codCuadrillaUsaurio
      };

      //Se almacena local en sqlite
      if (!conexionInternet) {
        try {
          final bdx = db.instance;
          mapRequisicion["JSON"] = jsonEncode(mapRequisicion);
          codRequisicion =
              await bdx.insertar(mapRequisicion, "SIAR_REQUISICION");
        } catch ($e) {
          Log.escribir(e.toString());
        }

        if (!mounted) return;

        if (codRequisicion! > 0) {
          BarraMensaje(context).Mensaje(
              '$lblrequisicion $codRequisicion, $lblGuardoInformacion',
              colorFondo: colorVerdeSecundario);
        }
        return;
      }

      //En linea
      vm = await crudrequisiones.guardarRequisicion(mapRequisicion);

      if (!mounted) return;

      if (vm.idInsertado != null && vm.idInsertado! > 0) {
        codRequisicion = vm.idInsertado!;
        BarraMensaje(context).Mensaje(
          '$lblrequisicion $codRequisicion, $lblGuardoInformacion',
          colorFondo: colorVerdeSecundario,
        );
      }
    } catch ($e) {
      if (!mounted) return;
      BarraMensaje(context)
          .Mensaje($e.toString(), colorFondo: colorRojoPrimario);
    }
  }

  Future<void> actualizarRequisicion() async {
    CrudRequisiciones crudrequisiones = CrudRequisiciones();
    VmRespuestaPost vm = VmRespuestaPost();

    DateTime fecha;
    String fechaDB = "";
    try {
      fecha = DateFormat('dd/MM/yyyy').parse(fechaController.text);
      fechaDB = formatoFechaDB(fecha);
    } catch (e) {
      print("Error al convertir la fecha: $e");
    }

    Map<String, dynamic> mapRequisicion = {
      "cod_requisiciones": "$codRequisicion",
      "fecha_solicitud": fechaDB,
      "cod_bodega": codBodegaUsuario,
      "nivel": nivelController.text,
      "ind_luminarias":
          (perfilUsuario == PerfilUsuario.AlumbradoPublicoLuminaria)
              ? "S"
              : "N",
      "ind_servicio_tecnico":
          (perfilUsuario == PerfilUsuario.ServicioTecnico) ? "S" : "N",
      "POST_PUT": "POST",
      "estado": EstadosRequisiciones.REG.name,
      "usuario_insert": usuarioLogin,
      "cod_cuadrilla": codCuadrillaUsaurio
    };

    if (!conexionInternet) {
      var bd = db.instance;
      mapRequisicion["JSON"] = jsonEncode(mapRequisicion);
      await bd.actualizar("SIAR_REQUISICION", mapRequisicion,
          "cod_requisiciones", codRequisicion);

      return;
    }

    vm = await crudrequisiones.actualizarRequisicion(mapRequisicion);

    if (vm.idInsertado != null) {
      if (vm.idInsertado! > 0) {
        BarraMensaje(context).Mensaje(
            '$lblrequisicion, $lblActualizoInformacion',
            colorFondo: colorVerdeSecundario);
      }
    }
  }

  Future<void> eliminarMaterial(int? codDetRequisiciones) async {
    CrudRequisiciones crudrequisiones = CrudRequisiciones();
    VmRespuestaPost vm = VmRespuestaPost();

    try {
      Map<String, dynamic> mapRequisicion = {
        "cod_det_requisiciones": codDetRequisiciones
      };

      vm = await crudrequisiones.eliminarDetalleRequisicion(mapRequisicion);
      if (vm.idInsertado != null) {
        if (vm.idInsertado! > 0) {
          await cargarProductosRequisicion();
        }
        if (!conexionInternet) {
          await cargarProductosRequisicion();
        }
      }
    } catch ($e) {
      BarraMensaje(context)
          .Mensaje($e.toString(), colorFondo: colorRojoPrimario);
    }
  }

  Future<void> actualizarCantidadMaterial(
      int? codDetRequisiciones, double cantidad) async {
    CrudRequisiciones crudrequisiones = CrudRequisiciones();
    VmRespuestaPost vm = VmRespuestaPost();

    try {
      List<Map<String, dynamic>> detalleAcutualizar = [];
      Map<String, dynamic> detallerequisicion = {
        "cod_det_requisiciones": codDetRequisiciones,
        "cantidad": cantidad
      };
      detalleAcutualizar.add(detallerequisicion);
      vm = await crudrequisiones
          .actualizarDetalleRequisicion(detalleAcutualizar);
      if (vm.idInsertado != null) {
        if (vm.idInsertado! > 0) {
          await cargarProductosRequisicion();
        }
        if (!conexionInternet) {
          await cargarProductosRequisicion();
        }
      }
    } catch ($e) {
      BarraMensaje(context)
          .Mensaje($e.toString(), colorFondo: colorRojoPrimario);
    }
  }

  Future<void> crearDetalleRequisicion() async {
    CrudRequisiciones crudrequisiones = CrudRequisiciones();
    VmRespuestaPost vm = VmRespuestaPost();

    try {
      List<Map<String, dynamic>> listado = [];
      for (var p in widget.produtosRecibidos) {
        Map<String, dynamic> mapRequisicion = {
          "cod_requisiciones": codRequisicion,
          "cod_producto": p['cod_siar_producto'],
          "cantidad": p[lblcantidad],
          "usuario_insert": usuarioLogin
        };

        listado.add(mapRequisicion);
      }

      //Se almacena local en sqlite
      if (!conexionInternet) {
        var id = 0;
        try {
          id = await guardardblocalDetallesRequisicion(listado);
        } catch ($e) {
          Log.escribir($e.toString());
        }

        if (!mounted) return;

        if (id > 0) {
          BarraMensaje(context).Mensaje(
              '$lblrequisicion $codRequisicion, $lblGuardoInformacion',
              colorFondo: colorVerdeSecundario);
        }
        return;
      }

      vm = await crudrequisiones.guardarDetalleRequisicion(listado);

      if (!mounted) return;

      if (vm.idInsertado != null) {
        if (vm.idInsertado! > 0) {
          if (!mounted) return;
          BarraMensaje(context).Mensaje(
              'Detalles de $lblrequisicion, $lblGuardoInformacion',
              colorFondo: colorVerdeSecundario);
        }
      }
    } catch ($e) {
      if (!mounted) return;
      BarraMensaje(context)
          .Mensaje($e.toString(), colorFondo: colorRojoPrimario);
    }
  }

  Future<void> cargarBodegas() async {
    CrudProducto producto = CrudProducto();
    //Listado de provincias
    await producto.traerBodegas().then(
      (resp) {
        cargandoBodegas = false;
        if (!esAdmin()) {
          idBodegaSeleccionada = codBodegaUsuario!;
        }
        fechaController.text = formatoFechaPantalla(DateTime.now());
        mapBodegas = resp.items!.map((item) => item.toJson()).toList();

        //actualizarRequisicion();
      },
    );
  }

  Future<int> guardardblocalRequisicion(Map<String, dynamic> map) async {
    final bd = db.instance;
    int id = 0;

    if (mounted) {
      id = await bd.insertar(map, "SIAR_REQUISICION");
      codRequisicion = id;
    }

    return id;
  }

  Future<int> guardardblocalDetallesRequisicion(
      List<Map<String, dynamic>> detalleRequisiciones) async {
    int x = 0;

    var bd = await db.instance.database;

    await bd.transaction((txn) async {
      for (var map in detalleRequisiciones) {
        try {
          map["JSON"] = jsonEncode(map);
          map["POST_PUT"] = "POST";
          await txn.insert("SIAR_DETALLE_REQUISICION", map);
        } catch ($e) {
          Log.escribir($e.toString());
        }

        x++;
      }
    });

    return x;
  }

  Future<VmDetalleRequisiciones> traerDetalleRequisicionLocal(
      {String bodegaExistencia = ""}) async {
    VmDetalleRequisiciones vm = VmDetalleRequisiciones(items: []);
    final bdz = db.instance;
    var productosReq = await bdz.obtenerRegistros("SIAR_DETALLE_REQUISICION",
        campo: "cod_requisiciones", valor: codRequisicion);

    if (productosReq.isNotEmpty) {
      var productos = vmProductoFromJson(listadosdblocal.first.siarProducto!);
      for (var p in productosReq) {
        ItemDetalleRequisiones det = ItemDetalleRequisiones();

        List<ItemProducto> listaProductos = productos.items!
            .where((w) => w.codSiarProducto == p["COD_PRODUCTO"])
            .toList();

        ItemProducto productoFinal = ItemProducto();

        if (listaProductos.isNotEmpty) {
          productoFinal = listaProductos.first;
        }

        det.codDetRequisiciones = p['COD_DET_REQUISICIONES'];
        det.codProducto = p['COD_PRODUCTO'];
        det.cantidad = p['CANTIDAD'];
        det.codRequisiciones = codRequisicion;
        det.existencia = productoFinal.existencia;
        det.nomProducto = productoFinal.nomProducto;
        vm.items!.add(det);
      }
    }

    return vm;
  }
}
