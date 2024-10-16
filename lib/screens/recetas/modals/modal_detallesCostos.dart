import 'package:DulcePrecision/database/metodos/ingredientes_recetas_mtd.dart';
import 'package:DulcePrecision/database/metodos/metodos_db_dp.dart';
import 'package:DulcePrecision/database/metodos/recetas_metodos.dart';
import 'package:DulcePrecision/models/font_size_model.dart';
import 'package:DulcePrecision/models/theme_model.dart';
import 'package:DulcePrecision/utils/funciones/preciosRecetas/recetasCalcularCostos.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:DulcePrecision/models/db_model.dart'; // Asegúrate de tener este modelo importado

// Modal para ver los detalles de la receta
Future<void> mostrarDetallesModal(BuildContext context, int? idReceta) {
  final themeModel = Provider.of<ThemeModel>(context, listen: false);
  final fontSizeModel = Provider.of<FontSizeModel>(context, listen: false);

  final recetaRepositorio = RecetaRepository();
  final ingredienteRecetaRepositorio = IngredienteRecetaRepository();

  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return FutureBuilder<Receta?>(
        future: recetaRepositorio.obtenerRecetaPorId(idReceta!),
        builder: (context, recetaSnapshot) {
          if (recetaSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!recetaSnapshot.hasData || recetaSnapshot.data == null) {
            return Center(child: Text('No se pudo cargar la receta.'));
          }
          final receta = recetaSnapshot.data!;

          return FutureBuilder<List<IngredienteReceta>>(
            future: ingredienteRecetaRepositorio
                .getAllIngredientesPorReceta(idReceta),
            builder: (context, ingredientesSnapshot) {
              if (ingredientesSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!ingredientesSnapshot.hasData ||
                  ingredientesSnapshot.data!.isEmpty) {
                return Center(child: Text('No hay ingredientes disponibles.'));
              }
              final ingredientes = ingredientesSnapshot.data!;
              return Dialog(
                child: Container(
                  width: MediaQuery.of(context).size.width *
                      0.8, // Ancho en 80% de la pantalla
                  height: MediaQuery.of(context).size.height *
                      0.8, // Alto en 60% de la pantalla
                  decoration: BoxDecoration(
                    color:
                        themeModel.backgroundColor, // Color de fondo del modal
                    borderRadius:
                        BorderRadius.circular(20), // Esquinas redondeadas
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16), // Padding para el título
                        child: Text(
                          'Costos de la receta: \n${receta.nombreReceta}',
                          style: TextStyle(
                            fontSize: fontSizeModel.titleSize,
                            color: themeModel.primaryTextColor,
                          ),
                        ),
                      ),
                      // Nueva fila para mostrar el precio de la receta y el botón para actualizar
                      // Verifica si el costo de la receta es un número válido o contiene letras
                      if (receta.costoReceta != null) ...[
                        // Expresión regular para verificar si contiene letras
                        RegExp(r'[a-zA-Z]').hasMatch(receta.costoReceta!)
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical:
                                            4), // Padding para el botón "Cerrar"
                                    child: Text(
                                      '${receta.costoReceta}', // Muestra el precio de la receta
                                      style: TextStyle(
                                        fontSize: fontSizeModel.textSize,
                                        color: themeModel.primaryTextColor,
                                      ),
                                      softWrap: true,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 25,
                                        vertical:
                                            0), // Padding para el botón "Cerrar"
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: Size(double.infinity, 30),
                                        backgroundColor:
                                            themeModel.primaryTextColor,
                                        foregroundColor:
                                            themeModel.primaryButtonColor,
                                      ),
                                      onPressed: () async {
                                        await calcularCostoCadaRecetas();
                                        MetodosRepository metodosRepository =
                                            MetodosRepository();
                                        await metodosRepository
                                            .getTableContent('recetas');
                                      },
                                      child: Icon(Icons.refresh),
                                    ),
                                  ),
                                ],
                              )
                            : Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical:
                                        0), // Padding para el botón "Cerrar"
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      RegExp(r'[a-zA-Z]')
                                              .hasMatch(receta.costoReceta!)
                                          ? '''Precio:
No se puede calcular'''
                                          : 'Precio: \$${(double.tryParse(receta.costoReceta!) ?? 0.0).round()}',
                                      style: TextStyle(
                                        fontSize: fontSizeModel.textSize,
                                        color: themeModel.primaryTextColor,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        await Future.delayed(
                                            Duration(seconds: 2));
                                        await calcularCostoCadaRecetas();
                                        MetodosRepository metodosRepository =
                                            MetodosRepository();
                                        await metodosRepository
                                            .getTableContent('recetas');
                                      },
                                      child: Container(
                                        child: Icon(
                                          Icons.refresh,
                                          size: fontSizeModel.iconSize,
                                          color: themeModel.primaryButtonColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ],
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: ingredientes.map((ingrediente) {
                              // Verificar si el costo contiene letras usando una expresión regular
                              bool contieneLetras = RegExp(r'[a-zA-Z]')
                                  .hasMatch(ingrediente.costoIngrediente);

                              // Si el costo no contiene letras, realizar la conversión y redondeo
                              String costoMostrar = contieneLetras
                                  ? ingrediente
                                      .costoIngrediente // Conservar el valor original si contiene letras
                                  : '\$${(double.tryParse(ingrediente.costoIngrediente) ?? 0.0).round()}'; // Redondear si es un número

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 25,
                                    vertical:
                                        10), // Padding para cada ingrediente
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '• ${ingrediente.nombreIngrediente}', // Nombre del ingrediente
                                      style: TextStyle(
                                        fontSize: fontSizeModel.textSize,
                                        color: themeModel.primaryTextColor,
                                      ),
                                    ),
                                    Text(
                                      'Costo: $costoMostrar', // Muestra el costo basado en la condición
                                      style: TextStyle(
                                        fontSize: fontSizeModel.textSize,
                                        color: themeModel.primaryTextColor,
                                      ),
                                    ),
                                    Divider(
                                      color: themeModel.primaryTextColor,
                                      thickness: 1,
                                      height: 10,
                                    ),
                                    SizedBox(
                                        height:
                                            8), // Espacio entre ingredientes
                                  ],
                                ),
                              );
                            }).toList(),
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
        },
      );
    },
  );
}
