import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/contact_repository.dart';
import '../../features/contact_detail/presentation/contact_detail_page.dart';
import '../../features/contacts/presentation/contacts_page.dart';
import '../../features/error/presentation/error_page.dart';
import '../../shared/widgets/empty_state.dart';
import '../constants/app_routes.dart';
import '../constants/app_strings.dart';

/// Router de la app. Una sola instancia del repositorio: el contador de
/// fallos se comparte entre vistas.
final GoRouter appRouter = buildAppRouter(ContactRepository());

/// Router general: todas las rutas en un solo lugar.
///
/// /                      → redirige a /contacts
/// /contacts?q=&dept=&status= → lista (en ancha, con "Selecciona un contacto" al lado)
/// /contacts/:id          → detalle (en ancha, al lado de la lista)
/// /error?message=&from=  → vista de error con Reintentar
///
/// Recibe el repositorio para poder usar uno falso en las pruebas.
GoRouter buildAppRouter(
  ContactRepository repository, {
  String initialLocation = AppRoutes.contacts,
}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(path: AppRoutes.root, redirect: (_, _) => AppRoutes.contacts),

      // Lista + detalle comparten la misma página (ContactsPage), que no se
      // destruye al cambiar entre /contacts y /contacts/:id.
      ShellRoute(
        builder: (context, state, child) {
          final params = state.uri.queryParameters;
          final segments = state.uri.pathSegments;
          return ContactsPage(
            repository: repository,
            query: params[AppRoutes.queryParam] ?? '',
            department: params[AppRoutes.departmentParam],
            active: AppRoutes.parseStatus(params[AppRoutes.statusParam]),
            selectedId: segments.length > 1 ? int.tryParse(segments[1]) : null,
            isDetailOpen: segments.length > 1,
            detail: child,
          );
        },
        routes: [
          GoRoute(
            path: AppRoutes.contacts,
            name: AppRoutes.contactsName,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: EmptyState(
                icon: Icons.person_search_outlined,
                title: AppStrings.selectContact,
                message: AppStrings.selectContactHint,
              ),
            ),
          ),
          GoRoute(
            path: AppRoutes.contactDetail,
            name: AppRoutes.contactDetailName,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: ContactDetailPage(
                contactId: int.tryParse(
                  state.pathParameters[AppRoutes.idParam] ?? '',
                ),
                repository: repository,
              ),
            ),
          ),
        ],
      ),

      GoRoute(
        path: AppRoutes.error,
        name: AppRoutes.errorName,
        // Recargar la página (o llegar por URL/historial) en /error no muestra
        // un error viejo: reintenta la ruta que había fallado.
        redirect: (context, state) => state.extra == AppRoutes.errorShownInApp
            ? null
            : AppRoutes.safeReturnPath(
                state.uri.queryParameters[AppRoutes.fromParam],
              ),
        builder: (context, state) => ErrorPage(
          message: state.uri.queryParameters[AppRoutes.messageParam],
          from: state.uri.queryParameters[AppRoutes.fromParam],
        ),
      ),
    ],

    // Cualquier URL desconocida muestra la vista de error.
    errorBuilder: (context, state) => const ErrorPage(
      message: AppStrings.errorPageNotFound,
      from: AppRoutes.contacts,
    ),
  );
}
