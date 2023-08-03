import 'package:flutter/material.dart';

class ConteinerTableTheme {
  static ThemeData themeData = ThemeData(
    primaryColor: Colors.deepPurple,
    hintColor: Colors.deepPurpleAccent,
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.deepPurple,
      accentColor: Colors.deepPurpleAccent,
    ),
    textTheme: TextTheme(
      bodyText1: TextStyle(fontSize: 24),
      bodyText2: TextStyle(fontSize: 18),
      headline6: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    ),
  );

  static TextStyle cap = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
  );

  static TextStyle bottom = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w400,
  );

  static TextStyle timeTextStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );

  static TextStyle sportsNameTextStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );

  // static TextStyle titleTextStyle = TextStyle(
  //   fontSize: 24,
  // );

  static TextStyle datTextStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );
}
