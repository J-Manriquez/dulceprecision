import 'package:DulcePrecision/utils/funciones/preciosIngredientes/ejecutar2doPlano.dart';
import 'package:DulcePrecision/menus/customNavigationBar.dart';
import 'package:DulcePrecision/menus/menuProductos.dart';
import 'package:DulcePrecision/menus/menuRecetas.dart';
import 'package:DulcePrecision/menus/menuVentas.dart';
import 'package:DulcePrecision/menus/principal_menu.dart';
import 'package:DulcePrecision/screens/recetas/agregar_receta_sc.dart';
import 'package:DulcePrecision/screens/recetas/recetas_screen.dart';
import 'package:DulcePrecision/screens/productos/productos_screen.dart';
import 'package:DulcePrecision/database/providers/ingredientes_provider.dart';
import 'package:DulcePrecision/database/providers/productos_provider.dart';
import 'package:DulcePrecision/database/providers/recetas_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/theme_model.dart'; // Importa el modelo de tema
import 'models/font_size_model.dart'; // Importa el modelo de tamaños de fuente
import 'screens/home_screen.dart'; // Importa la pantalla principal de inicio
import 'utils/custom_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

// ejecutar el Isolate con tareas en 2do plano
  await runBackgroundTasks(); // Ejecuta las tareas en segundo plano

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ThemeModel(), // Proveedor de colores
        ),
        ChangeNotifierProvider(
          create: (context) =>
              FontSizeModel(), // Proveedor de tamaños de fuente
        ),
        ChangeNotifierProvider(
            create: (_) => ProductosProvider()), // Proveer ProductosProvider
        ChangeNotifierProvider(create: (_) => RecetasProvider()),
        ChangeNotifierProvider(create: (_) => IngredientesRecetasProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  // Instancia del logger
  final CustomLogger customLogger = CustomLogger();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Oculta el banner de depuración
      title: 'Dulce Precisión', // Define el título de la aplicación
      theme: ThemeData(
        primarySwatch:
            Colors.blue, // Establece el tema principal de la app (colores)
      ),
      home: MainScreen(customLogger: customLogger), // Pasar customLogger
    );
  }
}

class MainScreen extends StatefulWidget {
  final CustomLogger customLogger; // Agregar este campo
  const MainScreen(
      {super.key,
      required this.customLogger}); // Asegúrate de requerir el parámetro

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1; // Índice seleccionado inicialmente (1 = HomeScreen)
  final List<Widget> _pages = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // Clave global para controlar el Scaffold

  // Lista de títulos que se mostrarán en el AppBar y Drawer
  final List<String> _pageTitles = [
    'Productos',
    'Ventas',
    'Recetas',
  ];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      ProductosScreen(),
      const HomeScreen(),
      RecetasScreen(),
    ]);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Actualiza el índice seleccionado
    });
  }

  // Método para navegar a InsertarRecetasScreen
  void _navegarAInsertarReceta(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InsertarRecetasScreen(),
      ),
    ).then((_) {
      // Luego de regresar, actualiza la lista de recetas
      Provider.of<RecetasProvider>(context, listen: false).obtenerRecetas();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context); // Obtenemos el modelo de tema
    final fontSizeModel = Provider.of<FontSizeModel>(context); // Obtenemos el modelo de tamaño de fuente

    // Actualizamos _floatingMenus para usar el método de navegación
    final List<Widget> _floatingMenus = [
      Row(
        children: [
          IconButton(
            icon: Icon(Icons.add, size: fontSizeModel.iconSize,
                color:  themeModel.primaryIconColor ), // Ícono específico para Productos
            onPressed: () {
              // Aquí iría la navegación para agregar un nuevo producto
            },
          ),
          MenuProductos(), // Menú flotante para Productos
        ],
      ),
      Row(
        children: [
          IconButton(
            icon: Icon(Icons.add, size: fontSizeModel.iconSize,
                color:  themeModel.primaryIconColor ), 
            onPressed: () {
              // Aquí iría la navegación para agregar una nueva venta
            },
          ),
          MenuVentas(), // Menú flotante para Ventas
        ],
      ),
      Row(
        children: [
          IconButton(
            icon: Icon(Icons.add, size: fontSizeModel.iconSize,
                color:  themeModel.primaryIconColor ),
            onPressed: () {
              _navegarAInsertarReceta(context); // Llama al método de navegación
            },
          ),
          MenuRecetas(), // Menú flotante para Recetas
        ],
      ),
    ];

    return Scaffold(
      key: _scaffoldKey, // Asigna el Scaffold al GlobalKey
      appBar: AppBar(
        backgroundColor: themeModel.primaryButtonColor, // Color dinámico para el AppBar
        leading: IconButton(
          icon: Icon(
            Icons.menu,
            size: fontSizeModel.iconSize, // Aplica el tamaño personalizado
            color: themeModel.primaryIconColor, // Aplica el color dinámico
          ),
          onPressed: () {
            // Abre el drawer utilizando el ScaffoldState a través del GlobalKey
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Text(
          _pageTitles[_selectedIndex], // Cambia el título según la pantalla seleccionada
          style: TextStyle(
            fontSize: fontSizeModel.titleSize, // Tamaño dinámico del texto del título
            color: themeModel.primaryTextColor, // Color dinámico del texto
          ),
        ),
        actions: <Widget>[
          _floatingMenus[_selectedIndex], // Cambia el menú flotante e ícono según la pantalla seleccionada
        ],
      ),
      drawer: PrincipalMenu(
        pageTitles: _pageTitles, // Pasa la lista de títulos al CustomDrawer
        selectedIndex: _selectedIndex, // Pasa el índice seleccionado al CustomDrawer
      ),
      body: Container(
        color: themeModel.backgroundColor,
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: CustomNavigationBar(
        selectedIndex: _selectedIndex, // Pasa el índice seleccionado al CustomBottomNavigationBar
        onItemTapped: _onItemTapped, // Pasa la función de callback para el cambio de índice
      ),
    );
  }
}
