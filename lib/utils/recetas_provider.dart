// Importar las librerías necesarias
import 'package:DulcePrecision/utils/custom_logger.dart';
import 'package:flutter/material.dart';
import 'package:DulcePrecision/models/db_model.dart'; // Modelo Receta
import 'package:DulcePrecision/database/metodos/recetas_metodos.dart'; // Repositorio de recetas

class RecetasProvider with ChangeNotifier {
  List<Receta> _recetas = []; // Lista privada de recetas
  final RecetaRepository _recetaRepository = RecetaRepository(); // Instancia del repositorio

  List<Receta> get recetas => _recetas; // Getter para la lista de recetas

  // Método para obtener recetas desde la base de datos
  Future<void> obtenerRecetas() async {
    try {
      _recetas = await _recetaRepository.getAllRecetas(); // Obtiene recetas del repositorio
      notifyListeners(); // Notifica a los widgets que los datos han cambiado
    } catch (e) {
      // Registro de errores usando CustomLogger
      CustomLogger().logError('Error al obtener recetas: $e');
      throw Exception("Error al obtener recetas"); // Lanzamos una excepción para manejo externo
    }
  }

  // Método para agregar una receta
  Future<void> agregarReceta(Receta receta) async {
    try {
      await _recetaRepository.insertReceta(receta); // Inserta receta
      await obtenerRecetas(); // Actualiza la lista después de insertar
    } catch (e) {
      // Registro de errores usando CustomLogger
      CustomLogger().logError('Error al agregar receta: $e');
      throw Exception("Error al agregar receta"); // Lanzamos una excepción para manejo externo
    }
  }

  // Método para eliminar una receta
  Future<void> eliminarReceta(int idReceta) async {
    try {
      await _recetaRepository.eliminarReceta(idReceta); // Elimina receta
      await obtenerRecetas(); // Actualiza la lista después de eliminar
    } catch (e) {
      // Registro de errores usando CustomLogger
      CustomLogger().logError('Error al eliminar receta con id $idReceta: $e');
      throw Exception("Error al eliminar receta"); // Lanzamos una excepción para manejo externo
    }
  }

  // Método para actualizar el precio de todas las recetas
  Future<void> actualizarPreciosRecetas() async {
    try {
      // Obtener todas las recetas
      List<Receta> recetas = await _recetaRepository.getAllRecetas(); // Obtén todas las recetas

      // Iterar sobre cada receta
      for (Receta receta in recetas) {
        // Calcular el precio de la receta
        double precio = await _recetaRepository.calcularPrecioReceta(receta.idReceta!); // Asegúrate de que el método calcularPrecioReceta existe en el repositorio

        // Actualizar el precio de la receta en la base de datos
        await _recetaRepository.actualizarPrecioReceta(receta.idReceta!, precio); // Asegúrate de que el método actualizarPrecioReceta está implementado
      }

      // Vuelve a obtener las recetas después de actualizar los precios
      await obtenerRecetas(); // Actualiza la lista después de la actualización de precios
    } catch (e) {
      // Registro de errores usando CustomLogger
      CustomLogger().logError('Error al actualizar precios de recetas: $e');
      throw Exception("Error al actualizar precios de recetas"); // Lanzamos una excepción para manejo externo
    }
  }
}
