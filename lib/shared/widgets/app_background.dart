import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';

/// Fondo de la app con manchas de color difuminadas. Le da algo que
/// "desenfocar" a los paneles de vidrio.
class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Stack(
        children: [
          const Positioned(
            top: -160,
            left: -120,
            child: _Blob(AppColors.blobPrimary),
          ),
          const Positioned(
            top: 80,
            right: -180,
            child: _Blob(AppColors.blobDesign),
          ),
          const Positioned(
            bottom: -200,
            left: 120,
            child: _Blob(AppColors.blobEngineering),
          ),
          const Positioned(
            bottom: -140,
            right: 60,
            child: _Blob(AppColors.blobPeople),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final Color color;

  const _Blob(this.color);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: AppDimens.blobSize,
        height: AppDimens.blobSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, AppColors.transparent]),
        ),
      ),
    );
  }
}
