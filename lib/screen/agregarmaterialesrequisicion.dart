import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jasec/class/crudproducto.dart';
import 'package:jasec/class/crudrequisiciones.dart';
import 'package:jasec/model/vmproducto.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:jasec/utilidades/utilidades.dart';
import 'package:jasec/widget/barramensaje.dart';
import 'package:jasec/widget/lineahoritzontal.dart';
import 'package:jasec/widget/widget.dart';

// ignore: must_be_immutable
class AgregarMaterialesRequisicion extends StatefulWidget {
  String codRequisicion;
  String codBodegaOrigen;

  AgregarMaterialesRequisicion(this.codRequisicion, this.codBodegaOrigen,
      {super.key});

  @override
  _RequisicionMateriales createState() => _RequisicionMateriales();
}

class _RequisicionMateriales extends State<AgregarMaterialesRequisicion> {
  bool procesando = true;

  final TextEditingController _searchController = TextEditingController();

  VmProducto productosFiltrados = VmProducto();
  VmProducto productos = VmProducto();

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

    return Center(
      child: Column(
        children: [
          Espacio(alto: 5),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 25,
              children: [
                Spacer(),
                Expanded(
                  flex: 2,
                  child: TextBoxForm(
                    controlador: _searchController,
                    textoEtiqueta: lblbuscar,
                    propiedadFormulario: '',
                    icono: Icons.search,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: IconButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                      },
                      icon: Icon(Icons.keyboard_hide_outlined)),
                ),
                Spacer(),
              ],
            ),
          ),
          LineaHorizontal(
            color: colorAzulSecundario,
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  DataTable(
                    columns: const [
                      DataColumn(
                        label: Etiqueta(
                          texto: lblcodigo,
                          tamanoFuente: tamanoFuenteSecundaria,
                          tipo: FontWeight.bold,
                        ),
                      ),
                      DataColumn(
                        label: Etiqueta(
                          texto: lbldescripcion,
                          tamanoFuente: tamanoFuenteSecundaria,
                          tipo: FontWeight.bold,
                        ),
                      ),
                      DataColumn(
                        label: Etiqueta(
                          texto: lblexistencia,
                          tamanoFuente: tamanoFuenteSecundaria,
                          tipo: FontWeight.bold,
                        ),
                      ),
                      DataColumn(
                        label: Etiqueta(
                          texto: lblagregar,
                          tamanoFuente: tamanoFuenteSecundaria,
                          tipo: FontWeight.bold,
                        ),
                      ),
                    ],
                    rows: productosFiltrados.items!.map((m) {
                      return DataRow(
                        cells: [
                          DataCell(SizedBox(
                            width: anchoUtil(context) / 7,
                            child: Etiqueta(
                              texto: m.codSiarProducto ?? "",
                              color: colorNegro,
                              tamanoFuente: tamanoFuente9px,
                            ),
                          )),
                          DataCell(SizedBox(
                            width: anchoUtil(context) / 3,
                            child: Etiqueta(
                              texto: m.nomProducto ?? "",
                              color: colorNegro,
                              tamanoFuente: tamanoFuente9px,
                            ),
                          )),
                          DataCell(SizedBox(
                            width: 50,
                            child: Etiqueta(
                              texto: m.existencia.toString(),
                              color: colorNegro,
                              tamanoFuente: tamanoFuente9px,
                            ),
                          )),
                          DataCell(IconButton(
                            onPressed: () async {
                              List<Map<String, dynamic>>
                                  mapMaterialesInsertados = [];
                              String existencia = (m.existencia == 0)
                                  ? ""
                                  : m.existencia.toString();
                              double? cantidad = await showDialog<double>(
                                context: context,
                                builder: (context) => dialogoCantidad(context,
                                    cantidadActul: existencia),
                              );

                              if (cantidad! > 0) {
                                Map<String, dynamic> mapRequisicion = {
                                  "cod_requisiciones": widget.codRequisicion,
                                  "cod_producto": m.codSiarProducto,
                                  "cantidad": cantidad,
                                  "usuario_insert": usuarioLogin
                                };

                                mapMaterialesInsertados.add(mapRequisicion);
                                await insertarMaterialesRequisicion(
                                    mapMaterialesInsertados);
                              }
                            },
                            icon: Icon(
                              size: sizeIcono,
                              Icons.add_circle,
                              color: colorVerdeSecundario,
                            ),
                          )),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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

  Future<void> insertarMaterialesRequisicion(
      List<Map<String, dynamic>> mapMateriales) async {
    CrudRequisiciones cls = CrudRequisiciones();

    await cls.guardarDetalleRequisicion(mapMateriales).then(
      (r) {
        if (r.idInsertado != null) {
          if (r.idInsertado! > 0) {
            BarraMensaje(context).Mensaje(
                '$lblrequisicion, $lblActualizoInformacion',
                colorFondo: colorVerdeSecundario);
          }
        }
      },
    );
  }

  Future<String?> solicitarCantidadx() async {
    final TextEditingController controlador = TextEditingController();

    String? resultado = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ingrese una cantidad'),
        content: TextField(
          controller: controlador,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: 'Solo números'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, controlador.text);
            },
            child: Text('Aceptar'),
          ),
        ],
      ),
    );

    return resultado;
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
                  existencia: item.existencia,
                  costo: item.costo,
                ))
            .toList();
        setState(() {});
      }
    } catch ($e) {
      Navigator.of(context).pop();
    } finally {
      // Siempre cerrar el loading
      Navigator.of(context).pop();
    }

    return vm;
  }
}
