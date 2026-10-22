import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_navigation.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/glass_panel.dart';
import '../cubit/error_cubit.dart';
import '../cubit/error_state.dart';

/// Vista de error: muestra el mensaje recibido y permite reintentar.
class ErrorPage extends StatelessWidget {
  final String? message;
  final String? from;

  const ErrorPage({super.key, this.message, this.from});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ErrorCubit(message: message, from: from),
      child: BlocListener<ErrorCubit, ErrorState>(
        // Vuelve a la ruta que falló reemplazando /error en el historial.
        listener: (context, state) {
          if (state is ErrorRetryReady) context.goReplacing(state.returnPath);
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: AppBackground(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimens.spaceLg),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppDimens.messageMaxWidth,
                  ),
                  child: GlassPanel(
                    padding: const EdgeInsets.all(AppDimens.spaceXl),
                    child: BlocBuilder<ErrorCubit, ErrorState>(
                      builder: (context, state) {
                        final text = switch (state) {
                          ErrorInitial(:final message) => message,
                          ErrorRetrying(:final message) => message,
                          ErrorRetryReady() => '',
                        };
                        return _ErrorContent(
                          message: text,
                          isRetrying: state is! ErrorInitial,
                          onRetry: () => context.read<ErrorCubit>().retry(),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorContent extends StatelessWidget {
  final String message;
  final bool isRetrying;
  final VoidCallback onRetry;

  const _ErrorContent({
    required this.message,
    required this.isRetrying,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(AppDimens.spaceLg),
          decoration: const BoxDecoration(
            color: AppColors.errorLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.warning_amber_rounded,
            size: AppDimens.iconLg,
            color: AppColors.error,
          ),
        ),
        const SizedBox(height: AppDimens.spaceLg),
        Text(
          AppStrings.errorTitle,
          textAlign: TextAlign.center,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimens.spaceSm),
        Text(
          message,
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppDimens.spaceXl),
        FilledButton.icon(
          onPressed: isRetrying ? null : onRetry,
          icon: isRetrying
              ? const SizedBox.square(
                  dimension: AppDimens.iconSm,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.textOnPrimary,
                  ),
                )
              : const Icon(Icons.refresh_rounded),
          label: const Text(AppStrings.retry),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            disabledForegroundColor: AppColors.textOnPrimary,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.spaceLg,
              vertical: AppDimens.spaceMd,
            ),
          ),
        ),
      ],
    );
  }
}
