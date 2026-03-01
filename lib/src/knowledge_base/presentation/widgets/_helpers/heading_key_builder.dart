import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// A [MarkdownElementBuilder] that wraps each heading element in a
/// [KeyedSubtree] using the corresponding [GlobalKey] from [headingKeys].
///
/// This preserves the scroll-anchor API used by the TOC panel to navigate
/// to specific headings within the rendered document.
class HeadingKeyBuilder extends MarkdownElementBuilder {
  HeadingKeyBuilder({required this.headingKeys}) : _headingIndex = 0;

  /// The ordered list of keys to assign to headings, one per heading in
  /// document order (h1–h6 all counted).
  final List<GlobalKey>? headingKeys;

  int _headingIndex;

  /// Resets the internal counter so the builder can be reused across rebuilds.
  void reset() => _headingIndex = 0;

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final text = element.textContent;

    final widget = Text(text, style: preferredStyle);

    if (headingKeys != null && _headingIndex < headingKeys!.length) {
      final keyed = KeyedSubtree(
        key: headingKeys![_headingIndex],
        child: widget,
      );
      _headingIndex++;
      return keyed;
    }

    _headingIndex++;
    return widget;
  }
}
