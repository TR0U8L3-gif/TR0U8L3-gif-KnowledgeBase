import 'dart:js_interop';

// ---------------------------------------------------------------------------
// JS interop — window & console bridge
// ---------------------------------------------------------------------------

extension type _AppWindow(JSObject _) implements JSObject {
  external bool? get __kbDebugEnabled;
  external set __kbDebugEnabled(bool? value);
  external set enableDebug(JSFunction fn);
  external set disableDebug(JSFunction fn);
}

extension type _Console(JSObject _) implements JSObject {
  external void log(JSString msg);
  external void info(JSString msg);
  external void warn(JSString msg);
  external void error(JSString msg);
}

@JS('window')
external _AppWindow get _appWindow;

@JS('window.console')
external _Console get _console;

// ---------------------------------------------------------------------------
// Public surface consumed by AppLogger
// ---------------------------------------------------------------------------

/// Returns `true` once the user has typed `enableDebug()` in DevTools.
bool isDebugEnabled() => _appWindow.__kbDebugEnabled == true;

void writeLog(String msg) => _console.log(msg.toJS);
void writeInfo(String msg) => _console.info(msg.toJS);
void writeWarn(String msg) => _console.warn(msg.toJS);
void writeError(String msg) => _console.error(msg.toJS);

/// Registers `enableDebug()` and `disableDebug()` on `window`.
///
/// Call once from `main()`. After that the user can run either command
/// directly in the Chrome DevTools **Console** tab.
void registerDebugCommands() {
  _appWindow.enableDebug = () {
    _appWindow.__kbDebugEnabled = true;
    _console.info(
      '[App] Debug logging ENABLED — all AppLogger entries will now appear '
              'here. Type disableDebug() to turn off.'
          .toJS,
    );
  }.toJS;

  _appWindow.disableDebug = () {
    _appWindow.__kbDebugEnabled = false;
    _console.info('[App] Debug logging DISABLED.'.toJS);
  }.toJS;
}
