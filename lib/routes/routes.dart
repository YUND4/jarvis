import 'package:flutter/widgets.dart';
import 'package:jarvis/pages/init.dart';

class Routes {
  static Map<String, Widget Function(BuildContext)> get loadRoutes => {
        Init.pageName: (BuildContext context) => Init(),
      };
}
