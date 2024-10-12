import 'package:DulcePrecision/utils/ingrediente_agregar_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'tipo_unidad_dropdown.dart';
import 'package:DulcePrecision/widgets/tipo_unidad_dropdown.dart';

class AgregarIngredientesWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AgregarIngredientesProvider>(context);

    return Column(
      children: [
        ElevatedButton(
          onPressed: provider.agregarIngrediente,
          child: Text('Añadir Ingrediente'),
          style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 40)),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: provider.getIngredientes.length,
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
                          decoration: InputDecoration(labelText: 'Nombre del Ingrediente'),
                          onChanged: (value) => provider.actualizarIngrediente(index, 'nombre', value),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () => provider.eliminarIngrediente(index),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        flex: 7,
                        child: TextField(
                          decoration: InputDecoration(labelText: 'Cantidad'),
                          keyboardType: TextInputType.number,
                          onChanged: (value) => provider.actualizarIngrediente(index, 'cantidad', value),
                        ),
                      ),
                      SizedBox(width: 8),
                      TipoUnidadDropdown(
                        initialValue: provider.getIngredientes[index]['tipoUnidad'],
                        onChanged: (value) => provider.actualizarIngrediente(index, 'tipoUnidad', value),
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
