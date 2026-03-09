import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowledge_base/core/shared/app_logger.dart';

import '../../../domain/entities/knowledge_base_item.dart';
import '../../../domain/repositories/favorites_repository.dart';
import 'favorites_state.dart';

/// Cubit managing the user's bookmarked (favorite) articles.
class FavoritesCubit extends Cubit<FavoritesState> {
  final FavoritesRepository _repository;

  FavoritesCubit({required FavoritesRepository repository})
    : _repository = repository,
      super(const FavoritesState());

  /// Loads saved favorite paths, validates them against [allFiles], discards
  /// stale entries, and persists the cleaned-up list.
  Future<void> loadAndValidate(List<FileItem> allFiles) async {
    if (allFiles.isEmpty) return;

    emit(state.copyWith(status: FavoritesStatus.loading));

    try {
      final resolved = await _repository.loadAndValidateFavorites(allFiles);
      emit(state.copyWith(status: FavoritesStatus.loaded, favorites: resolved));
    } catch (e, st) {
      AppLogger.error(
        'Failed to load and validate favorites',
        name: 'FavoritesCubit',
        error: e,
        stackTrace: st,
      );
      emit(state.copyWith(status: FavoritesStatus.error));
    }
  }

  /// Toggles the favorite status of [file]. If already favorited, removes it;
  /// otherwise adds it to the front of the list.
  Future<void> toggleFavorite(FileItem file) async {
    try {
      final List<FileItem> updated;
      if (state.isFavorite(file.path)) {
        updated = await _repository.removeFavorite(file.path, state.favorites);
      } else {
        updated = await _repository.addFavorite(file, state.favorites);
      }
      emit(state.copyWith(favorites: updated));
    } catch (e, st) {
      AppLogger.error(
        'Failed to toggle favorite: ${file.path}',
        name: 'FavoritesCubit',
        error: e,
        stackTrace: st,
      );
    }
  }
}
