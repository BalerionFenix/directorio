import '../../../data/models/contact.dart';

sealed class ContactsState {}

class ContactsInitial extends ContactsState {}

/// Cargando: la vista muestra skeletons.
class ContactsLoading extends ContactsState {
  final String query;
  final String? department;
  final bool? active;

  ContactsLoading({
    required this.query,
    required this.department,
    required this.active,
  });
}

/// Datos listos. Lo comparten [ContactsSuccess] y [ContactsEmpty].
sealed class ContactsLoaded extends ContactsState {
  /// Todos los contactos (para las métricas).
  final List<Contact> all;
  final String query;
  final String? department;

  /// `null` = todos, `true` = solo activos, `false` = solo inactivos.
  final bool? active;
  final Set<int> favoriteIds;

  ContactsLoaded({
    required this.all,
    required this.query,
    required this.department,
    required this.active,
    required this.favoriteIds,
  });

  int get activeCount => all.where((c) => c.active).length;
  int get favoriteCount => all.where((c) => favoriteIds.contains(c.id)).length;
  bool get hasFilters =>
      query.trim().isNotEmpty || department != null || active != null;

  /// Cambia cuando cambia cualquier filtro (sirve para reanimar la lista).
  String get filterKey => '$query|$department|$active';
}

/// Hay contactos que cumplen búsqueda + departamento + estado.
class ContactsSuccess extends ContactsLoaded {
  final List<Contact> visible;

  ContactsSuccess({
    required this.visible,
    required super.all,
    required super.query,
    required super.department,
    required super.active,
    required super.favoriteIds,
  });
}

/// Ningún contacto cumple los filtros: mensaje claro, nunca lista en blanco.
class ContactsEmpty extends ContactsLoaded {
  ContactsEmpty({
    required super.all,
    required super.query,
    required super.department,
    required super.active,
    required super.favoriteIds,
  });
}

/// Falló la carga: la vista redirige a /error con este mensaje.
class ContactsError extends ContactsState {
  final String message;

  ContactsError(this.message);
}
