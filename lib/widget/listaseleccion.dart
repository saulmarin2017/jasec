import 'package:flutter/material.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:jasec/utilidades/utilidades.dart';
import 'package:jasec/widget/etiqueta.dart';

class ListaSeleccion extends StatelessWidget {
  final String textoEtiqueta;
  final List<Map<String, dynamic>> mapaDatos;
  final String idKey;
  final String nameKey;
  final int? selectedValue;
  final ValueChanged<int?> onChanged;
  final String? Function(int?)? validator;
  final double? tamanoFuente;
  final bool? mostrarcodigo;
  final bool habilitado;

  const ListaSeleccion({
    Key? key,
    required this.textoEtiqueta,
    required this.mapaDatos,
    required this.idKey,
    required this.nameKey,
    required this.onChanged,
    this.selectedValue,
    this.validator,
    this.tamanoFuente = tamanoFuente10px,
    this.mostrarcodigo = false,
    this.habilitado = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
        icon: Align(
          alignment: Alignment.centerLeft,
          child: Icon(Icons.arrow_drop_down),
        ),
        value: selectedValue,
        hint: Etiqueta(
          texto: textoEtiqueta,
          tamanoFuente: tamanoFuente!,
        ),
        items: mapaDatos.map((map) {
          var textoMostrado = map[nameKey];
          if (mostrarcodigo!) {
            textoMostrado = "${map[idKey]} - ${map[nameKey]}";
          }

          return DropdownMenuItem<int>(
            value:
                int.parse(map[idKey].toString()), // Accede al ID dinámicamente
            child: Etiqueta(
              texto: textoMostrado,
              tamanoFuente: tamanoFuente!,
            ),
          );
        }).toList(),
        onChanged: (!habilitado) ? ((esAdmin()) ? onChanged : null) : onChanged,
        validator: validator ??
            (value) {
              if (value == null) {
                return 'Por favor, seleccione una opción';
              }
              return null;
            },
        decoration: InputDecoration(
          fillColor: colorGrisSecundario,
          filled: true,
          isDense: true,
          contentPadding:
              EdgeInsets.symmetric(horizontal: padingX, vertical: padingy),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 1,
              color: colorGrisPrimario,
            ),
            borderRadius: BorderRadius.zero, // Elimina las esquinas redondeadas
          ),
          border: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius
                .zero, // Elimina las esquinas redondeadas cuando está enfocado
            borderSide: BorderSide(
              width: 1,
              color: colorAcua,
            ),
          ),
        ));
  }
}
