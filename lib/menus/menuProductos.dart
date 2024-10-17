// Importa las dependencias necesarias
import 'package:flutter/material.dart';
import 'package:DulcePrecision/screens/settings_screen.dart'; // Importa la pantalla de configuraciones
import 'package:DulcePrecision/screens/recetas/recetas_screen.dart'; // Importa la pantalla de recetas

class MenuProductos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      // Ícono de tres puntos verticales que activa el menú
      icon: Icon(Icons.more_vert),
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
        // Construye las opciones del menú flotante
        return <PopupMenuEntry<int>>[
          PopupMenuItem<int>(
            value: 1, // Valor que se pasa al onSelected cuando se selecciona
            child: Text(
              'Configuraciones', 
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize, // Tamaño de fuente del texto
                color: Theme.of(context).textTheme.bodyMedium?.color, // Color de texto según el tema
              ),
            ),
          ),
          PopupMenuItem<int>(
            value: 2, // Valor que se pasa al onSelected cuando se selecciona
            child: Text(
              'Borrar todos los productos',
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize, // Tamaño de fuente del texto
                color: Theme.of(context).textTheme.bodyMedium?.color, // Color de texto según el tema
              ),
            ),
          ),
        ];
      },
    );
  }
}
