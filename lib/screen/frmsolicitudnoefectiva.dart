import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jasec/class/crudformularios.dart';
import 'package:jasec/class/crudsolicitud.dart';
import 'package:jasec/class/listasprecargadas.dart';
import 'package:jasec/model/vmformulario.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:jasec/utilidades/utilidades.dart';
import 'package:jasec/widget/etiqueta.dart';
import 'package:jasec/widget/listaselecciontexto.dart';
import 'package:jasec/widget/loading.dart';
import 'package:jasec/widget/texboxform.dart';

// ignore: must_be_immutable
class FrmSolicitudNoEfectiva extends StatefulWidget {
  String cod_solicitud;

  FrmSolicitudNoEfectiva(this.cod_solicitud, {super.key});

  @override
  _FrmSolicitudNoEfectiva createState() => _FrmSolicitudNoEfectiva();
}

class _FrmSolicitudNoEfectiva extends State<FrmSolicitudNoEfectiva> {
  ListasPrecargadas listasPrecargadas = ListasPrecargadas();

  List<Map<String, dynamic>> mapFormulario = [];
  List<Map<String, dynamic>> mapRespuestasFormulario = [];
  List<Map<String, dynamic>> mapCategorias = [];

  bool cargoDatos = false;
  bool guardoDatos = false;

  String codigoFormulario = "6";

