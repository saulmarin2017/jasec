import 'package:flutter/material.dart';
import 'package:jasec/screen/splash.dart';
import 'package:jasec/screen/screen.dart';
import 'package:jasec/route/opcionesmenu.dart';

class AppRoute {
  //Pantalla inicial, apuntada en el main
  static const rutaInicial = "splash";

  /*static Map<String, Widget Function(BuildContext)> rutas = 
     {
        'home' : (BuildContext context) => const Home(),
        'login' : (BuildContext context) => const Login(),
        'bienvenida' : (BuildContext context) => const Bienvenida(),        
         'producto' : (BuildContext context) => const Producto(),
      };*/

  static Route<dynamic> rutaSinDefinir(RouteSettings setting) {
    return MaterialPageRoute(builder: (context) => const Login());
  }

  static final menuOpciones = <OpcionesMenu>[
    OpcionesMenu(
        ruta: "splash",
        icon: Icons.home,
        nombre: 'Splash',
        screen: const Splash()),
    OpcionesMenu(
        ruta: "inicio", icon: Icons.home, nombre: 'Inicio', screen: Inicio()),
    OpcionesMenu(
        ruta: "login",
        icon: Icons.supervised_user_circle_sharp,
        nombre: 'Prueba de Login',
        screen: const Login()),
    OpcionesMenu(
        ruta: "ordenmanoobra",
        icon: Icons.home,
        nombre: 'ordenmanoobra',
        screen: const Materiales()),
    OpcionesMenu(
        ruta: "seguimiento",
        icon: Icons.home,
        nombre: 'seguimiento',
        screen: const Seguimiento()),
  ];

  static Map<String, Widget Function(BuildContext)> getAppRoute() {
    Map<String, Widget Function(BuildContext)> appRuta = {};

    for (final option in menuOpciones) {
      appRuta.addAll({option.ruta: (BuildContext context) => option.screen});
    }

    return appRuta;
  }
}
