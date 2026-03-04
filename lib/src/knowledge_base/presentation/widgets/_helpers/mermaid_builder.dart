import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'mermaid_webview.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// A [MarkdownElementBuilder] that renders `<mermaid>` pseudo-elements
/// (produced by [MermaidBlockSyntax]) as interactive diagrams inside a
/// platform-appropriate WebView.
///
/// The builder loads a self-contained HTML page that bundles `mermaid.min.js`
/// from a local asset, preserving offline support. The mermaid theme is
/// selected based on the app's current brightness.
class MermaidBuilder extends MarkdownElementBuilder {
  /// Default height for the mermaid diagram container.
  final double height;

  MermaidBuilder({this.height = 400});

  @override
  bool isBlockElement() => true;

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final source = element.textContent.trim();
    if (source.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _MermaidDiagramWidget(
      source: source,
      isDark: isDark,
      height: height,
    );
  }
}

// ── Stateful widget that manages the platform WebView lifecycle ─────────────

class _MermaidDiagramWidget extends StatefulWidget {
  const _MermaidDiagramWidget({
    required this.source,
    required this.isDark,
    required this.height,
  });

  final String source;
  final bool isDark;
  final double height;

  @override
  State<_MermaidDiagramWidget> createState() => _MermaidDiagramWidgetState();
}

class _MermaidDiagramWidgetState extends State<_MermaidDiagramWidget> {
  bool _isLoading = true;
  bool _hasError = false;
  double _contentHeight = 0;

  /// Resolved HTML string — null while the asset is still loading.
  String? _html;

  @override
  void initState() {
    super.initState();
    _loadHtml();
  }

  Future<void> _loadHtml() async {
    try {
      final mermaidJs = await rootBundle.loadString(
        'assets/mermaid/mermaid.min.js',
      );
      if (mounted) {
        setState(() {
          _html = _buildHtml(
            mermaidJs: mermaidJs,
            source: widget.source,
            isDark: widget.isDark,
          );
        });
      }
    } catch (_) {
      if (mounted) setState(() => _hasError = true);
    }
  }

  String _buildHtml({
    required String mermaidJs,
    required String source,
    required bool isDark,
  }) {
    final mermaidTheme = isDark ? 'dark' : 'default';
    final bgColor = isDark ? '#1a1a2e' : '#ffffff';
    final textColor = isDark ? '#e0e0e0' : '#333333';
    final escapedSource = _escapeForJs(source);

    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      background-color: $bgColor;
      color: $textColor;
      display: flex;
      justify-content: center;
      align-items: flex-start;
      padding: 16px;
      overflow: hidden;
    }
    #mermaid-container {
      width: 100%;
      display: flex;
      justify-content: center;
    }
    #mermaid-container svg { max-width: 100%; height: auto; }
    .error {
      color: #e74c3c;
      font-family: monospace;
      padding: 12px;
      white-space: pre-wrap;
    }
  </style>
</head>
<body>
  <div id="mermaid-container"></div>
  <script>$mermaidJs</script>
  <script>
    (async function() {
      try {
        mermaid.initialize({
          startOnLoad: false,
          theme: '$mermaidTheme',
          securityLevel: 'loose',
          fontFamily: 'system-ui, -apple-system, sans-serif',
        });
        const source = `$escapedSource`;
        const { svg } = await mermaid.render('mermaid-diagram', source);
        document.getElementById('mermaid-container').innerHTML = svg;
      } catch (err) {
        document.getElementById('mermaid-container').innerHTML =
          '<div class="error">Mermaid render error:\\n' + err.message + '</div>';
      }
    })();
  </script>
</body>
</html>
''';
  }

  /// Escapes a string for safe embedding inside a JS template literal.
  String _escapeForJs(String source) {
    return source
        .replaceAll(r'\', r'\\')
        .replaceAll('`', r'\`')
        .replaceAll(r'$', r'\$');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final scaling = theme.scaling;

    if (_hasError) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16 * scaling),
        decoration: BoxDecoration(
          color: colorScheme.destructive.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12 * scaling),
          border: Border.all(
            color: colorScheme.destructive.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: colorScheme.destructive,
              size: 20 * scaling,
            ),
            SizedBox(width: 8 * scaling),
            Expanded(
              child: Text(
                'Failed to render Mermaid diagram',
                style: TextStyle(
                  color: colorScheme.destructive,
                  fontSize: 14 * scaling,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final effectiveHeight = _contentHeight > 0 ? _contentHeight : widget.height;

    // Show a spinner while the mermaid JS asset is still loading from disk.
    if (_html == null) {
      return SizedBox(
        height: effectiveHeight,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12 * scaling),
      child: Container(
        width: double.infinity,
        height: effectiveHeight,
        decoration: BoxDecoration(
          color: colorScheme.muted.withValues(alpha: 0.2),
          border: Border.all(color: colorScheme.border, width: 0.5),
          borderRadius: BorderRadius.circular(12 * scaling),
        ),
        child: Stack(
          children: [
            MermaidPlatformWebView(
              htmlContent: _html!,
              onLoaded: () {
                if (mounted) setState(() => _isLoading = false);
              },
              onContentHeight: (h) {
                if (mounted) setState(() => _contentHeight = h);
              },
              onError: () {
                if (mounted) setState(() => _hasError = true);
              },
            ),
            if (_isLoading)
              const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ],
        ),
      ),
    );
  }
}
