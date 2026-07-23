import 'dart:io';

import 'package:jasec/class/log.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class db {
  static final db instance = db._init();
  static Database? _database;

  String baseDatos = "jasec2025.db";
  int version = 1;

  db._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, baseDatos);

    return await openDatabase(path,
        version: version, onCreate: _crearBD, onUpgrade: _actualizarBD);
  }

  Future<void> borrarBD() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, baseDatos);

    await deleteDatabase(path); // Borra la base de datos

    Log.escribir("📢 Base de datos $baseDatos eliminada");
    print("📢 Base de datos $baseDatos eliminada");

    _database = null;

    //await db.instance.database;
  }

  Future<void> exportarBD() async {
    try {
      final dbPath = await getDatabasesPath();
      final dbFile = File('$dbPath/$baseDatos');

      final downloadsDir = Directory('/storage/emulated/0/Download');
      final nuevoFile = File('${downloadsDir.path}/$baseDatos');

      await nuevoFile.writeAsBytes(await dbFile.readAsBytes());

      Log.escribir('Base de datos exportada a: ${nuevoFile.path}');
      print('Base de datos exportada a: ${nuevoFile.path}');
    } catch ($e) {
      Log.escribir('Base de datos exportada a: ${$e.toString()}');
      print('Error: ${$e.toString()}');
    }
  }

  Future<void> _crearBD(Database db, int version) async {
    print(" 📢 createDB $baseDatos");
    // Nueva tabla de LISTADOS , maneja la informacion en formato json de cada una de las tablas provinientes de backend ORDS
    try {
      //LISTADOS
      await db.execute('''
      CREATE TABLE LISTADOS (
        ROWID INTEGER PRIMARY KEY AUTOINCREMENT,        
        SIAR_TIPO_SOLICITUD TEXT NULL,
        SIAR_TIPO_SOLICITUD_ST TEXT NULL,
        SIAR_TIPO_SERVICIO TEXT NULL,    
        SIAR_TIPO_ATENCION TEXT NULL,  
        SIAR_MOTIVOS_RECHAZO TEXT NULL, 
        SIAR_PROVINCIA TEXT NULL, 
        SIAR_CANTON TEXT NULL, 
        SIAR_DISTRITO TEXT NULL ,
        FECHA_ACTUALIZACION DATETIME DEFAULT (CURRENT_TIMESTAMP),
        USUARIO VARCHAR(50) NULL,
        SIAR_CUENTA_GASTO TEXT NULL,   
        SIAR_OTC TEXT NULL,  
        SIAR_POSTE TEXT NULL,
        SIAR_ORDEN_TRABAJO TEXT NULL,
        SIAR_PRODUCTO TEXT NULL,
        SIAR_MINIMO_INVENTARIO TEXT NULL,
        SIAR_BODEGA TEXT NULL,
        SIAR_GRAFICA_DONA TEXT NULL,
        SIAR_GRAFICA_PORCENTAJE TEXT NULL,
        SIAR_GRAFICA_BARRAS TEXT NULL,
        SIAR_USUARIOS TEXT NULL,
        SIAR_FORMULARIOS TEXT NULL,
        SIAR_RESPUESTAS_SUJERIDAS TEXT NULL,
        SIAR_MEDIDOR TEXT NULL
      )
    ''');
    } catch (e) {
      print("❌ Error creando tabla: $e");
      Log.escribir('❌ Error creando tabla: ${e.toString()}');
    }

    try {
      //SIAR_DET_FORMULARIO_RESPUESTA
      await db.execute('''
      CREATE TABLE SIAR_DET_FORMULARIO_RESPUESTA (
      ROWID INTEGER PRIMARY KEY AUTOINCREMENT,
      COD_SOLICITUD INTEGER NULL,  
      COD_FORMULARIO INTEGER NULL,  
      JSON TEXT,
      POST_PUT VARCHAR(10) NULL,    
      USUARIO_TRASLADO VARCHAR(50) NULL,
      FECHA_TRASLADO DATETIME DEFAULT (CURRENT_TIMESTAMP),
      ESTADO_TRASLADO VARCHAR(20) NULL    
    )
    ''');
    } catch (e) {
      print("❌ Error creando tabla: $e");
      Log.escribir('❌ Error creando tabla: ${e.toString()}');
    }

    try {
      //SOLICITUDES
      await db.execute('''
      CREATE TABLE SIAR_SOLICITUDES (
        ROWID INTEGER PRIMARY KEY AUTOINCREMENT,     
        COD_SOLICITUD INTEGER NULL,  
        COD_ORDEN_TRABAJO INTEGER NULL,  
        JSON TEXT NULL,
        POST_PUT VARCHAR(10) NULL,    
        ESTADO VARCHAR(20) NULL,
        FECHA_CREACION DATETIME DEFAULT (CURRENT_TIMESTAMP),
        USUARIO_INSERT VARCHAR(50) NULL,       
        USUARIO_TRASLADO VARCHAR(50) NULL,
        FECHA_TRASLADO DATETIME DEFAULT (CURRENT_TIMESTAMP),
        ESTADO_TRASLADO VARCHAR(20) NULL
      )
    ''');
    } catch (e) {
      print("❌ Error creando tabla: $e");
      Log.escribir('❌ Error creando tabla: ${e.toString()}');
    }

    try {
      //SIAR_TIEMPO_ATENCION
      await db.execute('''CREATE TABLE SIAR_TIEMPO_ATENCION (
          COD_TIEMPO_ATENCION INTEGER PRIMARY KEY AUTOINCREMENT,
          COD_SOLICITUD INTEGER,  
          COD_ORDEN_TRABAJO INTEGER,  
          JSON TEXT,        
          JSON_PUT TEXT,        
          POST_PUT VARCHAR(10) NULL,    
          USUARIO_TRASLADO VARCHAR(50) NULL,
          FECHA_TRASLADO DATETIME DEFAULT (CURRENT_TIMESTAMP),
          ESTADO_TRASLADO VARCHAR(20) NULL
      )''');
    } catch (e) {
      print("❌ Error creando tabla: $e");
      Log.escribir('❌ Error creando tabla: ${e.toString()}');
    }

    try {
      //SIAR_SOLICITUD_MATERIALES
      await db.execute('''
      CREATE TABLE SIAR_SOLICITUD_MATERIALES (
        COD_SOLICITUD_MATERIAL INTEGER PRIMARY KEY AUTOINCREMENT, 
        COD_SOLICITUD VARCHAR(50) NULL,   
        CANTIDAD NUMERIC,
        INSTALADOS VARCHAR(1) NULL,  
        COD_POSTE VARCHAR(100) NULL,   
        OBSERVACIONES VARCHAR(200) NULL,   
        COD_SIAR_PRODUCTO VARCHAR(100) NULL,
        VERIFICADO NUMERIC(20) NULL, 
        ESTADO VARCHAR(20) NULL,
        USUARIO_INSERT  VARCHAR(20) NULL,
        FECHA_INSERT DATETIME NULL ,
        POST_PUT VARCHAR(10) NULL,    
        USUARIO_TRASLADO VARCHAR(50) NULL,
        FECHA_TRASLADO DATETIME DEFAULT (CURRENT_TIMESTAMP),
        ESTADO_TRASLADO VARCHAR(20) NULL   
      )
    ''');
    } catch (e) {
      print("❌ Error creando tabla: $e");
      Log.escribir('❌ Error creando tabla: ${e.toString()}');
    }

    try {
      //SIAR_REQUISICION
      await db.execute('''
          CREATE TABLE SIAR_REQUISICION (
            COD_REQUISICIONES INTEGER PRIMARY KEY AUTOINCREMENT,
            FECHA_SOLICITUD VARCHAR(50) NULL,
            COD_BODEGA NUMERIC,
            NIVEL VARCHAR(100) NULL,
            IND_LUMINARIAS VARCHAR(1) NULL,
            IND_SERVICIO_TECNICO VARCHAR(1) NULL,
            COD_CUADRILLA NUMERIC(20) NULL,
            USUARIO_INSERT VARCHAR(20) NULL,
            JSON TEXT NULL,
            POST_PUT VARCHAR(10) NULL,    
            ESTADO VARCHAR(20) NULL,
            USUARIO_TRASLADO VARCHAR(50) NULL,
            FECHA_TRASLADO DATETIME DEFAULT (CURRENT_TIMESTAMP),
            ESTADO_TRASLADO VARCHAR(20) NULL
        )''');
    } catch (e) {
      print("❌ Error creando tabla: $e");
      Log.escribir('❌ Error creando tabla: ${e.toString()}');
    }

    try {
      //SIAR_DETALLE_REQUISICION
      await db.execute('''
        CREATE TABLE SIAR_DETALLE_REQUISICION (
        COD_DET_REQUISICIONES INTEGER PRIMARY KEY AUTOINCREMENT,
        COD_REQUISICIONES NUMERIC NULL,
        COD_PRODUCTO VARCHAR(50),
        CANTIDAD NUMERIC(20) NULL,
        USUARIO_INSERT VARCHAR(20) NULL,
        POST_PUT VARCHAR(10) NULL,   
         JSON TEXT NULL, 
        ESTADO VARCHAR(20) NULL,
        USUARIO_TRASLADO VARCHAR(50) NULL,
        FECHA_TRASLADO DATETIME DEFAULT (CURRENT_TIMESTAMP),
        ESTADO_TRASLADO VARCHAR(20) NULL )
    ''');
    } catch (e) {
      print("❌ Error creando tabla: $e");
      Log.escribir('❌ Error creando tabla: ${e.toString()}');
    }

    try {
      //SIAR_SOLICITUD_MOTIVOS_RECHAZO
      await db.execute('''
    CREATE TABLE SIAR_SOLICITUD_MOTIVOS_RECHAZO (
        COD_SOLICITUD_MOTIVO_RECHAZO INTEGER PRIMARY KEY AUTOINCREMENT,
        COD_MOTIVOS_RECHAZO INTEGER,
        COD_SOLICITUD INTEGER,
        FECHA TEXT,
        USUARIO_INSERT TEXT,
        POST_PUT VARCHAR(10) NULL,    
        USUARIO_TRASLADO VARCHAR(50) NULL,
        FECHA_TRASLADO DATETIME DEFAULT (CURRENT_TIMESTAMP),
        ESTADO_TRASLADO VARCHAR(20) NULL
    )''');
    } catch (e) {
      print("❌ Error creando tabla: $e");
      Log.escribir('❌ Error creando tabla: ${e.toString()}');
    }

    try {
      //SIAR_SOLICITUD_DOCUMENTO
      await db.execute('''
    CREATE TABLE SIAR_SOLICITUD_DOCUMENTO (
      COD_SOLICITUD_DOCUMENTO INTEGER PRIMARY KEY AUTOINCREMENT,
      COD_SOLICITUD INTEGER NOT NULL,
      FILENAME TEXT NOT NULL,
      MIMETYPE TEXT,
      DOCUMENTO BLOB NOT NULL,
      USUARIO_INSERT TEXT,
      FECHA_INSERT TEXT,
      POST_PUT TEXT,
      USUARIO_TRASLADO VARCHAR(50) NULL,
      FECHA_TRASLADO DATETIME DEFAULT (CURRENT_TIMESTAMP),
      ESTADO_TRASLADO VARCHAR(20) NULL
    )
  ''');
    } catch (e) {
      print("❌ Error creando tabla: $e");
      Log.escribir('❌ Error creando tabla: ${e.toString()}');
    }
  }

