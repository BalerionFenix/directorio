import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_strings.dart';
import '../../../data/models/contact.dart';
import '../../../data/repositories/contact_repository.dart';
import 'contacts_state.dart';

class ContactsCubit extends Cubit<ContactsState> {
  final ContactRepository _repository;
  StreamSubscription<Set<int>>? _favoritesSub;

  List<Contact> _all = const [];
  Set<int> _favorites = {};
  String _query;
  String? _department;
  bool? _active;

  ContactsCubit(
    this._repository, {
    this._query = '',
    String? department,
    this._active,
  }) : _department = AppStrings.departments.contains(department)
           ? department
           : null,
       super(ContactsInitial()) {
    // Si el detalle marca un favorito, la lista se entera.
    _favoritesSub = _repository.favoritesChanges.listen((favorites) {
      _favorites = {...favorites};
      if (state is ContactsLoaded) _emitFiltered();
    });
  }

  Future<void> loadContacts() async {
    emit(
      ContactsLoading(query: _query, department: _department, active: _active),
    );
    try {
      _all = await _repository.getContacts();
      _favorites = await _loadFavorites();
      _emitFiltered();
    } on ContactRepositoryException catch (e) {
      emit(ContactsError(e.message));
    } catch (_) {
      emit(ContactsError(AppStrings.errorLoadContacts));
    }
  }

  /// Búsqueda en tiempo real por nombre.
  void search(String query) {
    _query = query;
    if (state is ContactsLoaded) _emitFiltered();
  }

  /// `null` = "Todos".
  void filterByDepartment(String? department) {
    _department = department;
    if (state is ContactsLoaded) _emitFiltered();
  }

  /// `null` = todos, `true` = activos, `false` = inactivos.
  void filterByStatus(bool? active) {
    _active = active;
    if (state is ContactsLoaded) _emitFiltered();
  }

  /// Aplica los tres filtros de una vez (ej. cuando cambian los query params).
  void applyFilters({String query = '', String? department, bool? active}) {
    _query = query;
    _department = AppStrings.departments.contains(department)
        ? department
        : null;
    _active = active;
    if (state is ContactsLoaded) _emitFiltered();
  }

  /// Restablece búsqueda, departamento y estado.
  void clearFilters() {
    _query = '';
    _department = null;
    _active = null;
    if (state is ContactsLoaded) _emitFiltered();
  }

  Future<void> toggleFavorite(int id) async {
    if (state is! ContactsLoaded) return;
    // Se pinta al instante; el repositorio lo guarda en el storage.
    _favorites = {..._favorites}..toggle(id);
    _emitFiltered();
    try {
      _favorites = await _repository.toggleFavorite(id);
    } catch (_) {
      // No se pudo guardar: se revierte.
      _favorites = {..._favorites}..toggle(id);
    }
    if (!isClosed && state is ContactsLoaded) _emitFiltered();
  }

  /// Si el storage no responde, la lista igual se muestra (sin favoritos).
  Future<Set<int>> _loadFavorites() async {
    try {
      return await _repository.getFavoriteIds();
    } catch (_) {
      return {};
    }
  }

  void _emitFiltered() {
    final needle = normalize(_query.trim());
    final visible = _all.where((contact) {
      final matchesName =
          needle.isEmpty || normalize(contact.name).contains(needle);
      final matchesDepartment =
          _department == null || contact.department == _department;
      final matchesStatus = _active == null || contact.active == _active;
      return matchesName && matchesDepartment && matchesStatus;
    }).toList();

    if (visible.isEmpty) {
      emit(
        ContactsEmpty(
          all: _all,
          query: _query,
          department: _department,
          active: _active,
          favoriteIds: _favorites,
        ),
      );
    } else {
      emit(
        ContactsSuccess(
          visible: visible,
          all: _all,
          query: _query,
          department: _department,
          active: _active,
          favoriteIds: _favorites,
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _favoritesSub?.cancel();
    return super.close();
  }

  /// Minúsculas y sin tildes: "Matías" → "matias", "Muñoz" → "munoz".
  static String normalize(String text) {
    const from = 'áàäâãéèëêíìïîóòöôõúùüûñç';
    const to = 'aaaaaeeeeiiiiooooouuuunc';
    final buffer = StringBuffer();
    for (final char in text.toLowerCase().split('')) {
      final i = from.indexOf(char);
      buffer.write(i == -1 ? char : to[i]);
    }
    return buffer.toString();
  }
}

extension on Set<int> {
  void toggle(int id) {
    if (!remove(id)) add(id);
  }
}
