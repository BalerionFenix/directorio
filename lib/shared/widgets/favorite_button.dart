import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_strings.dart';

/// Estrella para marcar/desmarcar favorito, con un pequeño rebote al cambiar.
class FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onPressed;
  final double size;

  const FavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onPressed,
    this.size = AppDimens.iconMd - 4,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: isFavorite ? AppStrings.removeFavorite : AppStrings.addFavorite,
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      hoverColor: AppColors.favoriteLight,
      icon: AnimatedSwitcher(
        duration: AppDurations.normal,
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.elasticOut),
          child: child,
        ),
        child: Icon(
          isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
          key: ValueKey(isFavorite),
          size: size,
          color: isFavorite ? AppColors.favorite : AppColors.hint,
        ),
      ),
    );
  }
}
