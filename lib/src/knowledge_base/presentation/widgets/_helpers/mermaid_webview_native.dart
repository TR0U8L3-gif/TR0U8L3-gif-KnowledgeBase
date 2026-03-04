import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Native (iOS / Android / desktop) renderer using [InAppWebView].
///
/// Communicates loading progress and measured content height back to the
/// caller via [onLoaded], [onContentHeight], and [onError].
class MermaidPlatformWebView extends StatelessWidget {
  const MermaidPlatformWebView({
    super.key,
    required this.htmlContent,
    required this.onLoaded,
    required this.onContentHeight,
    required this.onError,
  });

  final String htmlContent;
  final VoidCallback onLoaded;
  final ValueChanged<double> onContentHeight;
  final VoidCallback onError;

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialData: InAppWebViewInitialData(
        data: htmlContent,
        mimeType: 'text/html',
        encoding: 'utf-8',
      ),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        transparentBackground: true,
        disableVerticalScroll: true,
        supportZoom: false,
      ),
      onLoadStop: (controller, url) async {
        try {
          final result = await controller.evaluateJavascript(
            source:
                'document.getElementById("mermaid-container")?.scrollHeight ?? 0',
          );
          final h = double.tryParse(result?.toString() ?? '');
          if (h != null && h > 0) {
            onContentHeight(h + 32);
          }
        } catch (_) {
          // Height stays at default if JS eval fails.
        }
        onLoaded();
      },
      onReceivedError: (controller, request, error) {
        onError();
      },
    );
  }
}
