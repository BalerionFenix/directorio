import 'package:directorio/core/constants/app_strings.dart';
import 'package:directorio/features/contact_detail/cubit/contact_detail_cubit.dart';
import 'package:directorio/features/contact_detail/cubit/contact_detail_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_contact_repository.dart';

void main() {
  late FakeContactRepository repository;

  setUp(() => repository = FakeContactRepository(favorites: {2}));

  test('carga: Loading y luego Success con el favorito', () async {
    final cubit = ContactDetailCubit(repository, 2);
    final emitted = expectLater(
      cubit.stream,
      emitsInOrder([isA<ContactDetailLoading>(), isA<ContactDetailSuccess>()]),
    );
    await cubit.loadContact();
    await emitted;

    final success = cubit.state as ContactDetailSuccess;
    expect(success.contact.name, 'Matías Soto');
    expect(success.isFavorite, isTrue);
    await cubit.close();
  });

  test('id inexistente o inválido emite NotFound', () async {
    final missing = ContactDetailCubit(repository, 40);
    await missing.loadContact();
    expect(missing.state, isA<ContactDetailNotFound>());
    await missing.close();

    final invalid = ContactDetailCubit(repository, null);
    await invalid.loadContact();
    expect(invalid.state, isA<ContactDetailNotFound>());
    await invalid.close();
  });

  test('error del repositorio emite ContactDetailError', () async {
    repository.failDetail = true;
    final cubit = ContactDetailCubit(repository, 2);
    await cubit.loadContact();

    expect(cubit.state, isA<ContactDetailError>());
    expect(
      (cubit.state as ContactDetailError).message,
      AppStrings.errorLoadContact,
    );
    await cubit.close();
  });

  test(
    'favorito: se marca desde el detalle y se sincroniza desde la lista',
    () async {
      final cubit = ContactDetailCubit(repository, 1);
      await cubit.loadContact();
      expect((cubit.state as ContactDetailSuccess).isFavorite, isFalse);

      await cubit.toggleFavorite();
      expect((cubit.state as ContactDetailSuccess).isFavorite, isTrue);
      expect(repository.favorites, {1, 2});

      repository.emitFavorites({2}); // la lista lo desmarcó
      await Future<void>.delayed(Duration.zero);
      expect((cubit.state as ContactDetailSuccess).isFavorite, isFalse);
      await cubit.close();
    },
  );
}
