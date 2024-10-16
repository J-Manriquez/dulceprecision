import 'package:DulcePrecision/utils/custom_logger.dart'; // Importamos el logger personalizado
import 'package:sqflite/sqflite.dart'; // Importamos el paquete de SQLite
import 'package:DulcePrecision/database/dp_db.dart'; // Importamos el helper de la base de datos
import 'package:DulcePrecision/models/db_model.dart'; // Importamos el modelo IngredienteReceta

class IngredienteRecetaRepository {
  // Método para obtener un ingrediente por su ID
Future<IngredienteReceta> getIngredienteById(int idIngrediente) async {
  final db = await DatabaseHelper().database; // Obtenemos la instancia de la base de datos
  final List<Map<String, dynamic>> maps = await db.query(
    'ingredientesRecetas', // Nombre de la tabla
    where: 'idIngrediente = ?', // Condición para buscar el ingrediente
    whereArgs: [idIngrediente], // Argumento para el ID del ingrediente
  );

  if (maps.isNotEmpty) {
    return IngredienteReceta.fromMap(maps.first); // Retorna el ingrediente si se encuentra
  } else {
    throw Exception('Ingrediente no encontrado'); // Manejo de errores
  }
}
  // Método para eliminar un ingrediente
  Future<void> eliminarIngrediente(int idIngrediente) async {
    final db = await DatabaseHelper().database; // Obtenemos la instancia de la base de datos
    try {
      await db.delete(
        'ingredientesRecetas', // Nombre de la tabla
        where: 'idIngrediente = ?', // Condición para buscar el ingrediente
        whereArgs: [idIngrediente], // Argumento para el ID del ingrediente
      );
    } catch (e) {
      // Si ocurre un error, lo registramos y lanzamos una excepción
      CustomLogger().logError('Error al eliminar ingrediente con id $idIngrediente: $e');
      throw Exception("Error al eliminar ingrediente");
    }
  }

  // Método para actualizar un ingrediente en la base de datos
  Future<int> actualizarIngrediente(IngredienteReceta ingrediente) async {
    final db = await DatabaseHelper().database; // Obtenemos la instancia de la base de datos
    try {
      return await db.update(
        'ingredientesRecetas', // Nombre de la tabla
        ingrediente.toMap(), // Convierte el ingrediente a un mapa
        where: 'idIngrediente = ?', // Condición para actualizar el ingrediente
        whereArgs: [ingrediente.idIngrediente], // ID del ingrediente a actualizar
      );
    } catch (e) {
      // Si ocurre un error, lo registramos y lanzamos una excepción
      CustomLogger().logError('Error al actualizar ingrediente con id ${ingrediente.idIngrediente}: $e');
      throw Exception("Error al actualizar ingrediente");
    }
  }

  // Método para obtener todos los ingredientes de una receta específica
  Future<List<IngredienteReceta>> getAllIngredientesPorReceta(int idReceta) async {
    final db = await DatabaseHelper().database; // Obtenemos la instancia de la base de datos
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'ingredientesRecetas', // Nombre de la tabla
        where: 'idReceta = ?', // Condición para buscar por idReceta
        whereArgs: [idReceta], // Argumento para el ID de la receta
      );

      // Convertimos la lista de mapas a una lista de ingredientes
      return List.generate(maps.length, (i) {
        return IngredienteReceta.fromMap(maps[i]); // Creamos un objeto IngredienteReceta a partir del mapa
      });
    } catch (e) {
      // Si ocurre un error, lo registramos y lanzamos una excepción
      CustomLogger().logError('Error al obtener todos los ingredientes para la receta con id $idReceta: $e');
      throw Exception("Error al obtener todos los ingredientes");
    }
  }

  // Método para insertar un nuevo ingrediente en la base de datos
  Future<int> insertIngrediente(IngredienteReceta ingrediente) async {
    // Obtenemos la instancia de la base de datos
    final db = await DatabaseHelper().database;

    try {
      // Insertamos el ingrediente en la tabla 'ingredientesRecetas'
      return await db.insert(
        'ingredientesRecetas', // Nombre de la tabla
        ingrediente.toMap(), // Convertimos el ingrediente a un mapa usando el método toMap()
        conflictAlgorithm: ConflictAlgorithm.replace, // Si existe un conflicto (ej. id duplicado), reemplazamos el registro
      );
    } catch (e) {
      // Si ocurre un error, lo registramos y lanzamos una excepción
      CustomLogger().logError('Error al insertar ingrediente: $e');
      throw Exception("Error al insertar ingrediente");
    }
  }
}
