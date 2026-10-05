import 'package:flutter/material.dart';

/// Cores copiadas dos arquivos CSS do frontend (frontend/src/styles).
/// As transparências (rgba) foram convertidas para ARGB.
class AppColors {
  AppColors._();

  // :root
  static const primary = Color(0xFFD4A373); // --primary
  static const accent = Color(0xFFC9934A); // --accent

  // Fundos
  static const background = Color(0xFF050507); // body (login.css)
  static const backgroundAlt = Color(0xFF09090B); // body (menu.css) / hero
  static const page = Color(0xFF050505); // booking / admin / perfil
  static const headerBg = Color(0xCC09090B); // rgba(9,9,11,.8)
  static const headerBorder = Color(0xFF1F1F23);
  static const card = Color(0xFF161616);
  static const input = Color(0xFF1A1A1A);
  static const serviceCard = Color(0xFF0C0C0C);
  static const border222 = Color(0xFF222222);
  static const loginCard = Color(0xFF121214);
  static const loginInput = Color(0xFF0D0D10);
  static const loginBorder = Color(0xFF2A2A2D);
  static const heroVisualCard = Color(0xFF111111);

  // Textos
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
  static const text = Color(0xFFF5F5F5);
  static const gray9c = Color(0xFF9CA3AF);
  static const gray7a = Color(0xFF7A7A7A);
  static const gray77 = Color(0xFF777777);
  static const gray6f = Color(0xFF6F6F6F);
  static const gray66 = Color(0xFF666666);
  static const gray55 = Color(0xFF555555);
  static const gray88 = Color(0xFF888888);
  static const grayD4 = Color(0xFFD4D4D4);
  static const danger = Color(0xFFE06060);

  // Primária com transparência: rgba(212,163,115,x)
  static const primary3 = Color(0x08D4A373);
  static const primary4 = Color(0x0AD4A373);
  static const primary5 = Color(0x0DD4A373);
  static const primary8 = Color(0x14D4A373);
  static const primary10 = Color(0x1AD4A373);
  static const primary15 = Color(0x26D4A373);
  static const primary18 = Color(0x2ED4A373);
  static const primary20 = Color(0x33D4A373);
  static const primary30 = Color(0x4DD4A373);
  static const primary40 = Color(0x66D4A373);
  static const primary45 = Color(0x73D4A373);
  static const primary60 = Color(0x99D4A373);

  // Accent com transparência: rgba(201,147,74,x)
  static const accent5 = Color(0x0DC9934A);
  static const accent18 = Color(0x2EC9934A);
  static const accent20 = Color(0x33C9934A);

  // Branco com transparência: rgba(255,255,255,x)
  static const white2 = Color(0x05FFFFFF);
  static const white4 = Color(0x0AFFFFFF);
  static const white5 = Color(0x0DFFFFFF);
  static const white6 = Color(0x0FFFFFFF);
  static const white10 = Color(0x1AFFFFFF);
  static const white12 = Color(0x1FFFFFFF);

  // Vermelho com transparência: rgba(200,60,60,x)
  static const danger10 = Color(0x1AC83C3C);
  static const danger15 = Color(0x26C83C3C);
  static const danger20 = Color(0x33C83C3C);
  static const danger40 = Color(0x66C83C3C);
}

/// Fontes do site: Bebas Neue (títulos) e Rajdhani (textos).
class AppFonts {
  AppFonts._();

  static const display = 'BebasNeue';
  static const body = 'Rajdhani';
}

class AppText {
  AppText._();

  /// Bebas Neue (--font-display).
  static TextStyle display(
    double size, {
    Color color = AppColors.primary,
    double letterSpacing = 0,
    double? height,
  }) {
    return TextStyle(
      fontFamily: AppFonts.display,
      fontSize: size,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      fontWeight: FontWeight.w400,
    );
  }

  /// Rajdhani (--font-body).
  static TextStyle body(
    double size, {
    Color? color,
    FontWeight weight = FontWeight.w400,
    double letterSpacing = 0,
    double? height,
  }) {
    return TextStyle(
      fontFamily: AppFonts.body,
      fontSize: size,
      color: color,
      fontWeight: weight,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Fonte padrão do sistema. No site, os campos e botões da tela de login
  /// não definem font-family e usam a fonte do navegador.
  static TextStyle system(
    double size, {
    Color? color,
    FontWeight weight = FontWeight.w400,
    double letterSpacing = 0,
    double? height,
  }) {
    return TextStyle(
      fontSize: size,
      color: color,
      fontWeight: weight,
      letterSpacing: letterSpacing,
      height: height,
    );
  }
}

ThemeData buildAppTheme() {
  const scheme = ColorScheme.dark(
    primary: AppColors.primary,
    onPrimary: AppColors.page,
    secondary: AppColors.accent,
    onSecondary: AppColors.page,
    surface: AppColors.card,
    onSurface: AppColors.text,
    error: AppColors.danger,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    canvasColor: AppColors.input,
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.primary,
      selectionColor: AppColors.primary40,
      selectionHandleColor: AppColors.primary,
    ),
    datePickerTheme: const DatePickerThemeData(
      backgroundColor: AppColors.card,
      surfaceTintColor: Colors.transparent,
      headerBackgroundColor: AppColors.page,
      headerForegroundColor: AppColors.primary,
      shape: RoundedRectangleBorder(),
    ),
  );
}
