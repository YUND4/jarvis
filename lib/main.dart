import 'package:flutter/material.dart';
import 'package:jarvis/pages/init.dart';
import 'package:jarvis/routes/routes.dart';
import 'package:jarvis/theme/jarvisTheme.dart';

void main() {
  runApp(JARVIS());
}

class JARVIS extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'J.A.R.V.I.S',
      theme: JarvisTheme.data,
      home: Init(),
      routes: Routes.loadRoutes,
    );
  }
}
