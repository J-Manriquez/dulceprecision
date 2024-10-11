import 'package:flutter/material.dart';
import 'tipo_unidad_dropdown.dart';

class AgregarIngredientesWidget extends StatefulWidget {
  @override
  _AgregarIngredientesWidgetState createState() => _AgregarIngredientesWidgetState();
}

class _AgregarIngredientesWidgetState extends State<AgregarIngredientesWidget> {
  List<Map<String, dynamic>> _ingredientes = [];

  void _agregarIngrediente() {
    setState(() {
      _ingredientes.add({
        'nombre': '',
        'cantidad': '',
        'tipoUnidad': 'gramos',
      });
    });
  }

  void _eliminarIngrediente(int index) {
    setState(() {
      _ingredientes.removeAt(index);
    });
  }

  void _actualizarIngrediente(int index, String key, String value) {
    setState(() {
      _ingredientes[index][key] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _agregarIngrediente,
          child: Text('Añadir Ingrediente'),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _ingredientes.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Nombre del Ingrediente',
                          ),
                          onChanged: (value) => _actualizarIngrediente(index, 'nombre', value),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Cantidad',
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) => _actualizarIngrediente(index, 'cantidad', value),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TipoUnidadDropdown(
                          initialValue: _ingredientes[index]['tipoUnidad'],
                          onChanged: (value) => _actualizarIngrediente(index, 'tipoUnidad', value),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () => _eliminarIngrediente(index),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}