import 'package:DulcePrecision/database/metodos/ingredientes_recetas_mtd.dart';
import 'package:DulcePrecision/widgets/agregar_ingrediente_widget.dart';
import 'package:flutter/material.dart';
import 'package:DulcePrecision/database/metodos/recetas_metodos.dart'; // Importamos el repositorio
import 'package:DulcePrecision/models/db_model.dart'; // Importamos el modelo Receta
import 'package:DulcePrecision/models/theme_model.dart'; // Importamos el modelo de tema
import 'package:DulcePrecision/models/font_size_model.dart'; // Importamos el modelo de tamaños de fuente
import 'package:provider/provider.dart'; // Importa Provider
// Importa el nuevo widget para agregar ingredientes

class InsertarRecetasScreen extends StatefulWidget {
  final Receta? receta; // Se agrega la receta como parámetro opcional

  InsertarRecetasScreen({this.receta}); // Constructor con parámetro

  @override
  _InsertarRecetasScreenState createState() => _InsertarRecetasScreenState();
}

class _InsertarRecetasScreenState extends State<InsertarRecetasScreen> {
  // Controladores para los campos del formulario
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _costoController =
      TextEditingController(); // Este se mantiene por si se necesita en el futuro

  final GlobalKey<AgregarIngredientesWidgetState> _ingredientesKey =
      GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.receta != null) {
      // Si se está editando, se llenan los campos con los datos de la receta
      _nombreController.text = widget.receta!.nombreReceta;
      _descripcionController.text = widget.receta!.descripcionReceta!;
      _costoController.text = widget.receta!.costoReceta
          .toString(); // Esto puede no ser necesario mostrarlo.
    }
  }

  // Método para insertar o actualizar una receta en la base de datos
  Future<void> _guardarReceta() async {
    final recetaRepo = RecetaRepository();
    final ingredienteRepo = IngredienteRecetaRepository();

    // Validamos los campos antes de intentar guardar
    if (_nombreController.text.isEmpty || _descripcionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, completa todos los campos.')),
      );
      return;
    }

    // Creamos una nueva receta con los datos del formulario
    final receta = Receta(
      idReceta: widget.receta?.idReceta,
      nombreReceta: _nombreController.text,
      descripcionReceta: _descripcionController.text,
      costoReceta: 0.0,
    );

    try {
      int id;
      if (widget.receta == null) {
        // Si es una nueva receta, insertamos y obtenemos el id
        id = await recetaRepo.insertReceta(receta);
      } else {
        // Si es una receta existente, la actualizamos
        await recetaRepo.actualizarReceta(receta);
        id = receta.idReceta!; // Asegúrate de que idReceta no sea null
      }

      // Guardar ingredientes
      // Convertimos la lista de ingredientes a una lista de objetos IngredienteReceta
      final ingredientes =
          _ingredientesKey.currentState?.obtenerIngredientes() ?? [];

      // Convert ingredients to IngredienteReceta objects
      List<IngredienteReceta> listaIngredientes =
          ingredientes.map((ingredienteMap) {
        return IngredienteReceta(
          nombreIngrediente: ingredienteMap['nombre'],
          costoIngrediente:
              0, // You might want to add a field for this in AgregarIngredientesWidget
          cantidadIngrediente: double.parse(ingredienteMap['cantidad']),
          tipoUnidadIngrediente: ingredienteMap['tipoUnidad'],
          idReceta: id,
        );
      }).toList();

      // Llamamos a la función para insertar todos los ingredientes
      await ingredienteRepo.insertarIngredientes(listaIngredientes, id);

      // Limpiamos los campos del formulario
      _nombreController.clear();
      _descripcionController.clear();
      _ingredientesKey.currentState?.limpiarIngredientes();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Receta guardada con éxito'))
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar la receta: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtiene el modelo de tema y de tamaño de fuente
    final themeModel = Provider.of<ThemeModel>(context);
    final fontSizeModel = Provider.of<FontSizeModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.receta == null
              ? 'Insertar Receta'
              : 'Editar Receta', // Cambiar el título
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
            // Campo para el nombre de la receta
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
            SizedBox(height: 20), // Espacio entre el nombre y los ingredientes

            // Widget para añadir ingredientes
            AgregarIngredientesWidget(key: _ingredientesKey), // Aquí se añade el widget de ingredientes

            SizedBox(
                height: 20), // Espacio entre los ingredientes y la descripción

            // Campo para la descripción
            TextField(
              controller: _descripcionController,
              decoration: InputDecoration(
                labelText: 'Descripción',
                labelStyle: TextStyle(
                  color: themeModel.secondaryTextColor,
                ),
              ),
              maxLines: 5, // Permite múltiples líneas
              style: TextStyle(
                fontSize: fontSizeModel.textSize,
                color: themeModel.secondaryTextColor,
              ),
            ),
            SizedBox(height: 20), // Espacio antes del botón

            // Botón para guardar la receta
            ElevatedButton(
              onPressed: _guardarReceta,
              child: Text(widget.receta == null
                  ? 'Añadir Receta'
                  : 'Actualizar Receta'), // Cambiar el texto del botón
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
  }
}
