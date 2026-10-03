import 'package:flutter/material.dart';

/// Tier 1 primitives. Named by hue and step. Never applied in a widget.
abstract final class AppPalette {
  const AppPalette._();

  static const Color accent50 = Color(0xFFF3F6FF);
  static const Color accent100 = Color(0xFFE4EBFE);
  static const Color accent200 = Color(0xFFCAD8FE);
  static const Color accent300 = Color(0xFFA4BBFE);
  static const Color accent400 = Color(0xFF7593FD);
  static const Color accent500 = Color(0xFF516EF6);
  static const Color accent600 = Color(0xFF3E55E3);
  static const Color accent700 = Color(0xFF3447C5);
  static const Color accent800 = Color(0xFF2A3AA4);
  static const Color accent900 = Color(0xFF24338A);
  static const Color accent950 = Color(0xFF131D5B);

  static const Color neutral50 = Color(0xFFF7FAFD);
  static const Color neutral100 = Color(0xFFEEF1F6);
  static const Color neutral200 = Color(0xFFDEE2E8);
  static const Color neutral300 = Color(0xFFCBD0D7);
  static const Color neutral400 = Color(0xFFACB2BA);
  static const Color neutral500 = Color(0xFF899099);
  static const Color neutral600 = Color(0xFF6E757F);
  static const Color neutral700 = Color(0xFF575E68);
  static const Color neutral800 = Color(0xFF404751);
  static const Color neutral900 = Color(0xFF2A313A);
  static const Color neutral950 = Color(0xFF161C24);

  static const Color category50 = Color(0xFFFFEFDE);
  static const Color category100 = Color(0xFFFED4A5);
  static const Color category300 = Color(0xFFF0A43D);
  static const Color category400 = Color(0xFFDE8F13);
  static const Color category500 = Color(0xFFC47E0C);
  static const Color category600 = Color(0xFFA06608);
  static const Color category700 = Color(0xFF825102);
  static const Color category800 = Color(0xFF653E01);
  static const Color category900 = Color(0xFF482C01);

  static const Color success50 = Color(0xFFDFFAE5);
  static const Color success100 = Color(0xFFAEECBE);
  static const Color success300 = Color(0xFF62D286);
  static const Color success400 = Color(0xFF40BF6F);
  static const Color success500 = Color(0xFF2BA95D);
  static const Color success600 = Color(0xFF168B49);
  static const Color success700 = Color(0xFF10703A);
  static const Color success800 = Color(0xFF005729);
  static const Color success900 = Color(0xFF003E1C);

  static const Color danger50 = Color(0xFFFDEBE9);
  static const Color danger100 = Color(0xFFFFC9C1);
  static const Color danger300 = Color(0xFFFF8B7D);
  static const Color danger400 = Color(0xFFFB6254);
  static const Color danger500 = Color(0xFFE4473D);
  static const Color danger600 = Color(0xFFC33029);
  static const Color danger700 = Color(0xFFA12721);
  static const Color danger800 = Color(0xFF831B16);
  static const Color danger900 = Color(0xFF620A09);
}

