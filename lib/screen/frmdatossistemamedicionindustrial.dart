import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jasec/class/crudformularios.dart';
import 'package:jasec/class/listasprecargadas.dart';
import 'package:jasec/class/log.dart';
import 'package:jasec/model/model.dart';
import 'package:jasec/model/vmmarcamodelo.dart';
import 'package:jasec/model/vmmedidores.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:jasec/utilidades/utilidades.dart';
import 'package:jasec/widget/etiqueta.dart';
import 'package:jasec/widget/listaselecciontexto.dart';
import 'package:jasec/widget/loading.dart';
import 'package:jasec/widget/texboxform.dart';

// ignore: must_be_immutable
class FrmDatosSistemaMedicionIndustrial extends StatefulWidget {
  String cod_solicitud;

  FrmDatosSistemaMedicionIndustrial(this.cod_solicitud, {super.key});

  @override
  SistemaMedicionIndustrial createState() => SistemaMedicionIndustrial();
}

class SistemaMedicionIndustrial
    extends State<FrmDatosSistemaMedicionIndustrial> {
  ListasPrecargadas listasPrecargadas = ListasPrecargadas();

  List<Map<String, dynamic>> mapFormulario = [];
  List<Map<String, dynamic>> mapRespuestasFormulario = [];
  List<Map<String, dynamic>> mapCategorias = [];

  late VmMarcoModelo mapMarcaModelo;

  late VmMedidores mapMedidores;

  List<String> mapMarca = [];
  List<String> mapModelo59 = [];
  List<String> mapModelo70 = [];

  bool cargoDatos = false;
  bool guardoDatos = false;

  bool _loadingMarcaModelo = false;

  String codigoFormulario = "3";

  int idMarca = 0;
  int idModelo = 0;

  String? directa;
  String? indirecta;
  String? aplica20;

  @override
  void initState() {
    super.initState();
    Log.escribir("initState CON SOLICITUD ${widget.cod_solicitud}");
    inicializarFormulario(widget.cod_solicitud).then((r) {});

    if (!_loadingMarcaModelo) {
      cargarListados();
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
      lista.add(titulo(categoria["des_grupo_preguntas"].toUpperCase()));

      //Extraemos el grupo de preguntas de la categoria
      var listaPreguntas = mapFormulario
          .where((w) =>
              w["cod_grupo_preguntas"] == categoria["cod_grupo_preguntas"])
          .toList();

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

      //Categoria 1
      if (categoria["cod_grupo_preguntas"] == 1) {
        var opciones = listaPreguntas
            .where((w) => w["tipo_respuesta"] == "OPCION")
            .toList();

        var listaOpciones = listaPreguntas
            .where((w) => w["tipo_respuesta"] != "OPCION")
            .toList()
            .sublist(11, 21);

        directa =
            (opciones[0]['respuesta'] == "") ? "NO" : opciones[0]['respuesta'];
        indirecta =
            (opciones[1]['respuesta'] == "") ? "NO" : opciones[1]['respuesta'];

        lista.add(Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Radio<String>(
                  value: "SI",
                  groupValue: directa,
                  onChanged: (value) {
                    setState(() {
                      directa = value!;
                      opciones[0]['respuesta'] = directa;
                    });
                  },
                ),
                Etiqueta(texto: opciones[0]['des_det_grupo_preguntas']),
              ],
            ),
            SizedBox(width: 20), // Espacio entre opciones
            Row(
              children: [
                Radio<String>(
                  value: "SI",
                  groupValue: indirecta,
                  onChanged: (value) {
                    setState(() {
                      indirecta = value!;
                      opciones[1]['respuesta'] = indirecta;
                    });
                  },
                ),
                Etiqueta(texto: opciones[0]['des_det_grupo_preguntas']),
              ],
            ),
          ],
        ));

        lista.add(Row(
          children: [
            SizedBox(
              height: 650,
              width: (anchoUtil(context) / 2) - 25,
              child: _listapreguntas(
                  listaPreguntas
                      .where((w) => w["TIPO_RESPUESTA"] != "OPCION")
                      .toList()
                      .sublist(0, 11),
                  opcionesRespuesta, (int index, String? nuevaRespuesta) {
                setState(() {
                  mapFormulario[index]['respuesta'] = nuevaRespuesta;
                });
              }),
            ),
            SizedBox(
              width: 50,
            ),
            SizedBox(
              height: 650,
              width: (anchoUtil(context) / 2) - 25,
              child: _listapreguntas(listaOpciones, opcionesRespuesta,
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
        var opcionales = listaPreguntas
            .where((w) => w["tipo_respuesta"] == "OPCION")
            .toList();
        var observaciones = listaPreguntas
            .where((w) => w["tipo_respuesta"] == "TEXTOLARGO")
            .toList();

        /* aplica20 = (opcionales[0]['respuesta'] == "")
            ? "NO"
            : opcionales[0]['respuesta'];*/

        lista.add(Row(
          children: [
            SizedBox(
              height: 425,
              width: (anchoUtil(context) / 2) - 25,
              child: _listapreguntas(
                  listaPreguntas
                      .where((w) => w["TIPO_RESPUESTA"] != "OPCION")
                      .toList()
                      .sublist(0, 7),
                  opcionesRespuesta, (int index, String? nuevaRespuesta) {
                setState(() {
                  mapFormulario[index]['respuesta'] = nuevaRespuesta;
                });
              }),
            ),
            SizedBox(
              width: 50,
            ),
            SizedBox(
              height: 425,
              width: (anchoUtil(context) / 2) - 25,
              child: _listapreguntas(
                  listaPreguntas
                      .where((w) => w["TIPO_RESPUESTA"] != "OPCION")
                      .toList()
                      .sublist(7, 14),
                  opcionesRespuesta, (int index, String? nuevaRespuesta) {
                setState(() {
                  mapFormulario[index]['respuesta'] = nuevaRespuesta;
                });
              }),
            ),
          ],
        ));

        lista.add(Row(
          children: [
            Row(
              children: [
                Radio<String>(
                  value: "SI",
                  groupValue: aplica20,
                  onChanged: (value) {
                    setState(() {
                      if (aplica20 == "SI") {
                        aplica20 = null; // desmarca
                        opcionales[0]['respuesta'] = null;
                      } else {
                        aplica20 = "SI"; // marca
                        opcionales[0]['respuesta'] = "SI";
                      }
                    });
                  },
                ),
                Etiqueta(texto: opcionales[0]['des_det_grupo_preguntas']),
              ],
            ),
          ],
        ));

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

        //Para marca y modelo , ya que se manejan en cascada
        if (pregunta['cod_det_preguntas'] == 59 ||
            pregunta['cod_det_preguntas'] == 70) {
          final items = mapMedidores.items ?? [];

          final List<String> marcasUnicas = items
              .where((item) => item.marca != null)
              .map((item) => item.marca!)
              .toSet()
              .toList();

          marcasUnicas.add(lblseleccione);

          return ListTile(
            title: Etiqueta(
              texto: pregunta['des_det_grupo_preguntas'],
              color: colorNegro,
              tamanoFuente: tamanoFuente12px,
            ),
            trailing: SizedBox(
                height: altoInputFormulalrios,
                width: (anchoUtil(context) / 4) - 25,
                child: ListaSeleccionTexto(
                  tamanofuente: tamanoFuente10px,
                  opciones: marcasUnicas,
                  valorSeleccionado:
                      '${pregunta['respuesta'] ?? lblseleccione}',
                  onChanged: (String? nuevaRespuesta) {
                    setState(() {
                      listaPreguntas[index]['respuesta'] = nuevaRespuesta;
                    });
                  },
                )),
          );
          //return marcas(pregunta, index, listaPreguntas);
        }
        //Redibuja los combos de los modelos segun las marcas seleccionadas o guardadas en la DB
        if (pregunta['cod_det_preguntas'] == 60 ||
            pregunta['cod_det_preguntas'] == 71) {
          final items = mapMedidores.items ?? [];

          final List<String> modelosUnicos = items
              .where((item) => item.tipoMedidor != null)
              .map((item) => item.tipoMedidor!)
              .toSet()
              .toList();

          return ListTile(
            title: Etiqueta(
              texto: pregunta['des_det_grupo_preguntas'],
              color: colorNegro,
              tamanoFuente: tamanoFuente12px,
            ),
            trailing: SizedBox(
                height: altoInputFormulalrios,
                width: (anchoUtil(context) / 4) - 25,
                child: ListaSeleccionTexto(
                  tamanofuente: tamanoFuente10px,
                  opciones: modelosUnicos,
                  valorSeleccionado: (pregunta['respuesta']),
                  onChanged: (String? nuevaRespuesta) {
                    setState(() {
                      listaPreguntas[index]['respuesta'] = nuevaRespuesta;
                    });
                  },
                )),
          );

          //return modelosMarca(pregunta, index, listaPreguntas);
        }

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
                  tamanofuente: tamanoFuente10px,
                  opciones: respuestas,
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
                  texto: pregunta['respuesta'] ?? "0",
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
            String _opcionMedicion = pregunta["respuesta"];
            obj = ListTile(
                title: Etiqueta(
                  texto: pregunta['des_det_grupo_preguntas'],
                  color: colorNegro,
                  tamanoFuente: tamanoFuente12px,
                ),
                trailing: SizedBox(
                    height: altoInputFormulalrios,
                    width: (anchoUtil(context) / 2) - 25,
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
        }
        return obj;
      },
    );
  }

  ListTile marcas(Map<String, dynamic> pregunta, int index,
      List<Map<String, dynamic>> listaPreguntas) {
    List<String> marcas = [];

    for (var m in mapMarcaModelo.items!) {
      marcas.add(m.desMarcaMedidor ?? "");
    }

    mapMarca = marcas.toSet().toList();

    //Carga los datos de los modelos asociados a la marca
    llenarModeloMarca(pregunta);

    return ListTile(
      title: Etiqueta(
        texto: pregunta['des_det_grupo_preguntas'],
        color: colorNegro,
        tamanoFuente: tamanoFuente12px,
      ),
      trailing: SizedBox(
          height: altoInputFormulalrios,
          width: (anchoUtil(context) / 4) - 25,
          child: ListaSeleccionTexto(
            tamanofuente: tamanoFuente10px,
            opciones: mapMarca,
            valorSeleccionado: (pregunta['respuesta']),
            onChanged: (String? nuevaRespuesta) {
              setState(() {
                listaPreguntas[index]['respuesta'] = nuevaRespuesta;
              });
            },
          )),
    );
  }

  void llenarModeloMarca(Map<String, dynamic> pregunta) {
    switch (pregunta['cod_det_preguntas']) {
      case 59:
        mapModelo59 = [];
        break;
      case 70:
        mapModelo70 = [];
        break;
    }

    //Se recupera el id de marca seleccionada
    var marcaSelect = mapMarcaModelo.items!
        .where((w) => w.desMarcaMedidor == pregunta['respuesta'])
        .take(1);
    idMarca = marcaSelect.first.codMarcaMedidor ?? 0;

    //Filtramos modelos en base a marca seleccionada
    var modelosMaraca = mapMarcaModelo.items!
        .where((item) =>
            item.codMarcaMedidor == idMarca && item.codModeloMedidor != null)
        .toList();

    for (var m in modelosMaraca) {
      switch (pregunta['cod_det_preguntas']) {
        case 59:
          mapModelo59.add(m.desModeloMedidor ?? "");
          break;
        case 70:
          mapModelo70.add(m.desModeloMedidor ?? "");
          break;
      }
    }
  }

  ListTile modelosMarca(Map<String, dynamic> pregunta, int index,
      List<Map<String, dynamic>> listaPreguntas) {
    List<String> mapModelo = [];
    switch (pregunta['cod_det_preguntas']) {
      case 60:
        mapModelo = mapModelo59;
        break;
      case 71:
        mapModelo = mapModelo70;
        break;
    }

    return ListTile(
      title: Etiqueta(
        texto: pregunta['des_det_grupo_preguntas'],
        color: colorNegro,
        tamanoFuente: tamanoFuente12px,
      ),
      trailing: SizedBox(
          height: altoInputFormulalrios,
          width: (anchoUtil(context) / 4) - 25,
          child: ListaSeleccionTexto(
            tamanofuente: tamanoFuente10px,
            opciones: mapModelo,
            valorSeleccionado: (pregunta['respuesta']),
            onChanged: (String? nuevaRespuesta) {
              setState(() {
                listaPreguntas[index]['respuesta'] = nuevaRespuesta;
              });
            },
          )),
    );
  }

  Future inicializarFormulario(String cod_solicitud) async {
    bool encontroDatos = false;

    await traerDatosFormularioGuardado(cod_solicitud, codigoFormulario)
        .then((r) {
      encontroDatos = r;
      Log.escribir(
          "traerDatosFormularioGuardado $cod_solicitud Y $codigoFormulario RESPONDIO $r");
    });

    if (!encontroDatos) {
      await traerDatosFormularioNuevo(codigoFormulario).then((r) {
        encontroDatos = r;
        for (var m in mapFormulario) {
          m['cod_solicitud'] = cod_solicitud;
        }
      });
    }

    if (encontroDatos) {
      await traerRespuestasSujeridasFormulario();
    }

    cargoDatos = true;
  }

  Future<void> cargarListados() async {
    await listasPrecargadas.listaMedidores().then(
      (resp) {
        setState(() {
          mapMedidores = resp;
          _loadingMarcaModelo = true;
        });
      },
    );
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
