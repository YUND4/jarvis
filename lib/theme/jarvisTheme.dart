import 'package:flutter/material.dart';

class JarvisTheme {
  static ThemeData get data => ThemeData(
        backgroundColor: Colors.black,
        textTheme: TextTheme(
          bodyText2: def(size: 20),
          bodyText1: def(size: 22),
          headline1: def(size: 70),
        ),
      );

  static TextStyle def({double size}) {
    return TextStyle(
        fontSize: size, fontFamily: 'StarkIndustries', color: Colors.white);
  }
}

TextTheme theme(BuildContext context) => Theme.of(context).textTheme;
