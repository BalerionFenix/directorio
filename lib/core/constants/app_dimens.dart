/// Medidas, breakpoints y duraciones de la app.
abstract final class AppDimens {
  // Breakpoint del layout maestro-detalle (px lógicos)
  static const double masterDetailBreakpoint = 900;

  // Espaciados
  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 16;
  static const double spaceLg = 24;
  static const double spaceXl = 32;
  static const double spaceXxl = 48;

  // Bordes
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 20;
  static const double radiusPill = 999;

  // Tamaños
  static const double avatarSm = 44;
  static const double avatarMd = 56;
  static const double avatarLg = 96;
  static const double iconSm = 18;
  static const double iconMd = 24;
  static const double iconLg = 64;
  static const double maxContentWidth = 1440;
  static const double listPanelWidth =
      0.58; // fracción del ancho en pantalla ancha
  static const double cardMaxWidth = 280;
  static const double gridItemMaxWidth =
      400; // ≈ 2 columnas en el panel de la lista
  static const double gridItemHeight = 172;
  static const double listTileHeight = 76;
  static const double searchHeight = 44;
  static const double chipHeight = 32;
  static const double statusDot = 14;
  static const double statusDotSm = 6;
  static const double metricIconBox = 44;

  // Vidrio
  static const double glassBlur = 18;
  static const double blobSize = 520;

  // Animación pop
  static const double popStartScale = 0.6;
  static const int popMaxStaggered = 10; // a partir de aquí no se espera más
  static const double messageMaxWidth =
      420; // vistas de error, vacío, no encontrado
}

/// Duraciones de animaciones y de la simulación de red.
abstract final class AppDurations {
  static const Duration networkDelay = Duration(milliseconds: 800);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration flip = Duration(milliseconds: 600);
  static const Duration staggerStep = Duration(milliseconds: 40);
  static const Duration pop = Duration(milliseconds: 350);
  static const Duration popStagger = Duration(milliseconds: 60);
  static const Duration countUp = Duration(milliseconds: 800);
  static const Duration skeletonPulse = Duration(milliseconds: 1200);
}
