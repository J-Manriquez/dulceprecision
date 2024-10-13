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
                TextField(
                  controller: _nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre de la Receta',
                    labelStyle: TextStyle(
                      color: themeModel.secondaryTextColor,
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
                TextField(
                  controller: _descripcionController,
                  decoration: InputDecoration(
                    labelText: 'Descripción',
                    labelStyle: TextStyle(
                      color: themeModel.secondaryTextColor,
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

  Future<void> _guardarIngredientes(int idReceta, List<IngredienteReceta> ingredientesEditados, List<Map<String, dynamic>> nuevosIngredientes) async {
    final ingredienteRepo = IngredienteRecetaRepository();

    // Primero, eliminamos todos los ingredientes existentes
    await ingredienteRepo.eliminarIngredientesPorReceta(idReceta);

    // Luego, insertamos los ingredientes editados
    if (ingredientesEditados.isNotEmpty) {
      await ingredienteRepo.insertarIngredientes(ingredientesEditados, idReceta);
    }

    // Finalmente, insertamos los nuevos ingredientes
    if (nuevosIngredientes.isNotEmpty) {
      final nuevosIngredientesReceta = nuevosIngredientes.map((ing) => IngredienteReceta(
        nombreIngrediente: ing['nombre'],
        costoIngrediente: 0, // Ajusta esto según tus necesidades
        cantidadIngrediente: double.parse(ing['cantidad']),
        tipoUnidadIngrediente: ing['tipoUnidad'],
        idReceta: idReceta,
      )).toList();

      await ingredienteRepo.insertarIngredientes(nuevosIngredientesReceta, idReceta);
    }

    CustomLogger().logInfo('Ingredientes guardados: ${ingredientesEditados.length} editados, ${nuevosIngredientes.length} nuevos');
  }

  Future<void> _guardarReceta(
      IngredientesRecetasProvider ingredientesProvider) async {
    // Crear instancias de los repositorios para manejar las recetas y los ingredientes.
    final recetaRepo = RecetaRepository();

    // Verificar que los campos de nombre y descripción no estén vacíos.
    if (_nombreController.text.isEmpty || _descripcionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, completa todos los campos.')),
      );
      return; // Salir de la función si los campos están vacíos.
    }

    // Crear un objeto Receta con los datos proporcionados por el usuario.
    final receta = Receta(
      idReceta: widget.receta?.idReceta, // Si existe, asignar el ID existente.
      nombreReceta: _nombreController
          .text, // Nombre de la receta ingresado por el usuario.
      descripcionReceta: _descripcionController
          .text, // Descripción de la receta ingresada por el usuario.
      costoReceta:
          0.0, // Costo inicial de la receta, se puede calcular más tarde.
    );

    // Log de información sobre la receta antes de guardar.
    CustomLogger().logInfo('Receta a guardar: ${receta.toString()}');

    try {
      int id;
      if (widget.receta == null) {
        id = await recetaRepo.insertReceta(receta);
        // Para nuevas recetas, solo obtenemos los nuevos ingredientes
        final nuevosIngredientes = _agregarIngredientesKey.currentState?.obtenerIngredientes() ?? [];
        await _guardarIngredientes(id, [], nuevosIngredientes);
      } else {
        await recetaRepo.actualizarReceta(receta);
        id = receta.idReceta!;
        // Para recetas existentes, obtenemos tanto los editados como los nuevos
        final ingredientesEditados = _editarIngredientesKey.currentState?.obtenerIngredientesEditados() ?? [];
        final nuevosIngredientes = _editarIngredientesKey.currentState?.obtenerNuevosIngredientes() ?? [];
        await _guardarIngredientes(id, ingredientesEditados, nuevosIngredientes);
      }

      // Obtener ingredientes editados y nuevos.
      final ingredientesEditados = _editarIngredientesKey.currentState?.obtenerIngredientesEditados() ?? [];

      CustomLogger().logInfo('ingredientesEditados a guardar: ${ingredientesEditados.toString()}');

      final nuevosIngredientes = _editarIngredientesKey.currentState?.obtenerNuevosIngredientes() ?? [];

      CustomLogger().logInfo('nuevosIngredientes a guardar: ${nuevosIngredientes.toString()}');

      // Limpiar los controladores de texto y los estados de los ingredientes.
      _nombreController.clear();
      _descripcionController.clear();
      _editarIngredientesKey.currentState?.limpiarIngredientes();
      _agregarIngredientesKey.currentState?.limpiarIngredientes();

      // Mostrar un mensaje de éxito al guardar la receta.
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Receta guardada con éxito')));
    } catch (e) {
      // Mostrar un mensaje de error en caso de excepciones.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar la receta: $e')),
      );
    }
  }
}

