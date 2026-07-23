import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:jasec/class/graficas.dart';
import 'package:jasec/model/vmgraficadona.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:jasec/utilidades/utilidades.dart';
import 'package:jasec/widget/widget.dart';

VmGraficaDona vmDatosDona = VmGraficaDona();

List<Widget> kpi(BuildContext context) {
  double alto = (alturaUtil(context) - 50) / 3;
  double ancho = (anchoUtil(context) - 100) / 3;

  return graficas(alto, ancho);
}

List<Widget> graficas(double h, double w) {
  List<Widget> lista = [];
  List<Widget> listaf = [];

  lista.add(Padding(
    padding: const EdgeInsets.only(top: 100, left: 25),
    child: Column(
      children: [
        SizedBox(
            height: 100,
            width: 100,
            child: PieChart(
              duration: Duration(milliseconds: 3000),
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 50, // Espacio interno para la forma de dona
                sections: _datosDona(),
              ),
            )),
        Espacio(ancho: 50, alto: 50),
        Etiqueta(
          texto: lblsolicitudesatendidas,
          alinear: TextAlign.center,
          color: colorNegro,
          tamanoFuente: tamanoFuenteSecundaria,
        ),
        Etiqueta(
          texto: ' vrs ',
          alinear: TextAlign.center,
          color: colorNegro,
          tamanoFuente: tamanoFuenteSecundaria,
        ),
        Etiqueta(
          texto: lblsolicitudespendientes,
          alinear: TextAlign.center,
          color: colorNegro,
          tamanoFuente: tamanoFuenteSecundaria,
        ),
      ],
    ),
  ));

  lista.add(Padding(
    padding: const EdgeInsets.only(top: 100, right: 0, left: 10),
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
                    value: 0.35, // 70% de progreso
                    minHeight: 20,
                    backgroundColor: colorAzulPrimario,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(colorVerdePrimario),
                  ),
                ),
                Etiqueta(
                  texto: '35 %',
                ),
              ],
            )),
        Etiqueta(
          texto: lblsolicitudescumplientoOT,
          color: colorNegro,
          tamanoFuente: tamanoFuenteSecundaria,
        )
      ],
    ),
  ));

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
              maxY: 100, // Máximo valor en el eje Y
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
                          return Text("");
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
                      toY: 35, color: colorVerdePrimario, width: 50),
                ]),
                BarChartGroupData(x: 1, barRods: [
                  BarChartRodData(toY: 50, color: colorAzulPrimario, width: 50),
                ]),
                BarChartGroupData(x: 2, barRods: [
                  BarChartRodData(
                      toY: 80, color: colorVerdeSecundario, width: 50),
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

  listaf.add(Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: lista,
  ));

  return lista;
}

List<PieChartSectionData> _datosDona() {
  double pendientes = 0;
  double atendidas = 0;

  if (vmDatosDona.items != null) {
    pendientes =
        double.parse((vmDatosDona.items!.first.pendientes ?? 0).toString());
    atendidas =
        double.parse((vmDatosDona.items!.first.atendidas ?? 0).toString());
  }

  return [
    PieChartSectionData(
      value: pendientes,
      color: colorAzulPrimario,
      title: '${pendientes} %',
      radius: 50,
    ),
    PieChartSectionData(
      value: atendidas,
      color: colorVerdePrimario,
      title: '${atendidas} %',
      radius: 50,
    ),
  ];
}

BarChartData mainBarData() {
  return BarChartData(
      barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
    getTooltipColor: (_) => Colors.blueGrey,
    tooltipHorizontalAlignment: FLHorizontalAlignment.right,
    tooltipMargin: -10,
    getTooltipItem: (group, groupIndex, rod, rodIndex) {
      String weekDay;
      switch (group.x) {
        case 0:
          weekDay = 'Monday';
          break;
        case 1:
          weekDay = 'Tuesday';
          break;
        case 2:
          weekDay = 'Wednesday';
          break;
        case 3:
          weekDay = 'Thursday';
          break;
        case 4:
          weekDay = 'Friday';
          break;
        case 5:
          weekDay = 'Saturday';
          break;
        case 6:
          weekDay = 'Sunday';
          break;
        default:
          throw Error();
      }
      return BarTooltipItem(
        '$weekDay\n',
        const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        children: <TextSpan>[
          TextSpan(
            text: (rod.toY - 1).toString(),
            style: const TextStyle(
              color: Colors.white, //widget.touchedBarColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    },
  )));
}

Future<void> cargarDatosDona() async {
  await graficaDonas();
}

Future<void> graficaDonas() async {
  Graficas crudproducto = Graficas();

  try {
    vmDatosDona = await crudproducto.traerGraficaDonas();
  } catch ($e) {
    print($e);
  } finally {}
}
