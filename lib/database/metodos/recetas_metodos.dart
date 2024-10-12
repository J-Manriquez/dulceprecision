import 'package:DulcePrecision/utils/custom_logger.dart';
import 'package:DulcePrecision/utils/normalizar_nombre_funcion.dart';
import 'package:DulcePrecision/utils/trans_tipo_unidad_funcion.dart';
import 'package:sqflite/sqflite.dart'; // Importamos el paquete de SQLite
import 'package:DulcePrecision/database/dp_db.dart'; // Importamos el helper de la base de datos
import 'package:DulcePrecision/models/db_model.dart'; // Importamos el modelo Receta
import 'package:DulcePrecision/database/metodos/productos_metodos.dart'; // Importamos el helper de la base de datos
import 'package:DulcePrecision/database/metodos/ingredientes_recetas_mtd.dart'; // Importamos el helper de la base de datos

class RecetaRepository {
  ProductRepository productRepository = ProductRepository();
  IngredienteRecetaRepository ingredienteRecetaRepository =
      IngredienteRecetaRepository();

  // Dentro de RecetasProvider
  Future<void> actualizarPreciosRecetas() async {
    try {
      // Obtener todas las recetas
      List<Receta> recetas = await getAllRecetas();

      // Iterar sobre cada receta
      for (Receta receta in recetas) {
        double precio =
            await calcularPrecioReceta(receta.idReceta!); // Calcula el precio
        await actualizarPrecioReceta(
            receta.idReceta!, precio); // Actualiza el precio
      }

      // Si necesitas volver a obtener las recetas después de la actualización, puedes hacerlo
    } catch (e) {
      CustomLogger().logError('Error al actualizar precios de recetas: $e');
      throw Exception("Error al actualizar precios de recetas");
    }
  }

  // Función principal para calcular el precio de la receta
  Future<double> calcularPrecioReceta(int idReceta) async {
    try {
      // Registrar inicio de cálculo de precio
      CustomLogger().logInfo(
          'Iniciando cálculo del precio para la receta con ID: $idReceta');

      // Obtener todos los productos
      List<Producto> productos = await productRepository.getAllProductos();

      // Registrar que los productos han sido obtenidos
      CustomLogger().logInfo('Productos obtenidos: ${productos.length}');

      // Obtener la receta específica
      List<Receta> recetas = await getAllRecetas();

      // Registrar que las recetas han sido obtenidas
      CustomLogger().logInfo('Recetas obtenidas: ${recetas.length}');

      // Buscamos la receta por ID
      Receta receta = recetas.firstWhere(
        (r) => r.idReceta == idReceta,
        orElse: () => throw Exception("Receta no encontrada"),
      );

      double precioTotal = 0;

      // Obtener todos los ingredientes relacionados con la receta
      List<IngredienteReceta> ingredientes =
          (await ingredienteRecetaRepository.getIngredienteById(idReceta))
              as List<IngredienteReceta>; // Debes implementar esta función

      // Registrar que los ingredientes han sido obtenidos
      CustomLogger().logInfo(
          'Ingredientes obtenidos para la receta con ID: $idReceta, total: ${ingredientes.length}');

      // Iterar sobre los ingredientes de la receta
      for (IngredienteReceta ingrediente in ingredientes) {
        try {
          String nombreIngredienteNormalizado =
              normalizarNombre(ingrediente.nombreIngrediente);

          // Buscar un producto que coincida con el ingrediente
          Producto? productoCoincidente = productos.firstWhere(
            (p) =>
                normalizarNombre(p.nombreProducto) ==
                nombreIngredienteNormalizado,
            orElse: () => throw Exception(
                "Producto no encontrado para el ingrediente: $nombreIngredienteNormalizado"),
          );

          // Verificamos que el producto no sea nulo
          if (productoCoincidente != null) {
            // Transformar la unidad del ingrediente a la unidad del producto si es necesario
            double cantidadTransformada = transformarUnidad(
              ingrediente.cantidadIngrediente,
              ingrediente.tipoUnidadIngrediente,
              productoCoincidente
                  .tipoUnidadProducto, // Se utiliza el tipo de unidad del producto
            );

            // Calcular el precio del ingrediente
            double precioIngrediente =
                (cantidadTransformada / productoCoincidente.cantidadProducto) *
                    productoCoincidente
                        .precioProducto; // Usar las propiedades correctas
            precioTotal += precioIngrediente; // Sumar al precio total
          }
        } catch (e) {
          CustomLogger().logError(
              'Error al procesar el ingrediente: ${ingrediente.nombreIngrediente} - $e');
        }
      }

      // Actualizar el precio de la receta
      await actualizarPrecioReceta(idReceta, precioTotal);

      // Registrar el precio total calculado
      CustomLogger().logInfo(
          'Precio total calculado para la receta con ID: $idReceta es: $precioTotal');

      return precioTotal; // Retornar el precio total calculado
    } catch (e) {
      CustomLogger().logError('Error al calcular el precio de la receta: $e');
      throw Exception("Error al calcular el precio de la receta");
    }
  }

// Método para actualizar el precio de una receta en la base de datos
  Future<int> actualizarPrecioReceta(int idReceta, double nuevoPrecio) async {
    final db = await DatabaseHelper()
        .database; // Obtenemos la instancia de la base de datos
    try {
      // Registrar intento de actualización
      CustomLogger().logInfo(
          'Actualizando el precio de la receta con ID: $idReceta a nuevo precio: $nuevoPrecio');

      int resultado = await db.update(
        'recetas', // Nombre de la tabla
        {'precioReceta': nuevoPrecio}, // Actualizamos solo el campo del precio
        where: 'idReceta = ?', // Condición para actualizar
        whereArgs: [idReceta], // ID de la receta a actualizar
      );

      // Registrar éxito de la actualización
      CustomLogger().logInfo(
          'Precio actualizado para la receta con ID: $idReceta, filas afectadas: $resultado');

      return resultado;
    } catch (e) {
      // Si ocurre un error, lo registramos y lanzamos una excepción
      CustomLogger().logError(
          'Error al actualizar el precio de la receta con id $idReceta: $e');
      throw Exception("Error al actualizar el precio de la receta");
    }
  }

