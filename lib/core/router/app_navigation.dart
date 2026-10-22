import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_routes.dart';

/// Atajos de navegación de la app.
extension AppNavigation on BuildContext {
  /// URL actual (ruta + query params).
  Uri get currentUri =>
      GoRouter.of(this).routerDelegate.currentConfiguration.uri;

  /// Navega sin agregar una entrada al historial del navegador: reemplaza la
  /// actual. Se usa para el error, el reintento y los filtros de la URL.
  void goReplacing(String location, {Object? extra}) {
    Router.neglect(this, () => go(location, extra: extra));
  }

  /// Lleva a la vista de error recordando la ruta actual, para volver a ella
  /// al presionar "Reintentar" o al recargar la página.
  ///
  /// - Reemplaza la entrada del historial: el error no queda como un lugar al
  ///   que "volver" con el botón atrás.
  /// - Si ya estamos en /error no hace nada: cuando falla la carga, la lista y
  ///   el detalle reciben el mismo error y solo la primera debe redirigir.
  void goToError(String message) {
    final current = currentUri;
    if (current.path == AppRoutes.error) return;
    goReplacing(
      AppRoutes.errorPath(message: message, from: current.toString()),
      extra: AppRoutes.errorShownInApp,
    );
  }
}
