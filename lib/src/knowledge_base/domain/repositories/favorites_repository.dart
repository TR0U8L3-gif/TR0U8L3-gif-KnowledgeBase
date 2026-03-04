import '../entities/knowledge_base_item.dart';

/// Abstract repository defining operations for the favorites feature.
abstract class FavoritesRepository {
  /// Loads the stored favorite paths, resolves them against [allFiles],
  /// discards any stale entries, persists the cleaned list, and returns
  /// the resolved [FileItem] list.
  Future<List<FileItem>> loadAndValidateFavorites(List<FileItem> allFiles);

  /// Adds [file] to the front of [currentFavorites], persists the updated
  /// list, and returns it.
  Future<List<FileItem>> addFavorite(
    FileItem file,
    List<FileItem> currentFavorites,
  );

  /// Removes the file at [path] from [currentFavorites], persists the updated
  /// list, and returns it.
  Future<List<FileItem>> removeFavorite(
    String path,
    List<FileItem> currentFavorites,
  );
}
