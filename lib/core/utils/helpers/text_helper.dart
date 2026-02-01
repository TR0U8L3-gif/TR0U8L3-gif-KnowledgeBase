import 'package:shadcn_flutter/shadcn_flutter.dart';

class TextHelper {

  static double calculateWidth(String text, TextStyle style) {
    return calculateSize(text, style).width;
  }

  static Size calculateSize(String text, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    return textPainter.size;
  }
}