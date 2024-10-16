import 'package:DulcePrecision/screens/recetas/agregar_receta_sc.dart';
import 'package:DulcePrecision/screens/recetas/modals/eliminarReceta_modal.dart';
import 'package:DulcePrecision/screens/recetas/modals/modal_detallesCostos.dart';
import 'package:DulcePrecision/screens/recetas/modals/verReceta_modal.dart';
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

  // Future<void> _eliminarReceta(BuildContext context, int idReceta) async {
  // // Obtenemos los modelos de tema y tamaño de fuente del contexto
  // final themeModel = Provider.of<ThemeModel>(context, listen: false);
  // final fontSizeModel = Provider.of<FontSizeModel>(context, listen: false);

  // // Mostramos el diálogo de confirmación
  // final confirmar = await showDialog<bool>(
  //   context: context,
  //   builder: (context) => Dialog(
  //     // Usamos Dialog en lugar de AlertDialog para mantener la consistencia
  //     child: Container(
  //       // Alto del modal en un 40% de la altura de la pantalla
  //       // height: MediaQuery.of(context).size.height * 0.4,
  //       decoration: BoxDecoration(
  //         color: themeModel.backgroundColor, // Color de fondo del modal
  //         borderRadius: BorderRadius.circular(20), // Esquinas redondeadas
  //       ),
  //       child: Padding(
  //         padding: const EdgeInsets.all(16.0), // Padding alrededor del contenido
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min, // Ajusta el tamaño del modal al contenido
  //           crossAxisAlignment: CrossAxisAlignment.stretch, // Estira los hijos para ocupar todo el ancho
  //           children: [
  //             Text(
  //               'Confirmar eliminación', // Título del modal
  //               style: TextStyle(
  //                 fontWeight: FontWeight.bold,
  //                 fontSize: fontSizeModel.titleSize, // Tamaño de fuente del título
  //                 color: themeModel.primaryTextColor, // Color del texto
  //               ),
  //             ),
  //             SizedBox(height: 10), // Espacio entre el título y el contenido
  //             Center(
  //               child: Text(
  //                 '¿Estás seguro de que deseas eliminar esta receta?',
  //                 style: TextStyle(
  //                   fontSize: fontSizeModel.textSize, // Tamaño de fuente del contenido
  //                   color: themeModel.primaryTextColor, // Color del texto
  //                 ),
  //                 textAlign: TextAlign.center, // Centrar el texto
  //               ),
  //             ),
  //             SizedBox(height: 20), // Espacio entre el contenido y los botones
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Alinea los botones en el centro
  //               crossAxisAlignment: CrossAxisAlignment.end,
  //               children: [
  //                 Expanded(
  //                   child: TextButton(
  //                     style: TextButton.styleFrom(
  //                       backgroundColor: themeModel.primaryButtonColor, // Color de fondo del botón "Cancelar"
  //                       foregroundColor: themeModel.primaryTextColor, // Color del texto del botón
  //                     ),
  //                     child: Text(
  //                       'Cancelar',
  //                       style: TextStyle(
  //                         fontSize: fontSizeModel.subtitleSize, // Tamaño de fuente del botón
  //                       ),
  //                     ),
  //                     onPressed: () => Navigator.of(context).pop(false), // Cierra el modal y retorna false
  //                   ),
  //                 ),
  //                 SizedBox(width: 10), // Espacio entre los botones
  //                 Expanded(
  //                   child: TextButton(
  //                     style: TextButton.styleFrom(
  //                       backgroundColor: themeModel.primaryTextColor, // Color de fondo del botón "Eliminar"
  //                       foregroundColor: themeModel.primaryButtonColor, // Color del texto del botón
  //                     ),
  //                     child: Text(
  //                       'Eliminar',
  //                       style: TextStyle(
  //                         fontSize: fontSizeModel.subtitleSize, // Tamaño de fuente del botón
  //                       ),
  //                     ),
  //                     onPressed: () => Navigator.of(context).pop(true), // Cierra el modal y retorna true
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   ),
  // );

  Future<void> _eliminarReceta(BuildContext context, int idReceta) async {
    // Llamamos al nuevo modal de confirmación
    final confirmar = await verConfirmacionER(context);

    // Si el usuario confirma la eliminación
    if (confirmar == true) {
      try {
        // Eliminamos los ingredientes relacionados con la receta
        await Provider.of<IngredientesRecetasProvider>(context, listen: false)
            .eliminarIngredientesPorReceta(idReceta);
        // Eliminamos la receta
        await Provider.of<RecetasProvider>(context, listen: false)
            .eliminarReceta(idReceta);
        // Mostramos un mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Receta eliminada con éxito!')),
        );
      } catch (e) {
        // Mostramos un mensaje de error si ocurre una excepción
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
                        '${receta.nombreReceta}',
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
                          // Verifica si el costo de la receta es un número válido o contiene letras
                          if (receta.costoReceta != null) ...[
                            // Expresión regular para verificar si contiene letras
                            // Usa la variable RegExp para definir el texto a mostrar
                            Text(
                              RegExp(r'[a-zA-Z]').hasMatch(receta.costoReceta!)
                                  ? '''Precio:
No se puede calcular'''
                                  : 'Precio: \$${(double.tryParse(receta.costoReceta!) ?? 0.0).round()}',
                              style: TextStyle(
                                fontSize: fontSizeModel.textSize,
                                color: themeModel.secondaryTextColor,
                              ),
                            ),
                          ],
                          GestureDetector(
                            onTap: () {
                              mostrarDetallesModal(context, receta.idReceta);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 3),
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
