import 'package:DulcePrecision/database/metodos/ingredientes_recetas_mtd.dart';
import 'package:DulcePrecision/utils/custom_logger.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:DulcePrecision/database/metodos/recetas_metodos.dart';
import 'package:DulcePrecision/models/db_model.dart';
import 'package:DulcePrecision/models/theme_model.dart';
import 'package:DulcePrecision/models/font_size_model.dart';
import 'package:DulcePrecision/utils/ingredientes_provider.dart';
import 'package:DulcePrecision/widgets/agregar_ingrediente_widget.dart';
import 'package:DulcePrecision/widgets/editar_ingrediente_widget.dart';

class InsertarRecetasScreen extends StatefulWidget {
  final Receta? receta;

  InsertarRecetasScreen({this.receta});

  @override
  _InsertarRecetasScreenState createState() => _InsertarRecetasScreenState();
}

class _InsertarRecetasScreenState extends State<InsertarRecetasScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _costoController = TextEditingController();

  final GlobalKey<EditarIngredientesWidgetState> _editarIngredientesKey =
      GlobalKey();
  final GlobalKey<AgregarIngredientesWidgetState> _agregarIngredientesKey =
      GlobalKey();

  String estadoReceta = '';

  @override
  void initState() {
    super.initState();
    if (widget.receta != null) {
      estadoReceta = 'edit';
      _nombreController.text = widget.receta!.nombreReceta;
      _descripcionController.text = widget.receta!.descripcionReceta!;
      _costoController.text = widget.receta!.costoReceta.toString();
    } else {
      estadoReceta = 'insert';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);
    final fontSizeModel = Provider.of<FontSizeModel>(context);

    return Consumer<IngredientesRecetasProvider>(
      builder: (context, ingredientesProvider, child) {
        return Scaffold(
          appBar: AppBar(
            leading: Container(
              alignment: Alignment.center,
              child: IconButton(
                icon:
                    Icon(Icons.arrow_back, color: themeModel.primaryIconColor),
                iconSize: fontSizeModel.iconSize, // Tamaño dinámico del ícono
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            title: Text(
              widget.receta == null ? 'Insertar Receta' : 'Editar Receta',
              style: TextStyle(
                fontSize: fontSizeModel.titleSize,
                color: themeModel.primaryTextColor,
              ),
            ),
            backgroundColor: themeModel.primaryButtonColor,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Nombre de la Receta',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: fontSizeModel.textSize,
                      color: themeModel.secondaryTextColor,
                    ),
                  ),
                ),
                TextField(
                  controller: _nombreController,
                  decoration: InputDecoration(
                    labelText: '',
                    labelStyle: TextStyle(
                      color: themeModel.secondaryTextColor,
                      fontSize: fontSizeModel.textSize,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: fontSizeModel.textSize,
                    color: themeModel.secondaryTextColor,
                  ),
                ),
                SizedBox(height: 20),
                if (estadoReceta == 'insert')
                  AgregarIngredientesWidget(key: _agregarIngredientesKey),
                if (estadoReceta == 'edit')
                  EditarIngredientesWidget(
                    key: _editarIngredientesKey,
                    idReceta: widget.receta!.idReceta!,
                  ),
                SizedBox(height: 20),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Descripción',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: fontSizeModel.textSize,
                      color: themeModel.secondaryTextColor,
                    ),
                  ),
                ),
                TextField(
                  controller: _descripcionController,
                  decoration: InputDecoration(
                    labelText: '',
                    labelStyle: TextStyle(
                      color: themeModel.secondaryTextColor,
                      fontSize: fontSizeModel.textSize,
                    ),
                  ),
                  maxLines: 5,
                  style: TextStyle(
                    fontSize: fontSizeModel.textSize,
                    color: themeModel.secondaryTextColor,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _guardarReceta(ingredientesProvider),
                  child: Text(widget.receta == null
                      ? 'Añadir Receta'
                      : 'Actualizar Receta'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 40),
                    backgroundColor: themeModel.primaryButtonColor,
                    foregroundColor: themeModel.primaryTextColor,
                    textStyle: TextStyle(
                      fontSize: fontSizeModel.subtitleSize,
                      color: themeModel.primaryTextColor,
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

  Future<void> _guardarIngredientes(
      int idReceta,
      List<IngredienteReceta> ingredientesEditados,
      List<Map<String, dynamic>> nuevosIngredientes) async {
    final ingredienteRepo = IngredienteRecetaRepository();

    // Primero, eliminamos todos los ingredientes existentes
    await ingredienteRepo.eliminarIngredientesPorReceta(idReceta);

    // Luego, insertamos los ingredientes editados
    if (ingredientesEditados.isNotEmpty) {
      await ingredienteRepo.insertarIngredientes(
          ingredientesEditados, idReceta);
    }

    // Finalmente, insertamos los nuevos ingredientes
    if (nuevosIngredientes.isNotEmpty) {
      final nuevosIngredientesReceta = nuevosIngredientes
          .map((ing) => IngredienteReceta(
                nombreIngrediente: ing['nombre'],
                costoIngrediente: 0,
                cantidadIngrediente: double.parse(ing['cantidad']),
                tipoUnidadIngrediente: ing['tipoUnidad'],
                idReceta: idReceta,
              ))
          .toList();

      await ingredienteRepo.insertarIngredientes(
          nuevosIngredientesReceta, idReceta);
    }

    CustomLogger().logInfo(
        'Ingredientes guardados: ${ingredientesEditados.length} editados, ${nuevosIngredientes.length} nuevos');
  }

  Future<void> _guardarReceta(
      IngredientesRecetasProvider ingredientesProvider) async {
    final recetaRepo = RecetaRepository();

    if (_nombreController.text.isEmpty || _descripcionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, completa todos los campos.')),
      );
      return;
    }

    final receta = Receta(
      idReceta: widget.receta?.idReceta,
      nombreReceta: _nombreController.text,
      descripcionReceta: _descripcionController.text,
      costoReceta: 0.0,
    );

    CustomLogger().logInfo('Receta a guardar: ${receta.toString()}');

    try {
      int id;
      if (widget.receta == null) {
        id = await recetaRepo.insertReceta(receta);
        final nuevosIngredientes =
            _agregarIngredientesKey.currentState?.obtenerIngredientes() ?? [];
        await _guardarIngredientes(id, [], nuevosIngredientes);
      } else {
        await recetaRepo.actualizarReceta(receta);
        id = receta.idReceta!;
        final ingredientesEditados = _editarIngredientesKey.currentState
                ?.obtenerIngredientesEditados() ??
            [];
        final nuevosIngredientes =
            _editarIngredientesKey.currentState?.obtenerNuevosIngredientes() ??
                [];
        await _guardarIngredientes(
            id, ingredientesEditados, nuevosIngredientes);
      }

      _nombreController.clear();
      _descripcionController.clear();
      _editarIngredientesKey.currentState?.limpiarIngredientes();
      _agregarIngredientesKey.currentState?.limpiarIngredientes();

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Receta guardada con éxito')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar la receta: $e')),
      );
    }
  }
}
