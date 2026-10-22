import 'package:directorio/core/constants/app_routes.dart';
import 'package:directorio/core/constants/app_strings.dart';
import 'package:directorio/core/router/app_router.dart';
import 'package:directorio/main.dart';
import 'package:directorio/shared/widgets/contact_detail_view.dart';
import 'package:directorio/shared/widgets/department_chips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'helpers/fake_contact_repository.dart';

const _wide = Size(1280, 900);
const _narrow = Size(400, 900);

/// Monta la app con un repositorio falso y navega a [location].
Future<GoRouter> _pumpApp(
  WidgetTester tester, {
  required String location,
  Size size = _wide,
  FakeContactRepository? repository,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final router = buildAppRouter(
    repository ?? FakeContactRepository(),
    initialLocation: location,
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(DirectorioApp(router: router));
  await tester.pumpAndSettle();
  return router;
}

/// Chip de filtro (no la etiqueta de departamento de una tarjeta).
Finder _chip(String label) => find.descendant(
  of: find.byType(DepartmentChips),
  matching: find.text(label),
);

String _location(GoRouter router) =>
    router.routerDelegate.currentConfiguration.uri.toString();

void main() {
  testWidgets('"/" redirige a /contacts y muestra la lista', (tester) async {
    final router = await _pumpApp(tester, location: AppRoutes.root);

    expect(_location(router), AppRoutes.contacts);
    expect(find.text('Camila Reyes'), findsOneWidget);
    expect(find.text(AppStrings.contactsCount(6)), findsOneWidget);
    expect(find.text(AppStrings.selectContact), findsOneWidget);
  });

  testWidgets('búsqueda + filtro sin resultados muestra el mensaje de vacío', (
    tester,
  ) async {
    await _pumpApp(tester, location: AppRoutes.contacts);

    await tester.enterText(find.byType(TextField), 'pedro');
    await tester.tap(_chip(AppStrings.departmentPeople));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.emptyTitle), findsOneWidget);
    expect(
      find.text(
        AppStrings.emptyFor(
          query: 'pedro',
          department: AppStrings.departmentPeople,
        ),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text(AppStrings.clearFilters));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.contactsCount(6)), findsOneWidget);
  });

  testWidgets('la ✕ restablece búsqueda y departamento', (tester) async {
    await _pumpApp(tester, location: AppRoutes.contacts);

    await tester.enterText(find.byType(TextField), 'valentina');
    await tester.tap(_chip(AppStrings.departmentEngineering));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.contactsCount(1)), findsOneWidget);

    await tester.tap(find.byTooltip(AppStrings.clearFilters));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.contactsCount(6)), findsOneWidget);
    expect(find.text('valentina'), findsNothing);
  });

  testWidgets('filtro de estado: solo inactivos', (tester) async {
    await _pumpApp(tester, location: AppRoutes.contacts);

    await tester.tap(
      find.descendant(
        of: find.byType(StatusChips),
        matching: find.text(AppStrings.inactivePlural),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.contactsCount(1)), findsOneWidget);
    expect(find.text('Valentina Cid'), findsOneWidget);
  });

  testWidgets('la URL ?status=activos llega como filtro inicial', (
    tester,
  ) async {
    await _pumpApp(tester, location: '/contacts?status=activos');
    expect(find.text(AppStrings.contactsCount(5)), findsOneWidget);
  });

  testWidgets('ancha: tocar una tarjeta abre el detalle al lado', (
    tester,
  ) async {
    final router = await _pumpApp(tester, location: AppRoutes.contacts);

    await tester.tap(find.text('Matías Soto'));
    await tester.pumpAndSettle();

    expect(_location(router), AppRoutes.contactDetailPath(2));
    expect(find.text('Camila Reyes'), findsOneWidget); // la lista sigue ahí
    expect(find.text(AppStrings.detailSheetTitle), findsOneWidget);
    expect(find.text('matias.soto@empresa.cl'), findsOneWidget);
    expect(find.text('Backend Engineer'), findsNWidgets(2)); // tarjeta + ficha
  });

  testWidgets('angosta: detalle a pantalla completa y volver', (tester) async {
    final router = await _pumpApp(
      tester,
      location: AppRoutes.contacts,
      size: _narrow,
    );

    await tester.tap(find.text('Matías Soto'));
    await tester.pumpAndSettle();
    expect(find.text('Camila Reyes'), findsNothing);

    await tester.tap(find.byTooltip(AppStrings.back));
    await tester.pumpAndSettle();
    expect(_location(router), AppRoutes.contacts);
    expect(find.text('Camila Reyes'), findsOneWidget);
  });

  testWidgets('/contacts/40 muestra "Contacto no encontrado"', (tester) async {
    await _pumpApp(tester, location: AppRoutes.contactDetailPath(40));
    expect(find.text(AppStrings.notFoundTitle), findsOneWidget);
    expect(find.text('Camila Reyes'), findsOneWidget); // la lista sigue al lado

    await tester.tap(find.text(AppStrings.backToList));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.selectContact), findsOneWidget);
  });

  testWidgets('angosta: la ficha muestra todos los datos', (tester) async {
    await _pumpApp(
      tester,
      location: AppRoutes.contactDetailPath(3),
      size: _narrow,
    );
    expect(find.text('Valentina Cid'), findsOneWidget);
    expect(find.text('QA Lead'), findsOneWidget);
    expect(find.text('valentina.cid@empresa.cl'), findsOneWidget);
    expect(find.text('+56 9 3333 4444'), findsOneWidget);
    expect(find.text(AppStrings.inactive), findsOneWidget);
  });

  testWidgets('estrella en el detalle se refleja en la lista', (tester) async {
    final repository = FakeContactRepository();
    await _pumpApp(
      tester,
      location: AppRoutes.contactDetailPath(2),
      repository: repository,
    );

    final detailStar = find.descendant(
      of: find.byType(ContactDetailView),
      matching: find.byTooltip(AppStrings.addFavorite),
    );
    await tester.tap(detailStar);
    await tester.pumpAndSettle();

    expect(repository.favorites, {2});
    // La ficha y la tarjeta de la lista muestran la estrella marcada.
    expect(find.byTooltip(AppStrings.removeFavorite), findsNWidgets(2));
  });

  testWidgets('si falla el detalle redirige a /error y vuelve al reintentar', (
    tester,
  ) async {
    final repository = FakeContactRepository(failDetail: true);
    final router = await _pumpApp(
      tester,
      location: AppRoutes.contactDetailPath(2),
      repository: repository,
    );
    expect(find.text(AppStrings.errorLoadContact), findsOneWidget);

    repository.failDetail = false;
    await tester.tap(find.text(AppStrings.retry));
    await tester.pumpAndSettle();
    expect(_location(router), AppRoutes.contactDetailPath(2));
    expect(find.text('matias.soto@empresa.cl'), findsOneWidget);
  });

  testWidgets('falla en /contacts/1: un solo /error que vuelve al contacto', (
    tester,
  ) async {
    final repository = FakeContactRepository(fail: true);
    final router = await _pumpApp(
      tester,
      location: AppRoutes.contactDetailPath(1),
      repository: repository,
    );

    expect(
      _location(router),
      AppRoutes.errorPath(
        message: AppStrings.errorLoadContacts,
        from: AppRoutes.contactDetailPath(1),
      ),
    );

    repository.fail = false;
    await tester.tap(find.text(AppStrings.retry));
    await tester.pumpAndSettle();
    expect(_location(router), AppRoutes.contactDetailPath(1));
  });

  testWidgets('si la carga falla redirige a /error con el mensaje', (
    tester,
  ) async {
    final repository = FakeContactRepository(fail: true);
    final router = await _pumpApp(
      tester,
      location: AppRoutes.contacts,
      repository: repository,
    );

    expect(
      router.routerDelegate.currentConfiguration.uri.path,
      AppRoutes.error,
    );
    expect(find.text(AppStrings.errorLoadContacts), findsOneWidget);

    repository.fail = false;
    await tester.tap(find.text(AppStrings.retry));
    await tester.pumpAndSettle();
    expect(_location(router), AppRoutes.contacts);
    expect(find.text('Camila Reyes'), findsOneWidget);
  });

  testWidgets('recargar en /error reintenta la ruta que había fallado', (
    tester,
  ) async {
    // Llegar a /error sin pasar por la app = recargar la página o el historial.
    final router = await _pumpApp(
      tester,
      location: AppRoutes.errorPath(
        message: AppStrings.errorLoadContacts,
        from: AppRoutes.contactDetailPath(2),
      ),
    );
    expect(_location(router), AppRoutes.contactDetailPath(2));
    expect(find.text('matias.soto@empresa.cl'), findsOneWidget);
  });

  testWidgets('error: un "from" externo nunca se usa (va a /contacts)', (
    tester,
  ) async {
    final router = await _pumpApp(tester, location: AppRoutes.contacts);
    router.go(
      AppRoutes.errorPath(message: 'x', from: '//malo.com'),
      extra: AppRoutes.errorShownInApp,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(AppStrings.retry));
    await tester.pumpAndSettle();
    expect(_location(router), AppRoutes.contacts);
  });

  testWidgets('búsqueda y filtros se escriben en la URL', (tester) async {
    final router = await _pumpApp(tester, location: AppRoutes.contacts);

    await tester.enterText(find.byType(TextField), 'pedro');
    await tester.pumpAndSettle();
    await tester.tap(_chip(AppStrings.departmentEngineering));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(StatusChips),
        matching: find.text(AppStrings.activePlural),
      ),
    );
    await tester.pumpAndSettle();

    final uri = router.routerDelegate.currentConfiguration.uri;
    expect(uri.path, AppRoutes.contacts);
    expect(uri.queryParameters, {
      AppRoutes.queryParam: 'pedro',
      AppRoutes.departmentParam: AppStrings.departmentEngineering,
      AppRoutes.statusParam: AppRoutes.statusActive,
    });

    // La ✕ limpia también la URL.
    await tester.tap(find.byTooltip(AppStrings.clearFilters));
    await tester.pumpAndSettle();
    expect(_location(router), AppRoutes.contacts);
  });

  testWidgets('la URL con filtros abre la lista filtrada (deep link)', (
    tester,
  ) async {
    await _pumpApp(
      tester,
      location: '/contacts?q=pedro&dept=${AppStrings.departmentDesign}',
    );
    expect(find.text('Pedro Díaz'), findsOneWidget);
    expect(find.text('Pedro Rojas'), findsNothing);
    expect(find.text(AppStrings.contactsCount(1)), findsOneWidget);
  });

  testWidgets('abrir y cerrar el detalle conserva los filtros', (tester) async {
    final router = await _pumpApp(
      tester,
      location: '/contacts?q=pedro',
      size: _narrow,
    );

    await tester.tap(find.text('Pedro Rojas'));
    await tester.pumpAndSettle();
    expect(_location(router), '${AppRoutes.contactDetailPath(6)}?q=pedro');

    await tester.tap(find.byTooltip(AppStrings.back));
    await tester.pumpAndSettle();
    expect(_location(router), '/contacts?q=pedro');
    expect(find.text(AppStrings.contactsCount(2)), findsOneWidget);
  });

  testWidgets('URL desconocida muestra la vista de error', (tester) async {
    await _pumpApp(tester, location: '/no-existe');
    expect(find.text(AppStrings.errorPageNotFound), findsOneWidget);
  });
}
