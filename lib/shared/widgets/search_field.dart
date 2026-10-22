import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_strings.dart';

/// Buscador con lupa y botón ✕. Avisa cada cambio en tiempo real.
///
/// [value] permite limpiarlo desde fuera (ej. "Limpiar filtros").
/// Si se pasa [onClear], la ✕ llama a esa acción (ej. restablecer búsqueda y
/// filtro) y se muestra también cuando [hasFilters] es true aunque no haya texto.
class SearchField extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final bool hasFilters;
  final bool enabled;

  const SearchField({
    super.key,
    required this.value,
    required this.onChanged,
    this.onClear,
    this.hasFilters = false,
    this.enabled = true,
  });

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.value,
  );

  @override
  void didUpdateWidget(SearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    final onClear = widget.onClear;
    onClear != null ? onClear() : widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      borderSide: const BorderSide(color: AppColors.border),
    );

    return SizedBox(
      height: AppDimens.searchHeight,
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: _controller,
        builder: (context, value, _) => TextField(
          controller: _controller,
          enabled: widget.enabled,
          onChanged: widget.onChanged,
          textAlignVertical: TextAlignVertical.center,
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: AppStrings.searchHint,
            hintStyle: const TextStyle(color: AppColors.hint, fontSize: 14),
            filled: true,
            fillColor: AppColors.inputFill,
            contentPadding: EdgeInsets.zero,
            prefixIcon: const Icon(Icons.search_rounded, color: AppColors.hint),
            suffixIcon: value.text.isEmpty && !widget.hasFilters
                ? null
                : IconButton(
                    tooltip: widget.onClear != null
                        ? AppStrings.clearFilters
                        : AppStrings.clearSearch,
                    onPressed: _clear,
                    icon: const Icon(
                      Icons.close_rounded,
                      size: AppDimens.iconSm,
                    ),
                    color: AppColors.hint,
                    hoverColor: AppColors.primaryTint,
                  ),
            border: border,
            enabledBorder: border,
            disabledBorder: border,
            focusedBorder: border.copyWith(
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
