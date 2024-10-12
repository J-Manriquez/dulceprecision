// Función para transformar el tipo de unidad
double transformarUnidad(double cantidad, String unidadOrigen, String unidadDestino) {
  if (unidadOrigen == unidadDestino) return cantidad;

  switch (unidadOrigen) {
    case 'gramos':
      if (unidadDestino == 'kilogramos') return cantidad / 1000;
      break;
    case 'kilogramos':
      if (unidadDestino == 'gramos') return cantidad * 1000;
      break;
    case 'mililitros':
      if (unidadDestino == 'litros') return cantidad / 1000;
      break;
    case 'litros':
      if (unidadDestino == 'mililitros') return cantidad * 1000;
      break;
  }

  throw Exception('No se puede transformar de $unidadOrigen a $unidadDestino');
}
