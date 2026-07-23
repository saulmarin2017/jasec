import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jasec/class/omitircertificadohttps.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:jasec/service/seguridad.dart';
import 'package:jasec/route/approute.dart';
import 'package:jasec/theme/theme.dart';
import 'package:provider/provider.dart';

void main() {
  /*SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(MyApp());
  });*/

  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    //Ignora el certificado https
    // ⚠️⚠️⚠️⚠️⚠️⚠️⚠️ SOLO EN DEBUG, ESTO DESPROTEGE HTTPS, NO USAR EN PRODUCCION⚠️⚠️⚠️⚠️⚠️⚠️⚠️
    HttpOverrides.global = MyHttpOverrides();

    runApp(MyApp());
  });

  //runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<SeguridadServicio>(
              create: (_) => SeguridadServicio(), lazy: true),
        ],
        builder: (context, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: lblNombreAPP,
            //home: Inicio(),
            initialRoute: AppRoute.rutaInicial,
            routes: AppRoute.getAppRoute(),
            onGenerateRoute: AppRoute.rutaSinDefinir,
            theme: AppTheme.temaPrincipal,
          );
        });
  }
}
