import 'package:flutter/material.dart';
import 'package:jasec/class/crudproducto.dart';
import 'package:jasec/class/crudtransfererencias.dart';
import 'package:jasec/model/vmdetalletransferencia.dart';
import 'package:jasec/model/vmrespuestapost.dart';
import 'package:jasec/screen/agregarmaterialestransferencia.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:jasec/utilidades/utilidades.dart';
import 'package:jasec/widget/barramensaje.dart';
import 'package:jasec/widget/widget.dart';

// ignore: must_be_immutable
class CrearTransferencia extends StatefulWidget {
  List<Map<String, dynamic>> produtosRecibidos;

  CrearTransferencia(this.produtosRecibidos, {super.key});

  @override
  State<CrearTransferencia> createState() => _CrearTransferenciaState();
}

class _CrearTransferenciaState extends State<CrearTransferencia> {
  int idBodegaOrigen = 0;
  int idBodegaDestino = 0;

  String? idMovimiento = "";

  int? codTransferencia = 0;

  final List<bool> _expanded = [true, true];

  final TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> mapBodega = [];
  List<Map<String, dynamic>> mapBodegaOrigen = [];
  List<Map<String, dynamic>> mapBodegaDestino = [];
  List<String> mapMovimientos = [
    "ENTRADA",
    "SALIDA",
    "TRANSFERENCIA",
  ];

