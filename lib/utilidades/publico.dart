import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jasec/model/tokenords.dart';
import 'package:jasec/model/vmlistadosdblocal.dart';
import 'package:jasec/utilidades/utilidades.dart';

int? idUsuarioLogin = 0;
int? codCuadrillaUsaurio = 0;
int? codBodegaUsuario = 0;
String usuarioLogin = "";
String? tipoUsuario = "";
String? tipoUsuarioAdministrador = "ADMINIX";

double altoBox = 50;
double anchoBox = 50;

//Se configura desde menuconfiguracion
bool registrarLog = false;

late Position? PosGPSGlobal;

PerfilUsuario perfilUsuario = PerfilUsuario.ServicioTecnico;
String luminaria = "";

List<ListadosDBlocal> listadosdblocal = [];

bool conexionInternet = false;

const String lblfuenteDefecto = 'Gotham';
const String lblNombrePaquete = "jasec";
const String lblNombreAPP = "S I A R";

const String correoDefecto = "desarrollo@navasoftsoluciones.com";

const String lblinformacionactualizada = "Información actualizada";
const String lblaceptar = "Aceptar";
const String lblAbrirConfiguracion = "Abrir Configuración";
const String lbldebetenerconexioninternet =
    "Debe tener conexión a internet para poder iniciar la sincronización";
const String lblguardar = "Guardar";
const String lblNivel = "Nivel";
const String lblGuardoInformacion = "Se guardó la información";
const String lblActualizoInformacion = "Actualizo información";
const String lblInformacionGuardadaSolicitud =
    "Se guardó la información, puede adjuntar multimedia a la solicitud si lo desea.";
const String lblcancelar = "Cancelar";
const String lblcerrar = "Cerrar";
const String lblinformacion = "Información";
const String lblingresar = "Ingresar";
const String lblMenu = "Menú";
const String lblcalle = "Calle";
const String lblLogin = "Login";
const String lblprocesando = "Procesando";
const String lblHabilitarRegistroLog = "Habilitar registro de Log";

const String lblcrearrequisicion = "Crear Requisición";
const String lblfinalizarjornadalaboral =
    "¿ Ha finalizado su jornada laboral ?";
const String lblprocesoiniciado = "Proceso iniciado ";
const String lblprocesofinalizado = "Proceso finalizado";
const String lblcopiaSeguridadEnDescargas =
    "Se creó una copia de seguridad en la carpeta de descargas del dispositivo";
const String lblcerraraplicacion = "Cerrar Aplicación";
const String lblrequisiciondemateriales = "Requisición de Materiales";
const String lblrequisicion = "Requisición";
const String lbltransferirmateriales = "Transferir Materiales";
const String lbltransferenciamateriales = "Transferencia de Materiales";
const String lbltransferencia = "Transferencia";

const String lblvalidacioniniciojornada = "Validación Inicio de Jornada";
const String lbldeseainiciarjornada = "¿ Desea iniciar su jornada laboral ?";
const String lblhabilitarlog = "habilitarlog";

const String lblUsuario = "Usuario";
const String lblClave = "Clave";
const String lblClaveActual = "Clave Actual";
const String lblNuevaClave = "Nueva Clave";
const String lblConfirmeClave = "Confirme Nueva Clave";
const String lblCambiarClave = "Cambiar clave";
const String lblCambioDeClave = "Cambio de Clave";
const String lblconfirme = "Confirme";

const String lblreportespendientes =
    "Esta orden de trabajo aún tiene reportes pendientes por atender, ¿Está seguro quedesea cerrar la orden de trabajo?";

