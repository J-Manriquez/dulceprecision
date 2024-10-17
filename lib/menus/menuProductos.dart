// Importa las dependencias necesarias
import 'package:DulcePrecision/database/providers/productos_provider.dart';
import 'package:DulcePrecision/models/font_size_model.dart';
import 'package:DulcePrecision/models/theme_model.dart';
import 'package:DulcePrecision/screens/modals/confirmDALLP.dart';
import 'package:flutter/material.dart';
import 'package:DulcePrecision/screens/settings_screen.dart'; // Importa la pantalla de configuraciones
import 'package:provider/provider.dart'; // Importa la pantalla de recetas

class MenuProductos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeModel =
        Provider.of<ThemeModel>(context); // Obtenemos el modelo de tema
    final fontSizeModel = Provider.of<FontSizeModel>(
        context); // Obtenemos el modelo de tamaño de fuente

    return PopupMenuButton<int>(
      // Ícono de tres puntos verticales que activa el menú
      icon: Icon(Icons.more_vert, color: themeModel.primaryIconColor, size: fontSizeModel.iconSize,),
      onSelected: (int value) async {
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
            // Muestra el modal de confirmación y espera la respuesta
            final confirmacion = await mostrarDALLP(context);
            if (confirmacion == true) {
              // Si el usuario confirma la eliminación
              try {
                // Llamamos al método para eliminar todo el contenido de la tabla 'recetas'
                // await recetasProvider.eliminarContenidoTablaRecetas();
                // Supongamos que tienes un botón o acción que llama a este método
                await Provider.of<ProductosProvider>(context, listen: false)
                    .eliminarContenidoTablaProductos();

                // Muestra un mensaje de éxito si es necesario
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text('Todos los productos han sido eliminados.')),
                );
              } catch (e) {
                // Manejo del error
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Error al eliminar las productos: $e')),
                );
              }
            }
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
                fontSize: fontSizeModel.iconSize,
                color:  themeModel.secondaryIconColor
              ),
            ),
          ),
          PopupMenuItem<int>(
            value: 2, // Valor que se pasa al onSelected cuando se selecciona
            child: Text(
              'Borrar todos los productos',
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
