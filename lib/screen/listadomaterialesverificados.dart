import 'package:flutter/material.dart';
import 'package:jasec/class/crudmateriales.dart';
import 'package:jasec/model/vmsolicitudmaterial.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:jasec/utilidades/utilidades.dart';
import 'package:jasec/widget/widget.dart';

// ignore: must_be_immutable
class ListadoMaterialesVerificado extends StatefulWidget {
  String codSolicitud;
  String instalados;
  String codPoste;

  ListadoMaterialesVerificado(this.codSolicitud, this.instalados, this.codPoste,
      {super.key});

  @override
  _ListadoMaterialesPoste createState() => _ListadoMaterialesPoste();
}

class _ListadoMaterialesPoste extends State<ListadoMaterialesVerificado> {
  bool cargoDatos = false;
  late VmSolicitudMateriales mapSolicitudMateriales = VmSolicitudMateriales();

  final TextEditingController _searchController = TextEditingController();

  late VmSolicitudMateriales filteredOrdenes;

  List<TextEditingController> cantidadVerificadaControllers = [];
  List<TextEditingController> brechaControllers = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!cargoDatos) {
        traerSolicitudMateriales(
            widget.codSolicitud, widget.instalados, widget.codPoste);
      }
    });

    filteredOrdenes =
        mapSolicitudMateriales; // Inicialmente, mostramos todos los datos
    _searchController.addListener(_filterData);
  }

  @override
  void dispose() {
    _searchController.dispose(); // <-- esto falta

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!cargoDatos && mapSolicitudMateriales.items == null) {
      return progresoCirculo();
    }

    if (mapSolicitudMateriales.items == null && cargoDatos) {
      return Center(
          child: Etiqueta(
        texto: lblNoData,
        color: colorRojoPrimario,
      ));
    }

    return Column(
      children: [
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
                        texto: lblverificado,
                        tamanoFuente: tamanoFuente12px,
                        tipo: FontWeight.bold,
                      ),
                    ),
                    DataColumn(
                      label: Etiqueta(
                        texto: lblbrecha,
                        tamanoFuente: tamanoFuente12px,
                        tipo: FontWeight.bold,
                      ),
                    ),
                    DataColumn(
                      label: Etiqueta(
                        texto: lblestado,
                        tamanoFuente: tamanoFuente12px,
                        tipo: FontWeight.bold,
                      ),
                    ),
                  ],
                  rows: List.generate(mapSolicitudMateriales.items!.length,
                      (index) {
                    var m = mapSolicitudMateriales.items![index];

                    double brecha =
                        (m.cantidad! - double.parse(m.verificado.toString()));
                    brechaControllers[index].text = brecha.toString();

                    return DataRow(
                      cells: [
                        DataCell(Text(m.codSiarProducto.toString())),
                        DataCell(Text(m.nomProducto.toString())),
                        DataCell(Text(m.cantidad.toString())),
                        DataCell(IconButton(
                          onPressed: () async {
                            double? cantidad = await showDialog<double>(
                              context: context,
                              builder: (context) => dialogoCantidad(context),
                            );

                            if (cantidad! > 0) {
                              cantidadVerificadaControllers[index].text =
                                  cantidad.toInt().toString();

                              double br = (m.cantidad! -
                                  double.parse(cantidad.toString()));

                              brechaControllers[index].text = br.toString();
                            }

                            setState(() {});
                          },
                          icon: Icon(
                            Icons.verified,
                            color: colorVerdeSecundario,
                          ),
                        )),
                        DataCell(Text(brecha.toString())),
                        DataCell(Text(m.estado.toString())),
                      ],
                    );
                  }).toList(),
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
      filteredOrdenes.items = mapSolicitudMateriales.items!.where((orden) {
        return orden.codSiarProducto.toString().toLowerCase().contains(query) ||
            orden.nomProducto!.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> traerSolicitudMateriales(
      String codSolicitud, String instalados, String codPoste) async {
    CrudMateriales cls = CrudMateriales();

    //Listado de ordenes
    await cls.traerMaterialesSolicitud(codSolicitud, instalados, codPoste).then(
      (r) {
        if (r.items != null) {
          if (r.items is List) {
            if (r.items!.isNotEmpty) {
              setState(() {
                mapSolicitudMateriales = r;
                cargoDatos = true;
              });
            }
          }
        }

        setState(() {
          cargoDatos = true;
        });
      },
    );
  }
}
