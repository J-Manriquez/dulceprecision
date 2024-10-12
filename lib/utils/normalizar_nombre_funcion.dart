// Función para normalizar los nombres de ingredientes y productos
String normalizarNombre(String nombre) {
  return nombre.toLowerCase().replaceAll(' ', '');
}