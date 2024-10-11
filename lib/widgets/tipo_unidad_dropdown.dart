import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:DulcePrecision/models/font_size_model.dart'; // Importa el modelo de tamaños de fuente
import 'package:DulcePrecision/models/theme_model.dart'; // Importa el modelo de tema

class TipoUnidadDropdown extends StatefulWidget {
  final String? initialValue; // Valor inicial seleccionado (opcional)
  final ValueChanged<String> onChanged; // Callback para cuando el valor cambia

  TipoUnidadDropdown({this.initialValue, required this.onChanged});

  @override
  _TipoUnidadDropdownState createState() => _TipoUnidadDropdownState();
}

class _TipoUnidadDropdownState extends State<TipoUnidadDropdown> {
  // Lista de tipos de unidad disponibles
  final List<String> _tiposUnidad = [
    'gramos',
    'mililitros',
    'kilogramos',
    'litros',
    'unidad',
  ];

  late String _selectedTipo; // Almacena el tipo de unidad seleccionado

  @override
  void initState() {
    super.initState();
    // Inicializa el tipo de unidad seleccionado
    _selectedTipo = widget.initialValue ??
        _tiposUnidad[0]; // Usa el valor inicial o el primero de la lista
  }

  @override
  Widget build(BuildContext context) {
    // Obtiene el modelo de tema y de tamaño de fuente
    final themeModel = Provider.of<ThemeModel>(context);
    final fontSizeModel = Provider.of<FontSizeModel>(context);

    return DropdownButton<String>(
      value: _selectedTipo, // Tipo de unidad seleccionado
      icon: Icon(Icons.arrow_drop_down,
          color: themeModel.secondaryTextColor), // Icono del dropdown
      style: TextStyle(
        fontSize: fontSizeModel.textSize, // Tamaño dinámico del texto
        color: themeModel.primaryTextColor, // Color del texto dinámico
      ),
      dropdownColor:
          themeModel.primaryButtonColor, // Color de fondo del dropdown
      onChanged: (String? newValue) {
        setState(() {
          _selectedTipo = newValue!; // Actualiza el tipo de unidad seleccionado
        });
        widget.onChanged(newValue!); // Llama al callback con el nuevo valor
      },
      items: _tiposUnidad.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
            value: value, // Valor del item del dropdown
            child: Text(
              value, // Texto a mostrar en el dropdown
              style: TextStyle(
                  color: themeModel
                      .secondaryTextColor), // Cambia el color del texto aquí), // Texto a mostrar en el dropdown
            )
        );
      }).toList(),
    );
  }
}
