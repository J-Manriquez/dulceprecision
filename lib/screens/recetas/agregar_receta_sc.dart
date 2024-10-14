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
  // Variables para almacenar la información original de la receta e ingredientes
  Receta? _recetaOriginal;
  List<IngredienteReceta> _ingredientesOriginales = [];

  @override
  void initState() {
    super.initState();
    if (widget.receta != null) {
      estadoReceta = 'edit';
      _recetaOriginal = Receta(
        idReceta: widget.receta!.idReceta,
        nombreReceta: widget.receta!.nombreReceta,
        descripcionReceta: widget.receta!.descripcionReceta,
        costoReceta: widget.receta!.costoReceta,
      );
      _nombreController.text = widget.receta!.nombreReceta;
      _descripcionController.text = widget.receta!.descripcionReceta!;
      _costoController.text = widget.receta!.costoReceta.toString();

      // Cargar ingredientes originales para la edición
      _cargarIngredientesOriginales(widget.receta!.idReceta!);
    } else {
      estadoReceta = 'insert';
    }
  }

  Future<void> _cargarIngredientesOriginales(int idReceta) async {
    final ingredienteRepo = IngredienteRecetaRepository();
    _ingredientesOriginales =
        await ingredienteRepo.getAllIngredientesPorReceta(idReceta);
    // Imprime los ingredientes cargados para verificar su valor
    for (var ingrediente in _ingredientesOriginales) {
      print(
          'Ingrediente cargado: ${ingrediente.nombreIngrediente}, TipoUnidad: ${ingrediente.tipoUnidadIngrediente}');
    }
    CustomLogger().logInfo('ingredientes cargados $_ingredientesOriginales');
  }

  Future<void> restaurarReceta(int idReceta) async {
    CustomLogger().logInfo('Restaurando receta con ID: $idReceta');

    final recetaRepo = RecetaRepository();
    final ingredienteRepo = IngredienteRecetaRepository();

    try {
      // Verificamos si existe una copia original de la receta y sus ingredientes
      if (_recetaOriginal == null || _ingredientesOriginales.isEmpty) {
        CustomLogger().logError(
            'No se ha guardado una copia original de la receta para restaurar.');
        throw Exception('No hay datos originales para restaurar.');
      }
    } catch (e) {
      CustomLogger().logError('Error al restaurar la receta: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al restaurar la receta: $e')),
      );
    }

    try {
      // Primero, eliminamos los ingredientes actuales de la receta en la base de datos
      await ingredienteRepo.eliminarIngredientesPorReceta(idReceta);
      CustomLogger().logInfo('eliminando ingredientes');
    } catch (e) {
      CustomLogger().logError('Error al restaurar la receta: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al restaurar la receta: $e')),
      );
    }

    try {
      // Luego, eliminamos la receta actual
      await recetaRepo.eliminarReceta(idReceta);
      CustomLogger().logInfo('eliminando receta');
    } catch (e) {
      CustomLogger().logError('Error al restaurar la receta: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al restaurar la receta: $e')),
      );
    }

    try {
      // Insertamos la receta original nuevamente
      await recetaRepo.insertReceta(_recetaOriginal!);
      CustomLogger().logInfo('receta original insertada $_recetaOriginal');
    } catch (e) {
      CustomLogger().logError('Error al restaurar la receta: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al restaurar la receta: $e')),
      );
    }

    try {
      // Insertamos los ingredientes originales nuevamente
      await ingredienteRepo.insertarIngredientes(
          _ingredientesOriginales, _recetaOriginal!.idReceta!);
    } catch (e) {
      CustomLogger().logError('Error al restaurar la receta: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al restaurar la receta: $e')),
      );
    }

    CustomLogger().logInfo(
        'La receta y sus ingredientes han sido restaurados correctamente en la base de datos.');
    // } catch (e) {
    //   CustomLogger().logError('Error al restaurar la receta: $e');
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Error al restaurar la receta: $e')),
    //   );
    // }
  }

  Future<bool> _mostrarDialogoConfirmacion(BuildContext context) async {
    final themeModel = Provider.of<ThemeModel>(context, listen: false);
    final fontSizeModel = Provider.of<FontSizeModel>(context, listen: false);

    return await showDialog<bool>(
          context: context,
          builder: (context) => Dialog(
            // Cambiamos AlertDialog por Dialog para mantener la consistencia
            child: Container(
              // width: MediaQuery.of(context).size.width *
              //     , // Ancho en 80% de la pantalla
              height: MediaQuery.of(context).size.height *
                  0.4, // Alto en 60% de la pantalla
              decoration: BoxDecoration(
                color: themeModel.backgroundColor, // Color de fondo del modal
                borderRadius: BorderRadius.circular(20), // Esquinas redondeadas
              ),
              child: Padding(
                padding: const EdgeInsets.all(
                    16.0), // Padding alrededor del contenido
                child: Column(
                  mainAxisSize: MainAxisSize
                      .min, // Ajusta el tamaño del modal al contenido
                  crossAxisAlignment: CrossAxisAlignment
                      .stretch, // Estira los hijos para ocupar todo el ancho
                  children: [
                    Text(
                      'Conservar receta',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: fontSizeModel.titleSize,
                        color: themeModel.primaryTextColor,
                      ),
                    ),
                    SizedBox(
                        height: 10), // Espacio entre el título y el contenido
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
                    SizedBox(
                        height: 20), // Espacio entre el contenido y los botones
                    Row(
                      mainAxisAlignment: MainAxisAlignment
                          .spaceEvenly, // Alinea los botones en el centro
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
                            onPressed: () => Navigator.of(context)
                                .pop(false), // Cierra el modal y retorna false
                          ),
                        ),
                        SizedBox(width: 10), // Espacio entre los botones
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
        ) ??
        false; // Retorna false si se cierra sin selección
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
                onPressed: () async {
                  if (widget.receta != null) {
                    bool confirm = await _mostrarDialogoConfirmacion(context);
                    if (confirm) {
                      await restaurarReceta(widget.receta!.idReceta!);
                      Navigator.of(context).pop();
                    }
                  } else {
                    Navigator.of(context).pop();
                  }
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
                  onPressed: () => {
                    _guardarReceta(ingredientesProvider),
                    Navigator.of(context).pop()
                  },
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
