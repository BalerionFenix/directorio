import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';

/// Panel tipo vidrio: blanco translúcido, borde claro y sombra suave.
///
/// [blur] activa el desenfoque del fondo. Se usa en los paneles grandes;
/// en las tarjetas va apagado porque muchos desenfoques a la vez son pesados en web.
class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool blur;
  final Color? color;
  final Color? borderColor;
  final double borderWidth;
  final List<BoxShadow>? shadows;

  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppDimens.spaceLg),
    this.radius = AppDimens.radiusLg,
    this.blur = true,
    this.color,
    this.borderColor,
    this.borderWidth = 1,
    this.shadows,
  });

  static const List<BoxShadow> defaultShadow = [
    BoxShadow(color: AppColors.shadow, blurRadius: 16, offset: Offset(0, 4)),
  ];

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);

    Widget content = AnimatedContainer(
      duration: AppDurations.fast,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? (blur ? AppColors.glass : AppColors.glassStrong),
        borderRadius: borderRadius,
        border: Border.all(
          color: borderColor ?? AppColors.glassBorder,
          width: borderWidth,
        ),
      ),
      child: child,
    );

    if (blur) {
      content = BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppDimens.glassBlur,
          sigmaY: AppDimens.glassBlur,
        ),
        child: content,
      );
    }

    return AnimatedContainer(
      duration: AppDurations.fast,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: shadows ?? defaultShadow,
      ),
      child: ClipRRect(borderRadius: borderRadius, child: content),
    );
  }
}
