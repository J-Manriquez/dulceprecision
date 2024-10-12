import 'package:DulcePrecision/screens/recetas/agregar_receta_sc.dart';
import 'package:flutter/material.dart';
// import 'package:DulcePrecision/screens/recetas/agregar_receta_sc.dart'; // Asegúrate de tener esta pantalla
import 'package:provider/provider.dart';
import 'package:DulcePrecision/models/font_size_model.dart';
import 'package:DulcePrecision/models/theme_model.dart';
import 'package:DulcePrecision/utils/recetas_provider.dart'; // Importa el RecetasProvider

class RecetasScreen extends StatefulWidget {
  @override
  _RecetasScreenState createState() => _RecetasScreenState();
}

class _RecetasScreenState extends State<RecetasScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch recipes when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RecetasProvider>(context, listen: false).obtenerRecetas();
    });
  }

  Future<void> _eliminarReceta(BuildContext context, int idReceta) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar esta receta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await Provider.of<RecetasProvider>(context, listen: false).eliminarReceta(idReceta);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Receta eliminada con éxito!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar la receta: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);
    final fontSizeModel = Provider.of<FontSizeModel>(context);
    final recetasProvider = Provider.of<RecetasProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeModel.primaryButtonColor,
        title: Text(
          'Recetas',
          style: TextStyle(
            fontSize: fontSizeModel.titleSize,
            color: themeModel.primaryTextColor,
          ),
        ),actions: [
        // Botón de refresco para actualizar precios
        IconButton(
          icon: Icon(
            Icons.refresh,
            size: fontSizeModel.iconSize,
            color: themeModel.primaryIconColor,
          ),
          onPressed: () async {
            try {
              await recetasProvider.actualizarPreciosRecetas(); // Llama al método que actualiza los precios
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Precios actualizados con éxito!')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error al actualizar precios: $e')),
              );
            }
          },
        ),
        IconButton(
          icon: Icon(
            Icons.add,
            size: fontSizeModel.iconSize,
            color: themeModel.primaryIconColor,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InsertarRecetasScreen(),
              ),
            ).then((_) => recetasProvider.obtenerRecetas());
          },
        ),
        ],
      ),
      body: Consumer<RecetasProvider>(
        builder: (context, provider, child) {
          if (provider.recetas.isEmpty) {
            return Center(
              child: Text(
                'No hay recetas disponibles',
                style: TextStyle(
                  fontSize: fontSizeModel.textSize,
                  color: themeModel.secondaryTextColor,
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: provider.recetas.length,
            itemBuilder: (context, index) {
              final receta = provider.recetas[index];

              return Card(
                elevation: 2,
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nombre: ${receta.nombreReceta}',
                              style: TextStyle(
                                fontSize: fontSizeModel.textSize,
                                color: themeModel.secondaryTextColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            if (receta.descripcionReceta != null) ...[
                              Text(
                                'Descripción: ${receta.descripcionReceta}',
                                style: TextStyle(
                                  fontSize: fontSizeModel.textSize,
                                  color: themeModel.secondaryTextColor,
                                ),
                              ),
                              SizedBox(height: 4),
                            ],
                            if (receta.precioReceta != null) ...[
                              Text(
                                'Precio: \$${receta.precioReceta!.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: fontSizeModel.textSize,
                                  color: themeModel.secondaryTextColor,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      InsertarRecetasScreen(receta: receta), // Asegúrate de que esta pantalla esté implementada
                                ),
                              ).then((_) => recetasProvider.obtenerRecetas());
                            },
                            child: Text(
                              'Editar',
                              style: TextStyle(
                                fontSize: fontSizeModel.textSize,
                                color: themeModel.secondaryTextColor,
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              _eliminarReceta(context, receta.idReceta!);
                            },
                            child: Text(
                              'Borrar',
                              style: TextStyle(
                                fontSize: fontSizeModel.textSize,
                                color: themeModel.secondaryTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
