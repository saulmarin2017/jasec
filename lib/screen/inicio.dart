import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jasec/class/autenticacion.dart';
import 'package:jasec/class/crudnotificaciones.dart';
import 'package:jasec/class/gps.dart';
import 'package:jasec/class/graficas.dart';
import 'package:jasec/class/log.dart';
import 'package:jasec/class/red.dart';
import 'package:jasec/screen/creartransferencia.dart';
import 'package:jasec/screen/historialsolicitudalumbradopublico.dart';
import 'package:jasec/screen/graficaskpi.dart';
import 'package:jasec/screen/liquidarmateriales.dart';
import 'package:jasec/screen/listaddonotificaciones.dart';
import 'package:jasec/screen/mennuconfiguracion.dart';
import 'package:jasec/screen/minimosinventario.dart';
import 'package:jasec/screen/salida.dart';
import 'package:jasec/screen/screen.dart';
import 'package:jasec/utilidades/utilidades.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:jasec/widget/barramensaje.dart';
import 'package:jasec/widget/widget.dart';
import 'package:badges/badges.dart' as badges;

class Inicio extends StatefulWidget {
  const Inicio({super.key});

  @override
  _Inicio createState() => _Inicio();
}

class _Inicio extends State<Inicio> {
  late GPS gps;
  late Red red;

  int cantidadNotificaciones = 0;

  List<Widget> listaWidgetCentro = [];

  bool _habilitoGPS = false;

  double anchoMenuIzquierdo = 100;

  double altoSubBarra = 40;

  Map<dynamic, dynamic> mapParametros = {};