  // Método para eliminar una receta
  Future<void> eliminarReceta(int idReceta) async {
    final db = await DatabaseHelper()
        .database; // Obtenemos la instancia de la base de datos
    try {
      await db.delete(
        'recetas', // Nombre de la tabla
        where: 'idReceta = ?', // Condición para buscar la receta
        whereArgs: [idReceta], // Argumento para el ID de la receta
      );
    } catch (e) {
      // Si ocurre un error, lo registramos y lanzamos una excepción
      CustomLogger().logError('Error al eliminar receta con id $idReceta: $e');
      throw Exception("Error al eliminar receta");
    }
  }

  // Método para actualizar una receta en la base de datos
  Future<int> actualizarReceta(Receta receta) async {
    final db = await DatabaseHelper()
        .database; // Obtenemos la instancia de la base de datos
    try {
      return await db.update(
        'recetas', // Nombre de la tabla
        receta.toMap(), // Convierte la receta a un mapa
        where: 'idReceta = ?', // Condición para actualizar la receta
        whereArgs: [receta.idReceta], // ID de la receta a actualizar
      );
    } catch (e) {
      // Si ocurre un error, lo registramos y lanzamos una excepción
      CustomLogger()
          .logError('Error al actualizar receta con id ${receta.idReceta}: $e');
      throw Exception("Error al actualizar receta");
    }
  }

  // Método para obtener todas las recetas de la base de datos
  Future<List<Receta>> getAllRecetas() async {
    final db = await DatabaseHelper()
        .database; // Obtenemos la instancia de la base de datos
    try {
      final List<Map<String, dynamic>> maps =
          await db.query('recetas'); // Realizamos la consulta

      // Convertimos la lista de mapas a una lista de recetas
      return List.generate(maps.length, (i) {
        return Receta.fromMap(
            maps[i]); // Creamos un objeto Receta a partir del mapa
      });
    } catch (e) {
      // Si ocurre un error, lo registramos y lanzamos una excepción
      CustomLogger().logError('Error al obtener todas las recetas: $e');
      throw Exception("Error al obtener todas las recetas");
    }
  }

  // Método para insertar una nueva receta en la base de datos
  Future<int> insertReceta(Receta receta) async {
    // Obtenemos la instancia de la base de datos
    final db = await DatabaseHelper().database;

    try {
      // Insertamos la receta en la tabla 'recetas'
      return await db.insert(
        'recetas', // Nombre de la tabla
        receta
            .toMap(), // Convertimos la receta a un mapa usando el método toMap()
        conflictAlgorithm: ConflictAlgorithm
            .replace, // Si existe un conflicto (ej. id duplicado), reemplazamos el registro
      );
    } catch (e) {
      // Si ocurre un error, lo registramos y lanzamos una excepción
      CustomLogger().logError('Error al insertar receta: $e');
      throw Exception("Error al insertar receta");
    }
  }
}
