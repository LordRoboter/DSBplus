import 'package:material_ui/material_ui.dart';

enum AppThemes { system, light, dark }

enum DarkTheme { dark, amoled }

ThemeData createLightTheme({required ColorScheme colorScheme}) {
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.surface,
    canvasColor: colorScheme.surface,
  );
}

ThemeData createDarkTheme({required ColorScheme colorScheme}) {
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.surface,
    canvasColor: colorScheme.surface,
  );
}

ThemeData createAmoledTheme({required ColorScheme colorScheme}) {
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme.copyWith(
      surface: Colors.black,
      surfaceContainerLowest: Colors.black,
    ),
    scaffoldBackgroundColor: Colors.black,
    canvasColor: Colors.black,
  );
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
