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

  static TextStyle timeTextStyle = TextStyle(
    fontSize: 24, fontWeight: FontWeight.w600,
  );

  static TextStyle sportsNameTextStyle = TextStyle(
    fontSize: 24, fontWeight: FontWeight.w600,
  );

  // static TextStyle titleTextStyle = TextStyle(
  //   fontSize: 24,
  // );
  
  static TextStyle datTextStyle = TextStyle(
    fontSize: 18, fontWeight: FontWeight.w600,
  );

}


Widget buildBlueCell(String text) {
  return Container(
    color: Colors.blue, // Задаем синий цвет фона
    padding: EdgeInsets.all(8.0), // Добавляем отступы внутри ячейки
    child: Text(
      text,
      style: TextStyle(color: Colors.white, fontSize: 24),  // Задаем белый цвет текста
    ),
  );
}
