// Importa las dependencias necesarias
import 'package:DulcePrecision/models/font_size_model.dart';
import 'package:DulcePrecision/models/theme_model.dart';
import 'package:flutter/material.dart';
import 'package:DulcePrecision/screens/settings_screen.dart'; // Importa la pantalla de configuraciones
import 'package:DulcePrecision/screens/recetas/recetas_screen.dart';
import 'package:provider/provider.dart'; // Importa la pantalla de recetas

class MenuVentas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
        final themeModel = Provider.of<ThemeModel>(context); // Obtenemos el modelo de tema
    final fontSizeModel = Provider.of<FontSizeModel>(context); // Obtenemos el modelo de tamaño de fuente

    return PopupMenuButton<int>(
      // Ícono de tres puntos verticales que activa el menú
      icon: Icon(Icons.more_vert, size: fontSizeModel.iconSize,
                color:  themeModel.primaryIconColor ),
      onSelected: (int value) {
        // Maneja la selección del menú con base en el valor
        switch (value) {
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SettingsScreen(),
              ),
            ); // Navega a la pantalla de configuraciones
            break;
          case 2:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecetasScreen(),
              ),
            ); // Navega a la pantalla de recetas
            break;
        }
      },
      itemBuilder: (BuildContext context) {
            final themeModel = Provider.of<ThemeModel>(context); // Obtenemos el modelo de tema
    final fontSizeModel = Provider.of<FontSizeModel>(context); // Obtenemos el modelo de tamaño de fuente

        // Construye las opciones del menú flotante
        return <PopupMenuEntry<int>>[
          PopupMenuItem<int>(
            value: 1, // Valor que se pasa al onSelected cuando se selecciona
            child: Text(
              'Historial de ventas', 
              style: TextStyle(
                fontSize: fontSizeModel.iconSize,
                color:  themeModel.secondaryIconColor 
              ),
            ),
          ),
          PopupMenuItem<int>(
            value: 2, // Valor que se pasa al onSelected cuando se selecciona
            child: Text(
              'Borrar todas las ventas',
              style: TextStyle(
                fontSize: fontSizeModel.iconSize,
                color:  themeModel.secondaryIconColor 
              ),
            ),
          ),
        ];
      },
    );
  }
}
