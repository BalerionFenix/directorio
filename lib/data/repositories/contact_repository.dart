import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_strings.dart';
import '../models/contact.dart';

/// Error que lanza el repositorio. El cubit lo convierte en un estado de error.
class ContactRepositoryException implements Exception {
  final String message;

  const ContactRepositoryException(this.message);

  @override
  String toString() => message;
}

/// Acceso a los contactos (simula una llamada de red local) y a los favoritos.
///
/// - **Una llamada = una carga de la lista** ([getContacts]): espera 800 ms y
///   falla en la llamada 2 y luego una de cada 4 (2, 6, 10…).
/// - El detalle ([getContactById]) **no cuenta**: toma el contacto de la última
///   carga exitosa (caché) o espera la carga de la lista que está en curso.
/// - El contador se guarda en el storage del navegador, así sigue contando
///   aunque se recargue la página (si no hay storage, cuenta en memoria).
class ContactRepository {
  static const String _favoritesKey = 'favorite_contact_ids';
  static const String _callCountKey = 'contact_call_count';

  final AssetBundle _bundle;
  final SharedPreferencesAsync? _prefsOverride;
  late final SharedPreferencesAsync _prefs =
      _prefsOverride ?? SharedPreferencesAsync();
  final _favoritesController = StreamController<Set<int>>.broadcast();

  int _callCount = 0;

  /// Última carga exitosa de la lista (dura lo que dura la sesión de la página).
  List<Contact>? _cache;

  /// Carga de la lista en curso: si el detalle pide datos mientras tanto,
  /// espera esta misma llamada en vez de hacer otra.
  Future<List<Contact>>? _inFlight;

  ContactRepository({AssetBundle? bundle, SharedPreferencesAsync? prefs})
    : _bundle = bundle ?? rootBundle,
      _prefsOverride = prefs;

  /// Emite los favoritos cada vez que cambian, para sincronizar lista y detalle.
  Stream<Set<int>> get favoritesChanges => _favoritesController.stream;

  /// Carga la lista: cuenta como una llamada, espera 800 ms y puede fallar.
  /// Si ya hay una carga en curso, devuelve esa misma (no cuenta dos veces).
  Future<List<Contact>> getContacts() {
    return _inFlight ??= _simulateCall().whenComplete(() => _inFlight = null);
  }

  /// Devuelve un contacto por id, o `null` si no existe. No cuenta como llamada:
  /// usa la caché o espera la carga de la lista en curso.
  Future<Contact?> getContactById(int id) async {
    final contacts = _cache ?? await getContacts();
    return contacts.where((c) => c.id == id).firstOrNull;
  }

  Future<List<Contact>> _simulateCall() async {
    final call = await _nextCallNumber();
    await Future.delayed(AppDurations.networkDelay);

    if (_shouldFail(call)) {
      throw const ContactRepositoryException(AppStrings.errorLoadContacts);
    }
    return _cache = await _readContacts();
  }

  /// Suma 1 al contador guardado en el storage y devuelve el número de llamada.
  Future<int> _nextCallNumber() async {
    _callCount++;
    try {
      final next = (await _prefs.getInt(_callCountKey) ?? 0) + 1;
      await _prefs.setInt(_callCountKey, next);
      _callCount = next;
    } catch (_) {
      // Sin storage (ej. pruebas): se usa el contador en memoria.
    }
    return _callCount;
  }

  /// Ids de los contactos favoritos guardados en el storage del navegador.
  Future<Set<int>> getFavoriteIds() async {
    final stored = await _prefs.getStringList(_favoritesKey) ?? const [];
    return stored.map(int.tryParse).whereType<int>().toSet();
  }

  /// Marca o desmarca un contacto como favorito y devuelve los favoritos actualizados.
  Future<Set<int>> toggleFavorite(int id) async {
    final favorites = await getFavoriteIds();
    if (!favorites.remove(id)) favorites.add(id);

    await _prefs.setStringList(
      _favoritesKey,
      favorites.map((f) => f.toString()).toList(),
    );
    _favoritesController.add(Set.unmodifiable(favorites));
    return favorites;
  }

  void dispose() => _favoritesController.close();

  bool _shouldFail(int call) => call % 4 == 2;

  Future<List<Contact>> _readContacts() async {
    try {
      final raw = await _bundle.loadString(AppAssets.contactsJson);
      final data = jsonDecode(raw) as List<dynamic>;
      return data
          .map((item) => Contact.fromJson(item as Map<String, dynamic>))
          .toList();
    } on FormatException {
      throw const ContactRepositoryException(AppStrings.errorReadData);
    } on TypeError {
      throw const ContactRepositoryException(AppStrings.errorReadData);
    }
  }
}
