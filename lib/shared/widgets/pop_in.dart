import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_dimens.dart';

/// Hace aparecer a su hijo con un "pop": crece del 60 % al 100 % con un
/// pequeño rebote. [index] escalona la entrada (uno tras otro).
class PopIn extends StatefulWidget {
  final int index;
  final Widget child;

  /// En `false` el hijo aparece directo, sin pop (ej. al volver a verlo con scroll).
  final bool animate;

  const PopIn({
    super.key,
    required this.index,
    required this.child,
    this.animate = true,
  });

  @override
  State<PopIn> createState() => _PopInState();
}

class _PopInState extends State<PopIn> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDurations.pop,
  );

  late final Animation<double> _scale = Tween<double>(
    begin: AppDimens.popStartScale,
    end: 1,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

  late final Animation<double> _opacity = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );

  Timer? _delay;

  @override
  void initState() {
    super.initState();
    final step = widget.index.clamp(0, AppDimens.popMaxStaggered);
    if (!widget.animate) {
      _controller.value = 1;
    } else if (step == 0) {
      _controller.forward();
    } else {
      _delay = Timer(AppDurations.popStagger * step, _controller.forward);
    }
  }

  @override
  void dispose() {
    _delay?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}
