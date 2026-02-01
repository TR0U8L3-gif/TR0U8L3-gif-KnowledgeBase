import 'package:shadcn_flutter/shadcn_flutter.dart';

class TextHelper {
  static double calculateWidth(
    BuildContext context,
    String text,
    TextStyle? style,
    int maxLines,
  ) {
    return calculateSize(context, text, style, maxLines).width;
  }

  static Size calculateSize(
    BuildContext context,
    String text,
    TextStyle? style,
    int maxLines,
  ) {
    final defaultTextStyle = DefaultTextStyle.of(context);
    final textScaler = MediaQuery.textScalerOf(context);

    TextStyle effectiveStyle = defaultTextStyle.style;
    if (style != null) {
      effectiveStyle = effectiveStyle.merge(style);
    }

    final textPainter = TextPainter(
      text: TextSpan(text: text, style: effectiveStyle),
      textDirection: Directionality.of(context),
      maxLines: maxLines,
      textScaler: textScaler,
    );
    textPainter.layout();
    return textPainter.size;
  }
}
