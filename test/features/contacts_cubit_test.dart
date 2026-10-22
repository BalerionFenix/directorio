import 'package:directorio/core/constants/app_strings.dart';
import 'package:directorio/features/contacts/cubit/contacts_cubit.dart';
import 'package:directorio/features/contacts/cubit/contacts_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_contact_repository.dart';

List<String> _names(ContactsState state) =>
    (state as ContactsSuccess).visible.map((c) => c.name).toList();

void main() {
  late FakeContactRepository repository;
  late ContactsCubit cubit;

  setUp(() {
    repository = FakeContactRepository(favorites: {4});
    cubit = ContactsCubit(repository);
  });

  tearDown(() => cubit.close());

  test(
    'carga: emite Loading y luego Success con todos y las métricas',
    () async {
      final emitted = expectLater(
        cubit.stream,
        emitsInOrder([isA<ContactsLoading>(), isA<ContactsSuccess>()]),
      );
      await cubit.loadContacts();
      await emitted;

      final success = cubit.state as ContactsSuccess;
      expect(success.visible, hasLength(6));
      expect(success.activeCount, 5);
      expect(success.favoriteCount, 1);
    },
  );

  test('búsqueda sin mayúsculas ni tildes', () async {
    await cubit.loadContacts();

    cubit.search('matias');
    expect(_names(cubit.state), ['Matías Soto']);

    cubit.search('MUNOZ');
    expect(_names(cubit.state), ['Ignacio Muñoz']);
  });

  test('búsqueda + departamento se combinan', () async {
    await cubit.loadContacts();

    cubit.search('pedro');
    expect(_names(cubit.state), ['Pedro Díaz', 'Pedro Rojas']);

    cubit.filterByDepartment(AppStrings.departmentEngineering);
    expect(_names(cubit.state), ['Pedro Rojas']);
  });

  test('filtro de estado combinado con búsqueda y departamento', () async {
    await cubit.loadContacts();

    cubit.filterByStatus(false);
    expect(_names(cubit.state), ['Valentina Cid']);

    cubit.filterByStatus(true);
    cubit.filterByDepartment(AppStrings.departmentEngineering);
    expect(_names(cubit.state), ['Matías Soto', 'Pedro Rojas']);

    cubit.search('valentina');
    final empty = cubit.state as ContactsEmpty;
    expect(
      AppStrings.emptyFor(
        query: empty.query,
        department: empty.department,
        active: empty.active,
      ),
      'Ningún contacto activo coincide con «valentina» en Ingeniería.',
    );

    cubit.clearFilters();
    expect((cubit.state as ContactsLoaded).active, isNull);
    expect(_names(cubit.state), hasLength(6));
  });

  test('sin resultados emite Empty y limpiar filtros vuelve a todos', () async {
    await cubit.loadContacts();

    cubit.search('pedro');
    cubit.filterByDepartment(AppStrings.departmentPeople);
    final empty = cubit.state as ContactsEmpty;
    expect(empty.query, 'pedro');
    expect(empty.department, AppStrings.departmentPeople);
    expect(empty.hasFilters, isTrue);

    cubit.clearFilters();
    expect(_names(cubit.state), hasLength(6));
  });

  test('error del repositorio emite ContactsError con el mensaje', () async {
    repository.fail = true;
    await cubit.loadContacts();

    expect(cubit.state, isA<ContactsError>());
    expect(
      (cubit.state as ContactsError).message,
      AppStrings.errorLoadContacts,
    );
  });

  test(
    'favoritos: marcar, y sincronizar si cambian desde otra vista',
    () async {
      await cubit.loadContacts();

      await cubit.toggleFavorite(1);
      expect((cubit.state as ContactsLoaded).favoriteIds, {1, 4});

      repository.emitFavorites({2});
      await Future<void>.delayed(Duration.zero);
      expect((cubit.state as ContactsLoaded).favoriteIds, {2});
    },
  );

  test(
    'filtros iniciales desde la URL; un departamento inválido se ignora',
    () async {
      final fromUrl = ContactsCubit(
        repository,
        query: 'pedro',
        department: 'Diseño',
      );
      await fromUrl.loadContacts();
      expect(_names(fromUrl.state), ['Pedro Díaz']);
      await fromUrl.close();

      final invalid = ContactsCubit(repository, department: 'Marketing');
      await invalid.loadContacts();
      expect((invalid.state as ContactsLoaded).department, isNull);
      await invalid.close();
    },
  );
}