const String lblatendidas = "Atendidas";
const String lblrechazadas = "Rechazadas";
const String lblpendientes = "Pendientes";
const String lblindicadores = "Indicadores";
const String lblsolicitudes = "Solicitudes";
const String lblsolicitud = "Solicitud";
const String lblordenestrabajo = "Ordenes de Trabajo";
const String lblcierremanual = "Cierre Manual";
const String lblOT = "# OT";
const String lblId = "ID";
const String lblidsolicitud = "No Solicitud";
const String lblcuadrilla = "Cuadrilla";
const String lblaccion = "Acción";
const String lblestado = "Estado";
const String lblfechaapertura = "Fecha Apertura";
const String lblfechaCierre = "Fecha Cierre";
const String lblfecha = "Fecha";
const String lblvehiculo = "Vehículo";
const String lbltotalsolicitudesasignadas = "Total Solicitudes";
const String lbltotalsolicitudesregistradas = "Solicitudes Registradas";
const String lblregistrokilometrajeinicio = "Registro Kilómetraje Salida";
const String lblcodkilometrajeinicio = "kilometraje_inicio";
const String lblregistrokilometrajefinal = "Registro Kilómetraje Final";
const String lblingresecantidad = "Ingrese una Cantidad";
const String lblcantidadsuperaexistencia =
    "La cantidad ingresada supera la existencia disponible.";
const String lblError = "Error";
const String lblErrorConexionBac =
    "No es posible conectarse al servidor de servicios";
const String lbldiferenciakilometros =
    "La cantidad de kilómetros de salida deben ser mayor a los kilómetros indicados al inicio ";
const String lblkilometraje = "Kilómetros";
const String lblkilometrajemayoracero =
    "La cantidad de kilómetros debe ser mayor a 0.";
const String lblkilometraInicialNoRegistrado =
    "No sé a registrado el kilometraje inicial.";
const String lblmateriales = "Materiales";
const String lblconfiguracion = "Configuración";
const String lblsalir = "Salir";
const String lblsolicitudesatendidas = "Solicitudes Atendidas";
const String lblsolicitudespendientes = "Solicitudes Pendientes";
const String lblestadosolicitudes = "Estado de Solicitudes";
const String lblsolicitudescumplientoOT = "Solicitudes vrs Cumplimiento OT";

const String lblopcionprincipal = "OpcionPrincipal";
const String lblnombreopcion = "NombreOpcion";
const String lblimagenopcion = "ImagenOpcion";
const String lblllave = "Llave";

const String urlimagendefecto = "assets/images/logo.png";
const String urlimagenlogo = 'assets/images/logo.png';
const String urlimagenindicadores = "assets/images/kpib.png";
const String urlimagenengranaje = "assets/images/engranajeb.png";
const String urlimagenmateriales = "assets/images/materialesb.png";
const String urlimagenordenes = "assets/images/ordenb.png";
const String urlimagensolicitud = "assets/images/solicitudb.png";
const String usrliamgensalida = "assets/images/salirb.png";

const String lblsi = "Si";
const String lblno = "No";
const String lblir = "Ir";
const String lblsinexistencia = "Sin existencia";
const String lblNoData = "No se encontro información.";

const String lblregistrochekin = "Se registró el inicio de atención";
const String lblactualizochekin = "Se actualizo el fin de atención";
const String lblactualizomotivorechazo = "Se actualizo el motivo de rechazo";
const String lblactualizoestadoSolicitud =
    "Se actualizo el estado de la solicitud";

const String lblhistorial = "Historial";
const String lblhistoricoatencion = "Histórico de Atención";
const String lblinstalado = "Instalado";

const String lblnosolicitud = "No. Solicitud:";
const String lblTicket = "# Ticket:";
const String lblTipoSolicitudReportada = "Tipo de Solicitud Reportada";
const String lblobservaciones = "Observaciones";
const String lblarchivoadjunto = "Archivo Adjunto";
const String lblarchivoadjuntoSolicitud = "Archivos Adjuntos en Solicitud";
const String lblarchivoseleccionado = "Archivo Seleccionado";
const String lbladjunto = "Adjunto";
const String lblarchivo = "Archivo";
const String lblImagen = "Imagen";
const String lblarchivonocargado = "No fue posible cargar el archivo.";
const String lblarchivocargado = "Archivo cargado.";
const String lblvideo = "Video";
const String lbldatossolicitante = "Datos del Solicitante";
const String lblfacturacion = "Facturación";
const String lblidentificaciondequienreporta = "ID  del Solicitante";
const String lblnombereporta = "Nombre Completo";
const String lblprimerapellido = "Primer Apellido";
const String lblsegundoapellido = "Segundo Apellido";
const String lblcorreo = "Correo Electrónico";
const String lbldebeseleccionarbodega =
    "Debe seleccionar la bodega de origen/destino, para continuar";
