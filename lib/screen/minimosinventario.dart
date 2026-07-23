import 'package:flutter/material.dart';
import 'package:jasec/class/crudproducto.dart';
import 'package:jasec/class/crudrequisiciones.dart';
import 'package:jasec/model/vmminimosinventario.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:jasec/utilidades/utilidades.dart';
import 'package:jasec/widget/barramensaje.dart';
import 'package:jasec/widget/lineahoritzontal.dart';
import 'package:jasec/widget/widget.dart';

// ignore: must_be_immutable
class MinimosInventario extends StatefulWidget {
  MinimosInventario({super.key});

  @override
  _RequisicionMateriales createState() => _RequisicionMateriales();
}

class _RequisicionMateriales extends State<MinimosInventario> {
  bool procesando = true;

  final TextEditingController _searchController = TextEditingController();

  VmMinimosInventario productosFiltrados = VmMinimosInventario();
  VmMinimosInventario productos = VmMinimosInventario();

  List<Map<String, dynamic>> mapMaterialesMinimos = [];

  List<TextEditingController> cantidadControllers = [];

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
    _searchController.dispose(); // <-- esto falta

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (procesando) {
      var datos = productos.items ?? [];
      if (datos.isEmpty) {
        return progresoCirculo();
      }
    }

    if (productos.items == null) {
      return Center(
          child: Etiqueta(
        texto: lblNoData,
        color: colorRojoPrimario,
      ));
    }

    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(left: 50, right: 50, top: 10, bottom: 10),
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
              Align(
                alignment: Alignment.bottomRight,
                child: Boton(
                    textoEtiqueta: lblcrearrequisicion,
                    colorFondo: colorAzulPrimario,
                    colorTexto: colorBlanco,
                    onPressed: () async {
                      if (mapMaterialesMinimos.isNotEmpty) {
                        Navigator.pushReplacementNamed(context, "inicio",
                            arguments: {
                              lblopcionprincipal: 5.2, //Crear requision
                              lblnombreopcion: lblrequisiciondemateriales,
                              lblllave: mapMaterialesMinimos,
                              lblimagenopcion: urlimagenmateriales
                            });
                      } else {
                        if (conexionInternet) {
                          Navigator.pushReplacementNamed(context, "inicio",
                              arguments: {
                                lblopcionprincipal:
                                    5.1, //Consulta de inventario
                                lblnombreopcion: lblconsultadeinventario,
                                lblllave: 0,
                                lblimagenopcion: urlimagenmateriales
                              });
                        }
                      }
                    }),
              )
            ],
          ),
        ),
        LineaHorizontal(
          color: colorAzulSecundario,
        ),
        Center(
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
                        texto: lblminimo,
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
                        texto: lblcantidad,
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
                  rows:
                      List.generate(productosFiltrados.items!.length, (index) {
                    var m = productosFiltrados.items![index];

                    return DataRow(
                      cells: [
                        DataCell(Etiqueta(
                          texto: m.codProducto.toString(),
                          color: colorNegro,
                          tamanoFuente: tamanoFuenteSecundaria,
                        )),
                        DataCell(Etiqueta(
                          texto: m.nomProducto.toString(),
                          color: colorNegro,
                          tamanoFuente: tamanoFuenteSecundaria,
                        )),
                        DataCell(Etiqueta(
                          texto: m.minimo.toString(),
                          color: colorNegro,
                          tamanoFuente: tamanoFuenteSecundaria,
                        )),
                        DataCell(Etiqueta(
                          texto: m.existencia.toString(),
                          color: colorNegro,
                          tamanoFuente: tamanoFuenteSecundaria,
                        )),
                        DataCell(Etiqueta(
                          texto: cantidadControllers[index].text,
                          color: colorNegro,
                          tamanoFuente: tamanoFuenteSecundaria,
                        )),
                        DataCell(IconButton(
                          onPressed: () async {
                            double? cantidad = await showDialog<double>(
                              context: context,
                              builder: (context) => dialogoCantidad(context),
                            );

                            if (cantidad! > 0) {
                              agregarOActualizarMaterial(
                                  m.codProducto!, cantidad);
                              //mapMaterialesMinimos.add(mapRequisicion);

                              cantidadControllers[index].text =
                                  cantidad.toInt().toString();
                            }
                          },
                          icon: Icon(
                            Icons.add,
                            color: colorVerdeSecundario,
                          ),
                        )),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _filterData() {
    String query = _searchController.text.toLowerCase();
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

  void agregarOActualizarMaterial(String codProducto, dynamic cantidad) {
    // Buscar si ya existe el producto
    int index = mapMaterialesMinimos.indexWhere(
      (element) => element["cod_siar_producto"] == codProducto,
    );

    if (index != -1) {
      // Ya existe, actualizar cantidad
      mapMaterialesMinimos[index][lblcantidad] = cantidad;
    } else {
      // No existe, agregar nuevo
      mapMaterialesMinimos.add({
        "cod_siar_producto": codProducto,
        lblcantidad: cantidad,
      });
    }
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

  Future<VmMinimosInventario> cargarProductos() async {
    CrudProducto crudproducto = CrudProducto();
    VmMinimosInventario vm = VmMinimosInventario();

    //Loading minetras autentica
    DialogoProgreso(context, lblprocesando, lblprocesando, Icons.network_check,
        widget: Center(
            child: SizedBox(width: 200, height: 200, child: progresoCirculo())),
        cerrar: false);
    try {
      productos = await crudproducto.traerMinimoInventario();
      if (productos.items != null) {
        productosFiltrados.items = productos.items!
            .map((item) => ItemMinimoInventario(
                  codProducto: item.codProducto,
                  nomProducto: item.nomProducto,
                  existencia: item.existencia,
                  minimo: item.minimo,
                ))
            .toList();

        cantidadControllers = productos.items!
            .map((p) => TextEditingController(text: "0"))
            .toList();

        setState(() {
          procesando = false;
        });
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
