import 'package:flutter/material.dart';
import 'package:jasec/class/crudformularios.dart';
import 'package:jasec/class/listasprecargadas.dart';
import 'package:jasec/model/vmformulario.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:jasec/utilidades/utilidades.dart';
import 'package:jasec/widget/etiqueta.dart';
import 'package:jasec/widget/listaselecciontexto.dart';
import 'package:jasec/widget/loading.dart';
import 'package:jasec/widget/texboxform.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class FrmDatosSistemaMedicionResidencial extends StatefulWidget {
  String cod_solicitud;

  FrmDatosSistemaMedicionResidencial(this.cod_solicitud, {super.key});

  @override
  _FrmDatosSistemaMedicionResidencial createState() =>
      _FrmDatosSistemaMedicionResidencial();
}

class _FrmDatosSistemaMedicionResidencial
    extends State<FrmDatosSistemaMedicionResidencial> {
  List<Map<String, dynamic>> mapFormulario = [];
  List<Map<String, dynamic>> mapRespuestasFormulario = [];
  List<Map<String, dynamic>> mapCategorias = [];

  ListasPrecargadas listasPrecargadas = ListasPrecargadas();

  bool cargoDatos = false;
  bool guardoDatos = false;

  String cod_formulario = "2";

  @override
  void initState() {
    super.initState();
    inicializarFormulario(widget.cod_solicitud, cod_formulario);
  }

  @override
  void dispose() async {
    super.dispose();
    //Guardamos la infomacion del formulario
    if (mapFormulario.isNotEmpty) {
      await guardarFormulario();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: (!cargoDatos)
            ? Center(child: SizedBox(width: 200, height: 200, child: Loading()))
            : Column(children: listaWidget()));
  }

  List<Widget> listaWidget() {
    List<Widget> lista = [];

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

      //Listamos los codigos de respuestas que contiene la categoria
      Set<int> codigosPermitidos = listaPreguntas
          .map((mapa) => mapa["cod_respuesta_grupo_preguntas"])
          .where((codigo) => codigo != null)
          .cast<int>()
          .toSet();

      //Extraemos las respuestas predefinidas asociadas a la categoria
      List<Map<String, dynamic>> opcionesRespuesta = [];
      if (listaPreguntas.isNotEmpty) {
        // Paso 2: Filtrar los elementos con códigos válidos
        opcionesRespuesta = mapRespuestasFormulario.where((mapa) {
          final codigo = mapa["cod_respuesta_grupo_preguntas"];
          return codigo != null && codigosPermitidos.contains(codigo);
        }).toList();
      }

      lista.add(Row(
        children: [
          SizedBox(
            height: 400,
            width: (anchoUtil(context) / 2) - 25,
            child:
                _listapreguntas(listaPreguntas.sublist(0, 7), opcionesRespuesta,
                    (int index, String? nuevaRespuesta) {
              setState(() {
                mapFormulario[index]['respuesta'] = nuevaRespuesta;
              });
            }),
          ),
          SizedBox(
            width: 50,
          ),
          SizedBox(
            height: 400,
            width: (anchoUtil(context) / 2) - 25,
            child: _listapreguntas(
                listaPreguntas.sublist(8, 15), opcionesRespuesta,
                (int index, String? nuevaRespuesta) {
              setState(() {
                mapFormulario[index]['respuesta'] = nuevaRespuesta;
              });
            }),
          ),
        ],
      ));

      //Observaciones
      lista.add(Row(children: [
        Expanded(
            child: Padding(
          padding: const EdgeInsets.all(10),
          child: _listapreguntas(
              listaPreguntas.sublist(listaPreguntas.length - 1),
              opcionesRespuesta, (int index, String? nuevaRespuesta) {
            setState(() {
              mapFormulario[index]['respuesta'] = nuevaRespuesta;
            });
          }),
        ))
      ]));

      //Reiniciamos valores
      listaPreguntas = [];
      opcionesRespuesta = [];
    }

    return lista;
  }

  Widget _listapreguntas(
    List<Map<String, dynamic>>
        listaPreguntas, // Lista de preguntas seleccionada
    List<Map<String, dynamic>>
        posiblesRespuestas, // Opciones posibles para cada pregunta
    Function(int, String?)
        onChangedRespuesta, // Callback para manejar cambios de respuesta
  ) {
    return ListView.builder(
      shrinkWrap: true, // Ajuste al contenido
      physics: NeverScrollableScrollPhysics(), // Evita doble scroll
      itemCount: listaPreguntas.length,
      itemBuilder: (context, index) {
        var pregunta = listaPreguntas[index];
        Widget obj = Text("");

        switch (pregunta['tipo_respuesta']) {
          case "LISTA":

            //Creamos lista de posibles respuestas, para el listado
            var opcionesRespuesta = posiblesRespuestas.where((w) =>
                w["cod_respuesta_grupo_preguntas"] ==
                listaPreguntas[index]["cod_respuesta_grupo_preguntas"]);

            List<String> respuestas = [];
            for (var r in opcionesRespuesta) {
              respuestas.add(r["des_respuesta_grupo_preguntas"]);
            }

            respuestas.add(lblseleccione);

            obj = ListTile(
              title: Etiqueta(
                texto: pregunta['des_det_grupo_preguntas'],
                color: colorNegro,
                tamanoFuente: tamanoFuente12px,
              ),
              trailing: SizedBox(
                height: altoInputFormulalrios,
                width: (anchoUtil(context) / 4) - 25,
                child: ListaSeleccionTexto(
                  opciones: respuestas,
                  valorSeleccionado: (pregunta['respuesta'] ?? lblseleccione),
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
                tamanoFuente: tamanoFuente12px,
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
                tamanoFuente: tamanoFuente12px,
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
            controladorFecha.text = pregunta['respuesta'] ?? "";
            DateTime? fechaSeleccionada;
            obj = ListTile(
              title: Etiqueta(
                texto: pregunta['des_det_grupo_preguntas'],
                color: colorNegro,
                tamanoFuente: tamanoFuente12px,
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
                      fechaSeleccionada = formato.parse(pregunta['respuesta']);
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
                ),
              ),
            );
        }

        return obj;
      },
    );
  }

  Future inicializarFormulario(
      String cod_solicitud, String cod_formulario) async {
    bool encontroDatos = false;
    if (cod_solicitud.isNotEmpty) {
      await traerDatosFormularioGuardado(cod_solicitud, cod_formulario)
          .then((r) {
        encontroDatos = r;
      });
    }

    if (!encontroDatos) {
      await traerDatosFormularioNuevo(cod_formulario).then((r) {
        encontroDatos = r;
      });
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
            solicitud: widget.cod_solicitud, formulario: cod_formulario)
        .then(
      (resp) {
        guardoDatos = true;
      },
    );

    return guardoDatos;
  }

  Future<bool> traerDatosFormularioNuevo(String formulario) async {
    bool r = false;
    //Listado de distrito
    await listasPrecargadas.preguntasFormulario(formulario).then(
      (resp) {
        procesaCategorias(resp);
        r = true;
      },
    );
    return r;
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