const String lbltelefono = "Teléfono";
const String lblUbicacionSolicitada = "Ubicación Solicitada";
const String lblreferenciaubicacion = "Referencia Ubicación";
const String lblnoposte = "No. Poste";
const String lblordenruta = "Orden Ruta";
const String lblorden = "Orden";
const String lbltiposolicitud = "Tipo de Solicitud";
const String lblnombresolicitante = "Nombre Solicitante";
const String lblfechasolicitud = "Fecha Solicitud";
const String lblfechareactivacion = "Fecha Reactivación";
const String lblindicaciones = "Indicaciones";
const String lbltotalrechazos = "Total Rechazos";
const String lbldireccion = "Dirección";
const String lblbuscar = "Buscar";
const String lblBodegaOrigen = "Bodega Origen";
const String lblBodegaDestino = "Bodega Destino";
const String lblatencioncuenta = "Atención-Cuenta";
const String lbltipoatencion = "Tipo Atención";
const String lbltipocuenta = "Tipo Cuenta";
const String lbltiposervicio = "Tipo Servicio";
const String lblclaseservicio = "Clase Servicio";
const String lblestadoOT = "Estado OT";
const String lblnocuenta = "No Cuenta";
const String lblcuentagasto = "Cuenta Gasto";
const String lbltipoocupacion = "Tipo de Ocupación";
const String lbltipoinstalacion = "Tipo de Instalación";
const String lblnootc = "No OTC";
const String lblnoot = "No OT";
const String lblcuentaN = "Cuenta N";
const String lblnoordentrabajo = "No Orden Trabajo";
const String lblnumerocliente = "Número de Cliente";
const String lblpueblo = "Pueblo";
const String lblciclo = "Ciclo";
const String lblgeocodigo = "Geocódigo";
const String lbltarifa = "Tarifa";
const String lblnodeposito = "No Deposito";

const String lblnruta = "N. Ruta";
const String lblmonto = "Monto";
const String lblveradjuntos = "Ver Adjuntos";

const String lbldescripcion = "Descripción";
const String lbldescripciondelproceso = "Descripción del proceso";
const String lbldescripcionaspectoevaluado = "Descripción aspecto evaluado";
const String lblEvaluar = "Eval.";
const String lblEvaluacion = "Evaluación";
const String lblOtros =
    "Otros (Requiere que se presente en el Porceso Planificar y Desarrollar la Red de JASEC)";
const String lblformulariocontrolcalidadatencionordenestrabajo =
    "FORMULARIO DE CONTROL DE CALIDAD EN LA ATENCIÓN DE ORDENES DE TRABAJO";
const String lblnoseasignadocodigoposte = "No sé a asignado un código de poste";
const String lblmaterialesretirados = "Materiales Retirados";
const String lblmaterialesinstalados = "Materiales Instalados";
const String lblmaterialesluminaria = "Materiales en Luminaria";
const String lbljustificacionnoefectiva = "Justificación No Efectiva";
const String lblmotivoderechazo = "Motivo de Rechazo";
const String lblseleccionemotivorechazo = "Seleccione un motivo de rechazo";
const String lblseleccione = "Seleccione";
const String lblseleccioneproducto =
    "Seleccione amenos un producto para continuar";
const String lblcodigo = "Código";
const String lblproducto = "Producto";
const String lblnombrematerial = "Nombre Material";
const String lblnombre = "Nombre";
const String lbldetalle = "Detalle";
const String lblcantidad = "Cantidad";
const String lblverificado = "Verificado";
const String lblbrecha = "Brecha";
const String lblexistencia = "Existencia";
const String lblactivo = "Activo";
const String lblminimoinventario = "Mínimo de Inventario";
const String lblminimo = "Mínimo";
const String lblpreguntacantidadminima =
    "Cuenta con una cantidad mínima del producto XXXXX. ¿Desea realizar la requisición de este material?";

const String lblevaluacioncumplientonormativo =
    "Evaluación cumplimiento normativo";
const String lblcaracteristicasgenerales = "Caracteristicas Generales";
const String lblacometidasaereasbajatension =
    "Acometidas Aéreas a Baja Tensión";
