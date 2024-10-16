import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:DulcePrecision/models/theme_model.dart';
import 'package:DulcePrecision/models/font_size_model.dart';

class ConfirmDialog {
  // BAER = back desde agregar/editar receta
  static Future<bool> verConfirmacionBAER(BuildContext context) async {
    final themeModel = Provider.of<ThemeModel>(context, listen: false);
    final fontSizeModel = Provider.of<FontSizeModel>(context, listen: false);

    return await showDialog<bool>(
          context: context,
          builder: (context) => Dialog(
            child: Container(
              decoration: BoxDecoration(
                color: themeModel.backgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Conservar receta',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: fontSizeModel.titleSize,
                        color: themeModel.primaryTextColor,
                      ),
                    ),
                    SizedBox(height: 10),
                    Center(
                      child: Text(
                        '''No se aplicarán cambios a la receta 
¿Está seguro de que desea volver sin guardar?''',
                        style: TextStyle(
                          fontSize: fontSizeModel.textSize,
                          color: themeModel.primaryTextColor,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: themeModel.primaryButtonColor,
                              foregroundColor: themeModel.primaryTextColor,
                            ),
                            child: Text(
                              'Cancelar',
                              style: TextStyle(
                                fontSize: fontSizeModel.subtitleSize,
                              ),
                            ),
                            onPressed: () => Navigator.of(context).pop(false),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: themeModel.primaryTextColor,
                              foregroundColor: themeModel.primaryButtonColor,
                            ),
                            child: Text(
                              'Confirmar',
                              style: TextStyle(
                                fontSize: fontSizeModel.subtitleSize,
                              ),
                            ),
                            onPressed: () => Navigator.of(context).pop(true),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ) ??
        false; // Retorna false si se cierra sin selección
  }
}
