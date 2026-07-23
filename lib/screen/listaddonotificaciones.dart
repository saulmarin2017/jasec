import 'package:flutter/material.dart';
import 'package:jasec/class/crudnotificaciones.dart';
import 'package:jasec/model/vmnotificaciones.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:jasec/widget/widget.dart';

// ignore: must_be_immutable
class ListadoNotificaciones extends StatefulWidget {
  ListadoNotificaciones({super.key});

  @override
  _ListadoNotificaciones createState() => _ListadoNotificaciones();
}

class _ListadoNotificaciones extends State<ListadoNotificaciones> {
  bool procesando = true;

  final TextEditingController _searchController = TextEditingController();

  VmNotificacion notificacionesFiltradas = VmNotificacion();
  VmNotificacion notificaciones = VmNotificacion();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      cargarNoficaciones();
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
    var datos = notificaciones.items ?? [];
    if (datos.isEmpty) {
      return progresoCirculo();
    }

    return Center(
      child: Stack(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                DataTable(
                  sortAscending: true,
                  columns: const [
                    DataColumn(
                      label: Etiqueta(
                        texto: lblId,
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
                        texto: lblestado,
                        tamanoFuente: tamanoFuenteSecundaria,
                        tipo: FontWeight.bold,
                      ),
                    ),
                    DataColumn(
                      label: Etiqueta(
                        texto: lblaccion,
                        tamanoFuente: tamanoFuenteSecundaria,
                        tipo: FontWeight.bold,
                      ),
                    ),
                  ],
                  rows: notificacionesFiltradas.items!.map((m) {
                    return DataRow(
                      cells: [
                        DataCell(Etiqueta(
                          texto: m.codNotificacion.toString(),
                          color: colorNegro,
                          tamanoFuente: tamanoFuenteSecundaria,
                        )),
                        DataCell(Etiqueta(
                          texto: m.descripcion.toString(),
                          color: colorNegro,
                          tamanoFuente: tamanoFuenteSecundaria,
                        )),
                        DataCell((m.estado == "PENDIENTE")
                            ? Icon(
                                Icons.done,
                                size: 30,
                                color: colorVerdePrimario,
                              )
                            : Icon(
                                Icons.done_all,
                                size: 30,
                                color: colorAzulSecundario,
                              )),
                        DataCell(IconButton(
                          icon: Icon(
                            Icons.visibility,
                            color: colorAmarrillo,
                          ),
                          onPressed: () {
                            actualizarEstadoNotiicacion(
                                m.codNotificacion.toString());
                          },
                        )),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _filterData() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isNotEmpty) {
        notificacionesFiltradas.items = notificaciones.items!.where((orden) {
          return orden.descripcion.toString().toLowerCase().contains(query);
        }).toList();
      } else {
        notificacionesFiltradas.items = notificaciones.items!.toList();
      }
    });
  }

  Future<void> actualizarEstadoNotiicacion(String codNotificacion) async {
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
}
