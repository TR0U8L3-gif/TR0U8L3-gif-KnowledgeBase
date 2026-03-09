import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

import 'logging/web_console_stub.dart'
    if (dart.library.js_interop) 'logging/web_console.dart';

/// Project-wide logger that writes structured entries to the Chrome DevTools
/// Console tab on **both debug and release** builds.
///
/// ## How it works
///
/// | Build mode | Condition               | Output                            |
/// |------------|-------------------------|-----------------------------------|
/// | Debug      | always                  | `dart:developer.log` (IDE + DevTools) |
/// | Release    | `enableDebug()` called  | Direct `window.console.*` call    |
/// | Release    | not enabled             | suppressed (no-op)                |
///
/// ## Enabling logs on GitHub Pages (production)
///
/// 1. Open Chrome DevTools → **Console** tab.
/// 2. Type `enableDebug()` and press Enter.
/// 3. All subsequent `AppLogger` calls appear immediately.
/// 4. Type `disableDebug()` to suppress them again.
///
/// ## Filtering
/// Filter entries by typing the logger [name] (e.g. `FavoritesLocalDataSource`)
/// into the DevTools Console filter box.
abstract final class AppLogger {
  static const _defaultName = 'App';

  /// `true` when logging should actually write output.
  static bool get _enabled => kDebugMode || isDebugEnabled();

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  static String _format(
    String level,
    String name,
    String message,
    Object? error,
    StackTrace? stackTrace,
  ) {
    final buf = StringBuffer('[$level][$name] $message');
    if (error != null) buf.write('\n  error: $error');
    if (stackTrace != null) buf.write('\n$stackTrace');
    return buf.toString();
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Fine-grained informational message, typically used for tracing.
  static void debug(
    String message, {
    String name = _defaultName,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!_enabled) return;
    if (kDebugMode) {
      developer.log(
        message,
        name: name,
        level: 500,
        error: error,
        stackTrace: stackTrace,
      );
    } else {
      writeLog(_format('DEBUG', name, message, error, stackTrace));
    }
  }

  /// Informational message about normal application events.
  static void info(
    String message, {
    String name = _defaultName,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!_enabled) return;
    if (kDebugMode) {
      developer.log(
        message,
        name: name,
        level: 800,
        error: error,
        stackTrace: stackTrace,
      );
    } else {
      writeInfo(_format('INFO', name, message, error, stackTrace));
    }
  }

  /// Something unexpected occurred but the app can continue.
  static void warning(
    String message, {
    String name = _defaultName,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!_enabled) return;
    if (kDebugMode) {
      developer.log(
        message,
        name: name,
        level: 900,
        error: error,
        stackTrace: stackTrace,
      );
    } else {
      writeWarn(_format('WARN', name, message, error, stackTrace));
    }
  }

  /// A failure that likely affects observable behaviour or user data.
  static void error(
    String message, {
    String name = _defaultName,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!_enabled) return;
    if (kDebugMode) {
      developer.log(
        message,
        name: name,
        level: 1000,
        error: error,
        stackTrace: stackTrace,
      );
    } else {
      writeError(_format('ERROR', name, message, error, stackTrace));
    }
  }
}
