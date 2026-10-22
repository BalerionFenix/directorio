import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_strings.dart';

/// "● Activo" / "● Inactivo" en texto pequeño (tarjetas).
/// Con [asChip] se muestra como píldora con fondo (detalle).
class StatusIndicator extends StatelessWidget {
  final bool active;
  final bool asChip;

  const StatusIndicator({super.key, required this.active, this.asChip = false});

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.active : AppColors.textSecondary;
    final dotColor = active ? AppColors.active : AppColors.inactive;

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: AppDimens.statusDotSm,
          height: AppDimens.statusDotSm,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppDimens.spaceXs + 2),
        Text(
          active ? AppStrings.active : AppStrings.inactive,
          style: TextStyle(
            color: color,
            fontSize: asChip ? 12 : 11,
            fontWeight: asChip ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ],
    );

    if (!asChip) return content;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.spaceMd - 4,
        vertical: AppDimens.spaceXs,
      ),
      decoration: BoxDecoration(
        color: active ? AppColors.activeLight : AppColors.inactiveLight,
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      ),
      child: content,
    );
  }
}
