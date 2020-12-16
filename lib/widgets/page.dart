import 'package:flutter/material.dart';
import 'package:jarvis/utils/callbacks.dart';

mixin BasePage {
  dynamic _pageArguments;
  Map<String, dynamic> get pageArguments => _pageArguments;
  void loadArguments(BuildContext context) => _pageArguments == null
      ? _pageArguments = ModalRoute.of(context).settings.arguments
      : none;
}
