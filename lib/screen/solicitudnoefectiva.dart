import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jasec/class/crudsolicitud.dart';
import 'package:jasec/class/gps.dart';
import 'package:jasec/class/listasprecargadas.dart';
import 'package:jasec/db/db.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:jasec/utilidades/utilidades.dart';
import 'package:jasec/widget/barramensaje.dart';
import 'package:jasec/widget/dialogo.dart';
import 'package:jasec/widget/dialogoconfirmacion.dart';
import 'package:jasec/widget/etiqueta.dart';
import 'package:jasec/widget/lineahoritzontal.dart';
import 'package:jasec/widget/textboton.dart';

import '../widget/listaseleccion.dart';

class SolicitudNoEfectivaDialog extends StatefulWidget {
  final String idSolicitud;

  const SolicitudNoEfectivaDialog({
    super.key,
    required this.idSolicitud,
  });

  @override
  // ignore: library_private_types_in_public_api
  _SolicitudNoEfectivaDialogState createState() =>
      _SolicitudNoEfectivaDialogState();
}

class _SolicitudNoEfectivaDialogState extends State<SolicitudNoEfectivaDialog> {
  ListasPrecargadas listasPrecargadas = ListasPrecargadas();

  int idMotivoSeleccionado = 0;

  Map<String, String> mapSolicitudNoEfectiva = {
    'ID_SOLICITUD': '',
    'ID_MOTIVO': '',
  };

  List<Map<String, dynamic>> motivosRechazo = [];

  bool _loadingMotivosRechazo = false;
  bool cargoImagen = false;

  @override
  void initState() {
    super.initState();

    mapSolicitudNoEfectiva["cod_solicitud"] = widget.idSolicitud;

    carcarMotivosRechazo();
  }

