import 'package:directorio/core/constants/app_strings.dart';
import 'package:directorio/data/repositories/contact_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('cada carga de la lista es una llamada: falla la 2 y la 6', () async {
    final repository = ContactRepository();

    final first = await repository.getContacts(); // llamada 1
    expect(first, hasLength(18));
    expect(
      first.map((c) => c.department).toSet(),
      containsAll(AppStrings.departments),
    );
    expect(first.first.initials, 'CR');

    await expectLater(
      repository.getContacts(), // llamada 2
      throwsA(isA<ContactRepositoryException>()),
    );

    for (var i = 0; i < 3; i++) {
      expect(await repository.getContacts(), hasLength(18)); // 3, 4, 5
    }

    await expectLater(
      repository.getContacts(), // llamada 6
      throwsA(isA<ContactRepositoryException>()),
    );
  });

  test('el detalle no cuenta como llamada: usa la caché', () async {
    final repository = ContactRepository();
    await repository.getContacts(); // llamada 1

    // Muchos detalles seguidos no gastan llamadas ni fallan.
    for (final id in [2, 3, 4, 5, 6]) {
      expect((await repository.getContactById(id))?.id, id);
    }
    expect(await repository.getContactById(40), isNull);

    // La siguiente carga de la lista sigue siendo la llamada 2: falla.
    await expectLater(
      repository.getContacts(),
      throwsA(isA<ContactRepositoryException>()),
    );
  });

  test('lista y detalle a la vez comparten una sola llamada', () async {
    final repository = ContactRepository();

    // Como al abrir /contacts/1 directo: lista y detalle piden al mismo tiempo.
    final results = await Future.wait([
      repository.getContacts(),
      repository.getContactById(1),
    ]);
    expect(results[0], hasLength(18));

    // Solo se gastó la llamada 1: la próxima carga es la 2 y falla.
    await expectLater(
      repository.getContacts(),
      throwsA(isA<ContactRepositoryException>()),
    );
  });
}
