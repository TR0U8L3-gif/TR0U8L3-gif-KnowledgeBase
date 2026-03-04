import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Local data source for persisting favorite article paths using SharedPreferences.
class FavoritesLocalDataSource {
  FavoritesLocalDataSource({required SharedPreferences prefs}) : _prefs = prefs;

  final SharedPreferences _prefs;

  static const _kKey = 'favorites';

  /// Loads the list of favorite file paths from local storage.
  /// Returns an empty list on first run or decoded list is invalid.
  /// If reading from storage fails, throws [LocalDataSourceException].
  Future<List<String>> loadFavoritePaths() async {
    try {
      final raw = _prefs.getString(_kKey);
      if (raw == null) return [];
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.cast<String>();
      }
      return [];
    } catch (e) {
      throw LocalDataSourceException('Failed to load favorite paths: $e');
    }
  }

  /// Saves the list of favorite file paths to local storage.
  /// If saving to storage fails, throws [LocalDataSourceException].
  Future<void> saveFavoritePaths(List<String> paths) async {
    try {
      await _prefs.setString(_kKey, jsonEncode(paths));
    } catch (e) {
      throw LocalDataSourceException('Failed to save favorite paths: $e');
    }
  }
}

class LocalDataSourceException implements Exception {
  final String message;
  LocalDataSourceException(this.message);

  @override
  String toString() => 'LocalDataSourceException: $message';
}