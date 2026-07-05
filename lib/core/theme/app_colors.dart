import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const safetyOrange = Color(0xFFCB5B1D);
  static const safetyOrangeLight = Color(0xFFFFDBCC);
  static const safetyOrangeDark = Color(0xFFFFB595);

  static const steelBlue = Color(0xFF355C7D);
  static const steelBlueLight = Color(0xFFD4E3F4);
  static const steelBlueDark = Color(0xFFA4C9EF);

  static const blueprintNavy = Color(0xFF12263A);
  static const blueprintNavyDark = Color(0xFF0B1724);

  static const concrete = Color(0xFFE6E2DC);
  static const concreteDark = Color(0xFF2D2F31);
  static const rebar = Color(0xFF4B5563);
  static const formwork = Color(0xFF8B6F47);

  static const cautionAmber = Color(0xFFF2B705);
  static const successGreen = Color(0xFF2F7D4A);
  static const dangerRed = Color(0xFFB3261E);

  static const lightBackground = Color(0xFFFFFBF6);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceVariant = Color(0xFFF1ECE5);
  static const lightOutline = Color(0xFF7D766E);
  static const lightText = Color(0xFF1D1B18);
  static const lightTextMuted = Color(0xFF5F5A54);

  static const darkBackground = Color(0xFF111315);
  static const darkSurface = Color(0xFF1A1C1E);
  static const darkSurfaceVariant = Color(0xFF2A2D30);
  static const darkOutline = Color(0xFF938F89);
  static const darkText = Color(0xFFF2EFEA);
  static const darkTextMuted = Color(0xFFC9C3BB);

  static const lightShadow = Color(0x33000000);
  static const darkShadow = Color(0x66000000);

  static const lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: safetyOrange,
    onPrimary: lightSurface,
    primaryContainer: safetyOrangeLight,
    onPrimaryContainer: Color(0xFF3D1603),
    secondary: steelBlue,
    onSecondary: lightSurface,
    secondaryContainer: steelBlueLight,
    onSecondaryContainer: blueprintNavy,
    tertiary: formwork,
    onTertiary: lightSurface,
    tertiaryContainer: Color(0xFFF6E1BE),
    onTertiaryContainer: Color(0xFF2E1E05),
    error: dangerRed,
    onError: lightSurface,
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    surface: lightSurface,
    onSurface: lightText,
    surfaceContainerHighest: lightSurfaceVariant,
    onSurfaceVariant: lightTextMuted,
    outline: lightOutline,
    outlineVariant: Color(0xFFD1C7BC),
    shadow: lightShadow,
    scrim: Color(0x99000000),
    inverseSurface: blueprintNavy,
    onInverseSurface: lightBackground,
    inversePrimary: safetyOrangeDark,
  );

  static const darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: safetyOrangeDark,
    onPrimary: Color(0xFF552100),
    primaryContainer: Color(0xFF753200),
    onPrimaryContainer: safetyOrangeLight,
    secondary: steelBlueDark,
    onSecondary: Color(0xFF063451),
    secondaryContainer: Color(0xFF1B4968),
    onSecondaryContainer: steelBlueLight,
    tertiary: Color(0xFFDDBD86),
    onTertiary: Color(0xFF422B00),
    tertiaryContainer: Color(0xFF5F4217),
    onTertiaryContainer: Color(0xFFFBE0B0),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: darkSurface,
    onSurface: darkText,
    surfaceContainerHighest: darkSurfaceVariant,
    onSurfaceVariant: darkTextMuted,
    outline: darkOutline,
    outlineVariant: Color(0xFF4C463F),
    shadow: darkShadow,
    scrim: Color(0xCC000000),
    inverseSurface: lightBackground,
    onInverseSurface: blueprintNavy,
    inversePrimary: safetyOrange,
  );
}
