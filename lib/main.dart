import 'package:DulcePrecision/screens/recetas/recetas_screen.dart';
import 'package:DulcePrecision/screens/settings_screen.dart';
import 'package:DulcePrecision/screens/productos/productos_screen.dart';
import 'package:DulcePrecision/utils/productos_provider.dart';
import 'package:DulcePrecision/utils/recetas_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/theme_model.dart'; // Importa el modelo de tema
import 'models/font_size_model.dart'; // Importa el modelo de tamaños de fuente
// import 'services/db_adam.dart'; // Importa DatabaseHelper
import 'screens/home_screen.dart'; // Importa la pantalla principal de inicio
import 'utils/custom_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializamos la base de datos
  // await DatabaseHelper().database; // Aquí se llama a la base de datos que se inicializa de acuerdo al entorno

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
        ChangeNotifierProvider(
            create: (_) => RecetasProvider()),
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
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // Clave global para controlar el Scaffold

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
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeModel =
        Provider.of<ThemeModel>(context); // Obtenemos el modelo de tema
    final fontSizeModel = Provider.of<FontSizeModel>(
        context); // Obtenemos el modelo de tamaño de fuente

    return Scaffold(
      key: _scaffoldKey, // Asigna el Scaffold al GlobalKey
      appBar: AppBar(
        backgroundColor:
            themeModel.primaryButtonColor, // Color dinámico para el AppBar
        // Personaliza el ícono de menú (drawer) con el tamaño que quieras
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
          'Dulce Precisión',
          style: TextStyle(
            fontSize:
                fontSizeModel.titleSize, // Tamaño dinámico del texto del título
            color: themeModel.primaryTextColor, // Color dinámico del texto
          ),
        ),
      ),
      drawer: Drawer(
        backgroundColor:
            themeModel.backgroundColor, // Color dinámico para el Drawer
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: themeModel
                    .primaryButtonColor, // Color dinámico en el header del Drawer
              ),
              child: Row(
                // Alineación horizontal de los elementos dentro de la fila
                mainAxisAlignment: MainAxisAlignment
                    .start, // Centra horizontalmente el contenido
                // Alineación vertical de los elementos dentro de la fila
                crossAxisAlignment: CrossAxisAlignment
                    .start, // Centra verticalmente el contenido
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back,
                        color: themeModel.primaryIconColor),
                    iconSize:
                        fontSizeModel.iconSize, // Tamaño dinámico del ícono
                    onPressed: () {
                      Navigator.of(context).pop(); // Cierra el Drawer
                    },
                  ),
                  SizedBox(width: 8), // Espacio entre el ícono y el texto
                  Text(
                    'Menú principal',
                    style: TextStyle(
                      color: themeModel
                          .primaryTextColor, // Color dinámico del texto
                      fontSize:
                          fontSizeModel.titleSize, // Tamaño dinámico del texto
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.settings,
                  size: fontSizeModel.iconSize,
                  color: themeModel
                      .secondaryIconColor), // Ícono con tamaño dinámico
              title: Text(
                'Configuraciones',
                style: TextStyle(
                  color:
                      themeModel.secondaryTextColor, // Color dinámico del texto
                  fontSize: fontSizeModel.textSize, // Tamaño dinámico del texto
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const SettingsScreen()), // Navega a SettingsScreen
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.info,
                  size: fontSizeModel.iconSize,
                  color: themeModel
                      .secondaryIconColor), // Ícono con tamaño dinámico
              title: Text(
                'Acerca de',
                style: TextStyle(
                  color:
                      themeModel.secondaryTextColor, // Color dinámico del texto
                  fontSize: fontSizeModel.textSize, // Tamaño dinámico del texto
                ),
              ),
              onTap: () {
                // Implementa la navegación a la pantalla "Acerca de"
              },
            ),
          ],
        ),
      ),
      body: Container(
        color: themeModel.backgroundColor, // Color de fondo dinámico
        child: _pages[
            _selectedIndex], // Cambia la página según el índice seleccionado
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.add_business,
                size: fontSizeModel.iconSize), // Ícono con tamaño dinámico
            label: 'Productos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart,
                size: fontSizeModel.iconSize), // Ícono con tamaño dinámico
            label: 'Ventas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant,
                size: fontSizeModel.iconSize), // Ícono con tamaño dinámico
            label: 'Recetas',
          ),
        ],
        currentIndex: _selectedIndex, // Índice seleccionado
        selectedItemColor: themeModel
            .secondaryButtonColor, // Color dinámico del ítem seleccionado
        unselectedItemColor:
            themeModel.primaryIconColor, // Color para ítems no seleccionados
        backgroundColor:
            themeModel.primaryButtonColor, // Color de fondo dinámico
        showUnselectedLabels: true,
        // Modifica el tamaño del texto de los labels
        selectedLabelStyle: TextStyle(
          fontSize:
              fontSizeModel.textSize, // Tamaño dinámico del texto seleccionado
          color: themeModel.secondaryIconColor, // Color del texto seleccionado
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: fontSizeModel.textSize -
              2, // Tamaño dinámico del texto no seleccionado
          color: themeModel.primaryIconColor, // Color del texto no seleccionado
        ),
        onTap:
            _onItemTapped, // Método que se llama cuando se selecciona un ítem
      ),
    );
  }
}