const String lblacometidassubterraneabajatension =
    "Acometidas Subtteránea en Baja Tensión";
const String lbledificiosunifamiliaresocupacionsimple =
    "Edificios unifamiliares o de ocupación simple";
const String lblmedidoresedificiosocupacionmultiple =
    "Medidores en Edificios de Ocupación Múltiple";
const String lblmediosdedesconexion = "Medidores de Desconexión";
const String lblsistemapuestatierra = "Sistema de Puesta a Tierra";
const String lbldistanciaminimas = "Distancias mínimas";
const String lblacometidasmediatension = "Acometidas a Media Tensión";
const String lblefectiva = "Efectiva";
const String lblnoefectiva = "No Efectiva";
const String lblchekin = "Chek In";
const String lblchekinprevio = "Chek In, realizado previamente";
const String lblgeolocalizar = "Geolocalizar";
const String lblfoto = "Foto";
const String lbleliminar = "Eliminar";

const String lblregistroeliminado = "Registro eliminado";

const String lblSincronizacionJasecAPP = "Sincronización JASEC - APP";
const String lblSincronizacion = "Sincronización";
const String lbldescargardatos = "Descargar";
const String lblcargardatos = "Cargar";
const String lblcopiaseguridad = "Copia de seguridad";
const String lblconsultadeinventario = "Consulta de Inventario";
const String lblagregarmateriales = "Agregar Materiales";
const String lblretirarmateriales = "Retirar Materiales";
const String lblliquidacionmateriales = "Liquidación de Materiales";
const String lblliquidacion = "Liquidación";
const String lbllocalizacion = "Localización";
const String lblformularios = "Formularios";
const String lblmovimiento = "Movimiento";
const String lbltipodematerial = "Tipo de Material";
const String lbltipoArchivo = "Tipo de Archivo";
const String lblevaluacionrequisitostecnicos =
    "Evaluación de Requisitos Tecnicos";
const String lbldatosmedicionresidencial =
    "Datos Sistema de Medición Residencial";
const String lbldatosmedicionindustrial =
    "Datos Sistema de Medición Industrial";
const String lblviculacionusuariored = "Vinculación Usuario-Red";
const String lblinspeccionespecial = "Inspección Especial";
const String lblboletarechazoinstalacionservicioelectrico =
    "Boleta de rechazo de instalación de servicio eléctrico";

const String lbldatossistemamedicionindustrial =
    "Datos Sistema de Medición Industrial";
const String lbldatossistemamedicionresidencial =
    "Datos Sistema de Medición Residencial";
const String lbldatosgeneralesgeoposicionamiento =
    "Datos Generales de Geoposicionamiento";
const String lblOrdentrabajo = "Orden de trabajo";
const String lblnumeroabonado = "Numero Abonado";
const String lblCoordenadaXH = "Coordenada X(Historica)";
const String lblCoordenadaXtablet = "Coordenada X Tablet";
const String lbldiferenciaposcion10m = "Diferencia de posicion >10m";
const String lblCoordenadaYH = "Coordenada Y(Historica)";
const String lblCoordenadaYtablet = "Coordenada Y Tablet";
const String lblrequiereactualizacion = "Requiere actualizacion";
const String lblCoordenadaXnueva = "Coordenada X nueva";
const String lblCoordenadaYnueva = "Coordenada Y nueva";
const String lblestabilidadGPS = "Estabilidad GPS";
const String lblGPSDesactivado = "GPS Desactivado";
const String lblcamporequerido = "es requerido.";
const String lblDebesHabilitarGPSParaContinuar =
    "Debes activar el GPS para continuar.";
const String lblcapturageoposicionamiento = "Captura Geoposcionamiento";
const String lblcoordenadasgeoposcionamiento =
    "Coordenadas de Geoposcionamiento";
