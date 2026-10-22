import 'package:animated_switcher_plus/animated_switcher_plus.dart';
import 'package:flutter/foundation.dart' show mapEquals;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_navigation.dart';
import '../../../data/models/contact.dart';
import '../../../data/repositories/contact_repository.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/contacts_collection.dart';
import '../../../shared/widgets/contacts_filters_panel.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/glass_panel.dart';
import '../../../shared/widgets/metrics_bar.dart';
import '../cubit/contacts_cubit.dart';
import '../cubit/contacts_state.dart';

/// Página de contactos. Vive en un ShellRoute: no se destruye al abrir un
/// detalle, así la lista no se recarga.
///
/// - Pantalla ancha (≥ 900 px): métricas arriba, grilla a la izquierda y [detail] a la derecha.
/// - Pantalla angosta: métricas + lista, o el [detail] a pantalla completa si hay uno abierto.
class ContactsPage extends StatelessWidget {
  final ContactRepository repository;
  final String query;
  final String? department;
  final bool? active;
  final int? selectedId;
  final bool isDetailOpen;
  final Widget detail;

  const ContactsPage({
    super.key,
    required this.repository,
    required this.query,
    required this.department,
    required this.active,
    required this.selectedId,
    required this.isDetailOpen,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ContactsCubit(
        repository,
        query: query,
        department: department,
        active: active,
      )..loadContacts(),
      child: MultiBlocListener(
        listeners: [
          BlocListener<ContactsCubit, ContactsState>(
            listenWhen: (_, state) => state is ContactsError,
            listener: (context, state) =>
                context.goToError((state as ContactsError).message),
          ),
        ],
        child: _UrlFiltersSync(
          query: query,
          department: department,
          active: active,
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: AppBackground(
              child: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide =
                        constraints.maxWidth >=
                        AppDimens.masterDetailBreakpoint;
                    if (isWide) {
                      return _WideLayout(
                        selectedId: selectedId,
                        detail: detail,
                      );
                    }
                    return isDetailOpen ? detail : const _NarrowLayout();
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Mantiene los filtros y la URL sincronizados en las dos direcciones:
///
/// - Filtros → URL: cada cambio reemplaza `?q=&dept=&status=` (no agrega
///   entradas al historial del navegador).
/// - URL → filtros: si los query params cambian sin recrear la página, se
///   aplican al cubit. Se ignoran las URLs que escribió este mismo widget (si se
///   escribe rápido, una URL vieja podría llegar tarde y borrar lo tecleado).
class _UrlFiltersSync extends StatefulWidget {
  final String query;
  final String? department;
  final bool? active;
  final Widget child;

  const _UrlFiltersSync({
    required this.query,
    required this.department,
    required this.active,
    required this.child,
  });

  @override
  State<_UrlFiltersSync> createState() => _UrlFiltersSyncState();
}

class _UrlFiltersSyncState extends State<_UrlFiltersSync> {
  /// URLs de filtros escritas por este widget que todavía no han vuelto.
  final _written = <String>{};

  static String _key(String query, String? department, bool? active) =>
      '$query|$department|$active';

  void _writeToUrl(ContactsLoaded state) {
    final current = context.currentUri;
    if (current.path == AppRoutes.error) return;

    final params = AppRoutes.filterParams(
      query: state.query,
      department: state.department,
      active: state.active,
    );
    if (mapEquals(current.queryParameters, params)) return;

    _written.add(_key(state.query, state.department, state.active));
    context.goReplacing(AppRoutes.withParams(current.path, params));
  }

  @override
  void didUpdateWidget(_UrlFiltersSync oldWidget) {
    super.didUpdateWidget(oldWidget);
    final urlChanged =
        oldWidget.query != widget.query ||
        oldWidget.department != widget.department ||
        oldWidget.active != widget.active;
    if (!urlChanged) return;

    // Es una URL que escribimos nosotros: el cubit ya tiene esos filtros.
    if (_written.remove(_key(widget.query, widget.department, widget.active))) {
      return;
    }
    context.read<ContactsCubit>().applyFilters(
      query: widget.query,
      department: widget.department,
      active: widget.active,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ContactsCubit, ContactsState>(
      listenWhen: (_, state) => state is ContactsLoaded,
      listener: (_, state) => _writeToUrl(state as ContactsLoaded),
      child: widget.child,
    );
  }
}

// ───────────────────────────── Layouts ─────────────────────────────

class _WideLayout extends StatelessWidget {
  final int? selectedId;
  final Widget detail;

  const _WideLayout({required this.selectedId, required this.detail});

  @override
  Widget build(BuildContext context) {
    final listFlex = (AppDimens.listPanelWidth * 100).round();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppDimens.maxContentWidth),
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.spaceXl),
          child: Column(
            children: [
              const _Metrics(),
              const SizedBox(height: AppDimens.spaceLg),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: listFlex,
                      child: CustomScrollView(
                        slivers: [
                          const SliverToBoxAdapter(
                            child: _Filters(isWide: true),
                          ),
                          const SliverToBoxAdapter(
                            child: SizedBox(height: AppDimens.spaceMd),
                          ),
                          _ContactsBody(isWide: true, selectedId: selectedId),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppDimens.spaceLg),
                    Expanded(
                      flex: 100 - listFlex,
                      child: GlassPanel(
                        padding: EdgeInsets.zero,
                        child: detail,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NarrowLayout extends StatelessWidget {
  const _NarrowLayout();

  @override
  Widget build(BuildContext context) {
    return const CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            AppDimens.spaceMd,
            AppDimens.spaceMd,
            AppDimens.spaceMd,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: Column(
              children: [
                _Metrics(),
                SizedBox(height: AppDimens.spaceMd),
                _Filters(isWide: false),
                SizedBox(height: AppDimens.spaceMd),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            AppDimens.spaceMd,
            0,
            AppDimens.spaceMd,
            AppDimens.spaceLg,
          ),
          sliver: _ContactsBody(isWide: false, selectedId: null),
        ),
      ],
    );
  }
}

// ───────────────────────────── Secciones ─────────────────────────────

class _Metrics extends StatelessWidget {
  const _Metrics();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContactsCubit, ContactsState>(
      builder: (context, state) => switch (state) {
        ContactsLoaded() => MetricsBar(
          total: state.all.length,
          active: state.activeCount,
          favorites: state.favoriteCount,
        ),
        ContactsError() => const MetricsBar(total: 0, active: 0, favorites: 0),
        _ => const MetricsBar.loading(),
      },
    );
  }
}

/// Conecta el panel de filtros con el cubit.
class _Filters extends StatelessWidget {
  final bool isWide;

  const _Filters({required this.isWide});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ContactsCubit>();

    return BlocBuilder<ContactsCubit, ContactsState>(
      builder: (context, state) {
        final (query, department, active, count) = switch (state) {
          ContactsSuccess() => (
            state.query,
            state.department,
            state.active,
            state.visible.length,
          ),
          ContactsEmpty() => (state.query, state.department, state.active, 0),
          ContactsLoading() => (
            state.query,
            state.department,
            state.active,
            null,
          ),
          _ => ('', null, null, null),
        };

        return ContactsFiltersPanel(
          isWide: isWide,
          enabled: state is ContactsLoaded,
          count: count,
          query: query,
          department: department,
          active: active,
          onSearch: cubit.search,
          onClear: cubit.clearFilters,
          onDepartment: cubit.filterByDepartment,
          onStatus: cubit.filterByStatus,
        );
      },
    );
  }
}

/// Cuerpo según el estado: skeletons, grilla/lista, vacío o error.
class _ContactsBody extends StatelessWidget {
  final bool isWide;
  final int? selectedId;

  const _ContactsBody({required this.isWide, required this.selectedId});

  /// Abre el detalle conservando los filtros de la URL.
  void _openDetail(BuildContext context, Contact contact) => context.go(
    AppRoutes.withParams(
      AppRoutes.contactDetailPath(contact.id),
      context.currentUri.queryParameters,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ContactsCubit>();

    return BlocBuilder<ContactsCubit, ContactsState>(
      builder: (context, state) => switch (state) {
        ContactsSuccess() when isWide => ContactsGridSliver(
          contacts: state.visible,
          favoriteIds: state.favoriteIds,
          selectedId: selectedId,
          filterKey: state.filterKey,
          onTap: (contact) => _openDetail(context, contact),
          onToggleFavorite: (contact) => cubit.toggleFavorite(contact.id),
        ),
        ContactsSuccess() => ContactsListSliver(
          contacts: state.visible,
          favoriteIds: state.favoriteIds,
          filterKey: state.filterKey,
          onTap: (contact) => _openDetail(context, contact),
          onToggleFavorite: (contact) => cubit.toggleFavorite(contact.id),
        ),
        ContactsEmpty() => SliverFillRemaining(
          hasScrollBody: false,
          child: AnimatedSwitcherPlus.zoomIn(
            duration: AppDurations.normal,
            child: EmptyState(
              key: ValueKey(state.filterKey),
              icon: Icons.search_off_rounded,
              title: AppStrings.emptyTitle,
              message: AppStrings.emptyFor(
                query: state.query,
                department: state.department,
                active: state.active,
              ),
              actionLabel: state.hasFilters ? AppStrings.clearFilters : null,
              onAction: cubit.clearFilters,
            ),
          ),
        ),
        // Normalmente el BlocListener ya llevó a /error; esto es el respaldo
        // para que nunca quede un skeleton infinito.
        ContactsError() => SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(
            icon: Icons.warning_amber_rounded,
            title: AppStrings.errorTitle,
            message: state.message,
            actionLabel: AppStrings.retry,
            onAction: cubit.loadContacts,
          ),
        ),
        ContactsInitial() || ContactsLoading() =>
          isWide ? const GridSkeletonSliver() : const ListSkeletonSliver(),
      },
    );
  }
}
