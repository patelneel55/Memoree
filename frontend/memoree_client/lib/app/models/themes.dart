import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static Color _iconColor = Colors.black87;

  static const Color _lightPrimaryColor = Colors.white;
  static const Color _lightPrimaryVariantColor = Colors.white;
  static const Color _lightSecondaryColor = Colors.green;
  static const Color _lightOnPrimaryColor = Color(0xff3c4043);
  static const String _fontFamily = "Montserrat";

  static final ThemeData lightTheme = ThemeData(
    fontFamily: _fontFamily,
    scaffoldBackgroundColor: _lightPrimaryVariantColor,
    appBarTheme: AppBarTheme(
      color: _lightPrimaryVariantColor,
      iconTheme: IconThemeData(color: _lightOnPrimaryColor),
      textTheme: _lightTextTheme
    ),
    colorScheme: ColorScheme.light(
      primary: _lightPrimaryColor,
      primaryVariant: _lightPrimaryVariantColor,
      secondary: _lightSecondaryColor,
      onPrimary: _lightOnPrimaryColor,
    ),
    iconTheme: IconThemeData(
      color: _iconColor,
    ),
    textTheme: _lightTextTheme,
    canvasColor: _lightPrimaryColor,
  );
  
  static final TextTheme _lightTextTheme = TextTheme(
    headline5: _lightScreenHeadingStyle,
    headline6: _lightScreenHeadingStyle,
    bodyText2: _lightScreenTaskNameStyle,
    bodyText1: _lightScreenTaskDurationStyle,
  ).apply(
    bodyColor: _lightOnPrimaryColor,
    displayColor: _lightOnPrimaryColor
  );

  static final TextStyle _lightScreenHeadingStyle = TextStyle(fontFamily: _fontFamily, fontSize: 30.0, color: _lightOnPrimaryColor);
  static final TextStyle _lightScreenTaskNameStyle = TextStyle(fontFamily: _fontFamily, fontSize: 15.0, color: _lightOnPrimaryColor);
  static final TextStyle _lightScreenTaskDurationStyle = TextStyle(fontFamily: _fontFamily, fontSize: 15.0, color: Colors.grey);

  static const Color _darkPrimaryColor = Colors.white24;
static const Color _darkPrimaryVariantColor = Colors.black;
static const Color _darkSecondaryColor = Colors.white;
static const Color _darkOnPrimaryColor = Colors.white;

static final ThemeData darkTheme = ThemeData(
  fontFamily: _fontFamily,
  scaffoldBackgroundColor: _darkPrimaryVariantColor,
  appBarTheme: AppBarTheme(
    color: _darkPrimaryVariantColor,
    iconTheme: IconThemeData(color: _darkOnPrimaryColor),
    textTheme: _darkTextTheme,
  ),
  colorScheme: ColorScheme.light(
    primary: _darkPrimaryColor,
    primaryVariant: _darkPrimaryVariantColor,
    secondary: _darkSecondaryColor,
    onPrimary: _darkOnPrimaryColor,
  ),
  iconTheme: IconThemeData(
    color: _iconColor,
  ),
  textTheme: _darkTextTheme,
);

static final TextTheme _darkTextTheme = TextTheme(
  headline5: _darkScreenHeadingTextStyle,
  bodyText2: _darkScreenTaskNameTextStyle,
  bodyText1: _darkScreenTaskDurationTextStyle,
);

static final TextStyle _darkScreenHeadingTextStyle = _lightScreenHeadingStyle.copyWith(color: _darkOnPrimaryColor);
static final TextStyle _darkScreenTaskNameTextStyle = _lightScreenTaskNameStyle.copyWith(color: _darkOnPrimaryColor);
static final TextStyle _darkScreenTaskDurationTextStyle = _lightScreenTaskDurationStyle;
}