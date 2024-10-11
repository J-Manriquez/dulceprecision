import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../utils/custom_logger.dart'; // Importamos logger

class DatabaseHelper {
  // Variable estática para la instancia única de la base de datos
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  // Constructor privado para crear una única instancia
  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  // Inicializamos la base de datos
  Database? _database;

  Future<Database> get database async {
    // Si la base de datos ya ha sido creada, simplemente regresamos esa instancia
    if (_database != null) return _database!;
    // Si no, la creamos
    _database = await _initDB();
    return _database!;
  }

  // Método para inicializar la base de datos y crear las tablas
  Future<Database> _initDB() async {
    try {
      // Obtenemos la ruta del directorio donde se almacenará la base de datos
      String path = join(await getDatabasesPath(), 'dp_database.db');
      // Creamos la base de datos y definimos las tablas
      return await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          // Creación de tablas
          try {
            // 1 -----------------------------------------------------------------------------
            await db.execute('''
                  CREATE TABLE IF NOT EXISTS Productos (
                    idProducto INTEGER PRIMARY KEY AUTOINCREMENT, -- ID único para cada producto
                    nombreProducto TEXT NOT NULL, -- Nombre del producto
                    precioProducto REAL NOT NULL, -- Precio del producto
                    cantidadProducto REAL NOT NULL, -- Cantidad disponible del producto
                    tipoUnidadProducto TEXT NOT NULL, -- Unidad del producto (ej. kg, litros)
                    cantidadUnidadesProducto REAL NOT NULL -- Cantidad por unidad
                  );
                ''');
            // 2 -----------------------------------------------------------------------------
            await db.execute('''
                  CREATE TABLE IF NOT EXISTS recetas (
                    idReceta INTEGER PRIMARY KEY AUTOINCREMENT, -- ID único para cada receta
                    nombreReceta TEXT NOT NULL, -- Nombre de la receta
                    descripcionReceta TEXT, -- Descripción de la receta
                    precioReceta REAL -- Precio de la receta
                  );
                ''');
            // 3 -----------------------------------------------------------------------------
            await db.execute('''
                  CREATE TABLE IF NOT EXISTS ingredientesRecetas (
                    idIngrediente INTEGER PRIMARY KEY AUTOINCREMENT, -- ID único para cada ingrediente
                    nombreIngrediente TEXT NOT NULL, -- Nombre del ingrediente
                    costoIngrediente REAL NOT NULL, -- Costo del ingrediente
                    cantidadIngrediente REAL NOT NULL, -- Cantidad usada del ingrediente
                    tipoUnidadIngrediente TEXT NOT NULL, -- Unidad del ingrediente (ej. gramos, litros)
                    idReceta INTEGER, -- ID de la receta asociada
                    FOREIGN KEY (idReceta) REFERENCES recetas(idReceta) -- Relación con la tabla recetas
                  );
                ''');
            // 4 -----------------------------------------------------------------------------
            await db.execute('''
                  CREATE TABLE IF NOT EXISTS gastosFijos (
                    idGF INTEGER PRIMARY KEY AUTOINCREMENT, -- ID único para cada gasto fijo
                    nombreGF TEXT NOT NULL, -- Nombre del gasto fijo
                    valorGF REAL NOT NULL -- Valor del gasto fijo
                  );
                ''');
            // 5 -----------------------------------------------------------------------------
            await db.execute('''
                  CREATE TABLE IF NOT EXISTS ventas (
                    idVenta INTEGER PRIMARY KEY AUTOINCREMENT, -- ID único para cada venta
                    nombreVenta TEXT NOT NULL, -- Nombre de la venta
                    horaVenta TEXT NOT NULL, -- Hora de la venta
                    fechaVenta TEXT NOT NULL, -- Fecha de la venta
                    productoVenta INTEGER, -- ID del producto vendido
                    cantidadVenta REAL NOT NULL, -- Cantidad vendida del producto
                    pctjGFVenta REAL NOT NULL, -- Porcentaje de gastos fijos aplicados a la venta
                    desgloseGFVenta TEXT NOT NULL, -- Desglose de gastos fijos
                    precioGFVenta REAL NOT NULL, -- Precio de los gastos fijos aplicados
                    precioRecetaVenta REAL NOT NULL, -- Precio por receta en la venta
                    pctjGananciaVenta REAL NOT NULL, -- Porcentaje de ganancia de la venta
                    precioPorProductoVenta  -- Precio final por producto
                    productoVenta REAL NOT NULL, --
                  );
                ''');
            // 6 -----------------------------------------------------------------------------
            await db.execute('''
                  CREATE TABLE IF NOT EXISTS historialproducto (
                    idHistorialProducto INTEGER PRIMARY KEY AUTOINCREMENT, -- ID único para cada historial
                    antesHP REAL NOT NULL, -- Cantidad antes del cambio
                    despuesHP REAL NOT NULL, -- Cantidad después del cambio
                    fechaHP TEXT NOT NULL, -- Fecha del cambio
                    horaHP TEXT NOT NULL -- Hora del cambio
                  );
                ''');
            // 7 -----------------------------------------------------------------------------
            // Creación de la tabla Limitaciones
            await db.execute('''
                  CREATE TABLE IF NOT EXISTS historialGF (
                    idHistorialGF INTEGER PRIMARY KEY AUTOINCREMENT, -- ID único para cada historial de gastos fijos
                    antesHGF REAL NOT NULL, -- Valor antes del cambio
                    despuesHGF REAL NOT NULL, -- Valor después del cambio
                    fechaHGF TEXT NOT NULL, -- Fecha del cambio
                    horaHGF TEXT NOT NULL -- Hora del cambio
                  );
                ''');
            // Agrega el resto de las tablas aquí, similar al anterior
          } catch (e) {
            CustomLogger().logError('Error al crear las tablas: $e');
          }
        },
      );
    } catch (e) {
      CustomLogger().logError('Error al inicializar la base de datos: $e');
      rethrow; // Re-lanzamos la excepción para manejarla más arriba si es necesario
    }
  }

  // Método para cerrar la base de datos

  Future<void> closeDB() async {
    try {
      final db = await database;
      db.close();
    } catch (e) {
      CustomLogger().logError('Error al cerrar la base de datos: $e');
    }
  }
}