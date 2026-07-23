import 'package:flutter/material.dart';
import 'package:jasec/class/crudordenestrabajo.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:jasec/utilidades/utilidades.dart';
import 'package:jasec/widget/dialogo.dart';
import 'package:jasec/widget/etiqueta.dart';

class KilometrajeFinal extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  KilometrajeFinal({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: colorBlanco,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(1), // Bordes redondeados
      ),
      elevation: 10, // Sombra
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Evita ocupar toda la pantalla
          children: [
            Container(
              decoration: BoxDecoration(
                color: colorAzulSecundario, // Fondo del panel
              ),
              padding: EdgeInsets.all(10),
              width: double.infinity,
              child: // 🏷️ Título
                  Etiqueta(
                texto: lblregistrokilometrajefinal,
                color: colorBlanco,
                tipo: FontWeight.bold,
              ),
            ),

            Espacio(alto: 16),
            // ✍️ Input Kilometraje
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: lblkilometraje,
                prefixIcon:
                    Icon(Icons.directions_car, color: colorAzulSecundario),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5), // Bordes redondeados
                ),
              ),
            ),

            Espacio(alto: 20),

            // 🔘 Botones
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.start, // Alinea los botones a la derecha
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Devuelve el valor ingresado
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorGrisPrimario, // Color del botón
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(0), // Bordes redondeados
                    ),
                  ),
                  child: Etiqueta(
                    texto: lblcancelar,
                    color: colorBlanco,
                  ),
                ),
                Espacio(alto: 10),
                ElevatedButton(
                  onPressed: () async {
                    double kilometraje = double.parse(_controller.text);

                    if (kilometraje <= 0) {
                      Dialogo(context, lblkilometraje, lblkilometrajemayoracero,
                          Icons.info_rounded);
                      return;
                    }

                    //Recuperamos el kilometraje inicial de la jornada
                    await getPreferencia(lblregistrokilometrajeinicio)
                        .then((kilometrajeinicial) async {
                      double ki = double.parse(kilometrajeinicial);

                      //Validamos que el kilometraje inicial sea menor al kilometraje final
                      if (ki < kilometraje) {
                        String kmi =
                            await getPreferencia(lblcodkilometrajeinicio) ?? 0;

                        kmi = (kmi == "null") ? kmi = "0" : kmi;

                        int codkilometraje = int.parse(kmi);

                        if (codkilometraje <= 0) {
                          Dialogo(
                              context,
                              lblkilometraje,
                              lblkilometraInicialNoRegistrado,
                              Icons.info_rounded);
                          return;
                        }

                        //Actualzamos en Base de datos el kilometraje final
                        await actualizarKilometrajeFinalDB(
                            codkilometraje, kilometraje);

                        await guardarKilometraje(kilometraje).then((respuesta) {
                          setPreferencia(lblregistrokilometrajeinicio, "0");
                          setPreferencia(lblcodkilometrajeinicio, "0");
                          // ignore: use_build_context_synchronously
                          Navigator.of(context).pop(kilometraje
                              .toString()); // Devuelve el valor ingresado
                        });
                      } else {
                        Dialogo(context, lblinformacion,
                            '$lbldiferenciakilometros ($ki)', Icons.error);
                        return;
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorAzulSecundario, // Color del botón
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(0), // Bordes redondeados
                    ),
                  ),
                  child: Etiqueta(
                    texto: lblaceptar,
                    color: colorBlanco,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> guardarKilometraje(double valor) async {
    await setPreferencia(lblregistrokilometrajefinal, valor.toString());
  }

  Future<void> actualizarKilometrajeFinalDB(
      int cod_kilometraje, double valor) async {
    CrudOrdenesTrabajo cls = new CrudOrdenesTrabajo();

    if (!conexionInternet) {
      setPreferencia(lblcodkilometrajeinicio, generarNumeroAleatorio());
    } else {
      var kilometraje = {
        "cod_kilometraje": usuarioLogin,
        "kilometraje_fin": valor
      };

      await cls.guardarKilometrajeInicio(kilometraje);
    }
  }
}
