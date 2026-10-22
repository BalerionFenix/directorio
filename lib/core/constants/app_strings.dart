/// Todos los textos de la app en un solo lugar.
abstract final class AppStrings {
  // General
  static const String appTitle = 'Directorio de contactos';

  // Lista
  static const String contactsTitle = 'Contactos';
  static const String searchHint = 'Buscar por nombre';
  static const String clearSearch = 'Limpiar búsqueda';
  static const String allDepartments = 'Todos';
  static const String filterByDepartment = 'FILTRAR POR DEPARTAMENTO';
  static const String filterByStatus = 'FILTRAR POR ESTADO';
  static const String allStatuses = 'Todos';
  static const String activePlural = 'Activos';
  static const String inactivePlural = 'Inactivos';
  static const String selectContact = 'Selecciona un contacto';
  static const String selectContactHint =
      'Elige un contacto de la lista para ver su información completa.';
  static String contactsCount(int count) =>
      count == 1 ? '1 contacto' : '$count contactos';

  // Métricas
  static const String metricTotal = 'TOTAL';
  static const String metricActive = 'ACTIVOS';
  static const String metricInactive = 'INACTIVOS';
  static const String metricFavorites = 'FAVORITOS';
  static const String metricTotalCaption = 'contactos';
  static const String metricFavoritesCaption = 'marcados';
  static String percentOfTotal(int percent) => '$percent % del total';

  // Departamentos del dataset
  static const String departmentCommercial = 'Comercial';
  static const String departmentDesign = 'Diseño';
  static const String departmentEngineering = 'Ingeniería';
  static const String departmentPeople = 'Personas';
  static const List<String> departments = [
    departmentCommercial,
    departmentDesign,
    departmentEngineering,
    departmentPeople,
  ];

  // Estado vacío
  static const String emptyTitle = 'No se encontraron contactos';
  static const String emptyNoFilters = 'No hay contactos para mostrar.';
  static const String clearFilters = 'Limpiar filtros';

  /// Mensaje de vacío según los filtros activos. Ej.:
  /// "Ningún contacto inactivo coincide con «pedro» en Diseño."
  static String emptyFor({String? query, String? department, bool? active}) {
    final hasQuery = query != null && query.trim().isNotEmpty;
    if (!hasQuery && department == null && active == null) {
      return emptyNoFilters;
    }
    final status = switch (active) {
      true => ' activo',
      false => ' inactivo',
      null => '',
    };
    final match = hasQuery ? ' coincide con «${query.trim()}»' : '';
    final inDepartment = department != null ? ' en $department' : '';
    return 'Ningún contacto$status$match$inDepartment.';
  }

  // Detalle
  static const String detailTitle = 'Detalle del contacto';
  static const String detailSheetTitle = 'FICHA DE COLABORADOR';
  static const String emailLabel = 'CORREO ELECTRÓNICO';
  static const String phoneLabel = 'TELÉFONO';
  static const String departmentLabel = 'DEPARTAMENTO';
  static const String back = 'Volver';
  static const String role = 'Rol';
  static const String department = 'Departamento';
  static const String email = 'Email';
  static const String phone = 'Teléfono';
  static const String status = 'Estado';
  static const String active = 'Activo';
  static const String inactive = 'Inactivo';
  static const String notFoundTitle = 'Contacto no encontrado';
  static const String notFoundMessage =
      'El contacto que buscas no existe o fue eliminado.';
  static const String backToList = 'Volver a la lista';

  // Favoritos
  static const String addFavorite = 'Marcar como favorito';
  static const String removeFavorite = 'Quitar de favoritos';

  // Error
  static const String errorTitle = 'Algo salió mal';
  static const String retry = 'Reintentar';
  static const String errorUnknown = 'Ocurrió un error inesperado.';
  static const String errorLoadContacts =
      'No se pudieron cargar los contactos. Revisa tu conexión e intenta de nuevo.';
  static const String errorLoadContact =
      'No se pudo cargar el contacto. Revisa tu conexión e intenta de nuevo.';
  static const String errorReadData =
      'Los datos de contactos tienen un formato inválido.';
  static const String errorPageNotFound = 'La página que buscas no existe.';
}