  @override
  Widget build(BuildContext context) {
    mapSolicitudNoEfectiva["cod_solicitud"] = widget.idSolicitud;

    return Dialog(
      backgroundColor: colorBlanco,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1)),
      child: Container(
        width: anchoUtil(context) - 200,
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Etiqueta(texto: lblmotivoderechazo),
                IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => _cerrarDialogo(context, false)),
              ],
            ),
            LineaHorizontal(
              color: colorGrisSecundario,
              grosor: 1,
            ),
            Espacio(alto: 10),
            Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: colorGrisSecundario, // Color del remarco
                    width: 1.0, // Grosor del remarco
                  ),
                ),
                child: Column(
                  children: [
                    !_loadingMotivosRechazo
                        ? progresoCirculo()
                        : SizedBox(
                            width: anchoUtil(context) - 200,
                            child: ListaSeleccion(
                                textoEtiqueta: lblseleccionemotivorechazo,
                                tamanoFuente: tamanoFuente10px,
                                mapaDatos: motivosRechazo,
                                idKey: "cod_motivos_rechazo",
                                nameKey: "des_motivos_rechazo",
                                selectedValue: (idMotivoSeleccionado > 0)
                                    ? idMotivoSeleccionado
                                    : null,
                                onChanged: (int? value) async {
                                  mapSolicitudNoEfectiva[
                                      "cod_motivos_rechazo"] = '$value';

                                  /* await procesarMotivoRechazo(value.toString())
                                      .then((r) {
                                    _cerrarDialogo(context, true);
                                  });*/

                                  setState(() {
                                    idMotivoSeleccionado = value!;
                                  });
                                }),
                          ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Boton(
                          textoEtiqueta: lblcancelar,
                          colorFondo: colorGrisSecundario,
                          colorTexto: colorNegro,
                          onPressed: () => _cerrarDialogo(context, false),
                        ),
                        Espacio(alto: 10),
                        Boton(
                          textoEtiqueta: lblfoto,
                          colorFondo: colorAzulPrimario,
                          colorTexto: colorBlanco,
                          onPressed: () async {
                            await adjuntarImagen(
                                context,
                                mapSolicitudNoEfectiva["cod_solicitud"]
                                    .toString());
                          },
                        ),
                        Spacer(),
                        /* Boton(
                          textoEtiqueta: lbleliminar,
                          colorFondo: colorGrisSecundario,
                          colorTexto: colorNegro,
                          onPressed: () {},
                        ),
                        Espacio(alto: 10),*/
                        Boton(
                          textoEtiqueta: lblguardar,
                          colorFondo: colorAzulPrimario,
                          colorTexto: colorBlanco,
                          onPressed: () async {
                            var motivorechazo =
                                mapSolicitudNoEfectiva["cod_motivos_rechazo"] ??
                                    "";
                            if (motivorechazo.isNotEmpty) {
                              var continua = await DialogoConfirmacion(
                                  context, lblconfirme, lblnosecargoimagen);
                              if (continua!) {
                                await procesarMotivoRechazo(motivorechazo)
                                    .then((x) {
                                  _cerrarDialogo(context, true);
                                });
                              }
                            } else {
                              BarraMensaje(context).Mensaje(
                                  "Seleccione un motivo de rechazo.",
                                  colorFuente: colorRojoPrimario);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Future<void> procesarMotivoRechazo(String motivorechazo) async {
    if (!conexionInternet) {
      final bd = db.instance;
      Map<String, dynamic> datos = {
        "COD_SOLICITUD": widget.idSolicitud,
        "COD_MOTIVOS_RECHAZO": motivorechazo,
        "POST_PUT": "POST",
        "FECHA": DateTime.now().toIso8601String(),
        "USUARIO_INSERT": usuarioLogin
      };

      await bd
          .insertar(datos, "SIAR_SOLICITUD_MOTIVOS_RECHAZO")
          .then((x) async {
        await chekOut();
      });
      return;
    } else {
      CrudSolicitud cls = CrudSolicitud();
      Map<String, dynamic> mapFormulario = {
        "cod_solicitud": widget.idSolicitud,
        "cod_motivos_rechazo":
            motivorechazo, //mapSolicitudNoEfectiva["cod_motivos_rechazo"],
        "usuario_insert": usuarioLogin
      };

      await cls.guardarMotivosRechazoSolicitud(mapFormulario).then((r) async {
        await chekOut();
      });
    }
  }

  Future<void> chekOut() async {
    var codTiempoAtencion = await getPreferencia(widget.idSolicitud);
    if (!conexionInternet) {
      final bd = db.instance;
      Map<String, dynamic> datos = {
        "COD_TIEMPO_ATENCION": codTiempoAtencion,
        "LATITUD": PosGPSGlobal!.latitude.toString(),
        "LONGITUD": PosGPSGlobal!.longitude.toString(),
        "USUARIO_ATENCION": usuarioLogin,
        "FECHA_FIN": DateTime.now().toIso8601String()
      };

      await bd
          .actualizar("SIAR_TIEMPO_ATENCION", datos, "COD_TIEMPO_ATENCION",
              codTiempoAtencion)
          .then((x) {
        //Limpiamos el id de chekin
        setPreferencia(widget.idSolicitud, '');
      });
    } else {
      if (codTiempoAtencion.isNotEmpty) {
        CrudSolicitud cls = CrudSolicitud();
        GPS gps = GPS(context);
        if (await gps.exigirGPSYPermisos()) {
          Map<String, dynamic> map = {
            "cod_tiempo_atencion": codTiempoAtencion,
            "latitud": PosGPSGlobal!.latitude.toString(),
            "longitud": PosGPSGlobal!.longitude.toString()
          };

          await cls.actualizarFinTiempoAtencion(map).then((resp) {
            if (resp.idInsertado! > 0) {
              setPreferencia(widget.idSolicitud, "");
            }
          });
        }
      }
    }
  }

  void carcarMotivosRechazo() async {
    await listasPrecargadas.listaMotivosRechazo().then(
      (data) {
        setState(() {
          motivosRechazo = data.items!.map((item) => item.toJson()).toList();
          _loadingMotivosRechazo = true;
        });
      },
    );
  }

  Future<void> adjuntarImagen(
      BuildContext context, String cod_solicitud) async {
    //Loading minetras autentica
    DialogoProgreso(context, lblprocesando, lblprocesando, Icons.network_check,
        widget: Center(
            child: SizedBox(width: 200, height: 200, child: progresoCirculo())),
        cerrar: false);
    try {
      await cargarFotografiaSolicitud(cod_solicitud,
              origenFotografia: ImageSource.camera,
              nombreSujerido: "SolicitudNOEfectiva" + cod_solicitud)
          .then((resp) async {
        if (resp) {
          BarraMensaje(context).Mensaje(lblarchivoadjunto);
          cargoImagen = true;
          _cerrarDialogo(context, true);
        } else {
          cargoImagen = false;
          BarraMensaje(context).Mensaje(lblarchivonocargado,
              colorFondo: colorRojoPrimario, colorFuente: colorBlanco);
        }
      });
    } catch ($e) {
      Navigator.of(context).pop();
    } finally {
      // Siempre cerrar el loading
      Navigator.of(context).pop();
    }
  }
}

Future<bool?> dialogoSolicitudNoEfectiva(
    BuildContext context, String idSolicitud) async {
  bool? resultado = await showDialog<bool>(
    context: context,
    builder: (context) => SolicitudNoEfectivaDialog(idSolicitud: idSolicitud),
  );

  if (resultado != null) {
    print("Resultado del diálogo: $resultado");
    return resultado;
    // Puedes manejar la respuesta aquí
  }
  return resultado;
}

void _cerrarDialogo(BuildContext context, bool resultado) {
  Navigator.pop(context, resultado);
}
