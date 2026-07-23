import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jasec/class/crudformularios.dart';
import 'package:jasec/class/crudmateriales.dart';
import 'package:jasec/class/listasprecargadas.dart';
import 'package:jasec/model/model.dart';
import 'package:jasec/model/vmsolicitudmaterial.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:jasec/utilidades/utilidades.dart';
import 'package:jasec/widget/widget.dart';

// ignore: must_be_immutable
class FrmEvaluacionRequisitosTecnicosDesglosado extends StatefulWidget {
  String codigoFormulario;
  String cod_solicitud;
  String cod_poste;

  FrmEvaluacionRequisitosTecnicosDesglosado(
      this.codigoFormulario, this.cod_solicitud, this.cod_poste,
      {super.key});

  @override
  _FrmEvaluacionRequisitosTecnicosDesglosado createState() =>
      _FrmEvaluacionRequisitosTecnicosDesglosado();
}

class _FrmEvaluacionRequisitosTecnicosDesglosado
    extends State<FrmEvaluacionRequisitosTecnicosDesglosado> {
  String codigoFormulario =
      ""; //5=Inspeccion Especial, seccion de materiales visible solo para adminx
  ListasPrecargadas listasPrecargadas = ListasPrecargadas();

  List<Map<String, dynamic>> mapFormulario = [];
  List<Map<String, dynamic>> mapRespuestasFormulario = [];
  List<Map<String, dynamic>> mapCategorias = [];
  List<Map<String, dynamic>> mapCategoriasSinFiltro = [];

  late VmSolicitudMateriales mapSolicitudMateriales = VmSolicitudMateriales();

  bool cargoDatos = true;
  bool guardoDatos = false;
  bool redibujar = false;

  List<String>? mapNivelvoltaje = ["Baja Tensión", "Media Tensión"];
  List<String>? mapTipoOcupacion = [];
  List<String>? mapTipoInstalacion = ["Aérea", "Subterranea"];
  List<String>? mapEstadoMateriales = ["Cumple", "No Cumple"];

  String tipoOcupacionSeleccionado = "";
  String nivelVoltajeSeleccionado = "";
  String tipoInstalacionSeleccionado = "";

  String estadoSeleccionado = "";

  List<int> bajasimpleaerea = [2, 3, 5, 7, 8, 9, 11];
  List<int> bajamultipleaerea = [2, 3, 6, 7, 8, 9, 11];
  List<int> bajasimplesubterranea = [2, 4, 5, 7, 8, 9, 11];
  List<int> bajamultiplesubterranea = [2, 4, 6, 7, 8, 9, 11];
  List<int> mediaaereasubterranea = [2, 7, 8, 9, 10, 11];

  List<TextEditingController> brechaControllers = [];

  @override
  void initState() {
    super.initState();
    codigoFormulario = widget.codigoFormulario;

    inicializarFormulario(widget.codigoFormulario, widget.cod_solicitud);

    traerSolicitudMateriales(widget.cod_solicitud, "S", widget.cod_poste);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(children: [
          titulo(lblconfiguracion.toUpperCase()),
          Espacio(alto: 10),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Row(
              spacing: 10,
              children: [
                Expanded(
                  child: ListaSeleccionTexto(
                    textoEtiqueta: lblnivelvoltaje,
                    tamanofuente: tamanoFuente10px,
                    opciones: mapNivelvoltaje!,
                    valorSeleccionado: nivelVoltajeSeleccionado,
                    onChanged: (String? nuevaRespuesta) {
                      setState(() {
                        nivelVoltajeSeleccionado = nuevaRespuesta!;
                        switch (nuevaRespuesta) {
                          case "Baja Tensión":
                            mapTipoOcupacion = ["Simple", "Multiple"];
                            break;
                          case "Media Tensión":
                            mapTipoOcupacion = ["Media Tensión"];
                            break;
                        }
                      });
                    },
                  ),
                ),
                Expanded(
                  child: ListaSeleccionTexto(
                    textoEtiqueta: lbltipoocupacion,
                    tamanofuente: tamanoFuente10px,
                    opciones: mapTipoOcupacion!,
                    valorSeleccionado: tipoOcupacionSeleccionado,
                    onChanged: (String? nuevaRespuesta) {
                      setState(() {
                        tipoOcupacionSeleccionado = nuevaRespuesta!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: ListaSeleccionTexto(
                    textoEtiqueta: lbltipoinstalacion,
                    tamanofuente: tamanoFuente10px,
                    opciones: mapTipoInstalacion!,
                    valorSeleccionado: tipoInstalacionSeleccionado,
                    onChanged: (String? nuevaRespuesta) {
                      setState(() {
                        tipoInstalacionSeleccionado = nuevaRespuesta!;
                        redibujar = true;
                      });
                    },
                  ),
                )
              ],
            ),
          ),
          (redibujar) ? Column(children: listaWidget()) : Text(""),
          (esAdmin() &&
                  widget.codigoFormulario == "5" &&
                  mapSolicitudMateriales.items != null)
              ? materialesUtilizados()
              : Text("")
        ]));
  }

  @override
  void dispose() {
    super.dispose();
    //Guardamos la infomacion del formulario
    if (mapFormulario.isNotEmpty) {
      guardarFormulario();
    }
  }

  Widget materialesUtilizados() {
    // return ListadoMaterialesVerificado(
    //    widget.cod_solicitud, "S", widget.cod_poste);

    return (mapSolicitudMateriales.items != null)
        ? Column(
            children: [
              titulo(lblmaterialesinstalados),
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
                      texto: lblverificado,
                      tamanoFuente: tamanoFuente12px,
                      tipo: FontWeight.bold,
                    ),
                  ),
                  DataColumn(
                    label: Etiqueta(
                      texto: lblbrecha,
                      tamanoFuente: tamanoFuente12px,
                      tipo: FontWeight.bold,
                    ),
                  ),
                  DataColumn(
                    label: Etiqueta(
                      texto: lblestado,
                      tamanoFuente: tamanoFuente12px,
                      tipo: FontWeight.bold,
                    ),
                  ),
                ],
                rows: List.generate(mapSolicitudMateriales.items!.length,
                    (index) {
                  ItemSolicitudMateriales m =
                      mapSolicitudMateriales.items![index];
                  double verificado = double.parse(m.verificado.toString());
                  double brecha = (m.cantidad! - verificado);
                  brechaControllers[index].text = brecha.toInt().toString();

                  estadoSeleccionado = m.estado ?? "Cumple";

                  return DataRow(
                    cells: [
                      DataCell(Text(m.codSiarProducto.toString())),
                      DataCell(Text(m.nomProducto.toString())),
                      DataCell(Text(m.cantidad.toString())),
                      DataCell(Row(
                        children: [
                          TextButton.icon(
                            iconAlignment: IconAlignment.end,
                            label: Etiqueta(texto: m.verificado.toString()),
                            onPressed: () async {
                              double? cantidad = await showDialog<double>(
                                context: context,
                                builder: (context) => dialogoCantidad(context),
                              );

                              if (cantidad! > 0) {
                                double br = (m.cantidad! -
                                    double.parse(cantidad.toString()));

                                brechaControllers[index].text =
                                    br.toInt().toString();

                                Map<String, dynamic> map = {
                                  "cod_solicitud_material":
                                      m.codSolicitudMaterial,
                                  "cantidad": m.cantidad,
                                  "verificado": cantidad,
                                  "estado": estadoSeleccionado
                                };

                                await actualizarSolicitudMateriales(map)
                                    .then((x) {
                                  traerSolicitudMateriales(widget.cod_solicitud,
                                      "S", widget.cod_poste);
                                });
                              }
                              //setState(() {});
                            },
                            icon: Icon(
                              Icons.edit,
                              color: colorAmarrillo,
                            ),
                          )
                        ],
                      )),
                      DataCell(Text(brechaControllers[index].text)),
                      DataCell(SizedBox(
                        width: 150,
                        height: 30,
                        child: ListaSeleccionTexto(
                          tamanofuente: tamanoFuente8px,
                          opciones: mapEstadoMateriales!,
                          valorSeleccionado: estadoSeleccionado,
                          onChanged: (String? nuevaRespuesta) async {
                            estadoSeleccionado = nuevaRespuesta!;
                            Map<String, dynamic> map = {
                              "cod_solicitud_material": m.codSolicitudMaterial,
                              "cantidad": m.cantidad,
                              "verificado": m.verificado,
                              "estado": estadoSeleccionado
                            };

                            await actualizarSolicitudMateriales(map).then((x) {
                              traerSolicitudMateriales(
                                  widget.cod_solicitud, "S", widget.cod_poste);
                            });
                          },
                        ),
                      )),
                    ],
                  );
                }).toList(),
              ),
            ],
          )
        : Text("");
  }

  List<Widget> listaWidget() {
    List<Widget> lista = [];
    List<String> respuestas = [];
    List<int> filtro = listafiltrada();

    mapCategorias = mapCategoriasSinFiltro
        .where((mapa) => filtro.contains(mapa['cod_grupo_preguntas']))
        .toList();

    mapCategorias.sort(
        (a, b) => a['cod_grupo_preguntas'].compareTo(b['cod_grupo_preguntas']));

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

  List<int> listafiltrada() {
    List<int> categoriasFiltradas = [];

    if (nivelVoltajeSeleccionado == "Baja Tensión" &&
        tipoOcupacionSeleccionado == "Simple" &&
        tipoInstalacionSeleccionado == "Aérea") {
      categoriasFiltradas = bajasimpleaerea;
    }

    if (nivelVoltajeSeleccionado == "Baja Tensión" &&
        tipoOcupacionSeleccionado == "Multiple" &&
        tipoInstalacionSeleccionado == "Aérea") {
      categoriasFiltradas = bajamultipleaerea;
    }

    if (nivelVoltajeSeleccionado == "Baja Tensión" &&
        tipoOcupacionSeleccionado == "Simple" &&
        tipoInstalacionSeleccionado == "Subterranea") {
      categoriasFiltradas = bajasimplesubterranea;
    }
    if (nivelVoltajeSeleccionado == "Baja Tensión" &&
        tipoOcupacionSeleccionado == "Multiple" &&
        tipoInstalacionSeleccionado == "Subterranea") {
      categoriasFiltradas = bajamultiplesubterranea;
    }

    if (nivelVoltajeSeleccionado == "Media Tensión" &&
        tipoOcupacionSeleccionado == "Media Tensión" &&
        tipoInstalacionSeleccionado == "Aérea") {
      categoriasFiltradas = mediaaereasubterranea;
    }

    if (nivelVoltajeSeleccionado == "Media Tensión" &&
        tipoOcupacionSeleccionado == "Media Tensión" &&
        tipoInstalacionSeleccionado == "Subterranea") {
      categoriasFiltradas = mediaaereasubterranea;
    }

    return categoriasFiltradas;
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
              controladorFecha.text = pregunta['respuesta'] ?? "";
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
                          fechaSeleccionada = formato
                              .parse(pregunta['respuesta'] ?? DateTime.now());
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
        mapCategoriasSinFiltro.add({
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
        mapRespuestasFormulario =
            resp.items!.map((item) => item.toJson()).toList();

        cargoDatos = true;
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

  Future<void> actualizarSolicitudMateriales(Map<String, dynamic> map) async {
    CrudMateriales cls = CrudMateriales();

    //Listado de ordenes
    await cls.actualizarSolicitudMateriales(map).then(
      (r) {
        if (r.items != null) {
          if (r.items is List) {
            if (r.items!.isNotEmpty) {
              cargoDatos = true;
            }
          }
        }

        setState(() {
          cargoDatos = true;
        });
      },
    );
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
                mapSolicitudMateriales = r;
                cargoDatos = true;

                brechaControllers = mapSolicitudMateriales.items!
                    .map((p) => TextEditingController(text: "0"))
                    .toList();
              });
            }
          }
        }

        setState(() {
          cargoDatos = true;
        });
      },
    );
  }
}
