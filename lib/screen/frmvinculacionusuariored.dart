import 'package:flutter/material.dart';
import 'package:jasec/class/crudformularios.dart';
import 'package:jasec/class/gps.dart';
import 'package:jasec/class/listasprecargadas.dart';
import 'package:jasec/model/vmformulario.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:jasec/utilidades/utilidades.dart';
import 'package:jasec/widget/barramensaje.dart';
import 'package:jasec/widget/etiqueta.dart';
import 'package:jasec/widget/listaselecciontexto.dart';
import 'package:jasec/widget/loading.dart';
import 'package:jasec/widget/texboxform.dart';
import 'package:jasec/widget/textboton.dart';

// ignore: must_be_immutable
class FrmVinculacionUsuarioRed extends StatefulWidget {
  String cod_solicitud;
  FrmVinculacionUsuarioRed(this.cod_solicitud, {super.key});

  @override
  _VinculacionUsuarioRed createState() => _VinculacionUsuarioRed();
}

class _VinculacionUsuarioRed extends State<FrmVinculacionUsuarioRed> {
  ListasPrecargadas listasPrecargadas = ListasPrecargadas();

  List<Map<String, dynamic>> mapFormulario = [];
  List<Map<String, dynamic>> mapRespuestasFormulario = [];
  List<Map<String, dynamic>> mapCategorias = [];

  bool cargoDatos = false;
  bool guardoDatos = false;

  String codigoFormulario = "4";

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
        lista.add(Row(
          children: [
            SizedBox(
              height: 300,
              width: (anchoUtil(context) / 2) - 25,
              child: _listapreguntas(listaPreguntas.sublist(0, 5), [], null),
            ),
            SizedBox(
              width: 50,
            ),
            SizedBox(
              height: 300,
              width: (anchoUtil(context) / 2) - 25,
              child: _listapreguntas(listaPreguntas.sublist(5, 10), [], null),
            ),
          ],
        ));
      }

      //Categoria 2
      if (categoria["cod_grupo_preguntas"] == 2) {
        lista.add(Row(
          children: [
            SizedBox(
              height: 150,
              width: (anchoUtil(context) / 2) - 25,
              child: _listapreguntas(listaPreguntas.sublist(0, 2), [], null),
            ),
            SizedBox(
              width: 50,
            ),
            SizedBox(
              height: 150,
              width: (anchoUtil(context) / 2) - 25,
              child: Column(
                children: [
                  _listapreguntas(listaPreguntas.sublist(2, 3), [], null),
                  Container(
                    height: 50,
                    width: (anchoUtil(context) / 2) - 100,
                    child: Boton(
                        colorFondo: colorGrisSecundario,
                        colorTexto: colorNegro,
                        bordenRedondeado: 0,
                        tamanoFuente: tamanoFuente12px,
                        onPressed: () async {
                          GPS gps = GPS(context);
                          if (await gps.exigirGPSYPermisos()) {
                            BarraMensaje clsMensaje = BarraMensaje(context);

                            clsMensaje.Mensaje(
                                "Ubicación actual, Latitude: ${PosGPSGlobal!.latitude.toString()} , Longitud ${PosGPSGlobal!.longitude.toString()}");
                          }
                        },
                        textoEtiqueta:
                            lblcapturargeoposicionamiento.toUpperCase()),
                  )
                ],
              ),
            ),
          ],
        ));
      }

      //Categoria 3
      if (categoria["cod_grupo_preguntas"] == 3) {
        lista.add(Row(
          children: [
            SizedBox(
              height: 425,
              width: (anchoUtil(context) / 2) - 25,
              child: _listapreguntas(
                  listaPreguntas.sublist(0, 7), opcionesRespuesta,
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
              height: 425,
              width: (anchoUtil(context) / 2) - 25,
              child: _listapreguntas(
                  listaPreguntas.sublist(7, 14), opcionesRespuesta,
                  (int index, String? nuevaRespuesta) {
                setState(() {
                  mapFormulario[index]['respuesta'] = nuevaRespuesta;
                });
              }),
            ),
          ],
        ));

        lista.add(Boton(
            colorFondo: colorGrisSecundario,
            colorTexto: colorNegro,
            bordenRedondeado: 0,
            tamanoFuente: tamanoFuente12px,
            onPressed: () {},
            textoEtiqueta: lblcapturarvinculacionconlared.toUpperCase()));

        lista.add(
          SizedBox(
            height: 50,
          ),
        );
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
    List<Map<String, dynamic>>?
        posiblesRespuestas, // Opciones posibles para cada pregunta
    Function(int, String?)?
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
            var opcionesRespuesta = posiblesRespuestas!.where((w) =>
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
                tamanoFuente: tamanoFuente10px,
              ),
              trailing: SizedBox(
                height: altoInputFormulalrios,
                width: (anchoUtil(context) / 4) - 25,
                child: ListaSeleccionTexto(
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
        }
        return obj;
      },
    );
  }

  Future inicializarFormulario(String cod_solicitud) async {
    bool encontroDatos = false;

    await traerDatosFormularioGuardado(cod_solicitud, codigoFormulario)
        .then((r) {
      encontroDatos = r;
    });

    if (!encontroDatos) {
      await traerDatosFormularioNuevo(codigoFormulario).then((r) {
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
            solicitud: widget.cod_solicitud, formulario: codigoFormulario)
        .then(
      (resp) {
        // BarraMensaje(context).Mensaje(lblGuardoInformacion,
        //     colorFuente: colorBlanco, fontWeight: FontWeight.bold);

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