  @override
  void dispose() {
    red.detenerMonitoreoRed();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      gps = GPS(context);
      red = Red(context: context);

      // Escucha cambios RED
      red.iniciarMonitoreoRed((ConnectivityResult result) {
        // cambiarEstadoRed(result);
      });

      conexionABackEnd();

      _habilitoGPS = await gps.exigirGPSYPermisos();

      // Escucha cambios GPS
      gps.iniciarMonitoreoGPS((status) {
        if (status == ServiceStatus.enabled) {
          _habilitoGPS = true;
          print("📍 GPS activado");
        } else {
          _habilitoGPS = false;
          print("❌ GPS desactivado");
        }
      });

      if (conexionInternet) {
        await getCantidadNotificaciones().then((c) {
          if (mounted) {
            setState(() {
              cantidadNotificaciones = c!;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //Recibimos parametros de otro widget
    if (mapParametros.isEmpty) {
      final argumentos = ModalRoute.of(context)?.settings.arguments;
      if (argumentos != null && argumentos is Map) {
        mapParametros = argumentos;
        // ignore: prefer_interpolation_to_compose_strings
        print('**************************************************************' +
            mapParametros[lblnombreopcion]);

        Log.escribir("Cargando:{$lblnombreopcion} con {$argumentos}");
      }
    }
    // mapParametros = ModalRoute.of(context)!.settings.arguments as Map;

    // ignore: deprecated_member_use
    return WillPopScope(
        onWillPop: () async {
          var respuesta = await _pedirConfirmacionCerrarApp(context);
          if (respuesta != true) {
            return false;
          } else {
            exit(0);
          }
        },
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: colorAzulPrimario,
              toolbarHeight: 40,
              title: Row(
                children: [
                  IconButton(
                      onPressed: () async {
                        // conexionInternet = await red.verificarConexionRed(context);

                        if (conexionInternet) {
                          BarraMensaje(context)
                              .Mensaje('Ya estás conectado a internet.');
                        }

                        //  setState(() {
                        //    conexionInternet = true;
                        //  });
                      },
                      icon:
                          Icon(conexionInternet ? Icons.wifi : Icons.wifi_off)),
                  IconButton(
                      onPressed: () async {
                        _habilitoGPS = await gps.exigirGPSYPermisos();

                        if (_habilitoGPS) {
                          BarraMensaje(context).Mensaje(
                              "Ubicación actual, Latitude: ${PosGPSGlobal!.latitude.toString()} , Longitud ${PosGPSGlobal!.longitude.toString()}");
                        }

                        setState(() {
                          _habilitoGPS = true;
                        });
                      },
                      icon:
                          Icon(_habilitoGPS ? Icons.gps_fixed : Icons.gps_off)),
                  Spacer(),
                  Etiqueta(
                    texto: lblversion,
                    tamanoFuente: tamanoFuente8px,
                    tipo: FontWeight.bold,
                  ),
                  IconButton(
                    onPressed: () {
                      Log.escribir("MODO DESCONECTADO MANUAL");
                      BarraMensaje(context).Mensaje(lblmododesconectadoactivado,
                          colorFondo: colorRojoPrimario,
                          colorFuente: colorBlanco);
                      setState(() {
                        conexionInternet = false;
                      });
                    },
                    icon: (!conexionInternet)
                        ? Icon(Icons.circle, color: colorRojoPrimario)
                        : Icon(Icons.circle, color: colorVerdePrimario),
                  )
                ],
              ),
              leading: Padding(
                padding: const EdgeInsets.all(
                    8.0), // Ajusta el espacio si es necesario
                child: Image.asset(urlimagenlogo,
                    fit: BoxFit.contain), // Cambia la ruta según tu imagen
              ),
              actions: [_listaMenuSuperiorDerecho()],
            ),
            body: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Menú Izquierdo
                Container(
                  height: alturaUtil(context),
                  width: anchoMenuIzquierdo,
                  decoration: BoxDecoration(
                    color: colorAzulSecundario,
                  ),
                  child: Scrollbar(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        children: _listaOpcionesMenuIzquierda(),
                      ),
                    ),
                  ),
                ),

                // Contenido Principal
                Expanded(
                  child: Column(
                    children: [
                      // Sub barra superior con altura fija
                      Container(
                        height:
                            altoSubBarra, // Asigna una altura fija para evitar problemas
                        color: colorAzulClaro,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset(
                              (mapParametros[lblimagenopcion] != null)
                                  ? mapParametros[lblimagenopcion]
                                  : urlimagendefecto, // Ruta de tu imagen
                              width: 50, // Tamaño de la imagen
                              height: 50,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Etiqueta(
                                texto: mapParametros[lblnombreopcion],
                                color: colorBlanco,
                                tamanoFuente: tamanoFuenteTitulosDefecto,
                                tipo: FontWeight.bold,
                              ),
                            ),
                            Spacer(),
                            Padding(
                              padding: const EdgeInsets.only(right: 15),
                              child: badges.Badge(
                                onTap: () async {
                                  await MostrarWidgetEnDialogo(
                                          context,
                                          ListadoNotificaciones(),
                                          lblnotificaciones)
                                      .then((r) async {
                                    await getCantidadNotificaciones().then((c) {
                                      setState(() {
                                        cantidadNotificaciones = c!;
                                      });
                                    });
                                  });
                                },
                                position: badges.BadgePosition.topEnd(
                                    top: -5, end: -5),
                                badgeContent: Text(
                                  cantidadNotificaciones.toString(),
                                  style: TextStyle(
                                      color: colorBlanco,
                                      fontSize: tamanoFuente10px,
                                      fontWeight: FontWeight.bold),
                                ),
                                badgeStyle: badges.BadgeStyle(
                                  badgeColor: Colors.red,
                                  padding: EdgeInsets.all(5),
                                ),
                                child: Icon(Icons.mail_outline, size: 30),
                              ),
                            )
                          ],
                        ),
                      ),
                      // Contenedor de contenido principal que se expande al espacio restante
                      Expanded(
                          child: Container(
                        color: colorBlanco,
                        width: double.infinity, // Se adapta al ancho del padre
                        child: SingleChildScrollView(
                          child: Column(
                            children: _cargaContenidoPrincipal(),
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            )));
  }

  void cambiarEstadoRed(ConnectivityResult result) async {
    /*switch (result) {
      case ConnectivityResult.wifi:
        // Log.escribir("Conectado a WiFi");
        print("Conectado a WiFi");
        conexionInternet = true;
        break;
      case ConnectivityResult.mobile:
        //Log.escribir("Conectado a datos móviles");
        print("Conectado a datos móviles");
        conexionInternet = true;
        break;
      case ConnectivityResult.none:
        //Log.escribir("Sin conexión");
        print("Sin conexión");
        conexionInternet = false;
        break;
      default:
        print("Estado desconocido");
        //Log.escribir("Estado desconocido");
        conexionInternet = false;
        break;
    }*/

    conexionInternet = await conexionBackEnd();

    setState(() {
      conexionInternet;
    });
  }

  void conexionABackEnd() async {
    conexionInternet = await conexionBackEnd();

    setState(() {
      conexionInternet;
    });
  }

  void _onMenuItemSelected(String value) {
    switch (value) {
      case 'user':
        // Acción para mostrar usuario
        print("Usuario seleccionado");
        break;
      case 'logout':
        // Acción para cerrar sesión
        print("Cerrar sesión");
        break;
    }
  }

  PopupMenuButton<String> _listaMenuSuperiorDerecho() {
    return PopupMenuButton<String>(
        onSelected: _onMenuItemSelected,
        icon: Icon(Icons.person),
        itemBuilder: (BuildContext context) {
          return [
            PopupMenuItem<String>(
              value: 'user',
              child: Row(
                children: [
                  Icon(Icons.account_circle),
                  SizedBox(width: 8),
                  Etiqueta(texto: usuarioLogin),
                ],
              ),
            ),
            PopupMenuItem<String>(
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => Login()),
                  (Route<dynamic> route) => false,
                );
              },
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.exit_to_app),
                  SizedBox(width: 8),
                  Text('Cerrar sesión'),
                ],
              ),
            ),
            PopupMenuItem(
                child: IconButton(
                    onPressed: () async {
                      Autenticacion srvUsuario = Autenticacion();

                      await srvUsuario.consumirApi();
                    },
                    icon: Icon(Icons.api)))
          ];
        });
  }

