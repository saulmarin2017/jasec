import 'dart:convert';

VmCuentaGasto vmCuentaGastoFromJson(String str) =>
    VmCuentaGasto.fromJson(json.decode(str));

String vmCuentaGastoToJson(VmCuentaGasto data) => json.encode(data.toJson());

class VmCuentaGasto {
  List<ItemCuentaGasto>? items;

  VmCuentaGasto({
    this.items,
  });

  factory VmCuentaGasto.fromJson(Map<String, dynamic> json) => VmCuentaGasto(
        items: json["items"] == null
            ? []
            : List<ItemCuentaGasto>.from(
                json["items"]!.map((x) => ItemCuentaGasto.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "items": items == null
            ? []
            : List<dynamic>.from(items!.map((x) => x.toJson())),
      };
}

class ItemCuentaGasto {
  int? codCuentaGasto;
  String? desCuentaGasto;
  String? indLuminaria;
  String? indServicioTecnico;
  String? usuarioInsert;
  DateTime? fechaInsert;

  ItemCuentaGasto({
    this.codCuentaGasto,
    this.desCuentaGasto,
    this.indLuminaria,
    this.indServicioTecnico,
    this.usuarioInsert,
    this.fechaInsert,
  });

  factory ItemCuentaGasto.fromJson(Map<String, dynamic> json) =>
      ItemCuentaGasto(
        codCuentaGasto: json["cod_cuenta_gasto"],
        desCuentaGasto: json["des_cuenta_gasto"],
        indLuminaria: json["ind_luminaria"],
        indServicioTecnico: json["ind_servicio_tecnico"],
        usuarioInsert: json["usuario_insert"],
        fechaInsert: json["fecha_insert"] == null
            ? null
            : DateTime.parse(json["fecha_insert"]),
      );

  Map<String, dynamic> toJson() => {
        "cod_cuenta_gasto": codCuentaGasto,
        "des_cuenta_gasto": desCuentaGasto,
        "ind_luminaria": indLuminaria,
        "ind_servicio_tecnico": indServicioTecnico,
        "usuario_insert": usuarioInsert,
        "fecha_insert": fechaInsert?.toIso8601String(),
      };
}
