import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jasec/class/crudformularios.dart';
import 'package:jasec/class/listasprecargadas.dart';
import 'package:jasec/model/model.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:jasec/utilidades/utilidades.dart';
import 'package:jasec/widget/widget.dart';

// ignore: must_be_immutable
class FrmEvaluacionRequisitosTecnicos extends StatefulWidget {
  String codigoFormulario;
  String cod_solicitud;

  FrmEvaluacionRequisitosTecnicos(this.codigoFormulario, this.cod_solicitud,
      {super.key});

  @override
  _FrmEvaluacionRequisitos createState() => _FrmEvaluacionRequisitos();
}

class _FrmEvaluacionRequisitos extends State<FrmEvaluacionRequisitosTecnicos> {
  String codigoFormulario = "";
  ListasPrecargadas listasPrecargadas = ListasPrecargadas();

  List<Map<String, dynamic>> mapFormulario = [];
  List<Map<String, dynamic>> mapRespuestasFormulario = [];
  List<Map<String, dynamic>> mapCategorias = [];

  bool cargoDatos = false;
  bool guardoDatos = false;

  @override
  void initState() {
    super.initState();
    inicializarFormulario(widget.codigoFormulario, widget.cod_solicitud);
  }

  @override
  Widget build(BuildContext context) {
    codigoFormulario = widget.codigoFormulario;

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
    List<String> respuestas = [];

    //Generamos las preguntas de cada categoria o grupo de preguntas
    for (var categoria in mapCategorias) {
      //Titulo/Grupo de preguntas
      lista.add(titulo(categoria["des_grupo_preguntas"].toUpperCase()));

      //Extraemos el grupo de preguntas de la categoria
      var listaPreguntas = mapFormulario
          .where((w) =>
              w["cod_grupo_preguntas"] == categoria["cod_grupo_preguntas"])
          .toList();
      for (var p in listaPreguntas) {
        p["cod_solicitud"] == "";
      }

      //Extraemos las respuestas asociadas a la categoria
      var opcionesRespuesta = [];
      if (listaPreguntas.isNotEmpty) {
        opcionesRespuesta = mapRespuestasFormulario
            .where((w) =>
                w["cod_respuesta_grupo_preguntas"] ==
                listaPreguntas[0]["cod_respuesta_grupo_preguntas"])
            .toList();
      }

      //Creamos lista de posibles respuestas
      for (var r in opcionesRespuesta) {
        respuestas.add(r["des_respuesta_grupo_preguntas"]);
      }

      //Generamos el listado o litview con las pregunta y sus posibles respuestas
      lista.add(Row(children: [
        _listapreguntas(listaPreguntas, respuestas,
            (int index, String? nuevaRespuesta) {
          setState(() {
            mapFormulario[index]['respuesta'] = nuevaRespuesta;
          });
        })
      ]));

      //Reiniciamos valores
      listaPreguntas = [];
      opcionesRespuesta = [];
      respuestas = [];
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
    return Expanded(
      child: ListView.builder(
        shrinkWrap: true, // Ajuste al contenido
        physics: NeverScrollableScrollPhysics(), // Evita doble scroll
        itemCount: listaPreguntas.length,
        itemBuilder: (context, index) {
          var pregunta = listaPreguntas[index];
          Widget obj = Text("");

          switch (pregunta['tipo_respuesta']) {
            case "LISTA":
              obj = ListTile(
                title: Text(pregunta['des_det_grupo_preguntas']),
                trailing: SizedBox(
                  height: altoInputFormulalrios,
                  width: 150,
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
                title: Text(pregunta['des_det_grupo_preguntas']),
                trailing: SizedBox(
                  height: altoInputFormulalrios,
                  width: 200,
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
                title: Text(pregunta['des_det_grupo_preguntas']),
                trailing: SizedBox(
                  height: altoInputFormulalrios,
                  width: 150,
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
                title: Text(pregunta['des_det_grupo_preguntas']),
                trailing: SizedBox(
                    height: altoInputFormulalrios,
                    width: 150,
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
          }
          return obj;
        },
      ),
    );
  }

  Future inicializarFormulario(String formulario, String solicitud) async {
    var encontroDatos =
        await traerDatosFormularioGuardado(solicitud, formulario);

    if (!encontroDatos) {
      encontroDatos = await traerDatosFormularioNuevo(formulario);
      for (var m in mapFormulario) {
        m['cod_solicitud'] = solicitud;
      }
      /*var original = mapFormulario;
      List<Map<String, dynamic>> map = [];

      for (var m in original) {
        m['cod_solicitud'] = solicitud;
        map.add(m);
      }

      mapFormulario.clear();
      mapFormulario = map;*/
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

    return guardoDatos;
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
