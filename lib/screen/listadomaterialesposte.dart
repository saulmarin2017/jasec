import 'package:flutter/material.dart';
import 'package:jasec/class/crudmateriales.dart';
import 'package:jasec/class/log.dart';
import 'package:jasec/model/vmsolicitudmaterial.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:jasec/utilidades/utilidades.dart';
import 'package:jasec/widget/lineahoritzontal.dart';
import 'package:jasec/widget/widget.dart';

// ignore: must_be_immutable
class ListadoMaterialesPoste extends StatefulWidget {
  String codSolicitud;
  String instalados;
  String codPoste;

  ListadoMaterialesPoste(this.codSolicitud, this.instalados, this.codPoste,
      {super.key});

  @override
  _ListadoMaterialesPoste createState() => _ListadoMaterialesPoste();
}

class _ListadoMaterialesPoste extends State<ListadoMaterialesPoste> {
  bool cargoDatos = false;
  late VmSolicitudMateriales mapSolicitudMateriales = VmSolicitudMateriales();

  final TextEditingController _searchController = TextEditingController();

  late VmSolicitudMateriales filteredOrdenes;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!cargoDatos) {
        Log.escribir("CARGA DE DATOS INICIAL EN PANTALLA");
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
    if (!cargoDatos) {
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
                        texto: lblinstalado,
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
                        DataCell(Text(m.usuarioInsert.toString())),
                        DataCell(Text(m.instalados.toString())),
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
                Log.escribir("STATE DE MATERIALES,TRUE");
                mapSolicitudMateriales = r;
                cargoDatos = true;
              });
            }
          }
        }

        setState(() {
          Log.escribir("STATE DE MATERIALES,TRUE");
          cargoDatos = true;
        });
      },
    );
  }
}
