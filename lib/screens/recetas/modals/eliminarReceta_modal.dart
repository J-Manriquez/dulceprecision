import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:DulcePrecision/models/font_size_model.dart';
import 'package:DulcePrecision/models/theme_model.dart';

Future<bool?> verConfirmacionER(BuildContext context) {
  // ER = Eliminar Receta
  // Obtenemos los modelos de tema y tamaño de fuente del contexto
  final themeModel = Provider.of<ThemeModel>(context, listen: false);
  final fontSizeModel = Provider.of<FontSizeModel>(context, listen: false);

  // Mostramos el diálogo de confirmación
  return showDialog<bool>(
    context: context,
    builder: (context) => Dialog(
      child: Container(
        decoration: BoxDecoration(
          color: themeModel.backgroundColor, // Color de fondo del modal
          borderRadius: BorderRadius.circular(20), // Esquinas redondeadas
        ),
        child: Padding(
          padding:
              const EdgeInsets.all(16.0), // Padding alrededor del contenido
          child: Column(
            mainAxisSize:
                MainAxisSize.min, // Ajusta el tamaño del modal al contenido
            crossAxisAlignment: CrossAxisAlignment
                .stretch, // Estira los hijos para ocupar todo el ancho
            children: [
              Text(
                'Confirmar eliminación', // Título del modal
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize:
                      fontSizeModel.titleSize, // Tamaño de fuente del título
                  color: themeModel.primaryTextColor, // Color del texto
                ),
              ),
              SizedBox(height: 10), // Espacio entre el título y el contenido
              Center(
                child: Text(
                  '¿Estás seguro de que deseas eliminar esta receta?',
                  style: TextStyle(
                    fontSize: fontSizeModel
                        .textSize, // Tamaño de fuente del contenido
                    color: themeModel.primaryTextColor, // Color del texto
                  ),
                  textAlign: TextAlign.center, // Centrar el texto
                ),
              ),
              SizedBox(height: 20), // Espacio entre el contenido y los botones
              Row(
                mainAxisAlignment: MainAxisAlignment
                    .spaceEvenly, // Alinea los botones en el centro
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: themeModel
                            .primaryButtonColor, // Color de fondo del botón "Cancelar"
                        foregroundColor: themeModel
                            .primaryTextColor, // Color del texto del botón
                      ),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                          fontSize: fontSizeModel
                              .subtitleSize, // Tamaño de fuente del botón
                        ),
                      ),
                      onPressed: () => Navigator.of(context)
                          .pop(false), // Cierra el modal y retorna false
                    ),
                  ),
                  SizedBox(width: 10), // Espacio entre los botones
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: themeModel
                            .primaryTextColor, // Color de fondo del botón "Eliminar"
                        foregroundColor: themeModel
                            .primaryButtonColor, // Color del texto del botón
                      ),
                      child: Text(
                        'Eliminar',
                        style: TextStyle(
                          fontSize: fontSizeModel
                              .subtitleSize, // Tamaño de fuente del botón
                        ),
                      ),
                      onPressed: () => Navigator.of(context)
                          .pop(true), // Cierra el modal y retorna true
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
