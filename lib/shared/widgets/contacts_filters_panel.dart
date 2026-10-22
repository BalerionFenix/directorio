import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_strings.dart';
import 'department_chips.dart';
import 'glass_panel.dart';
import 'search_field.dart';

/// Panel de vidrio con título + contador, buscador y los filtros de
/// departamento y estado. Solo pinta: las acciones llegan por callbacks.
class ContactsFiltersPanel extends StatelessWidget {
  final bool isWide;
  final bool enabled;

  /// `null` mientras carga (no se muestra el contador).
  final int? count;
  final String query;
  final String? department;
  final bool? active;
  final ValueChanged<String> onSearch;
  final VoidCallback onClear;
  final ValueChanged<String?> onDepartment;
  final ValueChanged<bool?> onStatus;

  const ContactsFiltersPanel({
    super.key,
    required this.isWide,
    required this.enabled,
    required this.count,
    required this.query,
    required this.department,
    required this.active,
    required this.onSearch,
    required this.onClear,
    required this.onDepartment,
    required this.onStatus,
  });

  bool get _hasFilters =>
      query.trim().isNotEmpty || department != null || active != null;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: EdgeInsets.all(isWide ? AppDimens.spaceLg : AppDimens.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  AppStrings.contactsTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (count != null)
                Text(
                  AppStrings.contactsCount(count!),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppDimens.spaceMd),
          SearchField(
            value: query,
            enabled: enabled,
            onChanged: onSearch,
            // La ✕ restablece búsqueda, departamento y estado a la vez.
            onClear: onClear,
            hasFilters: _hasFilters,
          ),
          const SizedBox(height: AppDimens.spaceMd),
          const _SectionLabel(AppStrings.filterByDepartment),
          DepartmentChips(
            selected: department,
            enabled: enabled,
            scrollable: !isWide,
            onSelected: onDepartment,
          ),
          const SizedBox(height: AppDimens.spaceMd),
          const _SectionLabel(AppStrings.filterByStatus),
          StatusChips(
            selected: active,
            enabled: enabled,
            scrollable: !isWide,
            onSelected: onStatus,
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.spaceSm),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
