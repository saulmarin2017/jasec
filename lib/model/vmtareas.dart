import 'dart:convert';

import 'package:intl/intl.dart';

// Funciones para convertir desde/hacia JSON string
vmTareas vmTareasFromJson(String str) => vmTareas.fromJson(json.decode(str));
String vmTareasToJson(vmTareas data) => json.encode(data.toJson());

class vmTareas {
  String? descripcion;
  String? url;
  String? estado;

  String? fechaHora;

  vmTareas({this.descripcion, this.url, this.estado, this.fechaHora});

  // Constructor factory desde JSON
  factory vmTareas.fromJson(Map<String, dynamic> json) => vmTareas(
      descripcion: json["descripcion"],
      url: json["url"],
      estado: json["estado"],
      fechaHora: json["fechaHora"]);

  // Método para convertir a JSON map
  Map<String, dynamic> toJson() => {
        "descripcion": descripcion ?? '',
        "url": url ?? '',
        "estado": estado ?? '',
        "fechaHora": fechaHora
      };

  // Constructor helper para crear tarea rápida
  factory vmTareas.crear(
      {required String descripcion,
      required String url,
      String estado = 'EJECUTADO',
      String fechaHora = ""}) {
    String fh() {
      DateTime ahora = DateTime.now();
      return DateFormat('dd/MM/yyyy HH:mm:ss')
          .format(ahora); // ejemplo: 28/06/2025 17:42
    }

    return vmTareas(
        descripcion: descripcion, url: url, estado: estado, fechaHora: fh());
  }
}