  @override
  void initState() {
    super.initState();
    inicializarFormulario(widget.cod_solicitud);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: (!cargoDatos)
            ? Center(child: SizedBox(width: 200, height: 200, child: Loading()))
            : Column(children: listaWidget()));
  }

  @override
  void dispose() {
    super.dispose();
    //Guardamos la infomacion del formulario
    if (mapFormulario.isNotEmpty) {
      guardarFormulario();
    }
  }

  List<Widget> listaWidget() {
    List<Widget> lista = [];

    //Generamos las preguntas de cada categoria o grupo de preguntas
    for (var categoria in mapCategorias) {
      //Titulo/Grupo de preguntas
      lista.add(
        titulo(categoria["des_grupo_preguntas"].toUpperCase(),
            tamanoFuente: tamanoFuente12px),
      );

      //Extraemos el grupo de preguntas de la categoria
      var listaPreguntas = mapFormulario
          .where((w) =>
              w["cod_grupo_preguntas"] == categoria["cod_grupo_preguntas"])
          .toList();

      //Categoria 1
      if (categoria["cod_grupo_preguntas"] == 1) {
        lista.add(Row(
          children: [
            SizedBox(
              height: 650,
              width: (anchoUtil(context) / 2) - 10,
              child: _listapreguntas(listaPreguntas.toList().sublist(0, 15), [],
                  (int index, String? nuevaRespuesta) {
                setState(() {
                  mapFormulario[index]['respuesta'] = nuevaRespuesta;
                });
              }),
            ),
            SizedBox(
              width: 10,
            ),
            SizedBox(
              height: 650,
              width: (anchoUtil(context) / 2) - 10,
              child:
                  _listapreguntas(listaPreguntas.toList().sublist(15, 30), [],
                      (int index, String? nuevaRespuesta) {
                setState(() {
                  mapFormulario[index]['respuesta'] = nuevaRespuesta;
                });
              }),
            ),
          ],
        ));
      }

      //Categoria 2
      if (categoria["cod_grupo_preguntas"] == 2) {
        lista.add(Row(
          children: [
            SizedBox(
              height: 120,
              width: (anchoUtil(context) / 2) - 10,
              child: _listapreguntas(listaPreguntas.toList().sublist(0, 2), [],
                  (int index, String? nuevaRespuesta) {
                setState(() {
                  mapFormulario[index]['respuesta'] = nuevaRespuesta;
                });
              }),
            ),
            SizedBox(
              width: 10,
            ),
            SizedBox(
              height: 120,
              width: (anchoUtil(context) / 2) - 10,
              child: _listapreguntas(listaPreguntas.toList().sublist(2, 4), [],
                  (int index, String? nuevaRespuesta) {
                setState(() {
                  mapFormulario[index]['respuesta'] = nuevaRespuesta;
                });
              }),
            ),
          ],
        ));
      }

      //Categoria 3
      if (categoria["cod_grupo_preguntas"] == 3) {
        var observaciones = listaPreguntas
            .where((w) => w["tipo_respuesta"] == "TEXTOLARGO")
            .toList();

        //Observaciones
        lista.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: Padding(
              padding: const EdgeInsets.all(20),
              child: TextBoxForm(
                texto: observaciones[0]['respuesta'],
                textoEtiqueta: observaciones[0]['des_det_grupo_preguntas'],
                lineas: 5,
                tipo: TextInputType.multiline,
                propiedadFormulario: 'respuesta',
                valorFormulario: observaciones[0],
              ),
            ))
          ],
        ));
      }
    }

    return lista;
  }

  Widget _listapreguntas(
    List<Map<String, dynamic>>
        listaPreguntas, // Lista de preguntas seleccionada
    List<String>? posiblesRespuestas, // Opciones posibles para cada pregunta
    Function(int, String?)
        onChangedRespuesta, // Callback para manejar cambios de respuesta
  ) {
    listaPreguntas = listaPreguntas.toList()
      ..sort((a, b) =>
          a['orden_detalle_preguntas'].compareTo(b['orden_detalle_preguntas']));

    return ListView.builder(
      shrinkWrap: true, // Ajuste al contenido
      physics: NeverScrollableScrollPhysics(), // Evita doble scroll
      itemCount: listaPreguntas.length,
      itemBuilder: (context, index) {
        var pregunta = listaPreguntas[index];
        Widget obj = Text("");

        switch (pregunta['tipo_respuesta']) {
          case "LISTA":
            obj = ListTile(
              title: Etiqueta(
                texto: pregunta['des_det_grupo_preguntas'],
                color: colorNegro,
                tamanoFuente: tamanoFuente10px,
              ),
              trailing: SizedBox(
                height: altoInputFormulalrios,
                width: (anchoUtil(context) / 4) - 25,
                child: ListaSeleccionTexto(
                  opciones: posiblesRespuestas!,
                  valorSeleccionado: (pregunta['respuesta']),
                  onChanged: (String? nuevaRespuesta) {
                    setState(() {
                      listaPreguntas[index]['respuesta'] = nuevaRespuesta;
                    });
                  },
                ),
              ),
            );
          case "TEXTO":
            obj = ListTile(
              title: Etiqueta(
                texto: pregunta['des_det_grupo_preguntas'],
                color: colorNegro,
                tamanoFuente: tamanoFuente10px,
              ),
              trailing: SizedBox(
                height: altoInputFormulalrios,
                width: (anchoUtil(context) / 4) - 25,
                child: TextBoxForm(
                    texto: pregunta['respuesta'],
                    propiedadFormulario: "respuesta",
                    valorFormulario: pregunta),
              ),
            );

          case "TEXTOLARGO":
            obj = Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextBoxForm(
                    texto: pregunta['respuesta'],
                    textoEtiqueta: pregunta['des_det_grupo_preguntas'],
                    lineas: 5,
                    tipo: TextInputType.multiline,
                    propiedadFormulario: 'respuesta',
                    valorFormulario: pregunta,
                  ),
                ))
              ],
            );

          case "NUMERICO":
            obj = ListTile(
              title: Etiqueta(
                texto: pregunta['des_det_grupo_preguntas'],
                color: colorNegro,
                tamanoFuente: tamanoFuente10px,
              ),
              trailing: SizedBox(
                height: altoInputFormulalrios,
                width: (anchoUtil(context) / 4) - 25,
                child: TextBoxForm(
                  texto: pregunta['respuesta'],
                  propiedadFormulario: "respuesta",
                  valorFormulario: pregunta,
                  tipo: TextInputType.number,
                ),
              ),
            );
          case "FECHA":
            final controladorFecha = TextEditingController();
            controladorFecha.text = pregunta['respuesta'];
            DateTime? fechaSeleccionada;
            obj = ListTile(
              title: Etiqueta(
                texto: pregunta['des_det_grupo_preguntas'],
                color: colorNegro,
                tamanoFuente: tamanoFuente10px,
              ),
              trailing: SizedBox(
                  height: altoInputFormulalrios,
                  width: (anchoUtil(context) / 4) - 25,
                  child: TextBoxForm(
                    controlador: controladorFecha,
                    propiedadFormulario: 'respuesta',
                    tipo: TextInputType.datetime,
                    onTap: () async {
                      if (pregunta['respuesta'] != null &&
                          pregunta['respuesta'].isNotEmpty) {
                        final formato = DateFormat("dd/MM/yyyy");
                        fechaSeleccionada =
                            formato.parse(pregunta['respuesta']);
                      }

                      DateTime? piker = await showDatePicker(
                        context: context,
                        initialDate: fechaSeleccionada ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );

                      if (piker != null) {
                        setState(() {
                          fechaSeleccionada = piker;
                          pregunta['respuesta'] = formatoFechaPantalla(piker);
                          controladorFecha.text = formatoFechaPantalla(piker);
                        });
                      }
                    },
                  )),
            );
          case "OPCION":
            String _opcionMedicion = (pregunta["respuesta"]);
            obj = ListTile(
                title: Etiqueta(
                  texto: pregunta['des_det_grupo_preguntas'],
                  color: colorNegro,
                  tamanoFuente: tamanoFuente10px,
                ),
                trailing: SizedBox(
                    height: altoInputFormulalrios,
                    width: (anchoUtil(context) / 4) - 100,
                    child: Radio<String>(
                      value: 'SI',
                      groupValue: _opcionMedicion,
                      onChanged: (value) {
                        setState(() {
                          _opcionMedicion = value!;
                          pregunta['respuesta'] = value;
                        });
                      },
                    )));

          case "SWITCH":
            bool _valor =
                (pregunta['respuesta'] == "SI" || pregunta['respuesta'] == "")
                    ? true
                    : false;
            obj = SizedBox(
              height: altoInputFormulalrios,
              width: (anchoUtil(context) / 4) - 100,
              child: SwitchListTile(
                activeColor: colorVerdePrimario,
                inactiveThumbColor: colorRojoPrimario,
                inactiveTrackColor: colorAzulClaro,
                activeTrackColor: colorAzulClaro,
                title: Etiqueta(
                  texto: pregunta['des_det_grupo_preguntas'],
                  color: colorNegro,
                  tamanoFuente: tamanoFuente10px,
                ),
                value: _valor,
                onChanged: (val) {
                  setState(() {
                    pregunta['respuesta'] = (val == true) ? "SI" : "NO";
                  });
                },
                // secondary: Text(_valor ? 'SI' : 'NO'),
              ),
            );
        }
        return obj;
      },
    );
  }

  Future inicializarFormulario(String cod_solicitud) async {
    var encontroDatos =
        await traerDatosFormularioGuardado(cod_solicitud, codigoFormulario);

    if (!encontroDatos) {
      encontroDatos = await traerDatosFormularioNuevo(codigoFormulario);
      for (var m in mapFormulario) {
        m['cod_solicitud'] = cod_solicitud;
      }
    }

    if (encontroDatos) {
      traerRespuestasSujeridasFormulario();
    }

    cargoDatos = true;
  }

  void procesaCategorias(VmFormulario resp) {
    mapFormulario = resp.items!.map((item) => item.toJson()).toList();

    Set<int> codigosUnicos = {}; // para guardar los códigos únicos

    for (var item in resp.items ?? []) {
      if (item.codGrupoPreguntas != null &&
          !codigosUnicos.contains(item.codGrupoPreguntas)) {
        codigosUnicos.add(item.codGrupoPreguntas!);
        mapCategorias.add({
          'cod_grupo_preguntas': item.codGrupoPreguntas,
          'des_grupo_preguntas': item.desGrupoPreguntas,
        });
      }
    }
  }

  Future<bool> guardarFormulario() async {
    CrudFormularios crudFormularios = CrudFormularios();

    await crudFormularios
        .guardarRespuestasFormulario(mapFormulario,
            solicitud: widget.cod_solicitud, formulario: codigoFormulario)
        .then(
      (resp) {
        guardoDatos = true;
      },
    );

    await chekOut();

    return guardoDatos;
  }

  Future<void> chekOut() async {
    var codTiempoAtencion = await getPreferencia(lblchekin);

    if (codTiempoAtencion.isNotEmpty) {
      CrudSolicitud cls = CrudSolicitud();
      Map<String, dynamic> map = {"cod_tiempo_atencion": codTiempoAtencion};

      await cls.actualizarFinTiempoAtencion(map).then((resp) async {
        if (resp.idInsertado! > 0) {
          setPreferencia(lblchekin, "");
          await actualizarEstadoSolicitud(widget.cod_solicitud);
        }
      });
    }
  }

  Future<void> actualizarEstadoSolicitud(String cod_solicitud) async {
    CrudSolicitud cls = CrudSolicitud();
    Map<String, dynamic> map = {
      "cod_solicitud": cod_solicitud,
      "estado": "NO EFECTIVA"
    };

    await cls.actualizarEstadoSolicitud(map).then((resp) {
      if (resp.idInsertado! > 0) {}
    });
  }

  Future<bool> traerDatosFormularioNuevo(String formulario) async {
    bool completo = false;
    //Listado de distrito
    await listasPrecargadas.preguntasFormulario(formulario).then(
      (resp) {
        if (resp.items!.isEmpty) {
          completo = false;
        } else {
          procesaCategorias(resp);
          completo = true;
        }
      },
    );

    return completo;
  }

  Future<bool> traerRespuestasSujeridasFormulario() async {
    await listasPrecargadas.respuestasSujeridas().then(
      (resp) {
        setState(() {
          mapRespuestasFormulario =
              resp.items!.map((item) => item.toJson()).toList();

          cargoDatos = true;
        });
      },
    );
    return cargoDatos;
  }

  Future<bool> traerDatosFormularioGuardado(
      String solicitud, String formulario) async {
    CrudFormularios crudFormularios = CrudFormularios();
    bool completo = false;

    await crudFormularios.traerDatosFormulario(solicitud, formulario).then(
      (resp) {
        if (resp.items!.isEmpty) {
          completo = false;
        } else {
          procesaCategorias(resp);
          completo = true;
        }
      },
    );

    return completo;
  }
}
