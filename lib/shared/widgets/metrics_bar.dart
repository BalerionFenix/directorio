import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_strings.dart';
import 'glass_panel.dart';
import 'loading_skeleton.dart';
import 'pop_in.dart';

/// Barra de 4 métricas: total, activos, inactivos y favoritos.
/// Con [isLoading] muestra skeletons en lugar de los números.
class MetricsBar extends StatelessWidget {
  final int total;
  final int active;
  final int favorites;
  final bool isLoading;

  const MetricsBar({
    super.key,
    required this.total,
    required this.active,
    required this.favorites,
    this.isLoading = false,
  });

  const MetricsBar.loading({super.key})
    : total = 0,
      active = 0,
      favorites = 0,
      isLoading = true;

  int _percent(int value) => total == 0 ? 0 : (value * 100 / total).round();

  @override
  Widget build(BuildContext context) {
    final inactive = total - active;
    final items = [
      _MetricData(
        label: AppStrings.metricTotal,
        value: total,
        caption: AppStrings.metricTotalCaption,
        icon: Icons.groups_rounded,
        color: AppColors.primary,
        tint: AppColors.primaryTint,
      ),
      _MetricData(
        label: AppStrings.metricActive,
        value: active,
        caption: AppStrings.percentOfTotal(_percent(active)),
        icon: Icons.verified_user_rounded,
        color: AppColors.active,
        tint: AppColors.activeLight,
        dot: AppColors.active,
      ),
      _MetricData(
        label: AppStrings.metricInactive,
        value: inactive,
        caption: AppStrings.percentOfTotal(_percent(inactive)),
        icon: Icons.person_off_rounded,
        color: AppColors.textSecondary,
        tint: AppColors.inactiveLight,
        dot: AppColors.inactive,
      ),
      _MetricData(
        label: AppStrings.metricFavorites,
        value: favorites,
        caption: AppStrings.metricFavoritesCaption,
        icon: Icons.star_rounded,
        color: AppColors.favoriteDark,
        tint: AppColors.favoriteLight,
        captionIcon: Icons.star_rounded,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 640 ? 4 : 2;
        final rows = <Widget>[];
        for (var i = 0; i < items.length; i += columns) {
          if (i > 0) rows.add(const SizedBox(height: AppDimens.spaceMd));
          rows.add(
            Row(
              children: [
                for (var j = i; j < i + columns && j < items.length; j++) ...[
                  if (j > i) const SizedBox(width: AppDimens.spaceMd),
                  Expanded(
                    child: PopIn(
                      index: j,
                      child: _MetricCard(data: items[j], isLoading: isLoading),
                    ),
                  ),
                ],
              ],
            ),
          );
        }
        return Column(mainAxisSize: MainAxisSize.min, children: rows);
      },
    );
  }
}

class _MetricData {
  final String label;
  final int value;
  final String caption;
  final IconData icon;
  final Color color;
  final Color tint;
  final Color? dot;
  final IconData? captionIcon;

  const _MetricData({
    required this.label,
    required this.value,
    required this.caption,
    required this.icon,
    required this.color,
    required this.tint,
    this.dot,
    this.captionIcon,
  });
}

class _MetricCard extends StatelessWidget {
  final _MetricData data;
  final bool isLoading;

  const _MetricCard({required this.data, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GlassPanel(
      padding: const EdgeInsets.all(AppDimens.spaceMd + 2),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDimens.spaceXs),
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppDimens.spaceSm),
                    child: Shimmer(child: SkeletonBox(width: 48, height: 22)),
                  )
                else
                  TweenAnimationBuilder<int>(
                    tween: IntTween(begin: 0, end: data.value),
                    duration: AppDurations.countUp,
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) => Text(
                      '$value',
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                const SizedBox(height: AppDimens.spaceXs),
                Row(
                  children: [
                    if (data.dot != null) ...[
                      Container(
                        width: AppDimens.statusDotSm + 2,
                        height: AppDimens.statusDotSm + 2,
                        decoration: BoxDecoration(
                          color: data.dot,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppDimens.spaceXs + 2),
                    ],
                    if (data.captionIcon != null) ...[
                      Icon(
                        data.captionIcon,
                        size: 15,
                        color: AppColors.favorite,
                      ),
                      const SizedBox(width: AppDimens.spaceXs),
                    ],
                    Flexible(
                      child: Text(
                        isLoading ? '' : data.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: data.color,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimens.spaceSm),
          Container(
            width: AppDimens.metricIconBox,
            height: AppDimens.metricIconBox,
            decoration: BoxDecoration(
              color: data.tint,
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            ),
            child: Icon(
              data.icon,
              color: data.color,
              size: AppDimens.iconMd - 2,
            ),
          ),
        ],
      ),
    );
  }
}
