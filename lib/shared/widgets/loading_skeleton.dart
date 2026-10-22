import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import 'glass_panel.dart';

/// Brillo que recorre de izquierda a derecha a todos los [SkeletonBox] hijos.
class Shimmer extends StatefulWidget {
  final Widget child;

  const Shimmer({super.key, required this.child});

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDurations.skeletonPulse,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final t =
            _controller.value * 3 - 1; // -1 → 2: el brillo cruza todo el ancho
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) => LinearGradient(
            colors: const [
              AppColors.skeletonBase,
              AppColors.skeletonHighlight,
              AppColors.skeletonBase,
            ],
            stops: [t - 0.3, t, t + 0.3].map((s) => s.clamp(0.0, 1.0)).toList(),
          ).createShader(bounds),
          child: child,
        );
      },
    );
  }
}

/// Bloque gris del skeleton.
class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final bool circle;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.circle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.skeletonBase,
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(AppDimens.radiusSm),
      ),
    );
  }
}

/// Tarjeta fantasma con la misma forma de [ContactCard].
class ContactCardSkeleton extends StatelessWidget {
  const ContactCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const GlassPanel(
      blur: false,
      radius: AppDimens.radiusLg - 4,
      padding: EdgeInsets.all(AppDimens.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeletonBox(
                width: AppDimens.avatarMd,
                height: AppDimens.avatarMd,
                circle: true,
              ),
              Spacer(),
              SkeletonBox(
                width: AppDimens.iconMd,
                height: AppDimens.iconMd,
                circle: true,
              ),
            ],
          ),
          SizedBox(height: AppDimens.spaceMd),
          SkeletonBox(width: 140, height: 14),
          SizedBox(height: AppDimens.spaceSm),
          SkeletonBox(width: 100, height: 10),
          Spacer(),
          Row(
            children: [
              SkeletonBox(width: 72, height: 18),
              Spacer(),
              SkeletonBox(width: 52, height: 10),
            ],
          ),
        ],
      ),
    );
  }
}

/// Fila fantasma con la misma forma de [ContactTile].
class ContactTileSkeleton extends StatelessWidget {
  const ContactTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: AppDimens.listTileHeight,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppDimens.spaceSm),
        child: Row(
          children: [
            SkeletonBox(
              width: AppDimens.avatarSm,
              height: AppDimens.avatarSm,
              circle: true,
            ),
            SizedBox(width: AppDimens.spaceMd - 4),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 150, height: 14),
                  SizedBox(height: AppDimens.spaceSm),
                  SkeletonBox(width: 100, height: 10),
                ],
              ),
            ),
            SkeletonBox(
              width: AppDimens.iconMd,
              height: AppDimens.iconMd,
              circle: true,
            ),
          ],
        ),
      ),
    );
  }
}
