import 'package:flutter/material.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:jasec/utilidades/utilidades.dart';
import 'package:jasec/widget/widget.dart';

class MaterialesPoste extends StatefulWidget {
  final String llave;

  const MaterialesPoste({
    super.key,
    required this.llave,
  });

  @override
  _MaterialesPoste createState() => _MaterialesPoste();
}

class _MaterialesPoste extends State<MaterialesPoste> {
  final List<Map<String, String>> mapMateriales = [
    {
      lblcodigo: "APP-5543",
      lblnombrematerial: "Bombilla 40R  Led",
      lblcantidad: "1",
      lblactivo: "Bombillo tipo r40 luz blanca led",
    },
    {
      lblcodigo: "MS19009",
      lblnombrematerial: "Marchamo de seguridad",
      lblcantidad: "2",
      lblactivo: "Varios",
    },
    {
      lblcodigo: "FR3FAC",
      lblnombrematerial: "Foto resistencia común 3 contactos ",
      lblcantidad: "1",
      lblactivo: "Suministros",
    } // Agrega más filas según sea necesario
  ];

  final TextEditingController _searchController = TextEditingController();

  List<Map<String, String>> filtermapMateriales = [];

  @override
  void initState() {
    super.initState();
    filtermapMateriales =
        mapMateriales; // Inicialmente, mostramos todos los datos
    _searchController.addListener(_filtrarData);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /*TextField(
          controller: _searchController,
          decoration: InputDecoration(
              labelText: lblbuscar,
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              iconColor: colorVerdePrimario),
        ),*/
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints:
                BoxConstraints(minWidth: MediaQuery.of(context).size.width),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(
                columnSpacing: 15,
                columns: [
                  DataColumn(
                      label: Etiqueta(
                    texto: lblcodigo,
                    tamanoFuente: tamanoFuenteSecundaria,
                    tipo: FontWeight.bold,
                  )),
                  DataColumn(
                      label: Etiqueta(
                    texto: lblnombrematerial,
                    tamanoFuente: tamanoFuenteSecundaria,
                    tipo: FontWeight.bold,
                  )),
                  DataColumn(
                      label: Etiqueta(
                    texto: lbldetalle,
                    tamanoFuente: tamanoFuenteSecundaria,
                    tipo: FontWeight.bold,
                  )),
                  DataColumn(
                      label: Etiqueta(
                    texto: lblactivo,
                    tamanoFuente: tamanoFuenteSecundaria,
                    tipo: FontWeight.bold,
                  )),
                ],
                rows: filtermapMateriales
                    .map(
                      (item) => DataRow(cells: [
                        DataCell(Etiqueta(
                          texto: item[lblcodigo]!,
                          color: colorNegro,
                          tamanoFuente: tamanoFuenteSecundaria,
                        )),
                        DataCell(Etiqueta(
                          texto: item[lblnombrematerial]!,
                          color: colorNegro,
                          tamanoFuente: tamanoFuenteSecundaria,
                        )),
                        DataCell(Boton(
                          textoEtiqueta: lbldetalle,
                          colorTexto: colorBlanco,
                          onPressed: () {
                            Dialogo(context, lbldetalle,
                                item[lblnombrematerial]!, Icons.details);
                          },
                        )),
                        DataCell(Etiqueta(
                          texto: item[lblactivo]!,
                          color: colorNegro,
                          tamanoFuente: tamanoFuenteSecundaria,
                        )),
                      ]),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
        Espacio(alto: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Spacer(
              flex: 3,
            ),
            Expanded(
                child: Boton(
              textoEtiqueta: lblcerrar,
              colorFondo: colorAzulPrimario,
              colorTexto: colorBlanco,
              onPressed: () {
                Navigator.popAndPushNamed(context, "inicio", arguments: {
                  lblopcionprincipal: 4,
                  lblnombreopcion: lblordenestrabajo,
                  lblllave: 0
                });
              },
            )),
          ],
        )
      ],
    );
  }

  void _filtrarData() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filtermapMateriales = mapMateriales.where((orden) {
        return orden.values.any((value) => value.toLowerCase().contains(query));
      }).toList();
    });
  }
}
