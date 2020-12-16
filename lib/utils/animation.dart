import 'package:flutter/animation.dart';
import 'package:flutter/widgets.dart';

class StringTween extends Tween<String> {
  StringTween({String begin = '', @required String end})
      : super(begin: begin, end: end);

  @override
  String lerp(double t) {
    String result = begin;
    int step = t ~/ mixinStep;
    if (step < end.length && step < begin.length) {
      result = result.replaceRange(0, step, end.substring(0, step));
      step = t ~/ removeStep;
      result = result.substring(0, result.length - step);
    } else {
      result = end.substring(0, step);
    }
    return result;
  }

  double get removeStep => 1.0 / (end.length - begin.length).abs();

  double get mixinStep => 1.0 / end.length;
}
