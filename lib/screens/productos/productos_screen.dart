import 'package:flutter/material.dart';
import 'package:DulcePrecision/screens/productos/agregar_producto_sc.dart';
import 'package:provider/provider.dart';
import 'package:DulcePrecision/models/font_size_model.dart';
import 'package:DulcePrecision/models/theme_model.dart';
import 'package:DulcePrecision/utils/productos_provider.dart'; // Import the ProductosProvider

class ProductosScreen extends StatefulWidget {
  @override
  _ProductosScreenState createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch products when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductosProvider>(context, listen: false).obtenerProductos();
    });
  }

  Future<void> _eliminarProducto(BuildContext context, int idProducto) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar este producto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await Provider.of<ProductosProvider>(context, listen: false).eliminarProducto(idProducto);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Producto eliminado con éxito!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar el producto: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);
    final fontSizeModel = Provider.of<FontSizeModel>(context);
    final productosProvider = Provider.of<ProductosProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeModel.primaryButtonColor,
        title: Text(
          'Productos',
          style: TextStyle(
            fontSize: fontSizeModel.titleSize,
            color: themeModel.primaryTextColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
              size: fontSizeModel.iconSize,
              color: themeModel.primaryIconColor,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InsertarProductosScreen(),
                ),
              ).then((_) => productosProvider.obtenerProductos());
            },
          ),
        ],
      ),
      body: Consumer<ProductosProvider>(
        builder: (context, provider, child) {
          if (provider.productos.isEmpty) {
            return Center(
              child: Text(
                'No hay productos disponibles',
                style: TextStyle(
                  fontSize: fontSizeModel.textSize,
                  color: themeModel.secondaryTextColor,
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: provider.productos.length,
            itemBuilder: (context, index) {
              final producto = provider.productos[index];

              return Card(
                elevation: 2,
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nombre: ${producto.nombreProducto}',
                              style: TextStyle(
                                fontSize: fontSizeModel.textSize,
                                color: themeModel.secondaryTextColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Precio: \$${producto.precioProducto.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: fontSizeModel.textSize,
                                color: themeModel.secondaryTextColor,
                              ),
                            ),
                            Text(
                              'Cantidad: ${producto.cantidadProducto} ${producto.tipoUnidadProducto}',
                              style: TextStyle(
                                fontSize: fontSizeModel.textSize,
                                color: themeModel.secondaryTextColor,
                              ),
                            ),
                            Text(
                              'Cantidad de unidades: ${producto.cantidadUnidadesProducto}',
                              style: TextStyle(
                                fontSize: fontSizeModel.textSize,
                                color: themeModel.secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      InsertarProductosScreen(producto: producto),
                                ),
                              ).then((_) => productosProvider.obtenerProductos());
                            },
                            child: Text(
                              'Editar',
                              style: TextStyle(
                                fontSize: fontSizeModel.textSize,
                                color: themeModel.secondaryTextColor,
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              _eliminarProducto(context, producto.idProducto!);
                            },
                            child: Text(
                              'Borrar',
                              style: TextStyle(
                                fontSize: fontSizeModel.textSize,
                                color: themeModel.secondaryTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}