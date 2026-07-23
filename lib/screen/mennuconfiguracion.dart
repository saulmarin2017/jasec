import 'package:flutter/material.dart';
import 'package:jasec/screen/cambiarclave.dart';
import 'package:jasec/screen/sincronizacion.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:jasec/utilidades/utilidades.dart';
import 'package:jasec/widget/dialogo.dart';
import 'package:jasec/widget/etiqueta.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuConfiguracion extends StatefulWidget {
  const MenuConfiguracion({super.key});

  @override
  State<MenuConfiguracion> createState() => _MenuConfiguracionState();
}

class _MenuConfiguracionState extends State<MenuConfiguracion> {
  double wancho = 200, halto = 100;
  double bwidth = 200, bheight = 150;

  @override
  void initState() {
    super.initState();

    cargarHabilitarLog();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(10),
      color: colorBlanco,
      child: Wrap(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: GestureDetector(
                    onLongPress: () {},
                    onTap: () {
                      MostrarWidgetEnDialogo(context, CambioClave(),
                          lblCambioDeClave.toUpperCase());
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: anchoUtil(context) / 2,
                      height: 200,
                      padding: EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: colorNegro),
                        color: colorGrisSecundario, // Color de fondo
                        borderRadius: BorderRadius.circular(
                            10), // Bordes redondeados opcionales
                      ),
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/clave.png', // Ruta de tu imagen
                            width: wancho, // Tamaño de la imagen
                            height: halto,
                          ),
                          Etiqueta(
                              tamanoFuente: tamanoFuente10px,
                              texto: lblClave,
                              alinear: TextAlign.center,
                              tipo: FontWeight.bold,
                              color: colorNegro),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Espacio(alto: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: GestureDetector(
                    onLongPress: () {},
                    onTap: () {
                      MostrarWidgetEnDialogo(
                          context, Sincronizacion(), lblSincronizacionJasecAPP);
                    },
                    child: Container(
                      width: anchoUtil(context) / 2,
                      height: 200,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: colorNegro),
                        color: colorGrisSecundario, // Color de fondo
                        borderRadius: BorderRadius.circular(
                            10), // Bordes redondeados opcionales
                      ),
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/engranaje.png', // Ruta de tu imagen
                            width: wancho, // Tamaño de la imagen
                            height: halto,
                          ),
                          Etiqueta(
                              tamanoFuente: tamanoFuente10px,
                              texto: lblSincronizacion,
                              alinear: TextAlign.center,
                              tipo: FontWeight.bold,
                              color: colorNegro),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Espacio(alto: 10),
            ],
          ),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.start, // Alinea el contenido a la izquierda
            crossAxisAlignment:
                CrossAxisAlignment.center, // Alinea verticalmente en el centro
            children: [
              Checkbox(
                value: registrarLog,
                onChanged: (bool? valor) {
                  setState(() {
                    registrarLog = valor!;
                    guardarHabilitarLog(
                        registrarLog); // Guardar en SharedPreferences
                  });
                },
              ),
              const Text(
                lblHabilitarRegistroLog,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> guardarHabilitarLog(bool valor) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    registrarLog = valor;
    await prefs.setBool(lblhabilitarlog, valor);
  }

  Future<void> cargarHabilitarLog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      registrarLog =
          prefs.getBool(lblhabilitarlog) ?? false; // Si no existe, es false
    });
  }
}
