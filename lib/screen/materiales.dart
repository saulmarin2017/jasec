import 'package:flutter/material.dart';
import 'package:jasec/class/crudproducto.dart';
import 'package:jasec/model/vmminimosinventario.dart';
import 'package:jasec/utilidades/publico.dart';
import 'package:jasec/widget/widget.dart';

class Materiales extends StatefulWidget {
  const Materiales({super.key});

  @override
  _Ordenes createState() => _Ordenes();
}

class _Ordenes extends State<Materiales> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(milliseconds: 100), () {
        confirmarAccion(context);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Etiqueta(texto: "");
  }

  void confirmarAccion(BuildContext context) async {
    int? minimos = await cantidadProductosExistenciaMinima();
    bool? respuesta = await DialogoConfirmacion(context, lblminimoinventario,
        "Cuenta con cantidad mínima, en $minimos producto(s). ¿Desea realizar la requisición de este(s) material?",
        colorFonfoTitulo: colorRojoPrimario);
    if (respuesta != true) {
      Navigator.popAndPushNamed(context, "inicio", arguments: {
        lblopcionprincipal: 5.1, //Consulta de Inventario
        lblnombreopcion: lblconsultadeinventario,
        lblllave: 0,
        lblimagenopcion: urlimagenmateriales
      });
    } else {
      Navigator.popAndPushNamed(context, "inicio", arguments: {
        lblopcionprincipal: 5.5, //
        lblnombreopcion: lblminimoinventario,
        lblllave: 0,
        lblimagenopcion: urlimagenmateriales
      });
    }
  }

  Future<int?> cantidadProductosExistenciaMinima() async {
    CrudProducto crudproducto = CrudProducto();
    VmMinimosInventario vm = VmMinimosInventario();

    vm = await crudproducto.traerMinimoInventario();

    return (vm.items != null) ? vm.items!.length : 0;
  }
}