  List<Widget> _listaOpcionesMenuIzquierda() {
    List<Widget> listaWidget = [];

    listaWidget.add(Row(
      mainAxisSize: MainAxisSize.min, // Ajusta el tamaño al contenido
      children: [
        GestureDetector(
          onTap: () {
            Navigator.popAndPushNamed(context, "inicio", arguments: {
              lblopcionprincipal: 1,
              lblnombreopcion: lblMenu,
              lblllave: 0
            });
          },
          child: Icon(
            Icons.menu,
            color: colorBlanco,
          ),
        ),
        SizedBox(width: 8), // Espaciado entre el icono y el texto
        Etiqueta(
          texto: lblNombreAPP,
          color: colorBlanco,
          tamanoFuente: tamanoFuenteTitulosDefecto,
          tipo: FontWeight.bold,
        ),
      ],
    ));

    if (mapParametros[lblopcionprincipal] > 1) {
      listaWidget.addAll(_listaOpcionesMenu(
          ancho: 50,
          alto: 50,
          imagen: 'b',
          tamanoFuente: tamanoFuenteSecundaria));
    }

    return listaWidget;
  }

  List<Widget> _listaOpcionesMenu(
      {double ancho = 0,
      double alto = 0,
      String imagen = '',
      double tamanoFuente = tamanoAltoPorDefecto}) {
    List<Widget> listaWidget = [];
    List<Widget> listaWidgetf = [];
    double halto, wancho;

    if (alto > 0 && ancho > 0) {
      halto = alto;
      wancho = ancho;
    } else {
      halto = ((alturaUtil(context) - 10) / 3) - 50;
      wancho = ((anchoUtil(context) - 10) / 3) - 50;
    }

    //KPI
    listaWidget.add(
      Padding(
        padding: const EdgeInsets.all(10),
        child: GestureDetector(
          onLongPress: () {
            MostrarWidgetEnDialogo(
                context,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [GraficasKPI()],
                ),
                lblindicaciones);
          },
          onTap: () {
            Navigator.popAndPushNamed(context, "inicio", arguments: {
              lblopcionprincipal: 2,
              lblnombreopcion: lblindicadores,
              lblllave: 0,
              lblimagenopcion: urlimagenindicadores
            });
            /*setState(() {
              _nombreOpcion = lblindicadores;
              _opcionPrincipal = 2; // KPI
            });*/
          },
          child: Column(
            children: [
              Image.asset(
                'assets/images/kpi$imagen.png', // Ruta de tu imagen
                width: wancho, // Tamaño de la imagen
                height: halto,
              ),
              Etiqueta(
                tamanoFuente: tamanoFuente,
                texto: lblindicadores,
                alinear: TextAlign.center,
                tipo: FontWeight.bold,
                color: imagen != '' ? colorBlanco : colorNegro,
              ),
            ],
          ),
        ),
      ),
    );

