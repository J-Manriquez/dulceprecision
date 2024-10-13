import 'package:DulcePrecision/widgets/agregar_ingrediente_widget.dart';
import 'package:DulcePrecision/widgets/tipo_unidad_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:DulcePrecision/models/db_model.dart';
import 'package:DulcePrecision/models/theme_model.dart';
import 'package:DulcePrecision/models/font_size_model.dart';
import 'package:DulcePrecision/database/metodos/ingredientes_recetas_mtd.dart';

class EditarIngredientesWidget extends StatefulWidget {
  final int idReceta;

  EditarIngredientesWidget({Key? key, required this.idReceta})
      : super(key: key);

  @override
  EditarIngredientesWidgetState createState() =>
      EditarIngredientesWidgetState();
}

class EditarIngredientesWidgetState extends State<EditarIngredientesWidget> {
  final IngredienteRecetaRepository _ingredienteRepo =
      IngredienteRecetaRepository();
  List<IngredienteReceta> _ingredientes = [];
  final GlobalKey<AgregarIngredientesWidgetState> _agregarIngredientesKey =
      GlobalKey();

  @override
  void initState() {
    super.initState();
    _cargarIngredientes();
  }

  Future<void> _cargarIngredientes() async {
    try {
      final ingredientes =
          await _ingredienteRepo.getAllIngredientesPorReceta(widget.idReceta);
      setState(() {
        _ingredientes = ingredientes;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar ingredientes: $e')),
      );
    }
  }

  // Método para obtener los ingredientes editados
  List<IngredienteReceta> obtenerIngredientesEditados() {
    return _ingredientes;
  }

  List<Map<String, dynamic>> obtenerNuevosIngredientes() {
    return _agregarIngredientesKey.currentState?.obtenerIngredientes() ?? [];
  }

  // Método para limpiar los ingredientes
  void limpiarIngredientes() {
    setState(() {
      _ingredientes.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);
    final fontSizeModel = Provider.of<FontSizeModel>(context);

    return Column(
      children: [
        // Text(
        //   '',
        //   style: TextStyle(
        //     fontSize: fontSizeModel.textSize,
        //     color: themeModel.secondaryTextColor,
        //   ),
        // ),
        SizedBox(height: 10),
        ..._ingredientes
            .map((ingrediente) =>
                _buildIngredienteItem(ingrediente, themeModel, fontSizeModel))
            .toList(),
        SizedBox(height: 20),
        AgregarIngredientesWidget(key: _agregarIngredientesKey),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildIngredienteItem(IngredienteReceta ingrediente,
      ThemeModel themeModel, FontSizeModel fontSizeModel) {
    final nombreController =
        TextEditingController(text: ingrediente.nombreIngrediente);
    final cantidadController =
        TextEditingController(text: ingrediente.cantidadIngrediente.toString());
    String tipoUnidad = ingrediente.tipoUnidadIngrediente;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            // TextField(
            //   controller: nombreController,
            //   decoration: InputDecoration(labelText: 'Nombre del Ingrediente'),
            //   style: TextStyle(
            //       fontSize: fontSizeModel.textSize,
            //       color: themeModel.secondaryTextColor),
            // ),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: nombreController,
                    decoration: InputDecoration(
                      labelText: 'Nombre del Ingrediente',
                      labelStyle: TextStyle(
                          color: themeModel
                              .secondaryTextColor // Color del label cuando no hay texto
                          ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: themeModel.secondaryButtonColor.withOpacity(
                              0.5), // Color del borde cuando está enfocado
                          width: 3.0, // Grosor del borde
                        ),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: themeModel
                              .secondaryTextColor, // Color del borde cuando está habilitado
                          width: 1.0, // Grosor del borde
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.remove_circle, color: themeModel.secondaryButtonColor.withOpacity(0.6)),
                  onPressed: () => _eliminarIngrediente(ingrediente.idIngrediente!),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: cantidadController,
                    decoration: InputDecoration(labelText: 'Cantidad'),
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                        fontSize: fontSizeModel.textSize,
                        color: themeModel.secondaryTextColor),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TipoUnidadDropdown(
                    initialValue: tipoUnidad, // Valor inicial para el dropdown
                    onChanged: (String newValue) {
                      setState(() {
                        tipoUnidad =
                            newValue; // Actualiza el tipo de unidad cuando cambia
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => _actualizarIngrediente(
                      ingrediente,
                      nombreController.text,
                      cantidadController.text,
                      tipoUnidad),
                  child: Text('Actualizar Ingrediente'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeModel.primaryButtonColor,
                    foregroundColor: themeModel.primaryTextColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
  }

  Future<void> _actualizarIngrediente(IngredienteReceta ingrediente,
      String nombre, String cantidad, String tipoUnidad) async {
    try {
      final ingredienteActualizado = IngredienteReceta(
        idIngrediente: ingrediente.idIngrediente,
        nombreIngrediente: nombre,
        costoIngrediente: ingrediente.costoIngrediente,
        cantidadIngrediente: double.parse(cantidad),
        tipoUnidadIngrediente: tipoUnidad,
        idReceta: widget.idReceta,
      );
      await _ingredienteRepo.actualizarIngrediente(ingredienteActualizado);
      await _cargarIngredientes();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ingrediente actualizado con éxito')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar ingrediente: $e')),
      );
    }
  }

  Future<void> _eliminarIngrediente(int idIngrediente) async {
    try {
      await _ingredienteRepo.eliminarIngrediente(idIngrediente);
      await _cargarIngredientes();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ingrediente eliminado con éxito')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar ingrediente: $e')),
      );
    }
  }
}
