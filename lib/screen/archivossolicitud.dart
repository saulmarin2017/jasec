import 'package:flutter/material.dart';
import 'package:jasec/class/crudsolicitud.dart';
import 'package:jasec/model/vmadjuntossolicitud.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:jasec/widget/widget.dart';
import 'package:open_file/open_file.dart';

// ignore: must_be_immutable
class AdjuntosSolicitud extends StatefulWidget {
  final String llave;

  AdjuntosSolicitud({super.key, required this.llave});

  @override
  _AdjuntosSolicitud createState() => _AdjuntosSolicitud();
}

class _AdjuntosSolicitud extends State<AdjuntosSolicitud> {
  bool procesando = true;
  List<VmAdjuntosSolicitud> mapAdjuntos = [];

  @override
  void initState() {
    super.initState();
    traerArchivosAdjuntos(widget.llave);
  }

  @override
  Widget build(BuildContext context) {
    if (procesando) {
      return progresoCirculo();
    }

    if (mapAdjuntos.isEmpty) {
      return Center(
        child: Etiqueta(
          texto: lblNoData,
          color: colorRojoPrimario,
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(
              label: Etiqueta(
            texto: lblId,
            tamanoFuente: tamanoFuente12px,
            tipo: FontWeight.bold,
          )),
          DataColumn(
              label: Etiqueta(
            texto: lblsolicitud,
            tamanoFuente: tamanoFuente12px,
            tipo: FontWeight.bold,
          )),
          DataColumn(
              label: Etiqueta(
            texto: lblnombre,
            tamanoFuente: tamanoFuente12px,
            tipo: FontWeight.bold,
          )),
          DataColumn(
              label: Etiqueta(
            texto: lbltipoArchivo,
            tamanoFuente: tamanoFuente12px,
            tipo: FontWeight.bold,
          )),
          DataColumn(
              label: Etiqueta(
            texto: lblaccion,
            tamanoFuente: tamanoFuente12px,
            tipo: FontWeight.bold,
          )),
        ],
        rows: mapAdjuntos.map((item) {
          return DataRow(
            cells: [
              DataCell(Text(item.codSolicitudDocumento?.toString() ?? '')),
              DataCell(
                Text(item.codSolicitud ?? ''),
              ),
              DataCell(Text(item.filename?.toString() ?? '')),
              DataCell(Text(item.mimetype ?? '')),
              DataCell(Row(
                children: [
                  IconButton(
                    color: colorAzulSecundario,
                    iconSize: 20,
                    onPressed: () async {
                      //Loading minetras autentica
                      DialogoProgreso(context, lblprocesando, lblprocesando,
                          Icons.network_check,
                          widget: Center(
                              child: SizedBox(
                                  width: 200,
                                  height: 200,
                                  child: progresoCirculo())),
                          cerrar: false);
                      try {
                        CrudSolicitud cls = CrudSolicitud();
                        var string = await cls.descargarArchivoAdjuntoSolicitud(
                            item.codSolicitud.toString(),
                            item.codSolicitudDocumento.toString());

                        if (string.isNotEmpty) {
                          OpenFile.open(string);
                        }
                      } catch ($e) {
                        Navigator.of(context).pop();
                      } finally {
                        // Siempre cerrar el loading
                        Navigator.of(context).pop();
                      }
                    },
                    icon: Icon(Icons.visibility),
                    selectedIcon: Icon(Icons.expand),
                  ),
                  SizedBox(
                    width: 25,
                  ),
                  IconButton(
                      color: colorRojoPrimario,
                      iconSize: 20,
                      onPressed: () async {
                        {
                          //Loading minetras autentica
                          DialogoProgreso(context, lblprocesando, lblprocesando,
                              Icons.network_check,
                              widget: Center(
                                  child: SizedBox(
                                      width: 200,
                                      height: 200,
                                      child: progresoCirculo())),
                              cerrar: false);
                          try {
                            CrudSolicitud cls = CrudSolicitud();

                            await cls
                                .elimimnarArchivoAdjuntoSolicitud(
                                    item.codSolicitudDocumento.toString())
                                .then((x) {
                              traerArchivosAdjuntos(widget.llave);
                            });

                            setState(() {});
                          } catch ($e) {
                            Navigator.of(context).pop();
                          } finally {
                            // Siempre cerrar el loading
                            Navigator.of(context).pop();
                          }
                        }
                      },
                      icon: Icon(Icons.delete))
                ],
              )),
            ],
          );
        }).toList(),
      ),
    );
  }

  void traerArchivosAdjuntos(String codSolicitud) async {
    CrudSolicitud crudSolicitud = CrudSolicitud();

    //Listado de ordenes
    await crudSolicitud.descargarListaArchivosAdjuntos(codSolicitud).then(
      (r) {
        if (r.isNotEmpty) {
          mapAdjuntos = r;
        } else {
          mapAdjuntos.clear();
        }
      },
    );

    procesando = false;

    if (mounted) {
      setState(() {});
    }
  }
}
