import 'package:flutter/material.dart';
import 'package:jasec/utilidades/publico.dart';

class SelectorConBusquedaZoom extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final String idKey;
  final String nameKey;
  final Function(int?) onChanged;
  final String? textoEtiqueta;
  final int? selectedValue;

  const SelectorConBusquedaZoom({
    super.key,
    required this.items,
    required this.idKey,
    required this.nameKey,
    required this.onChanged,
    this.textoEtiqueta,
    this.selectedValue,
  });

  @override
  State<SelectorConBusquedaZoom> createState() =>
      _SelectorConBusquedaZoomState();
}

class _SelectorConBusquedaZoomState extends State<SelectorConBusquedaZoom> {
  String? nombreSeleccionado;

  @override
  void initState() {
    super.initState();
    final seleccionado = widget.items.firstWhere(
      (item) => item[widget.idKey] == widget.selectedValue,
      orElse: () => {},
    );
    nombreSeleccionado = seleccionado[widget.nameKey]?.toString();
  }

  void abrirSelectorConBusqueda() async {
    final resultado = await showDialog<int>(
      context: context,
      builder: (context) {
        TextEditingController busquedaCtrl = TextEditingController();
        List<Map<String, dynamic>> resultadosFiltrados = [...widget.items];

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            void filtrar(String valor) {
              setStateDialog(() {
                resultadosFiltrados = widget.items
                    .where((item) => item[widget.nameKey]
                        .toString()
                        .toLowerCase()
                        .contains(valor.toLowerCase()))
                    .toList();
              });
            }

            return AlertDialog(
              title: Text(widget.textoEtiqueta ?? 'Seleccione una opción'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: busquedaCtrl,
                    decoration: InputDecoration(
                      hintText: 'Buscar...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: filtrar,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 300,
                    width: double.maxFinite,
                    child: resultadosFiltrados.isEmpty
                        ? Center(child: Text('No hay resultados'))
                        : ListView.builder(
                            itemCount: resultadosFiltrados.length,
                            itemBuilder: (context, index) {
                              final item = resultadosFiltrados[index];
                              return ListTile(
                                title: Text(
                                  item[widget.nameKey].toString(),
                                  style: TextStyle(fontSize: tamanoFuente10px),
                                ),
                                onTap: () => Navigator.of(context)
                                    .pop(item[widget.idKey]),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (resultado != null) {
      setState(() {
        nombreSeleccionado = widget.items
            .firstWhere((e) => e[widget.idKey] == resultado)[widget.nameKey];
      });
      widget.onChanged(resultado);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: abrirSelectorConBusqueda,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: widget.textoEtiqueta,
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(),
        ),
        child: Text(nombreSeleccionado ?? 'Seleccione una opción'),
      ),
    );
  }
}
