import 'package:flutter/material.dart';
import 'package:jasec/class/crudordenestrabajo.dart';
import 'package:jasec/model/vmordentrabajo.dart';
import 'package:jasec/screen/screen.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:jasec/utilidades/utilidades.dart';
import 'package:jasec/widget/barramensaje.dart';
import 'package:jasec/widget/widget.dart';

class OrdenesTrabajo extends StatefulWidget {
  const OrdenesTrabajo({super.key});

  @override
  _OrdenesTrabajo createState() => _OrdenesTrabajo();
}

class _OrdenesTrabajo extends State<OrdenesTrabajo> {
  bool procesando = true;
  VmOrdenTrabajo mapOrdenes = VmOrdenTrabajo();

  @override
  void initState() {
    super.initState();
    traerOrdenesTrabajo();
  }

  @override
  Widget build(BuildContext context) {
    if (procesando) {
      return Center(
        child: progresoCirculo(),
      );
    }

    if (mapOrdenes.items == null) {
      return Center(
          child: Etiqueta(
        texto: lblNoData,
        color: colorRojoPrimario,
      ));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(
              label: Etiqueta(
            texto: lblordenestrabajo,
            tamanoFuente: tamanoFuente12px,
            tipo: FontWeight.bold,
          )),
          DataColumn(
              label: Etiqueta(
            texto: lblcuadrilla,
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
            texto: lblfechaapertura,
            tamanoFuente: tamanoFuente12px,
            tipo: FontWeight.bold,
          )),
          DataColumn(
              label: Etiqueta(
            texto: lblfechaCierre,
            tamanoFuente: tamanoFuente12px,
            tipo: FontWeight.bold,
          )),
          DataColumn(
              label: Etiqueta(
            texto: lblvehiculo,
            tamanoFuente: tamanoFuente12px,
            tipo: FontWeight.bold,
          )),
          DataColumn(
              label: Etiqueta(
            texto: lbltotalsolicitudesasignadas,
            tamanoFuente: tamanoFuente12px,
            tipo: FontWeight.bold,
          )),
          DataColumn(
              label: Etiqueta(
            texto: lblsolicitudespendientes,
            tamanoFuente: tamanoFuente12px,
            tipo: FontWeight.bold,
          )),
          DataColumn(
              label: Etiqueta(
            texto: lblcierremanual,
            tamanoFuente: tamanoFuente12px,
            tipo: FontWeight.bold,
          )),
        ],
        rows: mapOrdenes.items!.map((item) {
          String fechaApertura = formatoFechaPantalla(fechaDateTime(
              item.fechaApertura!.toLocal().toString().split(' ')[0]));

          return DataRow(
            cells: [
              DataCell(
                  SizedBox(
                    width: anchoUtil(context) / 8,
                    child: Etiqueta(
                      texto: item.numeroOrdenTrabajo ?? '',
                      tamanoFuente: tamanoFuente12px,
                      color: colorAzulPrimario,
                    ),
                  ), onTap: () async {
                //Recuperamos el kilometraje inicial de la jornada
                await getPreferencia(lblregistrokilometrajeinicio)
                    .then((kilometrajeinicial) async {
                  kilometrajeinicial =
                      (kilometrajeinicial == "") ? "0" : kilometrajeinicial;
                  double ki = double.parse(kilometrajeinicial.toString());
                  if (ki <= 0) {
                    Dialogo(context, lblkilometraje,
                        lblkilometraInicialNoRegistrado, Icons.info_rounded);

                    await mostrarKilometrajeDialog(
                        context, item.codOrdenTrabajo.toString());
                  }
                });

                MostrarWidgetEnDialogo(
                    context,
                    SolicitudesOrden(item.codOrdenTrabajo.toString()),
                    "$lblsolicitudes de Orden # ${item.codOrdenTrabajo}");
              }),
              DataCell(Etiqueta(
                texto: item.codCuadrilla?.toString() ?? '',
                tamanoFuente: tamanoFuente10px,
                color: colorNegro,
              )),
              DataCell(Etiqueta(
                texto: DescripcionEstado(item.estado ?? ''),
                tamanoFuente: tamanoFuente10px,
                color: colorNegro,
              )),
              DataCell(Etiqueta(
                texto: fechaApertura,
                tamanoFuente: tamanoFuente10px,
                color: colorNegro,
              )),
              DataCell(Text(item.fechaCierre != null
                  ? item.fechaCierre!.toLocal().toString().split(' ')[0]
                  : '')),
              DataCell(Etiqueta(
                texto: item.vehiculo ?? '',
                tamanoFuente: tamanoFuente10px,
                color: colorNegro,
              )),
              DataCell(Etiqueta(
                texto: item.solicitudesasignadas ?? "0",
                tamanoFuente: tamanoFuente10px,
                color: colorNegro,
              )),
              DataCell(Etiqueta(
                texto: item.solicitudesregistradas ?? "0",
                tamanoFuente: tamanoFuente10px,
                color: colorNegro,
              )),
              DataCell(IconButton(
                icon: Icon(Icons.close),
                color: colorRojoPrimario,
                iconSize: 30,
                onPressed: () async {
                  //Ordenes que no esten cerradas / Normal mente asignadas
                  if (item.estado! != EstadosOrdenesTrabajo.CER.name) {
                    var pendientes = int.parse(item.solicitudesregistradas!);
                    if (pendientes > 0) {
                      var continua = await DialogoConfirmacion(context,
                          lblsolicitudespendientes, lblreportespendientes);

                      if (continua!) {
                        CrudOrdenesTrabajo cls = CrudOrdenesTrabajo();
                        Map<String, dynamic> map = {
                          "cod_orden_trabajo": item.codOrdenTrabajo
                        };
                        cls.actualizarEstadoOrdenTrabajo(map);
                      }
                    } else {
                      BarraMensaje(context)
                          .Mensaje("Orden cerrada previamente.");
                    }
                  }
                },
              )),
            ],
          );
        }).toList(),
      ),
    );
  }

  void traerOrdenesTrabajo() async {
    String luminaria =
        (perfilUsuario == PerfilUsuario.AlumbradoPublicoLuminaria) ? "S" : "N";

    CrudOrdenesTrabajo ordenesTrabajo = CrudOrdenesTrabajo();

    //Listado de ordenes
    await ordenesTrabajo.traerOrdenesTrabajo(luminaria).then(
      (r) {
        if (r.items != null) {
          if (r.items!.isNotEmpty) {
            procesando = false;
            mapOrdenes = r;
          }
        }

        procesando = false;
      },
    );

    setState(() {});
  }

  Future<void> mostrarKilometrajeDialog(
      BuildContext context, String llave) async {
    String? resultado = await showDialog<String>(
      context: context,
      builder: (context) => KilometrajeInicio(),
    );

    if (resultado != null) {
      Navigator.popAndPushNamed(context, "inicio", arguments: {
        lblopcionprincipal: 4.1,
        lblnombreopcion: '$lblsolicitudes de Orden: $llave',
        lblllave: llave,
        lblimagenopcion: urlimagenordenes
      });
      print(
          'Kilometraje ingresado: $resultado'); // Puedes manejar el valor aquí
    }
  }
}
