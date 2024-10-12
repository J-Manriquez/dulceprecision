import 'package:flutter/material.dart';

class AgregarIngredientesProvider with ChangeNotifier {
  List<Map<String, dynamic>> _ingredientes;

  AgregarIngredientesProvider(this._ingredientes);

  List<Map<String, dynamic>> get getIngredientes => _ingredientes;

  void agregarIngrediente() {
    _ingredientes.add({
      'nombre': '',
      'cantidad': '',
      'tipoUnidad': 'gramos',
    });
    notifyListeners();
  }

  void eliminarIngrediente(int index) {
    _ingredientes.removeAt(index);
    notifyListeners();
  }

  void actualizarIngrediente(int index, String key, String value) {
    _ingredientes[index][key] = value;
    notifyListeners();
  }
}
