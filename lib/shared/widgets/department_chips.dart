import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_strings.dart';
import 'filter_pill.dart';

/// Filtros: Todos · Comercial · Diseño · Ingeniería · Personas.
/// [selected] es `null` cuando está en "Todos".
class DepartmentChips extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onSelected;
  final bool enabled;

  /// En pantalla angosta los chips se deslizan en horizontal.
  final bool scrollable;

  const DepartmentChips({
    super.key,
    required this.selected,
    required this.onSelected,
    this.enabled = true,
    this.scrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    return FilterPillRow(
      scrollable: scrollable,
      pills: [
        FilterPill(
          label: AppStrings.allDepartments,
          accent: AppColors.primary,
          isSelected: selected == null,
          onTap: enabled ? () => onSelected(null) : null,
        ),
        for (final department in AppStrings.departments)
          FilterPill(
            label: department,
            accent: AppColors.forDepartment(department),
            isSelected: selected == department,
            onTap: enabled ? () => onSelected(department) : null,
          ),
      ],
    );
  }
}

/// Filtros de estado: Todos · Activos · Inactivos.
/// [selected] es `null` (todos), `true` (activos) o `false` (inactivos).
class StatusChips extends StatelessWidget {
  final bool? selected;
  final ValueChanged<bool?> onSelected;
  final bool enabled;
  final bool scrollable;

  const StatusChips({
    super.key,
    required this.selected,
    required this.onSelected,
    this.enabled = true,
    this.scrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    return FilterPillRow(
      scrollable: scrollable,
      pills: [
        FilterPill(
          label: AppStrings.allStatuses,
          accent: AppColors.primary,
          isSelected: selected == null,
          onTap: enabled ? () => onSelected(null) : null,
        ),
        FilterPill(
          label: AppStrings.activePlural,
          accent: AppColors.active,
          icon: Icons.circle,
          isSelected: selected == true,
          onTap: enabled ? () => onSelected(true) : null,
        ),
        FilterPill(
          label: AppStrings.inactivePlural,
          accent: AppColors.textSecondary,
          icon: Icons.circle,
          isSelected: selected == false,
          onTap: enabled ? () => onSelected(false) : null,
        ),
      ],
    );
  }
}

/// Chip pequeño con el departamento de un contacto (tarjetas y detalle).
class DepartmentBadge extends StatelessWidget {
  final String department;
  final bool large;

  const DepartmentBadge({
    super.key,
    required this.department,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? AppDimens.spaceMd - 4 : AppDimens.spaceSm + 2,
        vertical: large ? AppDimens.spaceXs : 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.tintForDepartment(department),
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      ),
      child: Text(
        department,
        style: TextStyle(
          color: AppColors.forDepartment(department),
          fontSize: large ? 12 : 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
