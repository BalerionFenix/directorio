import 'dart:async';

import 'package:directorio/core/constants/app_strings.dart';
import 'package:directorio/data/models/contact.dart';
import 'package:directorio/data/repositories/contact_repository.dart';

/// Repositorio de prueba: sin espera, sin storage y con fallo controlado.
class FakeContactRepository extends ContactRepository {
  List<Contact> contacts;
  bool fail;

  /// Solo falla el detalle (getContactById); la lista carga bien.
  bool failDetail;
  final Set<int> favorites;
  final _changes = StreamController<Set<int>>.broadcast();

  FakeContactRepository({
    List<Contact>? contacts,
    this.fail = false,
    this.failDetail = false,
    Set<int>? favorites,
  }) : contacts = contacts ?? sampleContacts,
       favorites = favorites ?? {};

  @override
  Stream<Set<int>> get favoritesChanges => _changes.stream;

  @override
  Future<List<Contact>> getContacts() async {
    if (fail) {
      throw const ContactRepositoryException(AppStrings.errorLoadContacts);
    }
    return contacts;
  }

  @override
  Future<Contact?> getContactById(int id) async {
    if (failDetail) {
      throw const ContactRepositoryException(AppStrings.errorLoadContact);
    }
    final all = await getContacts();
    return all.where((c) => c.id == id).firstOrNull;
  }

  @override
  Future<Set<int>> getFavoriteIds() async => {...favorites};

  @override
  Future<Set<int>> toggleFavorite(int id) async {
    if (!favorites.remove(id)) favorites.add(id);
    _changes.add({...favorites});
    return {...favorites};
  }

  /// Simula que otra vista (el detalle) cambió los favoritos.
  void emitFavorites(Set<int> ids) {
    favorites
      ..clear()
      ..addAll(ids);
    _changes.add({...favorites});
  }
}

const sampleContacts = [
  Contact(
    id: 1,
    name: 'Camila Reyes',
    role: 'Product Designer',
    department: 'Diseño',
    email: 'camila.reyes@empresa.cl',
    phone: '+56 9 1111 2222',
    active: true,
  ),
  Contact(
    id: 2,
    name: 'Matías Soto',
    role: 'Backend Engineer',
    department: 'Ingeniería',
    email: 'matias.soto@empresa.cl',
    phone: '+56 9 2222 3333',
    active: true,
  ),
  Contact(
    id: 3,
    name: 'Valentina Cid',
    role: 'QA Lead',
    department: 'Ingeniería',
    email: 'valentina.cid@empresa.cl',
    phone: '+56 9 3333 4444',
    active: false,
  ),
  Contact(
    id: 4,
    name: 'Ignacio Muñoz',
    role: 'Sales Rep',
    department: 'Comercial',
    email: 'ignacio.munoz@empresa.cl',
    phone: '+56 9 4444 5555',
    active: true,
  ),
  Contact(
    id: 5,
    name: 'Pedro Díaz',
    role: 'UI Designer',
    department: 'Diseño',
    email: 'pedro.diaz@empresa.cl',
    phone: '+56 9 5555 6666',
    active: true,
  ),
  Contact(
    id: 6,
    name: 'Pedro Rojas',
    role: 'DevOps',
    department: 'Ingeniería',
    email: 'pedro.rojas@empresa.cl',
    phone: '+56 9 6666 7777',
    active: true,
  ),
];
