import 'dart:developer' as developer;

/// Project-wide logger that writes structured entries to [dart:developer.log].
///
/// On Flutter web the Dart tooling maps [dart:developer.log] calls to the
/// browser's native `console` methods, so every entry is visible in the
/// Chrome DevTools **Console** tab:
///
/// | Level       | `log level` value | Chrome DevTools appearance |
/// |-------------|-------------------|---------------------------|
/// | debug       | 500 (FINE)        | default (grey)            |
/// | info        | 800 (INFO)        | `console.info` (blue ℹ)  |
/// | warning     | 900 (WARNING)     | `console.warn` (yellow ⚠) |
/// | error       | 1000 (SEVERE)     | `console.error` (red ✕)  |
///
/// Filter entries in the Console tab by typing the logger [name] (e.g.
/// `FavoritesLocalDataSource`) into the filter box.
abstract final class AppLogger {
  static const _defaultName = 'App';

  /// Fine-grained informational message, typically used for tracing.
  static void debug(
    String message, {
    String name = _defaultName,
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: name,
      level: 500, // FINE
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Informational message about normal application events.
  static void info(
    String message, {
    String name = _defaultName,
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: name,
      level: 800, // INFO
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Something unexpected occurred but the app can continue.
  static void warning(
    String message, {
    String name = _defaultName,
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: name,
      level: 900, // WARNING
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// A failure that likely affects observable behaviour or user data.
  static void error(
    String message, {
    String name = _defaultName,
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: name,
      level: 1000, // SEVERE
      error: error,
      stackTrace: stackTrace,
    );
  }
}
