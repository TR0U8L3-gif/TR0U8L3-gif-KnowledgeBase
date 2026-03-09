import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Local data source for persisting favorite article paths using FlutterSecureStorage.
class FavoritesLocalDataSource {
  FavoritesLocalDataSource({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _kKey = 'favorites';

  /// Loads the list of favorite file paths from local storage.
  /// Returns an empty list on first run or decoded list is invalid.
  /// If reading from storage fails, throws [LocalDataSourceException].
  Future<List<String>> loadFavoritePaths() async {
    try {
      final raw = await _storage.read(key: _kKey);
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
      await _storage.write(key: _kKey, value: jsonEncode(paths));
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
