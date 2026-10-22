import 'package:directorio/core/constants/app_strings.dart';
import 'package:directorio/data/repositories/contact_repository.dart';
import 'package:directorio/features/contacts/cubit/contacts_cubit.dart';
import 'package:directorio/features/contacts/cubit/contacts_state.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pruebas de búsqueda + filtro con los datos reales de `assets/contacts.json`.
///
/// Estilo `test.each` de Jest: cada fila de la tabla es un caso con su entrada
/// (búsqueda + departamento) y su resultado esperado. Para agregar un caso se
/// agrega una fila; lo que depende de la entrada (el nombre de la prueba, que
/// cada resultado contenga lo buscado, el mensaje de vacío) se calcula a partir
/// de esa misma fila, no se escribe a mano.

/// Casos que SÍ encuentran contactos: entrada → nombres esperados.
const _found = [
  (
    query: 'camila',
    department: AppStrings.departmentDesign,
    expected: ['Camila Reyes'],
  ),
  // Sin distinguir mayúsculas ni tildes.
  (
    query: 'MATIAS',
    department: AppStrings.departmentEngineering,
    expected: ['Matías Soto'],
  ),
  (query: 'rojas', department: null, expected: ['Sebastián Rojas']),
  (
    query: 'a',
    department: AppStrings.departmentPeople,
    expected: ['Florencia Paz', 'Javiera Morales', 'Millaray Torres'],
  ),
];

/// Casos que NO encuentran a nadie.
const _notFound = [
  (query: 'matias', department: AppStrings.departmentEngineering),
  (query: 'camila', department: AppStrings.departmentDesign),
  (query: 'camilo', department: null), // no existe en el JSON
  (query: 'pedro', department: null),
];

String _describe(String query, String? department) =>
    '"$query" en ${department ?? 'todos los departamentos'}';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ContactsCubit cubit;

  setUp(() async {
    // Repositorio nuevo en cada caso: su primera llamada nunca falla.
    cubit = ContactsCubit(ContactRepository());
    await cubit.loadContacts();
  });

  tearDown(() => cubit.close());

  group('Se encuentra', () {
    for (final c in _found) {
      test('${_describe(c.query, c.department)} → ${c.expected}', () {
        // Act
        cubit.search(c.query);
        cubit.filterByDepartment(c.department);

        // Assert
        final state = cubit.state;
        expect(state, isA<ContactsSuccess>(), reason: 'debería encontrar');
        final visible = (state as ContactsSuccess).visible;
        expect(visible.map((x) => x.name), c.expected);

        // Cada resultado contiene lo buscado y es del departamento pedido.
        final needle = ContactsCubit.normalize(c.query);
        for (final contact in visible) {
          expect(ContactsCubit.normalize(contact.name), contains(needle));
          if (c.department != null) {
            expect(contact.department, c.department);
          }
        }
      });
    }
  });

  group('No se encuentra', () {
    for (final c in _notFound) {
      test('${_describe(c.query, c.department)} → vacío con mensaje', () {
        // Act
        cubit.search(c.query);
        cubit.filterByDepartment(c.department);

        // Assert: estado vacío, nunca una lista en blanco.
        final state = cubit.state;
        expect(state, isA<ContactsEmpty>(), reason: 'no debería encontrar');

        // El mensaje se arma con la misma entrada del caso.
        final empty = state as ContactsEmpty;
        final message = AppStrings.emptyFor(
          query: empty.query,
          department: empty.department,
        );
        expect(message, contains('«${c.query}»'));
        if (c.department != null) {
          expect(message, contains(c.department));
        }
      });
    }
  });
}
