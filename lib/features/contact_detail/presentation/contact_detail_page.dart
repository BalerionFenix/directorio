import 'package:animated_switcher_plus/animated_switcher_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_navigation.dart';
import '../../../data/repositories/contact_repository.dart';
import '../../../shared/widgets/contact_detail_view.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/glass_panel.dart';
import '../cubit/contact_detail_cubit.dart';
import '../cubit/contact_detail_state.dart';

/// Detalle de un contacto.
///
/// - Pantalla ancha: va dentro del panel de vidrio a la derecha de la lista.
/// - Pantalla angosta: pantalla completa con botón de volver.
///
/// Al cargar, la ficha aparece con un giro 3D (flip).
class ContactDetailPage extends StatelessWidget {
  /// `null` si el id de la URL no es un número (se mostrará "no encontrado").
  final int? contactId;
  final ContactRepository repository;

  const ContactDetailPage({
    super.key,
    required this.contactId,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    final isNarrow =
        MediaQuery.sizeOf(context).width < AppDimens.masterDetailBreakpoint;

    return BlocProvider(
      create: (_) => ContactDetailCubit(repository, contactId)..loadContact(),
      child: BlocListener<ContactDetailCubit, ContactDetailState>(
        listenWhen: (_, state) => state is ContactDetailError,
        listener: (context, state) =>
            context.goToError((state as ContactDetailError).message),
        child: Scaffold(
          backgroundColor: AppColors.transparent,
          appBar: isNarrow
              ? AppBar(
                  backgroundColor: AppColors.transparent,
                  surfaceTintColor: AppColors.transparent,
                  leading: IconButton(
                    tooltip: AppStrings.back,
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => _goBack(context),
                  ),
                  title: const Text(AppStrings.detailTitle),
                )
              : null,
          body: LayoutBuilder(
            builder: (context, constraints) {
              final padding = isNarrow ? AppDimens.spaceMd : AppDimens.spaceLg;
              const content = _DetailContent();

              return SingleChildScrollView(
                padding: EdgeInsets.all(padding),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - padding * 2,
                  ),
                  child: isNarrow
                      ? const GlassPanel(child: content)
                      : const Center(child: content),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Vuelve a la lista con los mismos filtros. Reemplaza la entrada del
  /// detalle en el historial, así el botón atrás del navegador no lo reabre.
  void _goBack(BuildContext context) =>
      context.goReplacing(_listLocation(context));
}

/// `/contacts` con los filtros que trae la URL actual.
String _listLocation(BuildContext context) => AppRoutes.withParams(
  AppRoutes.contacts,
  context.currentUri.queryParameters,
);

/// Contenido según el estado, con giro 3D al cambiar (skeleton → ficha).
class _DetailContent extends StatelessWidget {
  const _DetailContent();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ContactDetailCubit>();

    return BlocBuilder<ContactDetailCubit, ContactDetailState>(
      builder: (context, state) => AnimatedSwitcherPlus.flipY(
        duration: AppDurations.flip,
        child: switch (state) {
          ContactDetailSuccess() => ContactDetailView(
            // La clave es el id: marcar favorito no vuelve a girar la ficha.
            key: ValueKey('contact-${state.contact.id}'),
            contact: state.contact,
            isFavorite: state.isFavorite,
            onToggleFavorite: cubit.toggleFavorite,
          ),
          ContactDetailNotFound() => EmptyState(
            key: const ValueKey('not-found'),
            icon: Icons.person_off_outlined,
            title: AppStrings.notFoundTitle,
            message: AppStrings.notFoundMessage,
            actionLabel: AppStrings.backToList,
            onAction: () => context.go(_listLocation(context)),
          ),
          // Respaldo por si no se alcanzó a redirigir a /error.
          ContactDetailError() => EmptyState(
            key: const ValueKey('error'),
            icon: Icons.warning_amber_rounded,
            title: AppStrings.errorTitle,
            message: state.message,
            actionLabel: AppStrings.retry,
            onAction: cubit.loadContact,
          ),
          ContactDetailInitial() || ContactDetailLoading() =>
            const ContactDetailSkeleton(key: ValueKey('loading')),
        },
      ),
    );
  }
}
