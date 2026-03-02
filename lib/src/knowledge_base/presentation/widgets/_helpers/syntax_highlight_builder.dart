import 'package:flutter/services.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/github-gist.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:highlight/highlight.dart' show highlight, Node;
import 'package:markdown/markdown.dart' as md;
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Supported languages for syntax highlighting.
const _supportedLanguages = {
  'dart',
  'kotlin',
  'java',
  'swift',
  'objc',
  'javascript',
  'typescript',
  'yaml',
  'json',
  'bash',
  'xml',
  'html',
  'css',
  'sql',
  'python',
  'ruby',
  'go',
  'rust',
  'c',
  'cpp',
  'shell',
  'sh',
  'zsh',
  'dockerfile',
  'graphql',
  'markdown',
  'plaintext',
};

/// A [MarkdownElementBuilder] that intercepts `pre` elements (fenced code
/// blocks) and renders them with syntax highlighting via `flutter_highlight`.
///
/// The language is extracted from the child `code` element's `class` attribute
/// (e.g. `language-dart` → `dart`). A theme matching the app's current
/// brightness (dark/light) is automatically selected.
class SyntaxHighlightBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    // The `pre` element wraps a `code` child that holds the actual text.
    final codeElement = element.children?.whereType<md.Element>().firstWhere(
      (e) => e.tag == 'code',
      orElse: () => element,
    );

    final code = codeElement?.textContent ?? element.textContent;
    final language = _extractLanguage(codeElement) ?? 'plaintext';

    return _SyntaxHighlightBlock(code: code, language: language);
  }

  /// Extracts the language identifier from the code element's class attribute.
  ///
  /// Markdown parsers typically set `class="language-dart"` on `<code>` inside
  /// `<pre>`. Returns `null` if no recognized language is found.
  String? _extractLanguage(md.Element? element) {
    final className = element?.attributes['class'];
    if (className == null) return null;

    // Handle "language-dart" format
    final match = RegExp(r'language-(\w+)').firstMatch(className);
    final lang = match?.group(1)?.toLowerCase();

    if (lang != null && _supportedLanguages.contains(lang)) {
      return lang;
    }

    // Fallback: try the raw class name
    if (_supportedLanguages.contains(className.toLowerCase())) {
      return className.toLowerCase();
    }

    return lang; // Still pass it through even if not in our explicit set
  }
}

// ── Stateful code block widget ──────────────────────────────────────────────

class _SyntaxHighlightBlock extends StatefulWidget {
  const _SyntaxHighlightBlock({required this.code, required this.language});

  final String code;
  final String language;

  @override
  State<_SyntaxHighlightBlock> createState() => _SyntaxHighlightBlockState();
}

class _SyntaxHighlightBlockState extends State<_SyntaxHighlightBlock> {
  bool _copied = false;

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    if (!mounted) return;
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final scaling = theme.scaling;
    final isDark = theme.brightness == Brightness.dark;

    final highlightTheme = isDark ? atomOneDarkTheme : githubGistTheme;

    final bgColor = colorScheme.muted.withValues(alpha: isDark ? 0.4 : 0.6);

    final transparentTheme = Map<String, TextStyle>.from(highlightTheme);
    final rootStyle = transparentTheme['root'];
    if (rootStyle != null) {
      transparentTheme['root'] = rootStyle.copyWith(
        backgroundColor: Colors.transparent,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12 * scaling),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: colorScheme.border, width: 0.5),
          borderRadius: BorderRadius.circular(12 * scaling),
        ),
        child: Stack(
          children: [
            // Selectable & scrollable code content
            Padding(
              padding: EdgeInsets.only(
                left: 14 * scaling,
                right: 14 * scaling,
                top: 14 * scaling,
                bottom: 0,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SelectableText.rich(
                  _buildHighlightedSpan(
                    widget.code,
                    widget.language,
                    transparentTheme,
                    scaling,
                  ),
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14 * scaling,
                    height: 1.4,
                    leadingDistribution: TextLeadingDistribution.even,
                  ),
                ),
              ),
            ),
            // Copy button
            Positioned(
              top: 4 * scaling,
              right: 4 * scaling,
              child: IconButton.ghost(
                density: ButtonDensity.compact,
                onPressed: _copyToClipboard,
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _copied
                      ? Icon(
                          Icons.check,
                          key: const ValueKey('check'),
                          size: 16 * scaling,
                          color: colorScheme.mutedForeground,
                        )
                      : Icon(
                          Icons.copy,
                          key: const ValueKey('copy'),
                          size: 16 * scaling,
                          color: colorScheme.mutedForeground,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a highlighted [TextSpan] tree from source code using the
  /// `highlight` engine, replicating what `HighlightView` does internally
  /// but returning a [TextSpan] for use with [SelectableText.rich].
  TextSpan _buildHighlightedSpan(
    String source,
    String language,
    Map<String, TextStyle> theme,
    double scaling,
  ) {
    final result = highlight.parse(source, language: language);
    final nodes = result.nodes ?? [];

    return TextSpan(
      style: TextStyle(
        fontFamily: 'monospace',
        fontSize: 14 * scaling,
        height: 1.4,
        leadingDistribution: TextLeadingDistribution.even,
      ),
      children: _convertNodes(nodes, theme),
    );
  }

  List<TextSpan> _convertNodes(List<Node> nodes, Map<String, TextStyle> theme) {
    final spans = <TextSpan>[];
    for (final node in nodes) {
      if (node.value != null) {
        spans.add(
          TextSpan(
            text: node.value,
            style: node.className != null ? theme[node.className!] : null,
          ),
        );
      } else if (node.children != null) {
        spans.add(
          TextSpan(
            style: node.className != null ? theme[node.className!] : null,
            children: _convertNodes(node.children!, theme),
          ),
        );
      }
    }
    return spans;
  }
}
