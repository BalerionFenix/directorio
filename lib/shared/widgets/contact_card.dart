import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../data/models/contact.dart';
import 'contact_avatar.dart';
import 'department_chips.dart';
import 'favorite_button.dart';
import 'glass_panel.dart';
import 'status_indicator.dart';

/// Tarjeta de vidrio de la grilla (pantalla ancha).
class ContactCard extends StatefulWidget {
  final Contact contact;
  final bool isFavorite;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  const ContactCard({
    super.key,
    required this.contact,
    required this.isFavorite,
    required this.isSelected,
    required this.onTap,
    required this.onToggleFavorite,
  });

  @override
  State<ContactCard> createState() => _ContactCardState();
}

class _ContactCardState extends State<ContactCard> {
  bool _hover = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final contact = widget.contact;
    final selected = widget.isSelected;
    // Con teclado (Tab) la tarjeta enfocada se marca con el borde primario.
    final highlighted = selected || _focused;
    final textTheme = Theme.of(context).textTheme;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedSlide(
        duration: AppDurations.fast,
        offset: _hover && !selected ? const Offset(0, -0.015) : Offset.zero,
        child: Opacity(
          opacity: contact.active ? 1 : 0.9,
          // InkWell (no GestureDetector): enfocable con Tab, se activa con
          // Enter/Espacio y se anuncia como botón a los lectores de pantalla.
          child: Material(
            color: AppColors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              onFocusChange: (focused) => setState(() => _focused = focused),
              borderRadius: BorderRadius.circular(AppDimens.radiusLg - 4),
              child: GlassPanel(
                blur: false,
                radius: AppDimens.radiusLg - 4,
                padding: const EdgeInsets.all(AppDimens.spaceMd),
                color: selected ? AppColors.primaryTint : null,
                borderColor: highlighted
                    ? AppColors.primary
                    : _hover
                    ? AppColors.primaryLight
                    : null,
                borderWidth: highlighted ? 2 : 1,
                shadows: [
                  BoxShadow(
                    color: selected
                        ? AppColors.shadowPrimary
                        : AppColors.shadow,
                    blurRadius: _hover || selected ? 18 : 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ContactAvatar(contact: contact),
                        const Spacer(),
                        FavoriteButton(
                          isFavorite: widget.isFavorite,
                          onPressed: widget.onToggleFavorite,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimens.spaceMd - 4),
                    AnimatedDefaultTextStyle(
                      duration: AppDurations.fast,
                      style: textTheme.titleSmall!.copyWith(
                        fontWeight: FontWeight.w700,
                        color: _hover || selected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                      child: Text(
                        contact.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      contact.role,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        DepartmentBadge(department: contact.department),
                        const Spacer(),
                        StatusIndicator(active: contact.active),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Fila de la lista (pantalla angosta): burbuja + nombre + rol + estrella.
class ContactTile extends StatelessWidget {
  final Contact contact;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  const ContactTile({
    super.key,
    required this.contact,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        child: SizedBox(
          height: AppDimens.listTileHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.spaceSm),
            child: Row(
              children: [
                ContactAvatar(contact: contact, size: AppDimens.avatarSm),
                const SizedBox(width: AppDimens.spaceMd - 4),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        contact.role,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                FavoriteButton(
                  isFavorite: isFavorite,
                  onPressed: onToggleFavorite,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
