import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff001036),
      surfaceTint: Color(0xff455c99),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff142f69),
      onPrimaryContainer: Color(0xffaabfff),
      secondary: Color(0xff53606a),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffe0eefa),
      onSecondaryContainer: Color(0xff424f59),
      tertiary: Color(0xff765a00),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffffce4b),
      onTertiaryContainer: Color(0xff503c00),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff410002),
      surface: Color(0xfffaf8fe),
      onSurface: Color(0xff1a1b20),
      onSurfaceVariant: Color(0xff44474c),
      outline: Color(0xff74777d),
      outlineVariant: Color(0xffc4c6cd),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2f3035),
      inversePrimary: Color(0xffb2c5ff),
      primaryFixed: Color(0xffdae2ff),
      onPrimaryFixed: Color(0xff001849),
      primaryFixedDim: Color(0xffb2c5ff),
      onPrimaryFixedVariant: Color(0xff2d447f),
      secondaryFixed: Color(0xffd6e4f0),
      onSecondaryFixed: Color(0xff101d26),
      secondaryFixedDim: Color(0xffbac8d4),
      onSecondaryFixedVariant: Color(0xff3b4852),
      tertiaryFixed: Color(0xffffdf96),
      onTertiaryFixed: Color(0xff251a00),
      tertiaryFixedDim: Color(0xfff6bf00),
      onTertiaryFixedVariant: Color(0xff594400),
      surfaceDim: Color(0xffdbd9df),
      surfaceBright: Color(0xfffaf8fe),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff4f3f9),
      surfaceContainer: Color(0xffefedf3),
      surfaceContainerHigh: Color(0xffe9e7ed),
      surfaceContainerHighest: Color(0xffe3e2e7),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff001036),
      surfaceTint: Color(0xff455c99),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff142f69),
      onPrimaryContainer: Color(0xffebeeff),
      secondary: Color(0xff37444e),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff697681),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff554000),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff917000),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff8c0009),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffda342e),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffaf8fe),
      onSurface: Color(0xff1a1b20),
      onSurfaceVariant: Color(0xff404348),
      outline: Color(0xff5c5f65),
      outlineVariant: Color(0xff787b81),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2f3035),
      inversePrimary: Color(0xffb2c5ff),
      primaryFixed: Color(0xff5c73b1),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff435a96),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff697681),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff505e68),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff917000),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff735800),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffdbd9df),
      surfaceBright: Color(0xfffaf8fe),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff4f3f9),
      surfaceContainer: Color(0xffefedf3),
      surfaceContainerHigh: Color(0xffe9e7ed),
      surfaceContainerHighest: Color(0xffe3e2e7),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff001036),
      surfaceTint: Color(0xff455c99),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff142f69),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff17242c),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff37444e),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff2d2000),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff554000),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff4e0002),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff8c0009),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffaf8fe),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff212429),
      outline: Color(0xff404348),
      outlineVariant: Color(0xff404348),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2f3035),
      inversePrimary: Color(0xffe8ebff),
      primaryFixed: Color(0xff28407b),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff0d2964),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff37444e),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff212e37),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff554000),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff3a2b00),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffdbd9df),
      surfaceBright: Color(0xfffaf8fe),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff4f3f9),
      surfaceContainer: Color(0xffefedf3),
      surfaceContainerHigh: Color(0xffe9e7ed),
      surfaceContainerHighest: Color(0xffe3e2e7),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffb2c5ff),
      surfaceTint: Color(0xffb2c5ff),
      onPrimary: Color(0xff122d67),
      primaryContainer: Color(0xff00194b),
      onPrimaryContainer: Color(0xff90a6e8),
      secondary: Color(0xffffffff),
      onSecondary: Color(0xff25323b),
      secondaryContainer: Color(0xffc8d6e2),
      onSecondaryContainer: Color(0xff34414a),
      tertiary: Color(0xfffff2dc),
      onTertiary: Color(0xff3e2e00),
      tertiaryContainer: Color(0xfff9c100),
      onTertiaryContainer: Color(0xff483600),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff121317),
      onSurface: Color(0xffe3e2e7),
      onSurfaceVariant: Color(0xffc4c6cd),
      outline: Color(0xff8e9197),
      outlineVariant: Color(0xff44474c),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe3e2e7),
      inversePrimary: Color(0xff455c99),
      primaryFixed: Color(0xffdae2ff),
      onPrimaryFixed: Color(0xff001849),
      primaryFixedDim: Color(0xffb2c5ff),
      onPrimaryFixedVariant: Color(0xff2d447f),
      secondaryFixed: Color(0xffd6e4f0),
      onSecondaryFixed: Color(0xff101d26),
      secondaryFixedDim: Color(0xffbac8d4),
      onSecondaryFixedVariant: Color(0xff3b4852),
      tertiaryFixed: Color(0xffffdf96),
      onTertiaryFixed: Color(0xff251a00),
      tertiaryFixedDim: Color(0xfff6bf00),
      onTertiaryFixedVariant: Color(0xff594400),
      surfaceDim: Color(0xff121317),
      surfaceBright: Color(0xff38393d),
      surfaceContainerLowest: Color(0xff0d0e12),
      surfaceContainerLow: Color(0xff1a1b20),
      surfaceContainer: Color(0xff1f1f24),
      surfaceContainerHigh: Color(0xff292a2e),
      surfaceContainerHighest: Color(0xff343439),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffb9c9ff),
      surfaceTint: Color(0xffb2c5ff),
      onPrimary: Color(0xff00133e),
      primaryContainer: Color(0xff788fcf),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffffffff),
      onSecondary: Color(0xff25323b),
      secondaryContainer: Color(0xffc8d6e2),
      onSecondaryContainer: Color(0xff14212a),
      tertiary: Color(0xfffff2dc),
      onTertiary: Color(0xff3e2e00),
      tertiaryContainer: Color(0xfff9c100),
      onTertiaryContainer: Color(0xff1c1300),
      error: Color(0xffffbab1),
      onError: Color(0xff370001),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff121317),
      onSurface: Color(0xfffcfaff),
      onSurfaceVariant: Color(0xffc9cad1),
      outline: Color(0xffa0a3a9),
      outlineVariant: Color(0xff818389),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe3e2e7),
      inversePrimary: Color(0xff2e4581),
      primaryFixed: Color(0xffdae2ff),
      onPrimaryFixed: Color(0xff000e33),
      primaryFixedDim: Color(0xffb2c5ff),
      onPrimaryFixedVariant: Color(0xff1a336e),
      secondaryFixed: Color(0xffd6e4f0),
      onSecondaryFixed: Color(0xff05131b),
      secondaryFixedDim: Color(0xffbac8d4),
      onSecondaryFixedVariant: Color(0xff2b3841),
      tertiaryFixed: Color(0xffffdf96),
      onTertiaryFixed: Color(0xff181000),
      tertiaryFixedDim: Color(0xfff6bf00),
      onTertiaryFixedVariant: Color(0xff453400),
      surfaceDim: Color(0xff121317),
      surfaceBright: Color(0xff38393d),
      surfaceContainerLowest: Color(0xff0d0e12),
      surfaceContainerLow: Color(0xff1a1b20),
      surfaceContainer: Color(0xff1f1f24),
      surfaceContainerHigh: Color(0xff292a2e),
      surfaceContainerHighest: Color(0xff343439),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xfffcfaff),
      surfaceTint: Color(0xffb2c5ff),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffb9c9ff),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffffffff),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffc8d6e2),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xfffffaf6),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xfffbc300),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xfffff9f9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffbab1),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff121317),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xfffafaff),
      outline: Color(0xffc9cad1),
      outlineVariant: Color(0xffc9cad1),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe3e2e7),
      inversePrimary: Color(0xff082661),
      primaryFixed: Color(0xffe0e6ff),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffb9c9ff),
      onPrimaryFixedVariant: Color(0xff00133e),
      secondaryFixed: Color(0xffdbe9f5),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffbfcdd8),
      onSecondaryFixedVariant: Color(0xff0a1820),
      tertiaryFixed: Color(0xffffe4a9),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xfffbc300),
      onTertiaryFixedVariant: Color(0xff1e1500),
      surfaceDim: Color(0xff121317),
      surfaceBright: Color(0xff38393d),
      surfaceContainerLowest: Color(0xff0d0e12),
      surfaceContainerLow: Color(0xff1a1b20),
      surfaceContainer: Color(0xff1f1f24),
      surfaceContainerHigh: Color(0xff292a2e),
      surfaceContainerHighest: Color(0xff343439),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }


  ThemeData theme(ColorScheme colorScheme) => ThemeData(
     useMaterial3: true,
     brightness: colorScheme.brightness,
     colorScheme: colorScheme,
     textTheme: textTheme.apply(
       bodyColor: colorScheme.onSurface,
       displayColor: colorScheme.onSurface,
     ),
     scaffoldBackgroundColor: colorScheme.background,
     canvasColor: colorScheme.surface,
  );

  /// Custom Color 1
  static const customColor1 = ExtendedColor(
    seed: Color(0xff005776),
    value: Color(0xff005776),
    light: ColorFamily(
      color: Color(0xff00425a),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xff1f6786),
      onColorContainer: Color(0xffffffff),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff00425a),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xff1f6786),
      onColorContainer: Color(0xffffffff),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff00425a),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xff1f6786),
      onColorContainer: Color(0xffffffff),
    ),
    dark: ColorFamily(
      color: Color(0xff90cef2),
      onColor: Color(0xff003549),
      colorContainer: Color(0xff004c68),
      onColorContainer: Color(0xffbde6ff),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xff90cef2),
      onColor: Color(0xff003549),
      colorContainer: Color(0xff004c68),
      onColorContainer: Color(0xffbde6ff),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xff90cef2),
      onColor: Color(0xff003549),
      colorContainer: Color(0xff004c68),
      onColorContainer: Color(0xffbde6ff),
    ),
  );

  /// Custom Color 2
  static const customColor2 = ExtendedColor(
    seed: Color(0xffa9cce3),
    value: Color(0xffa9cce3),
    light: ColorFamily(
      color: Color(0xff416276),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffb0d3ea),
      onColorContainer: Color(0xff1b3f52),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff416276),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffb0d3ea),
      onColorContainer: Color(0xff1b3f52),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff416276),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffb0d3ea),
      onColorContainer: Color(0xff1b3f52),
    ),
    dark: ColorFamily(
      color: Color(0xffd9efff),
      onColor: Color(0xff0d3446),
      colorContainer: Color(0xffa4c7dd),
      onColorContainer: Color(0xff113749),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xffd9efff),
      onColor: Color(0xff0d3446),
      colorContainer: Color(0xffa4c7dd),
      onColorContainer: Color(0xff113749),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xffd9efff),
      onColor: Color(0xff0d3446),
      colorContainer: Color(0xffa4c7dd),
      onColorContainer: Color(0xff113749),
    ),
  );


  List<ExtendedColor> get extendedColors => [
    customColor1,
    customColor2,
  ];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
