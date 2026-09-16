import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jasec/class/http_overrides_setup.dart';
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
  // SSL limitado a srv-sifaj.jasec.go.cr (cadena incompleta en ORDS), como RRHH.
  setupHttpOverrides();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
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
