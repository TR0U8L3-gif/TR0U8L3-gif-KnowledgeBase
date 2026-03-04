import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_base/src/knowledge_base/domain/entities/knowledge_base_item.dart';
import 'package:knowledge_base/src/knowledge_base/domain/repositories/favorites_repository.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/bloc/favorites/favorites_cubit.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/bloc/favorites/favorites_state.dart';
import 'package:mocktail/mocktail.dart';

class MockFavoritesRepository extends Mock implements FavoritesRepository {}

void main() {
  late MockFavoritesRepository mockRepository;

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

  const file3 = FileItem(
    name: 'Local Dev',
    path: 'guides/local-dev.md',
    tags: ['dev'],
    extension: 'md',
  );

  const allFiles = [file1, file2, file3];

  setUp(() {
    mockRepository = MockFavoritesRepository();
  });

  FavoritesCubit buildCubit() => FavoritesCubit(repository: mockRepository);

  group('FavoritesCubit', () {
    group('initial state', () {
      test('is FavoritesState with initial status and empty favorites', () {
        expect(buildCubit().state, const FavoritesState());
      });
    });

    group('loadAndValidate', () {
      blocTest<FavoritesCubit, FavoritesState>(
        'does nothing when allFiles is empty',
        build: buildCubit,
        act: (cubit) => cubit.loadAndValidate([]),
        expect: () => <FavoritesState>[],
        verify: (_) {
          verifyNever(() => mockRepository.loadAndValidateFavorites(any()));
        },
      );

      blocTest<FavoritesCubit, FavoritesState>(
        'emits loading then loaded with resolved FileItems for all valid paths',
        setUp: () {
          when(
            () => mockRepository.loadAndValidateFavorites(allFiles),
          ).thenAnswer((_) async => [file1, file2]);
        },
        build: buildCubit,
        act: (cubit) => cubit.loadAndValidate(allFiles),
        expect: () => [
          const FavoritesState(status: FavoritesStatus.loading),
          const FavoritesState(
            status: FavoritesStatus.loaded,
            favorites: [file1, file2],
          ),
        ],
        verify: (_) {
          verify(
            () => mockRepository.loadAndValidateFavorites(allFiles),
          ).called(1);
        },
      );

      blocTest<FavoritesCubit, FavoritesState>(
        'emits loaded with subset when repository drops stale paths',
        setUp: () {
          when(
            () => mockRepository.loadAndValidateFavorites(allFiles),
          ).thenAnswer((_) async => [file1]);
        },
        build: buildCubit,
        act: (cubit) => cubit.loadAndValidate(allFiles),
        expect: () => [
          const FavoritesState(status: FavoritesStatus.loading),
          const FavoritesState(
            status: FavoritesStatus.loaded,
            favorites: [file1],
          ),
        ],
      );

      blocTest<FavoritesCubit, FavoritesState>(
        'emits loaded with empty list when all saved paths are stale',
        setUp: () {
          when(
            () => mockRepository.loadAndValidateFavorites(allFiles),
          ).thenAnswer((_) async => []);
        },
        build: buildCubit,
        act: (cubit) => cubit.loadAndValidate(allFiles),
        expect: () => [
          const FavoritesState(status: FavoritesStatus.loading),
          const FavoritesState(status: FavoritesStatus.loaded, favorites: []),
        ],
      );
    });

    group('toggleFavorite', () {
      blocTest<FavoritesCubit, FavoritesState>(
        'adds file to front of favorites when not already favorited',
        setUp: () {
          when(
            () => mockRepository.addFavorite(file2, [file1]),
          ).thenAnswer((_) async => [file2, file1]);
        },
        build: buildCubit,
        seed: () => const FavoritesState(
          status: FavoritesStatus.loaded,
          favorites: [file1],
        ),
        act: (cubit) => cubit.toggleFavorite(file2),
        expect: () => [
          const FavoritesState(
            status: FavoritesStatus.loaded,
            favorites: [file2, file1],
          ),
        ],
        verify: (_) {
          verify(() => mockRepository.addFavorite(file2, [file1])).called(1);
        },
      );

      blocTest<FavoritesCubit, FavoritesState>(
        'removes file from favorites when already favorited',
        setUp: () {
          when(
            () => mockRepository.removeFavorite('api/auth.md', [file2, file1]),
          ).thenAnswer((_) async => [file2]);
        },
        build: buildCubit,
        seed: () => const FavoritesState(
          status: FavoritesStatus.loaded,
          favorites: [file2, file1],
        ),
        act: (cubit) => cubit.toggleFavorite(file1),
        expect: () => [
          const FavoritesState(
            status: FavoritesStatus.loaded,
            favorites: [file2],
          ),
        ],
        verify: (_) {
          verify(
            () => mockRepository.removeFavorite('api/auth.md', [file2, file1]),
          ).called(1);
        },
      );

      blocTest<FavoritesCubit, FavoritesState>(
        'adds file to empty favorites list',
        setUp: () {
          when(
            () => mockRepository.addFavorite(file1, []),
          ).thenAnswer((_) async => [file1]);
        },
        build: buildCubit,
        seed: () => const FavoritesState(status: FavoritesStatus.loaded),
        act: (cubit) => cubit.toggleFavorite(file1),
        expect: () => [
          const FavoritesState(
            status: FavoritesStatus.loaded,
            favorites: [file1],
          ),
        ],
      );

      blocTest<FavoritesCubit, FavoritesState>(
        'removes last favorite to result in empty list',
        setUp: () {
          when(
            () => mockRepository.removeFavorite('api/auth.md', [file1]),
          ).thenAnswer((_) async => []);
        },
        build: buildCubit,
        seed: () => const FavoritesState(
          status: FavoritesStatus.loaded,
          favorites: [file1],
        ),
        act: (cubit) => cubit.toggleFavorite(file1),
        expect: () => [
          const FavoritesState(status: FavoritesStatus.loaded, favorites: []),
        ],
      );
    });
  });
}
