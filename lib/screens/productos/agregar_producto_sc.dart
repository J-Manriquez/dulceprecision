import 'package:flutter/material.dart';
import 'package:DulcePrecision/database/metodos/productos_metodos.dart'; // Importamos el repositorio
import 'package:DulcePrecision/models/db_model.dart'; // Importamos el modelo Producto
import 'package:DulcePrecision/models/theme_model.dart'; // Importamos el modelo de tema
import 'package:DulcePrecision/models/font_size_model.dart'; // Importamos el modelo de tamaños de fuente
import 'package:provider/provider.dart'; // Importa Provider
import 'package:DulcePrecision/widgets/tipo_unidad_dropdown.dart'; // Asegúrate de importar el widget Dropdown que creamos

class InsertarProductosScreen extends StatefulWidget {
  final Producto? producto; // Se agrega el producto como parámetro opcional

  InsertarProductosScreen({this.producto}); // Constructor con parámetro

  @override
  _InsertProductScreenState createState() => _InsertProductScreenState();
}

class _InsertProductScreenState extends State<InsertarProductosScreen> {
  // Controladores para los campos del formulario
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _cantidadUnidadController = TextEditingController();

  String _tipoUnidadSeleccionada = 'gramos'; // Valor inicial para el tipo de unidad

  @override
  void initState() {
    super.initState();
    if (widget.producto != null) {
      // Si se está editando, se llenan los campos con los datos del producto
      _nombreController.text = widget.producto!.nombreProducto;
      _precioController.text = widget.producto!.precioProducto.toString();
      _cantidadController.text = widget.producto!.cantidadProducto.toString();
      _cantidadUnidadController.text = widget.producto!.cantidadUnidadesProducto.toString();
      _tipoUnidadSeleccionada = widget.producto!.tipoUnidadProducto; // Cargar tipo de unidad
    }
  }

  // Método para insertar o actualizar un producto en la base de datos
  Future<void> _guardarProducto() async {
    final productRepo = ProductRepository();

    // Validamos los campos antes de intentar guardar
    if (_nombreController.text.isEmpty ||
        _precioController.text.isEmpty ||
        _cantidadController.text.isEmpty ||
        _cantidadUnidadController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, completa todos los campos.')),
      );
      return;
    }

    // Intentamos convertir los campos a sus respectivos tipos
    final double? precioProducto = double.tryParse(_precioController.text);
    final double? cantidadProducto = double.tryParse(_cantidadController.text);  // Cambiado a double
    final double? cantidadUnidadesProducto = double.tryParse(_cantidadUnidadController.text); // Cambiado a double

    // Validamos que los valores ingresados sean válidos
    if (precioProducto == null || cantidadProducto == null || cantidadUnidadesProducto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, ingresa valores numéricos válidos.')),
      );
      return;
    }

    // Creamos un nuevo producto con los datos del formulario
    final producto = Producto(
      idProducto: widget.producto?.idProducto, // Usar ID si se está editando
      nombreProducto: _nombreController.text,
      precioProducto: precioProducto,
      cantidadProducto: cantidadProducto,
      tipoUnidadProducto: _tipoUnidadSeleccionada,
      cantidadUnidadesProducto: cantidadUnidadesProducto,
    );

    try {
      if (widget.producto == null) {
        // Si no hay producto, lo insertamos
        int id = await productRepo.insertProducto(producto);
        print("Producto insertado con ID: $id");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Producto insertado con éxito!')),
        );
      } else {
        // Si hay producto, lo actualizamos
        await productRepo.actualizarProducto(producto);
        print("Producto actualizado con ID: ${producto.idProducto}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Producto actualizado con éxito!')),
        );
      }

      // Limpiamos los campos del formulario
      _nombreController.clear();
      _precioController.clear();
      _cantidadController.clear();
      _cantidadUnidadController.clear();
    } catch (e) {
      // En caso de error, mostramos un mensaje
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar el producto: $e')),
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
          widget.producto == null ? 'Insertar Producto' : 'Editar Producto', // Cambiar el título
          style: TextStyle(
            fontSize: fontSizeModel.titleSize,
            color: themeModel.primaryTextColor,
          ),
        ),
        backgroundColor: themeModel.primaryButtonColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Campos del formulario
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(
                labelText: 'Nombre del Producto',
                labelStyle: TextStyle(
                  color: themeModel.secondaryTextColor,
                ),
              ),
              style: TextStyle(
                fontSize: fontSizeModel.textSize,
                color: themeModel.secondaryTextColor,
              ),
            ),
            TextField(
              controller: _precioController,
              decoration: InputDecoration(
                labelText: 'Precio del Producto',
                labelStyle: TextStyle(
                  color: themeModel.secondaryTextColor,
                ),
              ),
              keyboardType: TextInputType.number,
              style: TextStyle(
                fontSize: fontSizeModel.textSize,
                color: themeModel.secondaryTextColor,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _cantidadController,
                    decoration: InputDecoration(
                      labelText: 'Cantidad de Producto',
                      labelStyle: TextStyle(
                        color: themeModel.secondaryTextColor,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      fontSize: fontSizeModel.textSize,
                      color: themeModel.secondaryTextColor,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: TipoUnidadDropdown(
                    initialValue: _tipoUnidadSeleccionada,
                    onChanged: (newValue) {
                      setState(() {
                        _tipoUnidadSeleccionada = newValue;
                      });
                    },
                  ),
                ),
              ],
            ),
            TextField(
              controller: _cantidadUnidadController,
              decoration: InputDecoration(
                labelText: 'Cantidad de unidades del producto',
                labelStyle: TextStyle(
                  color: themeModel.secondaryTextColor,
                ),
              ),
              keyboardType: TextInputType.number,
              style: TextStyle(
                fontSize: fontSizeModel.textSize,
                color: themeModel.secondaryTextColor,
              ),
            ),
            SizedBox(height: 20),
            // Botón para guardar el producto
            ElevatedButton(
              onPressed: _guardarProducto,
              child: Text(widget.producto == null ? 'Añadir Producto' : 'Actualizar Producto'), // Cambiar el texto del botón
              style: ElevatedButton.styleFrom(
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
