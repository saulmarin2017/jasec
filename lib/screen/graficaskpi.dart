import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:jasec/class/graficas.dart';
import 'package:jasec/model/vmgraficabarras.dart';
import 'package:jasec/model/vmgraficadona.dart';
import 'package:jasec/model/vmgraficaporcentaje.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:jasec/utilidades/utilidades.dart';
import 'package:jasec/widget/widget.dart';

class GraficasKPI extends StatefulWidget {
  const GraficasKPI({super.key});

  @override
  State<GraficasKPI> createState() => _GraficasKPIState();
}

class _GraficasKPIState extends State<GraficasKPI> {
  VmGraficaDona vmDatosDona = VmGraficaDona();
  VmGraficaPorcentaje vmDatosPorcentaje = VmGraficaPorcentaje();
  VmGraficaBarras vmDatosBarras = VmGraficaBarras();

  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatosDona();
    _cargarDatosPorcentaje();
    _cargarDatosBarras();
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return progresoCirculo();
    }

    return SingleChildScrollView(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: _graficas(
          (alturaUtil(context) - 50) / 3,
          (anchoUtil(context) - 100) / 3,
        ),
      ),
    );
  }

  Future<void> _cargarDatosDona() async {
    Graficas graficas = Graficas();
    try {
      VmGraficaDona datos = await graficas.traerGraficaDonas();
      setState(() {
        vmDatosDona = datos;
        cargando = false;
        print("Cargo Datos: ${vmDatosDona.items!.first.atendidas}");
      });
    } catch (e) {
      print("Error cargando datos: $e");
      setState(() {
        cargando = false; // aunque haya error, detenemos el loader
      });
    }
  }

  Future<void> _cargarDatosPorcentaje() async {
    Graficas graficas = Graficas();
    try {
      VmGraficaPorcentaje datos = await graficas.traerGraficaPorcentaje();
      setState(() {
        vmDatosPorcentaje = datos;
        cargando = false;
        print(
            "Cargo Datos Porcentaje: ${vmDatosPorcentaje.items!.first.atendidas}");
      });
    } catch (e) {
      print("Error cargando datos: $e");
      setState(() {
        cargando = false; // aunque haya error, detenemos el loader
      });
    }
  }

  Future<void> _cargarDatosBarras() async {
    Graficas graficas = Graficas();
    try {
      VmGraficaBarras datos = await graficas.traerGraficaBarras();
      setState(() {
        vmDatosBarras = datos;
        cargando = false;
        print("Cargo Datos Barras: ${vmDatosBarras.items!.first.registradas}");
      });
    } catch (e) {
      print("Error cargando datos: $e");
      setState(() {
        cargando = false; // aunque haya error, detenemos el loader
      });
    }
  }

  List<Widget> _graficas(double h, double w) {
    List<Widget> lista = [];

    //Datos dona
    lista.add(Padding(
      padding: const EdgeInsets.only(top: 100, left: 25),
      child: Column(
        children: [
          SizedBox(
            height: 100,
            width: 100,
            child: PieChart(
              duration: const Duration(milliseconds: 3000),
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                sections: _datosDona(),
              ),
            ),
          ),
          Espacio(ancho: 50, alto: 50),
          Etiqueta(
            texto: lblsolicitudes,
            alinear: TextAlign.center,
            color: colorNegro,
            tamanoFuente: tamanoFuenteSecundaria,
          ),
          Etiqueta(
            texto: lblatendidas,
            alinear: TextAlign.center,
            color: colorNegro,
            tamanoFuente: tamanoFuenteSecundaria,
          ),
          Etiqueta(
            texto: lblpendientes,
            alinear: TextAlign.center,
            color: colorNegro,
            tamanoFuente: tamanoFuenteSecundaria,
          ),
        ],
      ),
    ));

    // Barra horizontal
    double solicitudesAtendidas = 0.0;
    double totalSolicitudesAtendidas = 0.0;

    if (vmDatosPorcentaje.items != null &&
        vmDatosPorcentaje.items!.isNotEmpty) {
      solicitudesAtendidas =
          (vmDatosPorcentaje.items!.first.atendidas ?? 0).toDouble();
      totalSolicitudesAtendidas =
          (vmDatosPorcentaje.items!.first.solicitudes ?? 0).toDouble();
    }

    double etiquetaBarraHorizontal = 0.0;

    if (totalSolicitudesAtendidas > 0) {
      etiquetaBarraHorizontal =
          (solicitudesAtendidas / totalSolicitudesAtendidas) * 100;

      // Protección extra contra NaN o Infinity
      if (!etiquetaBarraHorizontal.isFinite) {
        etiquetaBarraHorizontal = 0.0;
      }

      // Opcional: redondear si quieres mostrarlo como entero
      etiquetaBarraHorizontal = etiquetaBarraHorizontal.roundToDouble();
    }

    lista.add(Padding(
      padding: const EdgeInsets.only(top: 100, left: 10),
      child: Column(
        children: [
          SizedBox(
            height: 100,
            width: 150,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (totalSolicitudesAtendidas > 0 &&
                            (solicitudesAtendidas / totalSolicitudesAtendidas)
                                .isFinite)
                        ? (solicitudesAtendidas / totalSolicitudesAtendidas)
                        : 0.0,
                    minHeight: 20,
                    backgroundColor: colorAzulPrimario,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(colorVerdePrimario),
                  ),
                ),
                Etiqueta(
                  texto: '${etiquetaBarraHorizontal} %',
                ),
              ],
            ),
          ),
          Etiqueta(
            texto: lblsolicitudescumplientoOT,
            color: colorNegro,
            tamanoFuente: tamanoFuente8px,
          )
        ],
      ),
    ));

    //Grafica de Barras
    double atendidasBarras = 0;
    double rechazadasBarras = 0;
    double pendientesBarra = 0;

    if (vmDatosBarras.items != null) {
      atendidasBarras =
          double.parse((vmDatosBarras.items!.first.efectivas ?? 0).toString());
      rechazadasBarras = double.parse(
          (vmDatosBarras.items!.first.noefectivas ?? 0).toString());
      pendientesBarra = double.parse(
          (vmDatosBarras.items!.first.registradas ?? 0).toString());
    }
    lista.add(Column(
      children: [
        SizedBox(
          height: h + 200,
          width: w + 50,
          child: Padding(
            padding: const EdgeInsets.only(top: 25),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceBetween,
                maxY: pendientesBarra,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  leftTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: true)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        switch (value.toInt()) {
                          case 0:
                            return Etiqueta(
                              texto: lblatendidas,
                              tamanoFuente: tamanoFuente8px,
                              color: colorNegro,
                            );
                          case 1:
                            return Etiqueta(
                              texto: lblrechazadas,
                              tamanoFuente: tamanoFuente8px,
                              color: colorNegro,
                            );
                          case 2:
                            return Etiqueta(
                              texto: lblpendientes,
                              tamanoFuente: tamanoFuente8px,
                              color: colorNegro,
                            );
                          default:
                            return const Text("");
                        }
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: true),
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [
                    BarChartRodData(
                        toY: atendidasBarras,
                        color: colorVerdePrimario,
                        width: 50),
                  ]),
                  BarChartGroupData(x: 1, barRods: [
                    BarChartRodData(
                        toY: rechazadasBarras,
                        color: colorAzulPrimario,
                        width: 50),
                  ]),
                  BarChartGroupData(x: 2, barRods: [
                    BarChartRodData(
                        toY: pendientesBarra,
                        color: colorVerdeSecundario,
                        width: 50),
                  ]),
                ],
              ),
            ),
          ),
        ),
        Etiqueta(
          texto: lblestadosolicitudes,
          alinear: TextAlign.center,
          color: colorNegro,
          tamanoFuente: tamanoFuenteSecundaria,
        )
      ],
    ));

    return lista;
  }

  List<PieChartSectionData> _datosDona() {
    double pendientes = 0;
    double atendidas = 0;

    if (vmDatosDona.items != null && vmDatosDona.items!.isNotEmpty) {
      pendientes = double.tryParse(
              (vmDatosDona.items!.first.pendientes ?? 0).toString()) ??
          0;
      atendidas = double.tryParse(
              (vmDatosDona.items!.first.atendidas ?? 0).toString()) ??
          0;
    }

    return [
      PieChartSectionData(
        value: pendientes,
        color: colorAzulPrimario,
        title: '$pendientes %',
        radius: 50,
      ),
      PieChartSectionData(
        value: atendidas,
        color: colorVerdePrimario,
        title: '$atendidas %',
        radius: 50,
      ),
    ];
  }
}
