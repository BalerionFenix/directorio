import 'package:flutter/material.dart';

import 'app_strings.dart';

/// Paleta centralizada de la app.
abstract final class AppColors {
  // Marca
  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFFE0E7FF);
  static const Color primaryTint = Color(0xFFEEF2FF);
  static const Color secondary = Color(0xFF0EA5E9);

  // Vidrio (glass)
  static const Color glass = Color(0x99FFFFFF); // blanco al 60 %
  static const Color glassStrong = Color(0xCCFFFFFF); // blanco al 80 %
  static const Color glassBorder = Color(0xB3FFFFFF); // blanco al 70 %
  static const Color shadow = Color(0x0F1F2937);
  static const Color shadowPrimary = Color(0x294F46E5);

  // Manchas del fondo
  static const Color blobPrimary = Color(0x2E4F46E5);
  static const Color blobDesign = Color(0x24DB2777);
  static const Color blobEngineering = Color(0x242563EB);
  static const Color blobPeople = Color(0x1F059669);
  static const Color transparent = Color(0x00FFFFFF);

  // Campos
  static const Color inputFill = Color(0xB3F9FAFB);
  static const Color hint = Color(0xFF9CA3AF);

  // Fondos y superficies
  static const Color background = Color(0xFFF6F7FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F3F9);
  static const Color border = Color(0xFFE4E7EF);

  // Texto
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Estados
  static const Color active = Color(0xFF16A34A);
  static const Color activeLight = Color(0xFFDCFCE7);
  static const Color inactive = Color(0xFF9CA3AF);
  static const Color inactiveLight = Color(0xFFF3F4F6);
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color favorite = Color(0xFFF59E0B);
  static const Color favoriteLight = Color(0xFFFEF3C7);
  static const Color favoriteDark = Color(0xFFD97706);

  // Skeleton
  static const Color skeletonBase = Color(0xFFE5E7EB);
  static const Color skeletonHighlight = Color(0xFFF3F4F6);

  // Departamentos
  static const Color commercial = Color(0xFFEA580C);
  static const Color design = Color(0xFFDB2777);
  static const Color engineering = Color(0xFF2563EB);
  static const Color people = Color(0xFF059669);
  static const Color departmentFallback = Color(0xFF64748B);

  static const Map<String, Color> _departmentColors = {
    AppStrings.departmentCommercial: commercial,
    AppStrings.departmentDesign: design,
    AppStrings.departmentEngineering: engineering,
    AppStrings.departmentPeople: people,
  };

  /// Color asociado a un departamento (burbuja de contacto, chips).
  static Color forDepartment(String department) =>
      _departmentColors[department] ?? departmentFallback;

  /// Fondo suave (12 %) del color de un departamento, para sus chips.
  static Color tintForDepartment(String department) =>
      forDepartment(department).withValues(alpha: 0.12);
}
