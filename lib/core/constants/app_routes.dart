/// Rutas de la app. Se navega siempre con estas constantes.
abstract final class AppRoutes {
  // Paths
  static const String root = '/';
  static const String contacts = '/contacts';
  static const String contactDetail = '/contacts/:id';
  static const String error = '/error';

  // Nombres (para goNamed)
  static const String contactsName = 'contacts';
  static const String contactDetailName = 'contactDetail';
  static const String errorName = 'error';

  // Parámetros
  static const String idParam = 'id';
  static const String queryParam = 'q';
  static const String departmentParam = 'dept';
  static const String statusParam = 'status';
  static const String statusActive = 'activos';
  static const String statusInactive = 'inactivos';
  static const String messageParam = 'message';
  static const String fromParam = 'from';

  /// `?status=activos` → true, `?status=inactivos` → false, otro valor → null (todos).
  static bool? parseStatus(String? value) => switch (value) {
    statusActive => true,
    statusInactive => false,
    _ => null,
  };

  /// Path del detalle de un contacto: `/contacts/7`.
  static String contactDetailPath(int id) => '$contacts/$id';

  /// Path de la vista de error: `/error?message=...&from=/contacts`.
  static String errorPath({required String message, required String from}) {
    return Uri(
      path: error,
      queryParameters: {messageParam: message, fromParam: from},
    ).toString();
  }

  /// Marca (`extra`) que indica que la app llevó al error en esta sesión.
  /// Si se llega a /error sin ella (recargar la página, escribir la URL o
  /// volver con el historial), el router reintenta la ruta `from`.
  static const String errorShownInApp = 'error-shown-in-app';

  /// Query params de los filtros de la lista (solo los que están activos).
  static Map<String, String> filterParams({
    String query = '',
    String? department,
    bool? active,
  }) => {
    if (query.isNotEmpty) queryParam: query,
    departmentParam: ?department,
    if (active != null) statusParam: active ? statusActive : statusInactive,
  };

  /// `path` + query params, sin `?` si no hay ninguno.
  static String withParams(String path, Map<String, String> params) => Uri(
    path: path,
    queryParameters: params.isEmpty ? null : params,
  ).toString();

  /// Solo se permite volver a rutas internas de la app (nunca a otra web ni a /error).
  static String safeReturnPath(String? from) {
    if (from == null || !from.startsWith('/') || from.startsWith('//')) {
      return contacts;
    }
    if (Uri.parse(from).path == error) return contacts;
    return from;
  }
}
