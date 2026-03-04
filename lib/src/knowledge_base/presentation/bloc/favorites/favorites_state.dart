import 'package:equatable/equatable.dart';

import '../../../domain/entities/knowledge_base_item.dart';

enum FavoritesStatus { initial, loading, loaded }

final class FavoritesState extends Equatable {
  final FavoritesStatus status;
  final List<FileItem> favorites;

  const FavoritesState({
    this.status = FavoritesStatus.initial,
    this.favorites = const [],
  });

  /// Returns `true` if the file at [path] is in the favorites list.
  bool isFavorite(String path) => favorites.any((f) => f.path == path);

  FavoritesState copyWith({
    FavoritesStatus? status,
    List<FileItem>? favorites,
  }) {
    return FavoritesState(
      status: status ?? this.status,
      favorites: favorites ?? this.favorites,
    );
  }

  @override
  List<Object?> get props => [status, favorites];
}
