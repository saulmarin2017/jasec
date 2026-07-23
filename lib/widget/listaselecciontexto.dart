import 'package:flutter/material.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:jasec/widget/etiqueta.dart';

class ListaSeleccionTexto extends StatelessWidget {
  final String? valorSeleccionado;
  final List<String> opciones;
  final Function(String?) onChanged;
  final Color colorFondo;
  final Color colorBorde;
  final Color colorBordeEnfocado;
  final double tamanofuente;
  final String textoEtiqueta;

  // ignore: use_super_parameters
  const ListaSeleccionTexto({
    Key? key,
    this.valorSeleccionado,
    required this.opciones,
    required this.onChanged,
    this.colorFondo = colorGrisSecundario,
    this.colorBorde = colorGrisPrimario,
    this.colorBordeEnfocado = colorAcua,
    this.tamanofuente = tamanoFuente14px,
    this.textoEtiqueta = "",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      hint: Etiqueta(
        texto: textoEtiqueta,
        tamanoFuente: tamanofuente,
      ),
      value: opciones.contains(valorSeleccionado) ? valorSeleccionado : null,
      decoration: InputDecoration(
        fillColor: colorFondo,
        filled: true,
        isCollapsed: true,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: padingX, vertical: padingy),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 1, color: colorBorde),
          borderRadius: BorderRadius.zero,
        ),
        border: InputBorder.none,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(width: 1, color: colorBordeEnfocado),
        ),
      ),
      items: opciones.map((String opcion) {
        return DropdownMenuItem<String>(
          value: opcion,
          child: Etiqueta(
            texto: opcion,
            tamanoFuente: tamanofuente,
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
