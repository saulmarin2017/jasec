import 'dart:convert';

VmUsuario vmUsuarioFromJson(String str) => VmUsuario.fromJson(json.decode(str));

String vmUsuarioToJson(VmUsuario data) => json.encode(data.toJson());

class VmUsuario {
  List<ItemUsuario>? items;
  FirstUsuario? first;
  String? error;

  VmUsuario({
    this.items,
    this.first,
    this.error,
  });

  factory VmUsuario.fromJson(Map<String, dynamic> json) => VmUsuario(
        items: json["items"] == null
            ? []
            : List<ItemUsuario>.from(
                json["items"]!.map((x) => ItemUsuario.fromJson(x))),
        first:
            json["first"] == null ? null : FirstUsuario.fromJson(json["first"]),
      );

  Map<String, dynamic> toJson() => {
        "items": items == null
            ? []
            : List<dynamic>.from(items!.map((x) => x.toJson())),
        "first": first?.toJson(),
      };
}

class FirstUsuario {
  String? ref;

  FirstUsuario({
    this.ref,
  });

  factory FirstUsuario.fromJson(Map<String, dynamic> json) => FirstUsuario(
        ref: json["\u0024ref"],
      );

  Map<String, dynamic> toJson() => {
        "\u0024ref": ref,
      };
}

class ItemUsuario {
  int? codUsuario;
  String? nombreUsuario;
  String? estado;
  String? tipoUsuario;
  String? indluminarias;
  String? indserviciotecnico;
  int? codenccuadrilla;
  int? codbodega;

  ItemUsuario(
      {this.codUsuario,
      this.nombreUsuario,
      this.estado,
      this.tipoUsuario,
      this.indluminarias,
      this.indserviciotecnico,
      this.codenccuadrilla,
      this.codbodega});

  factory ItemUsuario.fromJson(Map<String, dynamic> json) => ItemUsuario(
      codUsuario: json["cod_usuario"],
      nombreUsuario: json["nombre_usuario"],
      estado: json["estado"],
      tipoUsuario: json["tipo_usuario"],
      indluminarias: json["ind_luminarias"],
      indserviciotecnico: json["ind_servicio_tecnico"],
      codenccuadrilla: json['cod_enc_cuadrilla'],
      codbodega: json['cod_bodega']);

  Map<String, dynamic> toJson() => {
        "cod_usuario": codUsuario,
        "nombre_usuario": nombreUsuario,
        "estado": estado,
        "tipo_usuario": tipoUsuario,
        "ind_luminarias": indluminarias,
        "ind_servicio_tecnico": indserviciotecnico,
        "cod_enc_cuadrilla": codenccuadrilla,
        "cod_bodega": codbodega
      };
}
