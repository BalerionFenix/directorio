import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_strings.dart';
import '../../../data/repositories/contact_repository.dart';
import 'contact_detail_state.dart';

class ContactDetailCubit extends Cubit<ContactDetailState> {
  final ContactRepository _repository;

  /// `null` cuando el id de la URL no es un número.
  final int? _contactId;
  StreamSubscription<Set<int>>? _favoritesSub;

  ContactDetailCubit(this._repository, this._contactId)
    : super(ContactDetailInitial()) {
    // Si la estrella se marca desde la lista, la ficha se entera.
    _favoritesSub = _repository.favoritesChanges.listen((favorites) {
      final current = state;
      if (current is ContactDetailSuccess) {
        emit(
          ContactDetailSuccess(
            contact: current.contact,
            isFavorite: favorites.contains(current.contact.id),
          ),
        );
      }
    });
  }

  Future<void> loadContact() async {
    final id = _contactId;
    if (id == null) {
      emit(ContactDetailNotFound());
      return;
    }

    emit(ContactDetailLoading());
    try {
      final contact = await _repository.getContactById(id);
      if (isClosed) return;
      if (contact == null) {
        emit(ContactDetailNotFound());
        return;
      }
      final favorites = await _loadFavorites();
      if (isClosed) return;
      emit(
        ContactDetailSuccess(
          contact: contact,
          isFavorite: favorites.contains(contact.id),
        ),
      );
    } on ContactRepositoryException catch (e) {
      if (!isClosed) emit(ContactDetailError(e.message));
    } catch (_) {
      if (!isClosed) emit(ContactDetailError(AppStrings.errorLoadContact));
    }
  }

  Future<void> toggleFavorite() async {
    final current = state;
    if (current is! ContactDetailSuccess) return;

    // Se pinta al instante; el repositorio lo guarda y avisa a la lista.
    emit(
      ContactDetailSuccess(
        contact: current.contact,
        isFavorite: !current.isFavorite,
      ),
    );
    try {
      await _repository.toggleFavorite(current.contact.id);
    } catch (_) {
      // No se pudo guardar: se revierte.
      if (!isClosed) emit(current);
    }
  }

  Future<Set<int>> _loadFavorites() async {
    try {
      return await _repository.getFavoriteIds();
    } catch (_) {
      return {};
    }
  }

  @override
  Future<void> close() async {
    await _favoritesSub?.cancel();
    return super.close();
  }
}
