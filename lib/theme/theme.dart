import 'package:flutter/material.dart';
import 'package:jasec/utilidades/publico.dart';

class AppTheme {
  static const estiloTextoDefecto = TextStyle(
      color: colorAzulSecundario,
      fontFamily: lblfuenteDefecto,
      fontSize: tamanoFuenteDefecto,
      fontWeight: FontWeight.normal);

  static final ThemeData temaPrincipal = ThemeData.light().copyWith(
      primaryColor: colorAzulPrimario,
      primaryTextTheme: const TextTheme(
        bodyMedium: TextStyle(
          color: colorAzulPrimario,
          fontFamily: lblfuenteDefecto,
          fontSize: tamanoFuenteDefecto,
          fontWeight: FontWeight.normal,
        ),
      ),
      appBarTheme: const AppBarTheme(color: colorAzulPrimario, elevation: 0),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: colorAzulPrimario)),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(borderRadiusElevatedButton),
                    side: const BorderSide(color: colorVerdeSecundario))),
            backgroundColor: MaterialStateProperty.all(colorAzulPrimario)),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: estiloTextoDefecto,
        labelStyle: TextStyle(
            color: colorGrisPrimario,
            fontFamily: lblfuenteDefecto,
            fontSize: tamanoFuenteSecundaria,
            fontWeight: FontWeight.normal),
        helperStyle: estiloTextoDefecto,
        errorStyle: TextStyle(
          color: colorRojoPrimario,
          fontFamily: lblfuenteDefecto,
          fontSize: tamanoFuenteErrores,
          fontWeight: FontWeight.w100,
        ),

        floatingLabelStyle: TextStyle(color: colorGrisPrimario),

        //Borde interno
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 2, color: colorVerdeSecundario),
            borderRadius: BorderRadius.all(Radius.circular(borderRadiusImput))),

        //Borde Externo
        border: OutlineInputBorder(
            borderSide: BorderSide(width: 15, color: colorGrisPrimario),
            borderRadius: BorderRadius.all(Radius.circular(10))),
      ));
}
