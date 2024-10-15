import 'package:DulcePrecision/models/font_size_model.dart';
import 'package:DulcePrecision/models/theme_model.dart';
import 'package:DulcePrecision/database/providers/recetas_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:DulcePrecision/database/providers/ingredientes_provider.dart'; // Importa el provider de ingredientes
import 'package:DulcePrecision/models/db_model.dart'; // Asegúrate de tener este modelo importado

// Modal para ver el contenido de la receta
Future<void> mostrarContenidoRecetaModal(
    BuildContext context, int idReceta) async {
  final ingredientesProvider =
      Provider.of<IngredientesRecetasProvider>(context, listen: false);
  final recetasProvider = Provider.of<RecetasProvider>(context, listen: false);

  await recetasProvider.obtenerRecetaPorId(idReceta);
  Receta? receta = recetasProvider.receta;

  await ingredientesProvider.obtenerIngredientesPorReceta(idReceta);
  List<IngredienteReceta> ingredientes = ingredientesProvider.ingredientes;

  final themeModel = Provider.of<ThemeModel>(context, listen: false);
  final fontSizeModel = Provider.of<FontSizeModel>(context, listen: false);

  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width *
              0.95, // Ancho en 80% de la pantalla
          height: MediaQuery.of(context).size.height *
              0.9, // Alto en 60% de la pantalla
          decoration: BoxDecoration(
            color: themeModel.backgroundColor, // Color de fondo del modal
            borderRadius: BorderRadius.circular(20), // Esquinas redondeadas
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 0, vertical: 10), // Padding para el título
                child: Center(
                  child: Text(
                    '${receta?.nombreReceta}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: fontSizeModel.titleSize,
                      color: themeModel.primaryTextColor,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 5), // Padding para "Ingredientes"
                        child: Text(
                          'Ingredientes:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: fontSizeModel.subtitleSize,
                            color: themeModel.primaryButtonColor,
                          ),
                        ),
                      ),
                      ...ingredientes
                          .map((ingrediente) => Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 25,
                                    vertical:
                                        2), // Padding para cada ingrediente
                                child: Text(
                                  '- ${ingrediente.cantidadIngrediente} ${ingrediente.tipoUnidadIngrediente} de ${ingrediente.nombreIngrediente}',
                                  style: TextStyle(
                                      fontSize: fontSizeModel.textSize,
                                      color: themeModel.primaryTextColor),
                                ),
                              ))
                          .toList(),
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 5), // Padding para "Descripción"
                        child: Text(
                          'Descripción:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: fontSizeModel.subtitleSize,
                            color: themeModel.primaryButtonColor,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25,
                            vertical:
                                5), // Padding para la descripción de la receta
                        child: Text(
                          '${receta?.descripcionReceta}',
                          style: TextStyle(
                              fontSize: fontSizeModel.textSize,
                              color: themeModel.primaryTextColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16), // Padding para el botón "Cerrar"
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 40),
                    backgroundColor: themeModel.primaryButtonColor,
                    foregroundColor: themeModel.primaryTextColor,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Cierra el modal
                  },
                  child: Text(
                    'Cerrar',
                    style: TextStyle(
                      fontSize: fontSizeModel.subtitleSize,
                      color: themeModel.primaryTextColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// Modal para ver los detalles de la receta
Future<void> mostrarDetallesModal(BuildContext context, String nombreReceta) {
  final themeModel = Provider.of<ThemeModel>(context, listen: false);
  final fontSizeModel = Provider.of<FontSizeModel>(context, listen: false);

  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width *
              0.8, // Ancho en 80% de la pantalla
          height: MediaQuery.of(context).size.height *
              0.6, // Alto en 60% de la pantalla
          decoration: BoxDecoration(
            color: themeModel.backgroundColor, // Color de fondo del modal
            borderRadius: BorderRadius.circular(20), // Esquinas redondeadas
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10), // Padding para el título
                child: Center(
                  child: Text(
                    'Precios de los Ingredientes',
                    style: TextStyle(
                      fontSize: fontSizeModel.titleSize,
                      color: themeModel.primaryTextColor,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 5), // Padding para el texto
                        child: Text(
                          'Este modal está vacío por ahora.',
                          style: TextStyle(
                              fontSize: fontSizeModel.textSize,
                              color: themeModel.primaryTextColor),
                        ),
                      ),
                      // Agrega más detalles si es necesario
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16), // Padding para el botón "Cerrar"
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 40),
                    backgroundColor: themeModel.primaryButtonColor,
                    foregroundColor: themeModel.primaryTextColor,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Cierra el modal
                  },
                  child: Text(
                    'Cerrar',
                    style: TextStyle(
                      fontSize: fontSizeModel.subtitleSize,
                      color: themeModel.primaryTextColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