    //Solicitud
    if (perfilUsuario == PerfilUsuario.AlumbradoPublicoLuminaria) {
      //Solicitud
      listaWidget.add(
        Padding(
          padding: const EdgeInsets.all(10),
          child: GestureDetector(
            onTap: () {
              Navigator.popAndPushNamed(context, "inicio", arguments: {
                lblopcionprincipal: 3,
                lblnombreopcion: lblsolicitudes,
                lblllave: "0",
                lblimagenopcion: urlimagensolicitud,
                "cod_poste": "",
                "modo": "A",
                "numero_orden_trabajo": ""
              });
            },
            child: Column(
              children: [
                Image.asset(
                  'assets/images/solicitud$imagen.png', // Ruta de tu imagen
                  width: wancho, // Tamaño de la imagen
                  height: halto,
                ),
                Etiqueta(
                  tamanoFuente: tamanoFuente,
                  texto: lblsolicitudes,
                  alinear: TextAlign.center,
                  tipo: FontWeight.bold,
                  color: imagen != '' ? colorBlanco : colorNegro,
                ),
              ],
            ),
          ),
        ),
      );
    } /*else {
      listaWidget.add(
        Padding(
          padding: const EdgeInsets.all(10),
          child: GestureDetector(
            onTap: () {
              Navigator.popAndPushNamed(context, "inicio", arguments: {
                lblopcionprincipal: 7,
                lblnombreopcion: lblsolicitudes,
                lblllave: 0,
                lblimagenopcion: urlimagensolicitud
              });
            },
            child: Column(
              children: [
                Image.asset(
                  'assets/images/solicitud$imagen.png', // Ruta de tu imagen
                  width: wancho, // Tamaño de la imagen
                  height: halto,
                ),
                Etiqueta(
                  tamanoFuente: tamanoFuente,
                  texto: lblsolicitudes,
                  alinear: TextAlign.center,
                  tipo: FontWeight.bold,
                  color: imagen != '' ? colorBlanco : colorNegro,
                ),
              ],
            ),
          ),
        ),
      );
    }*/

    //Ordenes
    listaWidget.add(
      Padding(
        padding: const EdgeInsets.all(10),
        child: GestureDetector(
          onTap: () {
            Navigator.popAndPushNamed(context, "inicio", arguments: {
              lblopcionprincipal: 4,
              lblnombreopcion: lblordenestrabajo,
              lblllave: 0,
              lblimagenopcion: urlimagenordenes
            });
          },
          child: Column(
            children: [
              Image.asset(
                'assets/images/orden$imagen.png', // Ruta de tu imagen
                width: wancho, // Tamaño de la imagen
                height: halto,
              ),
              Etiqueta(
                tamanoFuente: tamanoFuente,
                texto: lblordenestrabajo,
                alinear: TextAlign.center,
                tipo: FontWeight.bold,
                color: imagen != '' ? colorBlanco : colorNegro,
              ),
            ],
          ),
        ),
      ),
    );

    //Materiales
    listaWidget.add(
      Padding(
        padding: const EdgeInsets.all(10),
        child: GestureDetector(
          onTap: () {
            Navigator.popAndPushNamed(context, "inicio", arguments: {
              lblopcionprincipal: 5,
              lblnombreopcion: lblmateriales,
              lblllave: 0,
              lblimagenopcion: urlimagenmateriales
            });
          },
          child: Column(
            children: [
              Image.asset(
                'assets/images/materiales$imagen.png', // Ruta de tu imagen
                width: wancho, // Tamaño de la imagen
                height: halto,
              ),
              Etiqueta(
                tamanoFuente: tamanoFuente,
                texto: lblmateriales,
                alinear: TextAlign.center,
                tipo: FontWeight.bold,
                color: imagen != '' ? colorBlanco : colorNegro,
              ),
            ],
          ),
        ),
      ),
    );

    //Engranajes
    listaWidget.add(
      Padding(
        padding: const EdgeInsets.all(10),
        child: GestureDetector(
          onTap: () {
            Navigator.popAndPushNamed(context, "inicio", arguments: {
              lblopcionprincipal: 8, //Menu engranaje
              lblnombreopcion: lblconfiguracion,
              "llave": 0,
              lblimagenopcion: urlimagenengranaje
            });
          },
          child: Column(
            children: [
              Image.asset(
                'assets/images/engranaje$imagen.png', // Ruta de tu imagen
                width: wancho, // Tamaño de la imagen
                height: halto,
              ),
              Etiqueta(
                tamanoFuente: tamanoFuente,
                texto: lblconfiguracion,
                alinear: TextAlign.center,
                tipo: FontWeight.bold,
                color: imagen != '' ? colorBlanco : colorNegro,
              ),
            ],
          ),
        ),
      ),
    );

    //Salida
    listaWidget.add(
      Padding(
        padding: const EdgeInsets.all(10),
        child: GestureDetector(
          onTap: () {
            Navigator.popAndPushNamed(context, "inicio", arguments: {
              lblopcionprincipal: 6, //Salir o registrar kilometraje
              lblnombreopcion: lblsalir,
              lblllave: 0,
              lblimagenopcion: usrliamgensalida
            });
          },
          child: Column(
            children: [
              Image.asset(
                'assets/images/salir$imagen.png', // Ruta de tu imagen
                width: wancho, // Tamaño de la imagen
                height: halto,
              ),
              Etiqueta(
                tamanoFuente: tamanoFuente,
                texto: lblsalir,
                alinear: TextAlign.center,
                tipo: FontWeight.bold,
                color: imagen != '' ? colorBlanco : colorNegro,
              ),
            ],
          ),
        ),
      ),
    );

