import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/bloc/favorites/favorites_state.dart';
import 'package:knowledge_base/src/knowledge_base/domain/entities/knowledge_base_item.dart';

void main() {
  const file1 = FileItem(
    name: 'Auth',
    path: 'api/auth.md',
    tags: ['auth'],
    extension: 'md',
  );

  const file2 = FileItem(
    name: 'Payments',
    path: 'api/payments.md',
    tags: ['payments'],
    extension: 'md',
  );

  group('FavoritesState', () {
    test('has correct initial values', () {
      const state = FavoritesState();
      expect(state.status, FavoritesStatus.initial);
      expect(state.favorites, isEmpty);
    });

    test('supports value equality', () {
      const state1 = FavoritesState();
      const state2 = FavoritesState();
      expect(state1, equals(state2));
    });

    test('isFavorite returns true when file path exists', () {
      final state = FavoritesState(
        status: FavoritesStatus.loaded,
        favorites: const [file1],
      );
      expect(state.isFavorite('api/auth.md'), isTrue);
    });

    test('isFavorite returns false when file path does not exist', () {
      final state = FavoritesState(
        status: FavoritesStatus.loaded,
        favorites: const [file1],
      );
      expect(state.isFavorite('api/payments.md'), isFalse);
    });

    test('copyWith returns new state with updated fields', () {
      const state = FavoritesState();
      final updated = state.copyWith(
        status: FavoritesStatus.loaded,
        favorites: [file1, file2],
      );
      expect(updated.status, FavoritesStatus.loaded);
      expect(updated.favorites, [file1, file2]);
    });

    test('copyWith preserves fields when not specified', () {
      final state = FavoritesState(
        status: FavoritesStatus.loaded,
        favorites: const [file1],
      );
      final updated = state.copyWith();
      expect(updated.status, FavoritesStatus.loaded);
      expect(updated.favorites, [file1]);
    });

    test('props contains status and favorites', () {
      final state = FavoritesState(
        status: FavoritesStatus.loaded,
        favorites: const [file1],
      );
      expect(state.props, [
        FavoritesStatus.loaded,
        [file1],
      ]);
    });
  });
}
