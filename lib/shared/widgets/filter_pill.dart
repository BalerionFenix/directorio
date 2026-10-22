import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';

/// Píldora de filtro: rellena con el color primario si está elegida; al pasar
/// el mouse el borde y el texto toman el color [accent].
class FilterPill extends StatefulWidget {
  final String label;
  final Color accent;
  final bool isSelected;
  final VoidCallback? onTap;
  final IconData? icon;

  const FilterPill({
    super.key,
    required this.label,
    required this.accent,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  @override
  State<FilterPill> createState() => _FilterPillState();
}

class _FilterPillState extends State<FilterPill> {
  bool _hover = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final selected = widget.isSelected;
    // Hover con mouse o foco con teclado (Tab) se marcan igual.
    final hover = (_hover || _focused) && !selected && widget.onTap != null;
    final foreground = selected
        ? AppColors.textOnPrimary
        : hover
        ? widget.accent
        : AppColors.textSecondary;

    return MouseRegion(
      cursor: widget.onTap == null
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Semantics(
        button: true,
        selected: selected,
        // InkWell (no GestureDetector): enfocable con Tab y se activa con
        // Enter/Espacio.
        child: Material(
          color: AppColors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            onFocusChange: (focused) => setState(() => _focused = focused),
            customBorder: const StadiumBorder(),
            child: AnimatedContainer(
              duration: AppDurations.normal,
              curve: Curves.easeOut,
              height: AppDimens.chipHeight,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.spaceMd,
              ),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.inputFill,
                borderRadius: BorderRadius.circular(AppDimens.radiusPill),
                border: Border.all(
                  color: selected
                      ? AppColors.primary
                      : hover
                      ? widget.accent
                      : AppColors.border,
                  width: _focused ? 2 : 1,
                ),
                boxShadow: selected
                    ? const [
                        BoxShadow(
                          color: AppColors.shadowPrimary,
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      size: AppDimens.statusDotSm + 2,
                      color: selected ? AppColors.textOnPrimary : widget.accent,
                    ),
                    const SizedBox(width: AppDimens.spaceXs + 2),
                  ],
                  AnimatedDefaultTextStyle(
                    duration: AppDurations.normal,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: foreground,
                    ),
                    child: Text(widget.label),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Fila de píldoras: con [Wrap] en pantalla ancha o deslizable en angosta.
class FilterPillRow extends StatelessWidget {
  final List<Widget> pills;
  final bool scrollable;

  const FilterPillRow({
    super.key,
    required this.pills,
    this.scrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!scrollable) {
      return Wrap(
        spacing: AppDimens.spaceSm,
        runSpacing: AppDimens.spaceSm,
        children: pills,
      );
    }
    return SizedBox(
      height: AppDimens.chipHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: pills.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppDimens.spaceSm),
        itemBuilder: (_, i) => pills[i],
      ),
    );
  }
}