    listaWidgetf.add(Wrap(
      alignment: WrapAlignment.spaceEvenly,
      children: listaWidget,
    ));

    return listaWidgetf;
  }

  List<Widget> _cargaContenidoPrincipal() {
    List<Widget> listaWidget = [];

    switch (mapParametros[lblopcionprincipal]) {
      case 1: // Opciones carga Principal
        listaWidget.addAll(_listaOpcionesMenu());
        break;
      case 2: // KPI
        listaWidget.add(GraficasKPI());
        break;
      case 3: // Solicitudes Alumnbrado Publico
        listaWidget.add(SolicitudAlumbradoPublico(
          codSolicitud: mapParametros[lblllave],
          codOrdenTrabajo: mapParametros["numero_orden_trabajo"],
          modo: mapParametros["modo"],
          codPoste: mapParametros['cod_poste'],
        ));
        break;
      case 3.1: // Solicitudes Alumnbrado Publico
        listaWidget.add(HistorialSolicitudAlumbradoPublico(
          codPoste: mapParametros[lblllave],
        ));
        break;
      case 4: // Ordenes de Trabajo
        listaWidget.add(OrdenesTrabajo());
        break;
      case 4.1: // Solicitudes de Orden de Trabajo
        listaWidget.add(SolicitudesOrden(mapParametros[lblllave]));
        break;
      case 4.2: // Atencion de la Solilcitud, de la orden de trabajo
        listaWidget.add(AtencionSolicitudServicioTecnico(
          codSolicitud: mapParametros[lblllave],
          numeroOrdenTrabajo: mapParametros['numero_orden_trabajo'],
          estado: mapParametros['estado'],
          codPoste: mapParametros['cod_poste'],
        ));
        break;
      case 4.3: // Historial de Atencion de la Solilcitud, de la orden de trabajo
        listaWidget.add(HistorialAtencionSolicitud(
          codPoste: mapParametros[lblllave],
          numero_orden_trabajo: mapParametros['numero_orden_trabajo'],
          estado: mapParametros['estado'],
        ));
        break;
      case 4.4: // Materiales en luminaria/poste
        listaWidget.add(MaterialesPoste(
          llave: mapParametros[lblllave],
        ));
        break;
      /*case 4.5: // Materiales en luminaria/poste
        listaWidget.add(SolicitudNoEfectiva(
          llave: mapParametros[lblllave],
        ));
        break;*/
      case 5: // Materiales
        listaWidget.add(Materiales());
        break;
      case 5.1: // Consulta Inventario
        listaWidget.add(ConsultaInventario());
        break;
      case 5.2: // Crear requisicion
        listaWidget.add(CrearRequisicion(mapParametros[
            lblllave])); //Recibe como parametro un objeto tipo productos
        break;
      case 5.3: // Crear Transferencia
        listaWidget.add(CrearTransferencia(
          mapParametros[lblllave],
        ));
        break;
      case 5.4: // Liquidacion de Materiales
        listaWidget.add(LiquidacioMateriales(
          mapParametros[lblllave],
        ));
        break;
      case 5.5: // Liquidacion de Materiales
        listaWidget.add(MinimosInventario());
        break;
      case 6: // Salida
        listaWidget.add(Salida());
        break;
      case 7:
        //listaWidget.add(SolicitudServicioTecnico(
        //  modo: 1,
        //));
        break;

      case 7.5: //Formuario datos sitema de medicion insdustrial
        // listaWidget.add(FrmDatosSistemaMedicionIndustrial());
        break;

      case 8:
        listaWidget.add(MenuConfiguracion());
        break;
    }

    return listaWidget;
  }

  Future<void> datosGraficaDona() async {
    Graficas crudproducto = Graficas();
    try {
      vmDatosDona = await crudproducto.traerGraficaDonas();
    } catch ($e) {
      print($e);
    } finally {}
  }

  Future<bool> _pedirConfirmacionCerrarApp(BuildContext context) async {
    bool? respuesta = await DialogoConfirmacion(
        context, lblsalir, lblcerraraplicacion,
        colorFonfoTitulo: colorRojoPrimario);
    return respuesta!;
  }

  Future<int?> getCantidadNotificaciones() async {
    CrudNotificaciones cls = CrudNotificaciones();

    var cantidad = await cls.cantidadNotificacionesPENDIENTES();

    return cantidad;
  }
}
