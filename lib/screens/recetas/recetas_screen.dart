import 'package:DulcePrecision/screens/recetas/agregar_receta_sc.dart';
import 'package:DulcePrecision/screens/recetas/receta_modals.dart';
import 'package:DulcePrecision/database/providers/ingredientes_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:DulcePrecision/models/font_size_model.dart';
import 'package:DulcePrecision/models/theme_model.dart';
import 'package:DulcePrecision/database/providers/recetas_provider.dart';

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
        await Provider.of<IngredientesRecetasProvider>(context, listen: false)
            .eliminarIngredientesPorReceta(idReceta);
        await Provider.of<RecetasProvider>(context, listen: false)
            .eliminarReceta(idReceta);
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
        ),
        actions: [
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Primera fila: Nombre de la receta
                      Text(
                        'Nombre: ${receta.nombreReceta}',
                        style: TextStyle(
                          fontSize: fontSizeModel.textSize,
                          color: themeModel.secondaryTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      // Segunda fila: Precio y botón "Detalles"
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          if (receta.costoReceta != null) ...[
                            Text(
                              'Precio: \$${receta.costoReceta!.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: fontSizeModel.textSize,
                                color: themeModel.secondaryTextColor,
                              ),
                            ),
                          ],
                          GestureDetector(
                            onTap: () {
                              mostrarDetallesModal(
                                  context, receta.nombreReceta);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 3),
                              // decoration: BoxDecoration(
                              //   color: themeModel.primaryButtonColor,
                              //   borderRadius: BorderRadius.circular(8),
                              // ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: fontSizeModel.iconSize * 0.7,
                                    color: themeModel.primaryIconColor,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Detalles',
                                    style: TextStyle(
                                      fontSize: fontSizeModel.textSize,
                                      color: themeModel.secondaryTextColor,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(
                                    Icons.visibility,
                                    size: fontSizeModel.iconSize * 0.7,
                                    color: themeModel.primaryIconColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      // Tercera fila: Botones "Editar", "Borrar" y "Ver"
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            flex: 3, // Proporción para el botón "Ver"
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: themeModel.primaryButtonColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                mostrarContenidoRecetaModal(
                                    context,
                                    receta
                                        .idReceta!); // Llama al modal de contenido
                              },
                              child: Text(
                                'Ver',
                                style: TextStyle(
                                  fontSize: fontSizeModel.textSize,
                                  color: themeModel.primaryTextColor,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 4),
                          Expanded(
                            flex: 3, // Proporción para el botón "Editar"
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: themeModel.primaryButtonColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        InsertarRecetasScreen(receta: receta),
                                  ),
                                ).then((_) => recetasProvider.obtenerRecetas());
                              },
                              child: Text(
                                'Editar',
                                style: TextStyle(
                                  fontSize: fontSizeModel.textSize,
                                  color: themeModel.primaryTextColor,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 4),
                          Expanded(
                            flex: 3, // Proporción para el botón "Borrar"
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: themeModel.primaryButtonColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                _eliminarReceta(context, receta.idReceta!);
                              },
                              child: Text(
                                'Borrar',
                                style: TextStyle(
                                  fontSize: fontSizeModel.textSize,
                                  color: themeModel.primaryTextColor,
                                ),
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
