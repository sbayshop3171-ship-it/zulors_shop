import 'package:flutter/material.dart';


Color _primaryColor = const Color(0xFF1455AC);
Color _secondaryColor = const Color(0xFFF58300);

ThemeData light = ThemeData(
  fontFamily: 'TitilliumWeb',
  primaryColor: _primaryColor,
  bottomSheetTheme: const BottomSheetThemeData(backgroundColor: Colors.transparent),
  brightness: Brightness.light,
  highlightColor: Colors.white,
  hintColor: const Color(0xFFA7A7A7),
  disabledColor:  const Color(0xFF343A40),
  canvasColor: const Color(0xFFFCFCFC),
  cardColor: const Color(0xFFFFFFFF),
  splashColor: Colors.transparent,
  scaffoldBackgroundColor: const Color(0xFFF7F8FA),

  textTheme: TextTheme(
    bodyLarge: const TextStyle(color: Color(0xFF222324)),  // Text color primary
    bodyMedium: TextStyle(color: _primaryColor), // Text color Secondary
    bodySmall: const TextStyle(color: Color(0xFFA7A7A7)),  // Text color Light grey
    headlineMedium: const TextStyle(color: Color(0xFFA0A0A0)),
    headlineLarge : const TextStyle(color: Color(0xFF656566)),
  ),


  colorScheme: ColorScheme.light(
    primary:  _primaryColor,  // Primary Color
    secondary:  _secondaryColor,  // Secondary Color
    error: const Color(0xFFFF5A5A),
    tertiary:  const Color(0xFFFFBB38), // Warning Color
    tertiaryContainer: const Color(0xFFADC9F3),
    onTertiaryContainer:  const Color(0xFF04BB7B), // Success Color
    primaryContainer: const Color(0xFF9AECC6),
    secondaryContainer: const Color(0xFFF2F2F2),
    surface: const Color(0xFFFFFFFF),
    surfaceTint: const Color(0xFF0087FF),
    onPrimary: const Color(0xFF67AFFF),
    onSecondary: const Color(0xFFFC9926),
    outline: const Color(0xff5C8FFC), // Info Color / Pending color
  ),

  pageTransitionsTheme: const PageTransitionsTheme(builders: {
    TargetPlatform.android: ZoomPageTransitionsBuilder(),
    TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
    TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
  }),
);