/// Tier 2 semantics. Named by the job they do. This is the only tier widgets
/// reference, so a theme change repoints these and leaves every widget alone.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.bgPage,
    required this.bgSurface,
    required this.bgSunken,
    required this.bgRaised,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textOnAccent,
    required this.borderSubtle,
    required this.borderDefault,
    required this.borderStrong,
    required this.borderSeparator,
    required this.borderFocus,
    required this.accentSubtle,
    required this.accentSolid,
    required this.accentHover,
    required this.accentText,
    required this.categorySubtle,
    required this.categorySolid,
    required this.categoryText,
    required this.successSubtle,
    required this.successSolid,
    required this.successText,
    required this.dangerSubtle,
    required this.dangerSolid,
    required this.dangerText,
  });

  final Color bgPage;
  final Color bgSurface;
  final Color bgSunken;
  final Color bgRaised;

  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textOnAccent;

  final Color borderSubtle;
  final Color borderDefault;
  final Color borderStrong;
  final Color borderSeparator;
  final Color borderFocus;

  final Color accentSubtle;
  final Color accentSolid;
  final Color accentHover;
  final Color accentText;

  final Color categorySubtle;
  final Color categorySolid;
  final Color categoryText;

  final Color successSubtle;
  final Color successSolid;
  final Color successText;

  final Color dangerSubtle;
  final Color dangerSolid;
  final Color dangerText;

  static const AppColors light = AppColors(
    bgPage: AppPalette.neutral50,
    bgSurface: Color(0xFFFFFFFF),
    bgSunken: AppPalette.neutral100,
    bgRaised: Color(0xFFFFFFFF),
    textPrimary: AppPalette.neutral900,
    textSecondary: AppPalette.neutral700,
    textMuted: AppPalette.neutral600,
    textOnAccent: Color(0xFFFFFFFF),
    borderSubtle: AppPalette.neutral200,
    borderDefault: AppPalette.neutral500,
    borderStrong: AppPalette.neutral400,
    borderSeparator: AppPalette.neutral300,
    borderFocus: AppPalette.accent600,
    accentSubtle: AppPalette.accent50,
    accentSolid: AppPalette.accent600,
    accentHover: AppPalette.accent700,
    accentText: AppPalette.accent700,
    categorySubtle: AppPalette.category50,
    categorySolid: AppPalette.category500,
    categoryText: AppPalette.category700,
    successSubtle: AppPalette.success50,
    successSolid: AppPalette.success500,
    successText: AppPalette.success700,
    dangerSubtle: AppPalette.danger50,
    dangerSolid: AppPalette.danger600,
    dangerText: AppPalette.danger700,
  );

  static const AppColors dark = AppColors(
    bgPage: AppPalette.neutral950,
    bgSurface: AppPalette.neutral900,
    bgSunken: AppPalette.neutral800,
    bgRaised: AppPalette.neutral800,
    textPrimary: AppPalette.neutral50,
    textSecondary: AppPalette.neutral300,
    textMuted: AppPalette.neutral400,
    textOnAccent: AppPalette.neutral950,
    borderSubtle: AppPalette.neutral700,
    borderDefault: AppPalette.neutral500,
    borderStrong: AppPalette.neutral400,
    borderSeparator: AppPalette.neutral700,
    borderFocus: AppPalette.accent300,
    accentSubtle: AppPalette.accent900,
    accentSolid: AppPalette.accent400,
    accentHover: AppPalette.accent300,
    accentText: AppPalette.accent300,
    categorySubtle: AppPalette.category900,
    categorySolid: AppPalette.category400,
    categoryText: AppPalette.category300,
    successSubtle: AppPalette.success900,
    successSolid: AppPalette.success400,
    successText: AppPalette.success300,
    dangerSubtle: AppPalette.danger900,
    dangerSolid: AppPalette.danger400,
    dangerText: AppPalette.danger300,
  );

  @override
  AppColors copyWith({
    Color? bgPage,
    Color? bgSurface,
    Color? bgSunken,
    Color? bgRaised,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? textOnAccent,
    Color? borderSubtle,
    Color? borderDefault,
    Color? borderStrong,
    Color? borderSeparator,
    Color? borderFocus,
    Color? accentSubtle,
    Color? accentSolid,
    Color? accentHover,
    Color? accentText,
    Color? categorySubtle,
    Color? categorySolid,
    Color? categoryText,
    Color? successSubtle,
    Color? successSolid,
    Color? successText,
    Color? dangerSubtle,
    Color? dangerSolid,
    Color? dangerText,
  }) {
    return AppColors(
      bgPage: bgPage ?? this.bgPage,
      bgSurface: bgSurface ?? this.bgSurface,
      bgSunken: bgSunken ?? this.bgSunken,
      bgRaised: bgRaised ?? this.bgRaised,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      textOnAccent: textOnAccent ?? this.textOnAccent,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderDefault: borderDefault ?? this.borderDefault,
      borderStrong: borderStrong ?? this.borderStrong,
      borderSeparator: borderSeparator ?? this.borderSeparator,
      borderFocus: borderFocus ?? this.borderFocus,
      accentSubtle: accentSubtle ?? this.accentSubtle,
      accentSolid: accentSolid ?? this.accentSolid,
      accentHover: accentHover ?? this.accentHover,
      accentText: accentText ?? this.accentText,
      categorySubtle: categorySubtle ?? this.categorySubtle,
      categorySolid: categorySolid ?? this.categorySolid,
      categoryText: categoryText ?? this.categoryText,
      successSubtle: successSubtle ?? this.successSubtle,
      successSolid: successSolid ?? this.successSolid,
      successText: successText ?? this.successText,
      dangerSubtle: dangerSubtle ?? this.dangerSubtle,
      dangerSolid: dangerSolid ?? this.dangerSolid,
      dangerText: dangerText ?? this.dangerText,
    );
  }

  @override
  AppColors lerp(covariant AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      bgPage: Color.lerp(bgPage, other.bgPage, t)!,
      bgSurface: Color.lerp(bgSurface, other.bgSurface, t)!,
      bgSunken: Color.lerp(bgSunken, other.bgSunken, t)!,
      bgRaised: Color.lerp(bgRaised, other.bgRaised, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textOnAccent: Color.lerp(textOnAccent, other.textOnAccent, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      borderDefault: Color.lerp(borderDefault, other.borderDefault, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      borderSeparator: Color.lerp(borderSeparator, other.borderSeparator, t)!,
      borderFocus: Color.lerp(borderFocus, other.borderFocus, t)!,
      accentSubtle: Color.lerp(accentSubtle, other.accentSubtle, t)!,
      accentSolid: Color.lerp(accentSolid, other.accentSolid, t)!,
      accentHover: Color.lerp(accentHover, other.accentHover, t)!,
      accentText: Color.lerp(accentText, other.accentText, t)!,
      categorySubtle: Color.lerp(categorySubtle, other.categorySubtle, t)!,
      categorySolid: Color.lerp(categorySolid, other.categorySolid, t)!,
      categoryText: Color.lerp(categoryText, other.categoryText, t)!,
      successSubtle: Color.lerp(successSubtle, other.successSubtle, t)!,
      successSolid: Color.lerp(successSolid, other.successSolid, t)!,
      successText: Color.lerp(successText, other.successText, t)!,
      dangerSubtle: Color.lerp(dangerSubtle, other.dangerSubtle, t)!,
      dangerSolid: Color.lerp(dangerSolid, other.dangerSolid, t)!,
      dangerText: Color.lerp(dangerText, other.dangerText, t)!,
    );
  }
}

extension AppColorsContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}

/// The categorical hues a peer group can be told apart by. Two hues, because
/// two things must be distinguishable at a glance; a third earns its place the
/// day a third category ships.
enum GoalCategory { accent, category }

extension GoalCategoryColors on GoalCategory {
  Color solid(AppColors colors) => switch (this) {
    GoalCategory.accent => colors.accentSolid,
    GoalCategory.category => colors.categorySolid,
  };

  Color subtle(AppColors colors) => switch (this) {
    GoalCategory.accent => colors.accentSubtle,
    GoalCategory.category => colors.categorySubtle,
  };

  Color text(AppColors colors) => switch (this) {
    GoalCategory.accent => colors.accentText,
    GoalCategory.category => colors.categoryText,
  };
}