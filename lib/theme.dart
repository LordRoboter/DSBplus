import 'package:material_ui/material_ui.dart';

enum AppThemes { system, light, dark }

enum DarkTheme { dark, amoled }

sealed class ThemeColor {
  const ThemeColor();

  factory ThemeColor.fromJson(String value) {
    if (value == 'standard') {
      return const StandardColor();
    }

    if (value == 'dynamic') {
      return const DynamicColor();
    }

    if (value.startsWith('#')) {
      final argb = int.parse(value.substring(1), radix: 16);
      return CustomColor(Color(argb));
    }

    throw FormatException('Invalid ThemeColor: $value');
  }

  String toJson();
}

class StandardColor extends ThemeColor {
  const StandardColor();

  @override
  String toJson() => 'standard';
}

class DynamicColor extends ThemeColor {
  const DynamicColor();

  @override
  String toJson() => 'dynamic';
}

class CustomColor extends ThemeColor {
  final Color color;

  const CustomColor(this.color);

  @override
  String toJson() => '#${color.toARGB32().toRadixString(16).padLeft(8, '0')}';
}

ThemeData createLightTheme({
  required ThemeColor themeColor,
  ColorScheme? dynamicLight,
}) {
  final colorScheme = resolveColorScheme(
    themeColor: themeColor,
    brightness: Brightness.light,
    dynamicColorScheme: dynamicLight,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: colorScheme,
  );
}

ThemeData createDarkTheme({
  required ThemeColor themeColor,
  ColorScheme? dynamicDark,
}) {
  final colorScheme = resolveColorScheme(
    themeColor: themeColor,
    brightness: Brightness.dark,
    dynamicColorScheme: dynamicDark,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: colorScheme,
  );
}

ThemeData createAmoledTheme({
  required ThemeColor themeColor,
  ColorScheme? dynamicDark,
}) {
  final theme = switch (themeColor) {
    StandardColor() => ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
    ),

    DynamicColor() => ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: dynamicDark,
    ),

    CustomColor(:final color) => ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: color,
        brightness: Brightness.dark,
      ),
    ),
  };

  final colorScheme = theme.colorScheme.copyWith(
    surface: Colors.black,
    surfaceContainerLowest: Colors.black,
  );

  return theme.copyWith(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: Colors.black,
    canvasColor: Colors.black,
  );
}

ColorScheme? resolveColorScheme({
  required ThemeColor themeColor,
  required Brightness brightness,
  ColorScheme? dynamicColorScheme,
}) {
  return switch (themeColor) {
    StandardColor() => null,

    DynamicColor() => dynamicColorScheme,

    CustomColor(:final color) => ColorScheme.fromSeed(
      seedColor: color,
      brightness: brightness,
    ),
  };
}

const themeColors = <Color>[
  Colors.blue,
  Colors.indigo,
  Colors.purple,
  Colors.deepPurple,
  Colors.pink,
  Colors.red,
  Colors.orange,
  Colors.amber,
  Colors.green,
  Colors.teal,
  Colors.cyan,
];
