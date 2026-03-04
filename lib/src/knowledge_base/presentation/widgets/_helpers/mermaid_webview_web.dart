// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';

/// Flutter-Web renderer for Mermaid diagrams using an [HtmlElementView]
/// backed by an `<iframe srcdoc="...">` element.
///
/// Because [InAppWebView] does not fire `onLoadStop` reliably on web,
/// this implementation registers a native iframe and listens to its
/// DOM `load` event directly.
class MermaidPlatformWebView extends StatefulWidget {
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
  State<MermaidPlatformWebView> createState() => _MermaidPlatformWebViewState();
}

// Counter used to generate unique view-type IDs.
int _viewCounter = 0;

class _MermaidPlatformWebViewState extends State<MermaidPlatformWebView> {
  late final String _viewId;

  @override
  void initState() {
    super.initState();
    _viewId = 'mermaid-view-${_viewCounter++}';

    ui_web.platformViewRegistry.registerViewFactory(_viewId, (int id) {
      final iframe = html.IFrameElement()
        ..srcdoc = widget.htmlContent
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%';

      iframe.onLoad.listen((_) {
        // Notify the parent that the iframe finished loading.
        // Height introspection from an srcdoc iframe is typically blocked by
        // browser security policies, so we rely on the caller's default height.
        widget.onLoaded();
      });

      iframe.onError.listen((_) => widget.onError());

      return iframe;
    });
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewId);
  }
}
