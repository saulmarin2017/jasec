import 'package:flutter/material.dart';
import 'package:jasec/class/crudordenestrabajo.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:jasec/utilidades/utilidades.dart';
import 'package:jasec/widget/dialogo.dart';
import 'package:jasec/widget/etiqueta.dart';

class KilometrajeInicio extends StatefulWidget {
  KilometrajeInicio({super.key});

  @override
  State<KilometrajeInicio> createState() => _KilometrajeInicioState();
}

class _KilometrajeInicioState extends State<KilometrajeInicio> {
  final TextEditingController _controller = TextEditingController();

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
              padding: EdgeInsets.all(5),
              width: double.infinity,
              child: // 🏷️ Título
                  Etiqueta(
                texto: lblregistrokilometrajeinicio,
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
                  onPressed: () async {
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
                    double kilometraje = 0;
                    if (_controller.text.isNotEmpty) {
                      kilometraje = double.parse(_controller.text);
                    }

                    if (kilometraje <= 0) {
                      Dialogo(context, lblkilometraje, lblkilometrajemayoracero,
                          Icons.info_rounded);
                      return;
                    }

                    await guardarKilometrajeDB(kilometraje);

                    await guardarKilometraje(kilometraje).then((respuesta) {
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop((kilometraje)
                          .toString()); // Devuelve el valor ingresado
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
    await setPreferencia(lblregistrokilometrajeinicio, valor.toString());
  }

  Future<void> guardarKilometrajeDB(double valor) async {
    CrudOrdenesTrabajo cls = CrudOrdenesTrabajo();

    if (!conexionInternet) {
      setPreferencia(lblcodkilometrajeinicio, generarNumeroAleatorio());
    } else {
      var kilometraje = {
        "usuario_registra": usuarioLogin,
        "kilometraje_inicio": valor,
        "kilometraje_fin": 0
      };

      await cls.guardarKilometrajeInicio(kilometraje).then((r) {
        //Guardamos codigo de registro de kilometraje insertado para ser usado cuando salga del sistema o finalice la jornada y se tome el kilometraje de salida en kolometrajefinal.dar
        setPreferencia(lblcodkilometrajeinicio, r.idInsertado.toString());
      });
    }
  }
}
