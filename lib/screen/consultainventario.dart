import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jasec/class/crudproducto.dart';
import 'package:jasec/model/vmproducto.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:jasec/utilidades/utilidades.dart';
import 'package:jasec/widget/barramensaje.dart';
import 'package:jasec/widget/widget.dart';

class ConsultaInventario extends StatefulWidget {
  const ConsultaInventario({super.key});

  @override
  State<ConsultaInventario> createState() => _ConsultaInventarioState();
}

class _ConsultaInventarioState extends State<ConsultaInventario> {
  bool botonVisibles = false;

  //final Set<int> _selectedIndexes = {};

  List<TextEditingController> cantidadControllers = [];

  final List<bool> _expanded = [true, false];

  List<Map<String, dynamic>> mapTipoCuenta = [];
  List<Map<String, dynamic>> mapMateriales = [];

  Map<String, String> mapBusqueda = {
    'NO_CUENTA': '',
    'ID_TIPO_CUENTA': '',
    'ID_MATERIAL': ''
  };

  Map<String, String> mapSeleccion = {};

  List<Map<String, dynamic>> mapProductosSeleccionados = [];

  VmProducto productosFiltrados = VmProducto();
  VmProducto productos = VmProducto();

  final TextEditingController _searchController = TextEditingController();

  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      cargarProductos();
    });

    _searchController.addListener(_filterData);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterData);
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var datos = productos.items ?? [];
    if (datos.isEmpty) {
      return progresoCirculo();
    }

    return Padding(
      padding: EdgeInsets.all(5),
      child: Form(
        child: Column(
          children: [
            Padding(
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
                  // Panel 1: Consulta de Inventario
                  ExpansionPanel(
                      highlightColor: colorAzulSecundario,
                      backgroundColor: colorAcua,
                      headerBuilder: (context, isExpanded) {
                        return ListTile(
                          dense: true,
                          title: Etiqueta(
                            texto: lblconsultadeinventario,
                            tipo: FontWeight.bold,
                            color: colorBlanco,
                            tamanoFuente: tamanoFuenteDefecto,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: anchoUtil(context) / 4,
                                height: 40,
                                child: TextBoxForm(
                                  controlador: _searchController,
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
                                Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
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
                                                label: SizedBox(
                                              width: 250,
                                              child: Etiqueta(
                                                texto: lblnombrematerial,
                                                tamanoFuente:
                                                    tamanoFuenteSecundaria,
                                                tipo: FontWeight.bold,
                                              ),
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
                                            ))
                                          ],
                                          rows: List.generate(
                                            productosFiltrados.items!.length,
                                            (index) {
                                              var producto = productosFiltrados
                                                  .items![index];
                                              //bool isSelected =
                                              //    _selectedIndexes.contains(index);

                                              return DataRow(
                                                color: MaterialStateProperty
                                                    .resolveWith<Color?>(
                                                  (Set<MaterialState> states) {
                                                    int? cantidad =
                                                        int.tryParse(productos
                                                                .items![index]
                                                                .cantidad
                                                                .toString()) ??
                                                            0;
                                                    return cantidad > 0
                                                        ? colorAcua // Color si cantidad > 0
                                                        : null; // Sin color si no cumple
                                                  },
                                                ),
                                                cells: [
                                                  DataCell(SizedBox(
                                                    width:
                                                        anchoUtil(context) / 7,
                                                    child: Etiqueta(
                                                      texto: producto
                                                              .codSiarProducto ??
                                                          "",
                                                      color: colorNegro,
                                                      tamanoFuente:
                                                          tamanoFuente9px,
                                                    ),
                                                  )),
                                                  DataCell(SizedBox(
                                                    width:
                                                        anchoUtil(context) / 3,
                                                    child: Etiqueta(
                                                      texto: producto
                                                              .nomProducto ??
                                                          "",
                                                      color: colorNegro,
                                                      tamanoFuente:
                                                          tamanoFuente9px,
                                                    ),
                                                  )),
                                                  DataCell(SizedBox(
                                                    width: 50,
                                                    child: Etiqueta(
                                                      texto: producto.existencia
                                                          .toString(),
                                                      color: colorNegro,
                                                      tamanoFuente:
                                                          tamanoFuente9px,
                                                    ),
                                                  )),
                                                  DataCell(SizedBox(
                                                    width: 100,
                                                    height: 25,
                                                    child: TextField(
                                                      decoration:
                                                          decoracionTextFieldCantidad(),
                                                      textAlign:
                                                          TextAlign.center,
                                                      controller:
                                                          cantidadControllers[
                                                              index],
                                                      keyboardType:
                                                          TextInputType.number,
                                                      onChanged: (value) async {
                                                        int cantidad =
                                                            int.tryParse(
                                                                    value) ??
                                                                0;
                                                        producto.cantidad =
                                                            cantidad;

                                                        botonVisibles =
                                                            await verificarHabilitaBoton();
                                                      },
                                                    ),
                                                  )),
                                                ],
                                              );
                                            },
                                          )),
                                    ),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                      isExpanded: _expanded[0]),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Spacer(),
                Expanded(
                    child: botonVisibles
                        ? Boton(
                            textoEtiqueta: lblliquidacionmateriales,
                            colorFondo: colorAzulClaro,
                            colorTexto: colorBlanco,
                            onPressed: () async {
                              var validacion =
                                  await procesarProductosSeleccionados(
                                      esRequisicion: false);

                              if (validacion) {
                                if (conexionInternet) {
                                  Navigator.popAndPushNamed(context, "inicio",
                                      arguments: {
                                        lblopcionprincipal:
                                            5.4, //Liquidacion Materiales
                                        lblnombreopcion:
                                            lblliquidacionmateriales,
                                        lblllave: mapProductosSeleccionados,
                                        lblimagenopcion: urlimagenmateriales
                                      });
                                }
                              } else {
                                setState(() {});
                              }
                            },
                          )
                        : Etiqueta(texto: '')),
                Espacio(alto: 10),
                Expanded(
                    child: botonVisibles
                        ? Boton(
                            textoEtiqueta: lblcrearrequisicion,
                            colorFondo: colorAzulPrimario,
                            colorTexto: colorBlanco,
                            onPressed: () async {
                              var validacion =
                                  await procesarProductosSeleccionados(
                                      esRequisicion: true);

                              if (validacion) {
                                Navigator.popAndPushNamed(context, "inicio",
                                    arguments: {
                                      lblopcionprincipal: 5.2, //Crear requision
                                      lblnombreopcion:
                                          lblrequisiciondemateriales,
                                      lblllave: mapProductosSeleccionados,
                                      lblimagenopcion: urlimagenmateriales
                                    });
                              } else {
                                setState(() {});
                              }
                            })
                        : Etiqueta(texto: '')),
                Espacio(alto: 25),
                Expanded(
                    child: botonVisibles
                        ? Boton(
                            textoEtiqueta: lbltransferirmateriales,
                            colorFondo: colorAcua,
                            colorTexto: colorBlanco,
                            onPressed: () async {
                              var validacion =
                                  await procesarProductosSeleccionados(
                                      esRequisicion: false);

                              if (validacion) {
                                if (conexionInternet) {
                                  Navigator.popAndPushNamed(context, "inicio",
                                      arguments: {
                                        lblopcionprincipal:
                                            5.3, //Crear transferencia
                                        lblnombreopcion:
                                            lbltransferenciamateriales,
                                        lblllave: mapProductosSeleccionados,
                                        lblimagenopcion: urlimagenmateriales
                                      });
                                }
                              } else {
                                setState(() {});
                              }
                              /*{
                                BarraMensaje(context).Mensaje(
                                    lblseleccioneproducto,
                                    colorFondo: colorAmarrillo);
                                return;
                              */
                            },
                          )
                        : Etiqueta(texto: ''))
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<bool> procesarProductosSeleccionados(
      {bool esRequisicion = false}) async {
    bool continua = false;

    for (int i = 0; i < productosFiltrados.items!.length; i++) {
      var cantidad = int.tryParse(cantidadControllers[i].text) ?? 0;
      int? existencia = productosFiltrados.items![i].existencia ?? 0;

      if (cantidad > 0) {
        productosFiltrados.items![i].cantidad = cantidad;

        //Solo verifica existencia si no es requision
        if (!esRequisicion) {
          if (cantidad > existencia) {
            BarraMensaje(context).Mensaje(
                '$lblcantidadsuperaexistencia, ${productosFiltrados.items![i].nomProducto}',
                colorFondo: colorRojoPrimario,
                colorFuente: colorBlanco);
            mapProductosSeleccionados.clear();
            productosFiltrados.items![i].cantidad = 0;
            continua = false;
            return false;
          }
        }

        mapProductosSeleccionados.add({
          "cod_siar_producto": productosFiltrados.items![i].codSiarProducto,
          lblcantidad: cantidad
        });

        continua = true;
      }
    }
    return continua;
  }

  void _filterData() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      final query = _searchController.text.trim().toLowerCase();

      List<ItemProducto> resultado;

      if (query.isNotEmpty) {
        resultado = productos.items!.where((m) {
          final cod = m.codSiarProducto?.toString().toLowerCase() ?? '';
          final nombre = m.nomProducto?.toLowerCase() ?? '';
          return cod.contains(query) || nombre.contains(query);
        }).toList();
      } else {
        resultado = List.from(productos.items!);
      }

      setState(() {
        productosFiltrados.items = resultado;
      });
    });
  }

  Future<VmProducto> cargarProductos() async {
    CrudProducto crudproducto = CrudProducto();
    VmProducto vm = VmProducto();

    //Loading minetras autentica
    DialogoProgreso(context, lblprocesando, lblprocesando, Icons.network_check,
        widget: Center(
            child: SizedBox(width: 200, height: 200, child: progresoCirculo())),
        cerrar: false);
    try {
      productos = await crudproducto.traerProductos();

      if (productos.items != null) {
        productosFiltrados.items = productos.items!
            .map((item) => ItemProducto(
                  codSiarProducto: item.codSiarProducto,
                  nomProducto: item.nomProducto,
                  costo: item.costo,
                  existencia: item.existencia,
                ))
            .toList();

        cantidadControllers = productos.items!
            .map((p) => TextEditingController(
                text: ((p.cantidad ?? 0).toString() == "0")
                    ? ""
                    : (p.cantidad).toString()))
            .toList();
      }

      setState(() {});
    } catch ($e) {
      Navigator.of(context).pop();
    } finally {
      // Siempre cerrar el loading
      Navigator.of(context).pop();
    }

    return vm;
  }

  Future<bool> verificarHabilitaBoton() async {
    bool habilita = false;
    for (int i = 0; i < productos.items!.length; i++) {
      var cantidad = int.tryParse(cantidadControllers[i].text) ?? 0;
      if (cantidad > 0) {
        habilita = true;
        break;
      }
    }
    return habilita;
  }
}
