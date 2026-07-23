import 'package:flutter/material.dart';
import 'package:jasec/class/crudordenestrabajo.dart';
import 'package:jasec/model/vmsolicitudesordentrabajo.dart';
import 'package:jasec/screen/solicituddirecciongps.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:jasec/utilidades/utilidades.dart';
import 'package:jasec/widget/widget.dart';

// ignore: must_be_immutable
class SolicitudesOrden extends StatefulWidget {
  String idOrden = '';
  SolicitudesOrden(this.idOrden, {super.key});

  @override
  _SolicitudesOrden createState() => _SolicitudesOrden();
}

class _SolicitudesOrden extends State<SolicitudesOrden> {
  bool procesando = true;
  VmSolicitudesOrdenTrabajo mapSolicitudesOrden = VmSolicitudesOrdenTrabajo();

  VmSolicitudesOrdenTrabajo filteredOrdenes = VmSolicitudesOrdenTrabajo();

  @override
  void initState() {
    super.initState();
    filteredOrdenes =
        mapSolicitudesOrden; // Inicialmente, mostramos todos los datos

    traerSolicitudesOrdenesTrabajo(widget.idOrden);
  }

  @override
  Widget build(BuildContext context) {
    bool _ascendente = true;
    int? _sortColumnIndex;

    if (procesando) {
      return Center(child: progresoCirculo());
    }

    if (mapSolicitudesOrden.items == null) {
      return Center(
          child: Etiqueta(
        texto: lblNoData,
        color: colorRojoPrimario,
      ));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          sortAscending: _ascendente,
          sortColumnIndex: _sortColumnIndex,
          columns: [
            DataColumn(
                label: Etiqueta(
              texto: lblorden,
              tamanoFuente: tamanoFuente12px,
              tipo: FontWeight.bold,
            )),
            DataColumn(
                label: Etiqueta(
              texto: lblTicket,
              tamanoFuente: tamanoFuente12px,
              tipo: FontWeight.bold,
            )),
            DataColumn(
                label: Etiqueta(
              texto: lblnoot,
              tamanoFuente: tamanoFuente12px,
              tipo: FontWeight.bold,
            )),
            DataColumn(
                label: Etiqueta(
              texto: lbltiposolicitud,
              tamanoFuente: tamanoFuente12px,
              tipo: FontWeight.bold,
            )),
            DataColumn(
                label: Etiqueta(
              texto: lblnombresolicitante,
              tamanoFuente: tamanoFuente12px,
              tipo: FontWeight.bold,
            )),
            DataColumn(
                label: Etiqueta(
              texto: lblestado,
              tamanoFuente: tamanoFuente12px,
              tipo: FontWeight.bold,
            )),
            DataColumn(
                label: Etiqueta(
              texto: lbldireccion,
              tamanoFuente: tamanoFuente12px,
              tipo: FontWeight.bold,
            )),
            DataColumn(
                label: Etiqueta(
              texto: lbllocalizacion,
              tamanoFuente: tamanoFuente12px,
              tipo: FontWeight.bold,
            )),
            DataColumn(
                label: Etiqueta(
              texto: lblpueblo,
              tamanoFuente: tamanoFuente12px,
              tipo: FontWeight.bold,
            )),
            DataColumn(
                label: Etiqueta(
              texto: lbltelefono,
              tamanoFuente: tamanoFuente12px,
              tipo: FontWeight.bold,
            )),
            DataColumn(
                label: Etiqueta(
              texto: lblnoposte,
              tamanoFuente: tamanoFuente12px,
              tipo: FontWeight.bold,
            )),
            DataColumn(
              label: Etiqueta(
                texto: lblfechasolicitud,
                tamanoFuente: tamanoFuente12px,
                tipo: FontWeight.bold,
              ),
              onSort: (columnIndex, ascending) {
                setState(() {
                  _sortColumnIndex = columnIndex;
                  _ascendente = ascending;
                  mapSolicitudesOrden.items!.sort((a, b) => ascending
                      ? a.fechaInsert!.compareTo(b.fechaInsert!)
                      : b.fechaInsert!.compareTo(a.fechaInsert!));
                });
              },
            ),
          ],
          rows: mapSolicitudesOrden.items!.map((item) {
            String fechaSolicitud = formatoFechaPantalla(fechaDateTime(
                item.fechaInsert!.toLocal().toString().split(' ')[0]));

            return DataRow(
              cells: [
                DataCell(SizedBox(
                  width: 30,
                  child: IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.arrow_circle_up),
                  ),
                )),
                DataCell(
                  SizedBox(
                    width: anchoUtil(context) / 8,
                    child: Etiqueta(
                      texto: item.numeroTicket.toString(),
                      tamanoFuente: tamanoFuente12px,
                      color: colorAzulPrimario,
                    ),
                  ),
                  onTap: () async {
                    var codSolicitud = '${item.codSolicitud}';
                    if (luminaria == 'S') {
                      Navigator.popAndPushNamed(context, "inicio", arguments: {
                        lblopcionprincipal:
                            3, //atencionsolicitud: Atencion de la Solilcitud, de la orden de trabajo
                        lblnombreopcion: '$lblsolicitud: $codSolicitud',
                        lblllave: codSolicitud,
                        lblimagenopcion: urlimagensolicitud,
                        "modo": "C",
                        "numero_orden_trabajo": '${item.codOrdenTrabajo}',
                        "cod_poste": '',
                      });
                    } else {
                      String mensaje = "";
                      if (luminaria == "N") {
                        mensaje =
                            "El reporte a atender es de Tipo de Servicio:${item.desTipoSolicitudSt}, ¿Desea continuar?";
                      } else {
                        mensaje =
                            "El reporte a atender es de Tipo de Atención ${item.desTipoAtencion}. ¿Desea continuar?";
                      }
                      var continua = await DialogoConfirmacion(
                          context, lbltipoinstalacion, mensaje);

                      if (continua!) {
                        Navigator.popAndPushNamed(context, "inicio",
                            arguments: {
                              lblopcionprincipal:
                                  4.2, //atencionsolicitud: Atencion de la Solilcitud, de la orden de trabajo
                              lblnombreopcion: '$lblsolicitud: $codSolicitud',
                              lblllave: codSolicitud,
                              "numero_orden_trabajo": '${item.codOrdenTrabajo}',
                              "estado": '${item.estado}',
                              "cod_poste": '',
                              lblimagenopcion: urlimagensolicitud
                            });
                      }
                    }
                  },
                ),
                DataCell(SizedBox(
                  width: anchoUtil(context) / 8,
                  child: Etiqueta(
                    texto: item.tnNumOt.toString(),
                    tamanoFuente: tamanoFuente10px,
                    color: colorNegro,
                  ),
                )),
                DataCell(SizedBox(
                  width: anchoUtil(context) / 8,
                  child: Etiqueta(
                    texto: (luminaria == "S")
                        ? item.desTipoSolicitud.toString()
                        : item.desTipoSolicitudSt.toString(),
                    tamanoFuente: tamanoFuente10px,
                    color: colorNegro,
                  ),
                )),
                DataCell(SizedBox(
                  width: anchoUtil(context) / 4,
                  child: Etiqueta(
                    texto: item.nombre.toString(),
                    tamanoFuente: tamanoFuente10px,
                    color: colorNegro,
                  ),
                )),
                DataCell(Etiqueta(
                  texto: DescripcionEstado(item.estado.toString()),
                  tamanoFuente: tamanoFuente10px,
                  color: colorNegro,
                )),
                DataCell(IconButton(
                    onPressed: () async {
                      MostrarWidgetEnDialogo(
                          context,
                          SolicitudDireccionGPS(item.codSolicitud.toString()),
                          lbldireccion);
                    },
                    icon: Icon(
                      Icons.location_on,
                      color: colorAzulSecundario,
                    ))),
                DataCell(Etiqueta(
                  texto: item.localizacion ?? "",
                  tamanoFuente: tamanoFuente10px,
                  color: colorNegro,
                )),
                DataCell(Etiqueta(
                  texto: item.codPueblo ?? "",
                  tamanoFuente: tamanoFuente10px,
                  color: colorNegro,
                )),
                DataCell(Etiqueta(
                  texto: item.telefono1 ?? "",
                  tamanoFuente: tamanoFuente10px,
                  color: colorNegro,
                )),
                DataCell(Etiqueta(
                  texto: item.codPoste ?? '',
                  tamanoFuente: tamanoFuente10px,
                  color: colorNegro,
                )),
                DataCell(Etiqueta(
                  texto: fechaSolicitud,
                  tamanoFuente: tamanoFuente10px,
                  color: colorNegro,
                ))
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  void traerSolicitudesOrdenesTrabajo(String codOrdenTrabajo) async {
    String luminaria =
        (perfilUsuario == PerfilUsuario.AlumbradoPublicoLuminaria) ? "S" : "N";

    CrudOrdenesTrabajo ordenesTrabajo = CrudOrdenesTrabajo();

    //Listado de ordenes
    await ordenesTrabajo
        .traerSolicitudesOrdenesTrabajo(luminaria, codOrdenTrabajo)
        .then(
      (r) {
        if (r.items is List) {
          if (r.items!.isNotEmpty) {
            setState(() {
              procesando = false;
              mapSolicitudesOrden = r;
              mapSolicitudesOrden.items!
                  .sort((a, b) => b.fechaInsert!.compareTo(a.fechaInsert!));
            });
          }
        }

        setState(() {
          procesando = false;
        });
      },
    );
  }
}
