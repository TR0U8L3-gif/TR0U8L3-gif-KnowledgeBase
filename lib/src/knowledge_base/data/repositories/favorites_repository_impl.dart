import '../../domain/entities/knowledge_base_item.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../data_sources/favorites_local_data_source.dart';

/// Concrete implementation of [FavoritesRepository].
///
/// Delegates persistence to [FavoritesLocalDataSource] and handles
/// path resolution / validation logic.
class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesLocalDataSource _dataSource;

  FavoritesRepositoryImpl({required FavoritesLocalDataSource dataSource})
    : _dataSource = dataSource;

  @override
  Future<List<FileItem>> loadAndValidateFavorites(
    List<FileItem> allFiles,
  ) async {
    final savedPaths = await _dataSource.loadFavoritePaths();
    final resolved = <FileItem>[];

    for (final path in savedPaths) {
      final file = _resolveFile(path, allFiles);
      if (file != null) {
        resolved.add(file);
      }
    }

    // Persist cleaned-up paths (stale entries removed)
    await _dataSource.saveFavoritePaths(resolved.map((f) => f.path).toList());

    return resolved;
  }

  @override
  Future<List<FileItem>> addFavorite(
    FileItem file,
    List<FileItem> currentFavorites,
  ) async {
    final updated = [file, ...currentFavorites];
    await _dataSource.saveFavoritePaths(updated.map((f) => f.path).toList());
    return updated;
  }

  @override
  Future<List<FileItem>> removeFavorite(
    String path,
    List<FileItem> currentFavorites,
  ) async {
    final updated = currentFavorites.where((f) => f.path != path).toList();
    await _dataSource.saveFavoritePaths(updated.map((f) => f.path).toList());
    return updated;
  }

  // ── Private helpers ──────────────────────────────────────────────────

  /// Attempts to find a [FileItem] in [allFiles] by exact path match first,
  /// then falls back to a case-insensitive name match. Returns `null` if
  /// neither succeeds.
  FileItem? _resolveFile(String path, List<FileItem> allFiles) {
    // Exact path match
    final exactMatch = allFiles.cast<FileItem?>().firstWhere(
      (f) => f!.path == path,
      orElse: () => null,
    );
    if (exactMatch != null) return exactMatch;

    // Fallback: name-based lookup (case-insensitive, trimmed)
    final fileName = path.split('/').last.trim().toLowerCase();
    return allFiles.cast<FileItem?>().firstWhere(
      (f) => f!.name.trim().toLowerCase() == fileName,
      orElse: () => null,
    );
  }
}
