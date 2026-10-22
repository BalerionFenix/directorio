import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/contact.dart';
import 'contact_avatar.dart';
import 'department_chips.dart';
import 'favorite_button.dart';
import 'loading_skeleton.dart';
import 'status_indicator.dart';

/// Ficha de colaborador: encabezado con favorito, burbuja grande, nombre,
/// rol, chips de departamento y estado, y los datos de contacto.
class ContactDetailView extends StatelessWidget {
  final Contact contact;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  const ContactDetailView({
    super.key,
    required this.contact,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(child: _Label(AppStrings.detailSheetTitle)),
            FavoriteButton(
              isFavorite: isFavorite,
              onPressed: onToggleFavorite,
              size: AppDimens.iconMd,
            ),
          ],
        ),
        const Divider(height: AppDimens.spaceLg, color: AppColors.border),
        const SizedBox(height: AppDimens.spaceSm),
        Center(
          child: ContactAvatar(contact: contact, size: AppDimens.avatarLg),
        ),
        const SizedBox(height: AppDimens.spaceMd),
        Text(
          contact.name,
          textAlign: TextAlign.center,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          contact.role,
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppDimens.spaceMd - 4),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppDimens.spaceSm,
          runSpacing: AppDimens.spaceSm,
          children: [
            DepartmentBadge(department: contact.department, large: true),
            StatusIndicator(active: contact.active, asChip: true),
          ],
        ),
        const SizedBox(height: AppDimens.spaceLg),
        Container(
          padding: const EdgeInsets.all(AppDimens.spaceMd),
          decoration: BoxDecoration(
            color: AppColors.inputFill,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _InfoRow(
                icon: Icons.alternate_email_rounded,
                label: AppStrings.emailLabel,
                value: contact.email,
              ),
              const SizedBox(height: AppDimens.spaceMd - 2),
              _InfoRow(
                icon: Icons.call_rounded,
                label: AppStrings.phoneLabel,
                value: contact.phone,
              ),
              const SizedBox(height: AppDimens.spaceMd - 2),
              _InfoRow(
                icon: Icons.apartment_rounded,
                label: AppStrings.departmentLabel,
                value: contact.department,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  final String text;

  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
        color: AppColors.textSecondary,
      ),
    );
  }
}

/// Fila de dato: ícono en un cuadrito blanco, etiqueta y valor (seleccionable).
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: AppDimens.iconMd + 12,
          height: AppDimens.iconMd + 12,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(icon, size: AppDimens.iconSm, color: AppColors.primary),
        ),
        const SizedBox(width: AppDimens.spaceMd - 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Label(label),
              const SizedBox(height: 2),
              SelectableText(
                value,
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Ficha fantasma mientras carga el detalle.
class ContactDetailSkeleton extends StatelessWidget {
  const ContactDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Shimmer(
      child: Column(
        children: [
          Row(
            children: [
              SkeletonBox(width: 140, height: 10),
              Spacer(),
              SkeletonBox(
                width: AppDimens.iconMd,
                height: AppDimens.iconMd,
                circle: true,
              ),
            ],
          ),
          SizedBox(height: AppDimens.spaceXl),
          SkeletonBox(
            width: AppDimens.avatarLg,
            height: AppDimens.avatarLg,
            circle: true,
          ),
          SizedBox(height: AppDimens.spaceMd),
          SkeletonBox(width: 180, height: 20),
          SizedBox(height: AppDimens.spaceSm),
          SkeletonBox(width: 120, height: 12),
          SizedBox(height: AppDimens.spaceMd),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SkeletonBox(width: 80, height: 22),
              SizedBox(width: AppDimens.spaceSm),
              SkeletonBox(width: 70, height: 22),
            ],
          ),
          SizedBox(height: AppDimens.spaceLg),
          SkeletonBox(width: double.infinity, height: 170),
        ],
      ),
    );
  }
}