const String lblcapturargeoposicionamiento = "Capturar Geoposcionamiento";
const String lbldatosdevinculacionconred = "Datos de vinculación con la red";
const String lblposte = "Poste";
const String lblcircuito = "Circuito";
const String lblsubestacion = "Subestación";
const String lblfase = "Fase";
const String lbltransformador1 = "TRansformador 1(T1)";
const String lbltransformador2 = "TRansformador 2(T2)";
const String lbltransformador3 = "TRansformador 3(T3)";
const String lbltransformador4 = "TRansformador 4(T4)";
const String lbltipoconexion = "Tipo de conexión";
const String lblcapacidadT1 = "Capacidad(T1)";
const String lblcapacidadT2 = "Capacidad(T2)";
const String lblcapacidadT3 = "Capacidad(T3)";
const String lblcapacidadT4 = "Capacidad(T4)";
const String lbltensiondeservicio = "Tensión de servicio";
const String lblcapturarvinculacionconlared = "Capturar vinculación con la red";

const String lblmediciondirecta = "Medición Directa";
const String lblmedicionindirecta = "Medición Indirecta";
const String lblmedidorretirado = "Medidor retirado:";
const String lbllecturaretiro = "Lectura retiro:";
const String lblmarcamedidor = "Marca medidor:";
const String lblnotificaciones = "Notificaciones";
const String lblfechaejecucion = "Fecha ejecución:";
const String lblmarchamointerno = "Marchamo interno";
const String lblmarchamoexterno = "Marchamo externo";
const String lblmarchamomaxima = "Marchamo máxima";
const String lblmarchamoregleta1 = "Marchamo regleta 1";
const String lblmarchamoregleta2 = "Marchamo regleta 2";
const String lblprogramamedidor = "Programa medidor";
const String lblmedidorinstalado = "Medidor instalado:";
const String lbllecturainstalacion = "Lectura instalación:";
const String lbldatosequipocomplementario = "Datos Equipo Complementario";
const String lblclasificacionservicio = "Clasificación servicio:";
const String lblrelacionTcorriente = "Relación T. Corriente";
const String lblmarcaTcorriente = "Marca T. Corriente";
const String lblmodeloTcorriente = "Modelo T. Corriente";
const String lblmodelomedidor = "Modelo Medidor";
const String lbltencionnominalTC = "Tención Nominal TC";
const String lblubicacionTcorriente = "Ubicación T. Corriente";
const String lblubicacionmedicion = "Ubicación medición";
const String lblrelacionTpotencial = "Relación T. potencial";
const String lblmarcaTpotencial = "Marca T. potencial";
const String lblubicacionTpotencial = "Ubiación T. potencial";
const String lblmododesconectadoactivado = "Modo desconectado, activado";
const String lblmedicionenmediatencion =
    "Medición en media tensión media en baja tensión(Aplica 2%)";
const String lblobservacionesdeejecucion = "Observaciones de ejecución";
const String lblobservacionesadicionales = "Observaciones adicionales";
const String lblprovincia = "Provincia";
const String lblcanton = "Canton";
const String lbldistrito = "Distrito";
const String lblagregar = "Agregar";

const String lblRecordarUsuario = "Recordar nombre de usuario";
const String lblconfirmacancelaroperacion =
    "¿Está seguro que desea cancelar la operación, si elige ACEPTAR, se borrara la información ingresada en esta operación?";

const String lblSIAR = "Sistema Integrado de Atención de Reportes";
const String lblUsuarioClaveVacios = 'El usuario o la clave están vacíos.';
const String lblClavesnoCoinciden = 'Las claves no coinciden.';
const String lblnoseabriogooglemaps = 'No fue posible abrir Google Maps';
const String lblUsuarioClaveIncorrectos =
    'El usuario o la clave, son incorrectos.';
const String lblAgoSalioMal = 'Algo salió mal, inténtelo nuevamente más tarde.';
const String lblnosecargoimagen =
    '¿No sé a cargado una imagen, desea continuar?';
const String lblCambioClaveExito = 'Se cambió la clave de acceso.';
const String lblnivelvoltaje = 'Nivel de Voltaje';
const String lbltextoObligatorio = 'Debe ingresar información en ';
const String lblcorreoNoValido = 'Correo electrónico no valido.';
const String lblexpresionRegularCorreo =
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$";
const String lblnumeroMinimoCaracteresClave =
    'Debe contener mínimo de 3 caracteres.';
const String lblformatoFecha = 'DD/MM/YYYY';
const String lblformatoFechaInvalido =
    'El formato de fecha debe ser $lblformatoFecha';