// Manejo de actualización de la base de datos, cuando se agreguen campos
  Future<void> _actualizarBD(
      Database db, int oldVersion, int newVersion) async {
    // Nueva tabla de RUTA
    if (oldVersion < version) {
      //await db.execute('ALTER TABLE LISTADOS ADD COLUMN SIAR_SOLICITUD_CUADRILLA TEXT NULL');
      //await db.execute('ALTER TABLE LISTADOS ADD COLUMN SIAR_SOLICITUD_MATERIALES TEXT NULL');
    }
  }

  Future<int> insertar(Map<String, dynamic> datos, String tabla) async {
    final db = await instance.database;
    return await db.insert(tabla, datos);
  }

  Future<List<Map<String, dynamic>>> obtenerRegistros(String tabla,
      {String campo = "", dynamic valor}) async {
    final db = await instance.database;
    if (campo.isNotEmpty) {
      return await db.query(tabla, where: '$campo = ?', whereArgs: [valor]);
    } else {
      return await db.query(tabla);
    }
  }

  Future<List<Map<String, dynamic>>> obtenerRegistrosWhere(
    String tabla, {
    Map<String, dynamic>? condiciones,
  }) async {
    final db = await instance.database;

    String? where;
    List<dynamic>? whereArgs;

    if (condiciones != null && condiciones.isNotEmpty) {
      where = condiciones.keys.map((k) => '$k = ?').join(' AND ');
      whereArgs = condiciones.values.toList();
    }

    return await db.query(
      tabla,
      where: where,
      whereArgs: whereArgs,
    );
  }

  Future<List<Map<String, dynamic>>> obtenerRegistrosISNULL(String tabla,
      {String campo = ""}) async {
    final db = await instance.database;
    if (campo.isNotEmpty) {
      return await db.query(tabla, where: '$campo IS NULL');
    } else {
      return await db.query(tabla);
    }
  }

  Future<Map<String, dynamic>?> obtenerUnRegistro(
      String tabla, String campo, dynamic valor) async {
    final db = await instance.database;
    List<Map<String, dynamic>> resultado =
        await db.query(tabla, where: '$campo = ?', whereArgs: [valor]);

    return resultado.isNotEmpty ? resultado.first : null;
  }

  /*Future<int> actualizar(String tabla, Map<String, dynamic> datos, String campo,
      dynamic valor) async {
    int r = 0;
    try {
      final db = await instance.database;
      r = await db.update(
        tabla,
        datos,
        where: '$campo = ?',
        whereArgs: [valor],
      );
    } catch ($e) {
      print($e);
      Log.escribir('❌ Error Actualizar $tabla: ${$e.toString()}');
    }
    return r;
  }*/

  Future<int> actualizar(
      String tabla, Map<String, dynamic> datos, String campo, dynamic valor,
      {Map<String, dynamic>? condicionesExtras}) async {
    int r = 0;
    try {
      final db = await instance.database;

      // Cláusula WHERE principal
      String where = '$campo = ?';
      List<dynamic> whereArgs = [valor];

      // Si se proporcionan condiciones adicionales
      if (condicionesExtras != null && condicionesExtras.isNotEmpty) {
        condicionesExtras.forEach((k, v) {
          where += ' AND $k = ?';
          whereArgs.add(v);
        });
      }

      r = await db.update(
        tabla,
        datos,
        where: where,
        whereArgs: whereArgs,
      );
    } catch (e) {
      print(e);
      Log.escribir('❌ Error Actualizar $tabla: ${e.toString()}');
    }
    return r;
  }

  Future<int> eliminar(String tabla, String campo, dynamic valor,
      {String operador = "="}) async {
    final db = await instance.database;
    return await db.delete(
      tabla,
      where: '$campo $operador ?',
      whereArgs: [valor],
    );
  }

  Future<bool> verificarBD() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, baseDatos);

    bool existe = await databaseExists(path);
    print("📂 ¿Existe la BD?: $existe");
    Log.escribir("📂 ¿Existe la BD?: $existe");
    return existe;
  }

  Future<void> verificarTablas() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> tablas = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='RUTA'");

    if (tablas.isNotEmpty) {
      print("✅ La tabla 'RUTA' existe en la base de datos $baseDatos.");
    } else {
      print("❌ La tabla 'RUTA' NO existe en la base de datos $baseDatos..");
    }
  }
}
