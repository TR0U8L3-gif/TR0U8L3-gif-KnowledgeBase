import 'package:markdown/markdown.dart' as md;

/// A custom [md.BlockSyntax] that intercepts fenced code blocks whose info
/// string is `mermaid` and converts them into a `<mermaid>` pseudo-element.
///
/// This must be registered **before** the GFM block syntaxes to prevent
/// [md.FencedCodeBlockSyntax] from consuming the block first.
class MermaidBlockSyntax extends md.BlockSyntax {
  @override
  RegExp get pattern => _mermaidFencePattern;

  /// Matches a fenced code block opening with info string `mermaid`.
  /// Supports both backtick (```) and tilde (~~~) fences.
  static final _mermaidFencePattern = RegExp(
    r'^[ ]{0,3}(?:(`{3,})\s*mermaid\s*|(~{3,})\s*mermaid\s*)$',
    caseSensitive: false,
  );

  /// Matches the closing fence (>=3 backticks or tildes with no info string).
  static final _closingFencePattern = RegExp(r'^[ ]{0,3}(?:`{3,}|~{3,})\s*$');

  const MermaidBlockSyntax();

  @override
  md.Node parse(md.BlockParser parser) {
    // Determine the opening fence marker (backticks or tildes).
    final openMatch = pattern.firstMatch(parser.current.content);
    final marker = openMatch?.group(1) ?? openMatch?.group(2) ?? '```';

    // Advance past the opening fence.
    parser.advance();

    // Collect lines until the closing fence or end-of-input.
    final lines = <String>[];
    while (!parser.isDone) {
      final line = parser.current.content;
      final closeMatch = _closingFencePattern.firstMatch(line);
      if (closeMatch != null && _isValidClose(closeMatch, marker)) {
        parser.advance();
        break;
      }
      lines.add(line);
      parser.advance();
    }

    final source = lines.join('\n');
    return md.Element.text('mermaid', source);
  }

  /// Checks that the closing fence uses the same character as the opening
  /// and is at least as long.
  bool _isValidClose(RegExpMatch match, String openMarker) {
    final closeContent = match.group(0)?.trim() ?? '';
    if (closeContent.isEmpty) return false;
    final closeChar = closeContent[0];
    final openChar = openMarker[0];
    return closeChar == openChar && closeContent.length >= openMarker.length;
  }
}
