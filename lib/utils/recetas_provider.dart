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
      // Aquí puedes manejar los errores, como mostrar un mensaje al usuario.
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
}