const String lblexpresionRegularFecha = "[0-9/]";
const String lbldatosDelFormularioInvalidos =
    "Existen valores incorrectos en el formulario, corrija la información y vuelva a intentarlo.";

const double tamanoFuente8px = 8;
const double tamanoFuente9px = 9;
const double tamanoFuente10px = 10;
const double tamanoFuente12px = 12;
const double tamanoFuente13px = 13;
const double tamanoFuente14px = 14;
const double tamanoFuenteDefecto = 15;
const double tamanoFuenteSecundaria = 10;
const double tamanoFuenteTitulosDefecto = 20;
const double tamanoFuenteSubTitulo = 16;
const double tamanoFuenteBotonesDefecto = 20;
const double tamanoFuenteErrores = 10;
const double tamanoAltoPorDefecto = 15;
const double altoInputFormulalrios = 40;

const double borderRadiusElevatedButton = 10;
const double borderRadiusImput = 1;

int tabSeleccionado = 1;

//Pading horizontal y vertical de listados
const double padingX = 5;
const double padingy = 8;

//Pading horizontal y vertical de TextFormField
const double txtpadingX = 8;
const double txtpadingy = 10;

//Tamaño de iconos, agregar, eliminar, editar etc
const double sizeIcono = 35;

//Colores Globales
const Color colorAzulPrimario = Color.fromARGB(178, 21, 125, 223);
const Color colorAzulSecundario = Color.fromARGB(224, 1, 48, 92);
const Color colorAmarrillo = Color.fromARGB(223, 243, 182, 83);
const Color colorAzulClaro = Color.fromARGB(223, 171, 208, 243);
const Color colorNegro = Color.fromARGB(223, 10, 10, 10);
const Color colorVerdePrimario = Color.fromARGB(255, 153, 234, 39);
const Color colorVerdeSecundario = Color.fromARGB(255, 56, 94, 2);
const Color colorGrisPrimario = Color.fromARGB(255, 131, 131, 131);
const Color colorGrisSecundario = Color.fromARGB(255, 245, 241, 241);
const Color colorRojoPrimario = Color.fromARGB(255, 222, 18, 18);
const Color colorAcua = Color.fromARGB(255, 13, 170, 212);
const Color colorBlanco = Color(0xffffffff);
const Color colorBordeInterno = colorAzulPrimario;

const String lblUrlImagenLoading = "assets/images/hojaverde.png";

//Http API
TockenOrds? tokenOrds;
String tokenBackend = "";
String tipoAplicacion = 'application/json';

//CONEXION JASEC
const String urlbase = 'srv-sifaj.jasec.go.cr';
/// Cadena SSL incompleta en ORDS (igual que RRHH). true en debug y release;
/// el callback solo acepta [urlbase], no cualquier servidor.
const bool allowBadCertificates = true;
const String usuarioClaveAuth2 =
    "Z3ZXbDZZeXVNeWRGYjFsZS1VdWNaZy4uOmhkTGZ0YkFxUDhjTS1MVVM0VmU2QUEuLg==";
String protocolo = "https";

//CONEXION Navasoft
/*const String urlbase = 'u1268360.onlinehome-server.com:8080';
const String usuarioClaveAuth2 =
    "cGpILTRDaksydHBmXzNWWWQ2R1FDdy4uOkhvZGstRzhsMURyVC1VTXA1ODhQaEEuLg=="; // Usuario y Password de ords codificados en base 64, Eje:     usuario:password
String protocolo = "http";*/

const String lblversion = "V-050520261";

const String suburl = '/ords/siar/siarrest/'; //ords'esquema'modulo

const String lbltoken = "TokenApi";
const bool https = false;

const Map<String, String> headersToken = {
  'Content-Type': 'application/x-www-form-urlencoded',
  'Authorization': 'Basic $usuarioClaveAuth2',
};

Map<String, String>? headersConsumoApi(String accessToken) {
  return {
    'Content-Type': tipoAplicacion,
    'Authorization': 'Bearer $accessToken',
  };
}

DateTime fechaDateTime(String fechaIso) {
  return DateTime.parse(fechaIso);
}

String formatoFechaPantalla(DateTime fecha) {
  return "${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}";
}

String formatoFechaDB(DateTime fecha) {
  return "${fecha.year.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.day}";
}
