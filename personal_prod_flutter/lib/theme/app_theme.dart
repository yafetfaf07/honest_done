import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_prod/theme/colors.dart';
import 'package:personal_prod/theme/surfaces.dart';

abstract final class AppTheme {
  const AppTheme._();

  static ThemeData light() => _build(Brightness.light, AppColors.light);

  static ThemeData dark() => _build(Brightness.dark, AppColors.dark);

  static ThemeData _build(Brightness brightness, AppColors colors) {
    final base = ThemeData(
      brightness: brightness,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppPalette.accent600,
        brightness: brightness,
      ),
    );

    return base.copyWith(
      extensions: <ThemeExtension<dynamic>>[colors],
      scaffoldBackgroundColor: colors.bgPage,
      colorScheme: base.colorScheme.copyWith(
        primary: colors.accentSolid,
        onPrimary: colors.textOnAccent,
        surface: colors.bgSurface,
        onSurface: colors.textPrimary,
        error: colors.dangerSolid,
        onError: colors.textOnAccent,
      ),
      textTheme: GoogleFonts.outfitTextTheme(base.textTheme).apply(
        bodyColor: colors.textPrimary,
        displayColor: colors.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.bgPage,
        foregroundColor: colors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      dividerColor: colors.borderSeparator,
      dividerTheme: DividerThemeData(
        color: colors.borderSeparator,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.accentSolid,
        linearTrackColor: colors.bgSunken,
        circularTrackColor: colors.bgSunken,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.accentSolid,
          foregroundColor: colors.textOnAccent,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.accentSolid,
          foregroundColor: colors.textOnAccent,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.accentSolid,
        foregroundColor: colors.textOnAccent,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: colors.accentText),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.textPrimary,
          side: BorderSide(color: colors.borderDefault),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.bgSurface,
        hintStyle: TextStyle(color: colors.textMuted),
        labelStyle: TextStyle(color: colors.textSecondary),
        border: _inputBorder(colors.borderDefault),
        enabledBorder: _inputBorder(colors.borderDefault),
        focusedBorder: _inputBorder(colors.borderFocus, width: 2),
        errorBorder: _inputBorder(colors.dangerSolid),
        focusedErrorBorder: _inputBorder(colors.dangerSolid, width: 2),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return colors.accentSolid;
          return colors.borderDefault;
        }),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: colors.bgRaised,
        textStyle: TextStyle(color: colors.textPrimary),
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: AppRadii.mdAll,
      borderSide: BorderSide(color: color, width: width),
    );
  }
}