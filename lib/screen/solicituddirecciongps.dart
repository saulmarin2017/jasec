import 'package:flutter/material.dart';
import 'package:jasec/class/crudsolicitud.dart';
import 'package:jasec/class/listasprecargadas.dart';
import 'package:jasec/model/vmposte.dart';
import 'package:jasec/model/vmsolicitud.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:jasec/utilidades/utilidades.dart';
import 'package:jasec/widget/widget.dart';

// ignore: must_be_immutable
class SolicitudDireccionGPS extends StatefulWidget {
  String codSolicitud = '';
  SolicitudDireccionGPS(this.codSolicitud, {super.key});

  @override
  _SolicitudDireccionGPS createState() => _SolicitudDireccionGPS();
}

class _SolicitudDireccionGPS extends State<SolicitudDireccionGPS> {
  bool procesando = true;
  VmPoste mapPostes = VmPoste();
  VmSolicitud mapSolicitud = VmSolicitud(items: []);

  @override
  void initState() {
    super.initState();

    traerSolicitud(widget.codSolicitud);
  }

  @override
  Widget build(BuildContext context) {
    if (procesando) {
      return Center(child: progresoCirculo());
    }

    if (mapSolicitud.items == null) {
      return Center(
          child: Etiqueta(
        texto: lblNoData,
        color: colorRojoPrimario,
      ));
    }

    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(50),
      child: Column(
        mainAxisSize:
            MainAxisSize.min, // importante para que se centre verticalmente
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 4,
            child: Padding(
                padding: EdgeInsets.all(16),
                child: Etiqueta(
                    texto:
                        '$lbldireccion : ${mapSolicitud.items!.first.otrasSenas!}')),
          ),
          (mapPostes.items!.isNotEmpty)
              ? TextButton.icon(
                  label: Etiqueta(texto: lblir),
                  onPressed: () async {
                    ItemPoste poste = mapPostes.items!.first;
                    double lat = double.parse(poste.latitud!);
                    double lon = double.parse(poste.longitud!);
                    await abrirURLGPS(lat, lon);
                  },
                  icon: Icon(
                    Icons.map,
                    color: colorAzulSecundario,
                  ))
              : Text("")
        ],
      ),
    );
  }

  void traerSolicitud(String codSolicitud) async {
    CrudSolicitud crudSolicitud = CrudSolicitud();
    ListasPrecargadas listasPrecargadas = ListasPrecargadas();

    await crudSolicitud.traerSolicitud(codSolicitud, luminaria).then(
      (r) {
        procesando = false;
        if (r.items!.isNotEmpty) {
          mapSolicitud = r;
        }
      },
    );

    if (mapSolicitud.items!.isNotEmpty) {
      await listasPrecargadas
          .listaPostes(codPoste: mapSolicitud.items!.first.codPoste!)
          .then(
        (resp) {
          mapPostes = resp;
        },
      );
    }

    setState(() {});
  }
}
