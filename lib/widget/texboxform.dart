import 'package:flutter/material.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

// ignore: must_be_immutable
class TextBoxForm extends StatelessWidget {
  var maskaraDefecto = MaskTextInputFormatter(
      filter: {"#": RegExp(r'[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$')},
      type: MaskAutoCompletionType.lazy);

  var maskaraFecha = MaskTextInputFormatter(
      mask: '##/##/####',
      filter: {"#": RegExp(r'[0-9,/]')},
      type: MaskAutoCompletionType.lazy);

  var maskaraTelefono = MaskTextInputFormatter(
      mask: '####-####',
      filter: {"#": RegExp(r'[0-9,-]')},
      type: MaskAutoCompletionType.lazy);

  // ignore: prefer_typing_uninitialized_variables
  var maskara = MaskTextInputFormatter();

  final String? textoEtiqueta;
  final String? helperInicial;
  final String? texto;
  final IconData? icono;
  final IconData? iconoDerecha;
  final TextInputType? tipo;
  final bool enfoque;
  final bool password;
  final bool sugerirTexto;
  final bool autoCorrector;
  final bool? obligatorio;
  final bool? habilitado;
  final bool lectura;
  final int? lineas;
  final Color? colorRelleno;
  final String propiedadFormulario;
  final Map<String, dynamic>? valorFormulario;
  final dynamic mascaraPersonalizada;
  final double? tamanoFuente;
  final TextEditingController? controlador;
  final VoidCallback? onTap;
  final VoidCallback? onSave;
  final FontWeight? negrilla;

  TextBoxForm(
      {Key? key,
      this.textoEtiqueta,
      this.helperInicial,
      this.controlador,
      this.habilitado,
      this.tipo,
      this.enfoque = false,
      required this.propiedadFormulario,
      this.valorFormulario,
      this.password = false,
      this.sugerirTexto = true,
      this.autoCorrector = true,
      this.obligatorio = false,
      this.colorRelleno = colorGrisSecundario,
      this.texto = "",
      this.mascaraPersonalizada,
      this.icono,
      this.iconoDerecha,
      this.lineas = 1,
      this.tamanoFuente = tamanoFuente14px,
      this.lectura = false,
      this.onTap,
      this.negrilla = FontWeight.normal,
      this.onSave})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (tipo) {
      case TextInputType.datetime:
        maskara = maskaraFecha;
      case TextInputType.phone:
        maskara = maskaraTelefono;
      default:
        maskara = maskaraDefecto;
    }

    if (mascaraPersonalizada != null) {
      maskara = mascaraPersonalizada;
    }

    if (tipo == TextInputType.datetime) {
    } else {}

    return TextFormField(
      readOnly: lectura,
      textAlignVertical: TextAlignVertical.top,
      enabled: habilitado,
      initialValue: (controlador == null) ? texto : null,
      controller: (texto == "") ? controlador : null,
      inputFormatters: [maskara],
      autovalidateMode: AutovalidateMode.onUserInteraction,
      autofocus: enfoque,
      obscureText: password,
      maxLines: lineas,
      enableSuggestions: sugerirTexto,
      autocorrect: autoCorrector,
      keyboardType: tipo,
      decoration: InputDecoration(
        isDense: true,
        alignLabelWithHint: false,
        floatingLabelBehavior: FloatingLabelBehavior
            .always, //Cambia la ubicacion de la etiqueta del input
        prefixIcon: icono != null ? Icon(icono) : null,
        labelText: textoEtiqueta,
        labelStyle: TextStyle(color: colorNegro, fontWeight: negrilla),
        //hintText: textoInicial,
        helperText: helperInicial,
        fillColor: colorRelleno,
        filled: true,
        border: OutlineInputBorder(),
        contentPadding:
            EdgeInsets.symmetric(horizontal: txtpadingX, vertical: txtpadingy),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
              0), // Aplica cuando el campo no está enfocado
          borderSide: BorderSide(color: colorGrisPrimario), // Color del borde
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: colorGrisPrimario, width: 0),
          borderRadius: BorderRadius.circular(0),
        ),
      ),
      onChanged: (value) {
        valorFormulario?[propiedadFormulario] = value;
      },
      onTap: onTap,
      onSaved: (value) {
        valorFormulario?[propiedadFormulario] = value;
      },
      validator: (value) {
        if (obligatorio!) {
          if (value!.isEmpty) {
            return lbltextoObligatorio + textoEtiqueta.toString();
          }
        }

        if (tipo == TextInputType.emailAddress) {
          bool emailValue = RegExp(lblexpresionRegularCorreo).hasMatch(value!);
          if (!emailValue) {
            return lblcorreoNoValido;
          }
        }

        if (tipo == TextInputType.visiblePassword) {
          if (value!.length < 3) {
            return lblnumeroMinimoCaracteresClave;
          }
        }

        if (tipo == TextInputType.datetime) {
          bool dateValid = RegExp(lblexpresionRegularFecha).hasMatch(value!);
          if (!dateValid) {
            return lblformatoFechaInvalido;
          }
        }

        return null;
      },
      style: TextStyle(
          color: colorNegro,
          fontFamily: lblfuenteDefecto,
          fontSize: tamanoFuente!,
          fontWeight: FontWeight.normal,
          height: 1.0),
    );
  }
}