  VmDetalleTransferencia productos = VmDetalleTransferencia();
  VmDetalleTransferencia productosFiltrados = VmDetalleTransferencia();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      cargarBodegas().then((r) {
        actualizaBodegaDestino();
      });
    });

    searchController.addListener(_filterData);
  }

  @override
  void dispose() {
    searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    // Panel 0: Movimiento
                    ExpansionPanel(
                      highlightColor: colorAzulSecundario,
                      backgroundColor: colorAcua,
                      headerBuilder: (context, isExpanded) {
                        return ListTile(
                          title: Etiqueta(
                            texto: lblmovimiento,
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
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: ListaSeleccionTexto(
                                    textoEtiqueta: lblmovimiento,
                                    tamanofuente: tamanoFuente10px,
                                    opciones: mapMovimientos,
                                    valorSeleccionado: (idMovimiento),
                                    onChanged: (String? mov) async {
                                      if (mov!.isNotEmpty &&
                                          idBodegaOrigen > 0 &&
                                          idBodegaDestino > 0 &&
                                          codTransferencia == 0) {
                                        await guardarTransferencia();
                                      }
                                      setState(() {
                                        idMovimiento = mov;
                                      });
                                    },
                                  ),
                                ),
                                Espacio(alto: 10),
                                Expanded(
                                  flex: 2,
                                  child: ListaSeleccion(
                                      habilitado: false,
                                      tamanoFuente: tamanoFuente8px,
                                      textoEtiqueta: lblBodegaOrigen,
                                      mapaDatos: mapBodegaOrigen,
                                      idKey: "cod_bodega",
                                      nameKey: "des_bodega",
                                      selectedValue: (idBodegaOrigen > 0)
                                          ? idBodegaOrigen
                                          : null,
                                      onChanged: (int? value) async {
                                        idBodegaOrigen = value!;

                                        if (codTransferencia! > 0) {
                                          cargarProductosTransferencia();
                                        }

                                        await actualizaBodegaDestino();
                                        setState(() {});
                                      }),
                                ),
                                Espacio(alto: 25),
                                Expanded(
                                  flex: 2,
                                  child: ListaSeleccion(
                                      tamanoFuente: tamanoFuente8px,
                                      textoEtiqueta: lblBodegaDestino,
                                      mapaDatos: mapBodegaDestino,
                                      idKey: "cod_bodega",
                                      nameKey: "des_bodega",
                                      selectedValue: (idBodegaDestino > 0)
                                          ? idBodegaDestino
                                          : null,
                                      onChanged: (int? value) async {
                                        idBodegaDestino = value!;
                                        //si ya selecciono los 3 datos se crea la transferencia con los materiales recibibos de la pantalla inicial
                                        if (idMovimiento!.isNotEmpty &&
                                            idBodegaOrigen > 0 &&
                                            value > 0 &&
                                            codTransferencia == 0) {
                                          await guardarTransferencia();
                                        }
                                        setState(() {
                                          idBodegaDestino = value;
                                        });
                                      }),
                                ),
                                Espacio(alto: 25),
                                (codTransferencia! > 0)
                                    ? IconButton(
                                        tooltip: lblagregarmateriales,
                                        icon: Icon(
                                          Icons.add,
                                          color: colorVerdeSecundario,
                                          size: 30,
                                        ),
                                        onPressed: () async {
                                          if (idBodegaOrigen > 0 &&
                                              idBodegaDestino > 0) {
                                            await MostrarWidgetEnDialogo(
                                                    context,
                                                    AgregarMaterialesTransferencia(
                                                        codTransferencia
                                                            .toString(),
                                                        idBodegaOrigen
                                                            .toString()),
                                                    '$lbltransferenciamateriales (# $codTransferencia)')
                                                .then((r) async {
                                              await cargarProductosTransferencia();
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
                              ],
                            ),
                          ],
                        ),
                      ),
                      isExpanded: _expanded[0],
                    ),

                    // Panel 1: Lista de Materiales de la transferencias
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
                                                  label: Etiqueta(
                                                texto: lblaccion,
                                                tamanoFuente:
                                                    tamanoFuenteSecundaria,
                                                tipo: FontWeight.bold,
                                              ))
                                            ],
                                            rows: productosFiltrados.items!
                                                .map((item) => DataRow(cells: [
                                                      DataCell(Etiqueta(
                                                        texto: item.codProducto
                                                            .toString(),
                                                        color: colorNegro,
                                                        tamanoFuente:
                                                            tamanoFuenteSecundaria,
                                                      )),
                                                      DataCell(Etiqueta(
                                                        texto:
                                                            item.nomProducto!,
                                                        color: colorNegro,
                                                        tamanoFuente:
                                                            tamanoFuenteSecundaria,
                                                      )),
                                                      DataCell(Etiqueta(
                                                        texto: item.existencia
                                                            .toString(),
                                                        color: colorNegro,
                                                        tamanoFuente:
                                                            tamanoFuenteSecundaria,
                                                      )),
                                                      DataCell(Etiqueta(
                                                        texto: item.cantidad
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
                                                          (item.existencia! > 0)
                                                              ? IconButton(
                                                                  icon: Icon(
                                                                    Icons.edit,
                                                                    color:
                                                                        colorAmarrillo,
                                                                  ),
                                                                  onPressed:
                                                                      () async {
                                                                    double?
                                                                        cantidad =
                                                                        await showDialog<
                                                                            double>(
                                                                      context:
                                                                          context,
                                                                      builder: (context) => dialogoCantidad(
                                                                          context,
                                                                          cantidadActul: item
                                                                              .cantidad
                                                                              .toString(),
                                                                          existencia:
                                                                              item.existencia!),
                                                                    );

                                                                    if (cantidad! >
                                                                        0) {
                                                                      await actualizarCantidadMaterial(
                                                                          item.codDetMateriales,
                                                                          cantidad);
                                                                    }
                                                                  },
                                                                )
                                                              : IconButton(
                                                                  tooltip:
                                                                      lblsinexistencia,
                                                                  onPressed:
                                                                      () {
                                                                    BarraMensaje(context).Mensaje(
                                                                        lblsinexistencia,
                                                                        colorFondo:
                                                                            colorAmarrillo,
                                                                        colorFuente:
                                                                            colorBlanco);
                                                                  },
                                                                  icon: Icon(
                                                                    Icons.block,
                                                                    color:
                                                                        colorRojoPrimario,
                                                                  )),
                                                          IconButton(
                                                            icon: Icon(
                                                              Icons.delete,
                                                              color:
                                                                  colorRojoPrimario,
                                                            ),
                                                            onPressed:
                                                                () async {
                                                              await eliminarMaterial(
                                                                  item.codDetMateriales);
                                                            },
                                                          )
                                                        ],
                                                      ))
                                                    ]))
                                                .toList()),
                                      )
                                    : Center(
                                        child: Etiqueta(
                                            texto: lblNoData,
                                            color: colorRojoPrimario))
                              ],
                            )
                          ],
                        ),
                      ),
                      isExpanded: _expanded[1],
                    )
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(flex: 2, child: Espacio(alto: 100)),
                Expanded(
                    flex: 1,
                    child: Boton(
                      tamanoFuente: tamanoFuente10px,
                      bordenRedondeado: 25,
                      textoEtiqueta: lblguardar,
                      colorFondo: colorAzulPrimario,
                      colorTexto: colorBlanco,
                      onPressed: () async {
                        if (codTransferencia! > 0) {
                          await actualizarTransferencia();
                        } else {
                          await crearTransferencia();
                        }
                      },
                    )),
                Espacio(alto: 25),
                Expanded(
                    flex: 1,
                    child: Boton(
                      tamanoFuente: tamanoFuente10px,
                      bordenRedondeado: 25,
                      textoEtiqueta: lblcancelar,
                      colorFondo: colorGrisPrimario,
                      colorTexto: colorBlanco,
                      onPressed: () async {
                        bool? confirmacion = await DialogoConfirmacion(
                            context, lblconfirme, lblconfirmacancelaroperacion);
                        if (confirmacion!) {
                          await eliminarTransferencia().then((r) {
                            irConsultaInventario();
                          });
                        } else {
                          irConsultaInventario();
                        }
                      },
                    ))
              ],
            )
          ],
        ),
      ),
    );
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

  Future<void> cargarBodegas() async {
    CrudProducto producto = CrudProducto();
    //Listado de provincias
    await producto.traerBodegas().then(
      (resp) {
        setState(() {
          mapBodega = resp.items!.map((item) => item.toJson()).toList();
          mapBodegaOrigen = resp.items!.map((item) => item.toJson()).toList();
          mapBodegaDestino = resp.items!.map((item) => item.toJson()).toList();
          if (!esAdmin()) {
            idBodegaOrigen = codBodegaUsuario!;
          }
        });
      },
    );
  }

  Future<void> actualizaBodegaDestino() async {
    mapBodegaDestino.removeWhere((w) => w['cod_bodega'] == idBodegaOrigen);
  }

  Future<void> cargarProductosTransferencia() async {
    CrudTransferencias transferencia = CrudTransferencias();

    //Loading minetras autentica
    DialogoProgreso(context, lblprocesando, lblprocesando, Icons.network_check,
        widget: Center(
            child: SizedBox(width: 200, height: 200, child: progresoCirculo())),
        cerrar: false);
    try {
      productos = await transferencia.traerDetalleTransferencia(
          codTransferencia.toString(), idBodegaOrigen.toString());

      if (productos.items != null) {
        productosFiltrados.items = productos.items!
            .map((item) => ItemDetalleTransferencia(
                codDetMateriales: item.codDetMateriales,
                codEncMateriales: item.codEncMateriales,
                codProducto: item.codProducto,
                nomProducto: item.nomProducto,
                existencia: item.existencia,
                cantidad: item.cantidad))
            .toList();
        setState(() {});
      }
    } catch ($e) {
      Navigator.of(context).pop();
    } finally {
      // Siempre cerrar el loading
      Navigator.of(context).pop();
    }
  }

  Future<void> guardarTransferencia() async {
    await crearTransferencia().then((r) async {
      if (codTransferencia! > 0 && widget.produtosRecibidos.isNotEmpty) {
        await crearDetalleTransferecias().then((x) async {
          if (codTransferencia! > 0) {
            await cargarProductosTransferencia();
          }
        });
      }
    });
  }

  Future<void> crearTransferencia() async {
    CrudTransferencias crearTransferencia = CrudTransferencias();
    VmRespuestaPost vm = VmRespuestaPost();

    try {
      Map<String, dynamic> mapTransferencia = {
        "cod_bodega_origen": idBodegaOrigen,
        "cod_bodega_destino": idBodegaDestino,
        "tipo_movimiento": idMovimiento!.substring(0, 1),
        "estado": EstadosOperacionesMateriales.REG.name,
        "ind_luminaria": luminaria,
        "ind_servicio_tecnico": (luminaria == "S") ? "N" : "S",
        "usuario_insert": usuarioLogin,
      };

      vm = await crearTransferencia.guardarTransferencia(mapTransferencia);
      if (vm.idInsertado != null) {
        if (vm.idInsertado! > 0) {
          codTransferencia = vm.idInsertado ?? 0;
          BarraMensaje(context).Mensaje(
              '$lbltransferencia $codTransferencia, $lblGuardoInformacion',
              colorFondo: colorVerdeSecundario);
        }
      }
    } catch ($e) {
      BarraMensaje(context)
          .Mensaje($e.toString(), colorFondo: colorRojoPrimario);
    }
  }

  Future<void> actualizarTransferencia() async {
    CrudTransferencias crudTransferencia = CrudTransferencias();
    VmRespuestaPost vm = VmRespuestaPost();

    //Loading minetras autentica
    DialogoProgreso(context, lblprocesando, lblprocesando, Icons.network_check,
        widget: Center(
            child: SizedBox(width: 200, height: 200, child: progresoCirculo())),
        cerrar: false);
    try {
      Map<String, dynamic> mapTransferencia = {
        "cod_enc_movimiento": codTransferencia,
        "cod_bodega_origen": idBodegaOrigen,
        "cod_bodega_destino": idBodegaDestino,
        "tipo_movimiento": idMovimiento!.substring(0, 1),
        "fecha_aplicacion": formatoFechaDB(DateTime.now()),
        "estado": "R",
        "ind_luminaria": luminaria,
        "ind_servicio_tecnico": (luminaria == "S") ? "N" : "S",
      };
      vm = await crudTransferencia.actualizarTransferencia(mapTransferencia);

      if (vm.idInsertado != null) {
        if (vm.idInsertado! > 0) {
          BarraMensaje(context).Mensaje(
              '$lbltransferencia, $lblActualizoInformacion',
              colorFondo: colorVerdeSecundario);
        }
      }
    } catch ($e) {
      Navigator.of(context).pop();
    } finally {
      Navigator.of(context).pop();
    }
  }

  Future<void> eliminarTransferencia() async {
    CrudTransferencias crudTransferencia = CrudTransferencias();
    VmRespuestaPost vm = VmRespuestaPost();

    //Loading minetras autentica
    DialogoProgreso(context, lblprocesando, lblprocesando, Icons.network_check,
        widget: Center(
            child: SizedBox(width: 200, height: 200, child: progresoCirculo())),
        cerrar: false);
    try {
      Map<String, dynamic> mapTransferencia = {
        "cod_enc_movimiento": codTransferencia
      };
      vm = await crudTransferencia.eliminarTransferencia(mapTransferencia);

      if (vm.idInsertado != null) {
        if (vm.idInsertado! > 0) {
          irConsultaInventario();
        }
      }
    } catch ($e) {
      Navigator.of(context).pop();
    } finally {
      Navigator.of(context).pop();
    }
  }

  Future<void> eliminarMaterial(int? codDetMateriales) async {
    CrudTransferencias crudTransferencia = CrudTransferencias();
    VmRespuestaPost vm = VmRespuestaPost();

    try {
      Map<String, dynamic> mapTransferencia = {
        "cod_det_materiales": codDetMateriales
      };
      vm = await crudTransferencia
          .eliminarDetalleTransferencia(mapTransferencia);
      if (vm.idInsertado != null) {
        if (vm.idInsertado! > 0) {
          await cargarProductosTransferencia();
        }
      }
    } catch ($e) {
      BarraMensaje(context)
          .Mensaje($e.toString(), colorFondo: colorRojoPrimario);
    }
  }

  Future<void> actualizarCantidadMaterial(
      int? codDetTransferencia, double cantidad) async {
    CrudTransferencias cls = CrudTransferencias();
    VmRespuestaPost vm = VmRespuestaPost();

    try {
      List<Map<String, dynamic>> detalleAcutualizar = [];
      Map<String, dynamic> detallerequisicion = {
        "cod_det_materiales": codDetTransferencia,
        "cantidad": cantidad,
        "observaciones": ''
      };
      detalleAcutualizar.add(detallerequisicion);
      vm = await cls.actualizarDetalleTransferencia(detalleAcutualizar);
      if (vm.idInsertado != null) {
        if (vm.idInsertado! > 0) {
          await cargarProductosTransferencia();
        }
      }
    } catch ($e) {
      BarraMensaje(context)
          .Mensaje($e.toString(), colorFondo: colorRojoPrimario);
    }
  }

  Future<void> crearDetalleTransferecias() async {
    CrudTransferencias cls = CrudTransferencias();
    VmRespuestaPost vm = VmRespuestaPost();

    try {
      List<Map<String, dynamic>> listado = [];
      for (var p in widget.produtosRecibidos) {
        Map<String, dynamic> mapRequisicion = {
          "cod_enc_materiales": codTransferencia,
          "cod_producto": p['cod_siar_producto'],
          "cantidad": p[lblcantidad],
          "usuario_insert": usuarioLogin,
          "observaciones": usuarioLogin,
        };

        listado.add(mapRequisicion);
      }

      vm = await cls.guardarDetalleTransferencia(listado);
      if (vm.idInsertado != null) {
        if (vm.idInsertado! > 0) {
          BarraMensaje(context).Mensaje(
              'Detalles de $lbltransferencia, $lblGuardoInformacion',
              colorFondo: colorVerdeSecundario);
        }
      }
    } catch ($e) {
      BarraMensaje(context)
          .Mensaje($e.toString(), colorFondo: colorRojoPrimario);
    }
  }

  void irConsultaInventario() {
    Navigator.popAndPushNamed(context, "inicio", arguments: {
      lblopcionprincipal: 5.1, //Consulta de inventario
      lblnombreopcion: lblconsultadeinventario,
      lblllave: 0,
      lblimagenopcion: urlimagenmateriales
    });
  }
}
