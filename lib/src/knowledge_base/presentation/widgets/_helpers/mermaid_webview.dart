// Selects the correct platform WebView implementation at compile time.
// On Flutter Web the iframe-based renderer is used; on all other targets
// (iOS, Android, macOS, Windows, Linux) the InAppWebView renderer is used.
export 'mermaid_webview_native.dart'
    if (dart.library.js_interop) 'mermaid_webview_web.dart';
