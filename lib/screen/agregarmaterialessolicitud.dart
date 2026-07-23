import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jasec/class/crudmateriales.dart';
import 'package:jasec/class/crudproducto.dart';
import 'package:jasec/class/log.dart';
import 'package:jasec/model/vmproducto.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:jasec/utilidades/utilidades.dart';
import 'package:jasec/widget/lineahoritzontal.dart';
import 'package:jasec/widget/widget.dart';

// ignore: must_be_immutable
class AgregarMaterialesSolicitud extends StatefulWidget {
  String codSolicitud;
  String instalados;
  String codPoste;

  AgregarMaterialesSolicitud(this.codSolicitud, this.instalados, this.codPoste,
      {super.key});

  @override
  _SolicitudMateriales createState() => _SolicitudMateriales();
}

class _SolicitudMateriales extends State<AgregarMaterialesSolicitud> {
  bool procesando = true;

  List<Map<String, dynamic>> mapSolicitudInsertados = [];

  List<TextEditingController> observaciones = [];

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
    if (mapSolicitudInsertados.isNotEmpty) {
      insertarSolicitudMateriales();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (productosFiltrados.items != null) {
      if (productosFiltrados.items!.isEmpty) {
        return Center(
            child: Etiqueta(
          texto: lblNoData,
          color: colorRojoPrimario,
        ));
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          children: [
            Container(
              padding:
                  EdgeInsets.only(left: 50, right: 50, top: 10, bottom: 10),
              width: anchoUtil(context) - 100,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 25,
                children: [
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
                ],
              ),
            ),
            LineaHorizontal(
              color: colorAzulSecundario,
            ),
            (productosFiltrados.items != null)
                ? DataTable(
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
                          texto: lblobservaciones,
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
                          texto: lblagregar,
                          tamanoFuente: tamanoFuente12px,
                          tipo: FontWeight.bold,
                        ),
                      ),
                    ],
                    rows: List.generate(productosFiltrados.items!.length,
                        (index) {
                      var m = productosFiltrados.items![index];

                      return DataRow(
                        cells: [
                          DataCell(SizedBox(
                            width: 100,
                            child: Etiqueta(
                              texto: m.codSiarProducto ?? "",
                              color: colorNegro,
                              tamanoFuente: tamanoFuente9px,
                            ),
                          )),
                          DataCell(IconButton(
                            icon: Icon(Icons.note),
                            onPressed: () async {
                              var textoActua = observaciones[index].text;
                              String? str = await showDialog<String>(
                                context: context,
                                builder: (context) =>
                                    dialogoText(context, textoActua),
                              );

                              observaciones[index].text = str!;

                              if (mapSolicitudInsertados.isNotEmpty) {
                                //Obtenemos el indice del registro a actualizar
                                final i = mapSolicitudInsertados.indexWhere(
                                  (d) =>
                                      d['cod_siar_producto'] ==
                                      m.codSiarProducto,
                                );
                                if (i != -1) {
                                  mapSolicitudInsertados[i]['observaciones'] =
                                      str;
                                }
                              }
                            },
                          )),
                          DataCell(SizedBox(
                            width: anchoUtil(context) / 4,
                            child: Etiqueta(
                              texto: m.nomProducto ?? "",
                              color: colorNegro,
                              tamanoFuente: tamanoFuente9px,
                            ),
                          )),
                          DataCell(IconButton(
                            onPressed: () async {
                              double? cantidad = await showDialog<double>(
                                context: context,
                                builder: (context) => dialogoCantidad(context),
                              );

                              if (cantidad! > 0) {
                                Map<String, dynamic> registro = {
                                  "cod_solicitud": widget.codSolicitud,
                                  "cod_siar_producto": m.codSiarProducto,
                                  "cantidad": cantidad,
                                  "cod_poste": widget.codPoste,
                                  "instalados": widget.instalados,
                                  "usuario_insert": usuarioLogin,
                                  "observaciones": observaciones[index].text
                                };

                                mapSolicitudInsertados.add(registro);
                              }
                            },
                            icon: Icon(
                              Icons.add_circle,
                              size: sizeIcono,
                              color: colorVerdeSecundario,
                            ),
                          )),
                        ],
                      );
                    }).toList(),
                  )
                : Center(
                    child: Etiqueta(
                    texto: lblNoData,
                    color: colorRojoPrimario,
                  ))
          ],
        ),
      ),
    );
  }

  void _filterData() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      final query = _searchController.text.trim().toLowerCase();
      Log.escribir('TEXTO A BUSCAR: $query');

      List<ItemProducto> resultado;

      if (query.isNotEmpty) {
        resultado = productos.items!.where((m) {
          final cod = m.codSiarProducto?.toString().toLowerCase() ?? '';
          final nombre = m.nomProducto?.toLowerCase() ?? '';
          return cod.contains(query) || nombre.contains(query);
        }).toList();

        Log.escribir(
            'ANTES DE FILTRAR: ${productosFiltrados.items!.map((e) => e.nomProducto).join(', ')}');
        Log.escribir(
            'DESPUES DE FILTRAR: ${resultado.map((e) => e.nomProducto).join(', ')}');
      } else {
        resultado = List.from(productos.items!);
        Log.escribir(
            'BUSQUEDA VACIA, MOSTRANDO TODOS: ${resultado.map((e) => e.nomProducto).join(', ')}');
      }

      setState(() {
        productosFiltrados.items = resultado;
      });
    });
  }

  void insertarSolicitudMateriales() async {
    CrudMateriales cls = CrudMateriales();

    await cls.solicitudMaterialesInstalados(mapSolicitudInsertados).then(
      (r) {
        if ((r.idInsertado ?? 0) > 0) {}
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
      Log.escribir("Llamo traerProductos ");
      productos = await crudproducto.traerProductos();
      Log.escribir('Productos:${productos.items}');
      if (productos.items != null) {
        productosFiltrados.items = productos.items!
            .map((item) => ItemProducto(
                  codSiarProducto: item.codSiarProducto,
                  nomProducto: item.nomProducto,
                  existencia: item.existencia,
                  costo: item.costo,
                ))
            .toList();

        observaciones = productos.items!
            .map((p) => TextEditingController(text: ""))
            .toList();

        setState(() {});
      }
    } catch ($e) {
      Log.escribir("error al cargar ${$e.toString()} ");
      Navigator.of(context).pop();
    } finally {
      // Siempre cerrar el loading
      Navigator.of(context).pop();
    }

    return vm;
  }
}
