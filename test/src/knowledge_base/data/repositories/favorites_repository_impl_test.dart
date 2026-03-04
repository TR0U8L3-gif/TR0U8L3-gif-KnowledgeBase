import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_base/src/knowledge_base/data/data_sources/favorites_local_data_source.dart';
import 'package:knowledge_base/src/knowledge_base/data/repositories/favorites_repository_impl.dart';
import 'package:knowledge_base/src/knowledge_base/domain/entities/knowledge_base_item.dart';
import 'package:mocktail/mocktail.dart';

class MockFavoritesLocalDataSource extends Mock
    implements FavoritesLocalDataSource {}

void main() {
  late MockFavoritesLocalDataSource mockDataSource;
  late FavoritesRepositoryImpl repository;

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
    mockDataSource = MockFavoritesLocalDataSource();
    repository = FavoritesRepositoryImpl(dataSource: mockDataSource);
  });

  group('FavoritesRepositoryImpl', () {
    group('loadAndValidateFavorites', () {
      test('returns resolved FileItems for all valid paths', () async {
        when(
          () => mockDataSource.loadFavoritePaths(),
        ).thenAnswer((_) async => ['api/auth.md', 'api/payments.md']);
        when(
          () => mockDataSource.saveFavoritePaths(any()),
        ).thenAnswer((_) async {});

        final result = await repository.loadAndValidateFavorites(allFiles);

        expect(result, [file1, file2]);
        verify(
          () => mockDataSource.saveFavoritePaths([
            'api/auth.md',
            'api/payments.md',
          ]),
        ).called(1);
      });

      test('drops stale paths that no longer exist in allFiles', () async {
        when(
          () => mockDataSource.loadFavoritePaths(),
        ).thenAnswer((_) async => ['api/auth.md', 'nonexistent/file.md']);
        when(
          () => mockDataSource.saveFavoritePaths(any()),
        ).thenAnswer((_) async {});

        final result = await repository.loadAndValidateFavorites(allFiles);

        expect(result, [file1]);
        verify(
          () => mockDataSource.saveFavoritePaths(['api/auth.md']),
        ).called(1);
      });

      test('resolves by name when exact path not found', () async {
        when(
          () => mockDataSource.loadFavoritePaths(),
        ).thenAnswer((_) async => ['old-path/Auth']);
        when(
          () => mockDataSource.saveFavoritePaths(any()),
        ).thenAnswer((_) async {});

        final result = await repository.loadAndValidateFavorites(allFiles);

        expect(result, [file1]);
        verify(
          () => mockDataSource.saveFavoritePaths(['api/auth.md']),
        ).called(1);
      });

      test('returns empty list when all saved paths are stale', () async {
        when(
          () => mockDataSource.loadFavoritePaths(),
        ).thenAnswer((_) async => ['gone/a.md', 'gone/b.md']);
        when(
          () => mockDataSource.saveFavoritePaths(any()),
        ).thenAnswer((_) async {});

        final result = await repository.loadAndValidateFavorites(allFiles);

        expect(result, isEmpty);
        verify(() => mockDataSource.saveFavoritePaths([])).called(1);
      });

      test('returns empty list when no saved paths exist', () async {
        when(
          () => mockDataSource.loadFavoritePaths(),
        ).thenAnswer((_) async => []);
        when(
          () => mockDataSource.saveFavoritePaths(any()),
        ).thenAnswer((_) async {});

        final result = await repository.loadAndValidateFavorites(allFiles);

        expect(result, isEmpty);
        verify(() => mockDataSource.saveFavoritePaths([])).called(1);
      });
    });

    group('addFavorite', () {
      test('adds file to front and persists updated list', () async {
        when(
          () => mockDataSource.saveFavoritePaths(any()),
        ).thenAnswer((_) async {});

        final result = await repository.addFavorite(file2, [file1]);

        expect(result, [file2, file1]);
        verify(
          () => mockDataSource.saveFavoritePaths([
            'api/payments.md',
            'api/auth.md',
          ]),
        ).called(1);
      });

      test('adds file to empty list', () async {
        when(
          () => mockDataSource.saveFavoritePaths(any()),
        ).thenAnswer((_) async {});

        final result = await repository.addFavorite(file1, []);

        expect(result, [file1]);
        verify(
          () => mockDataSource.saveFavoritePaths(['api/auth.md']),
        ).called(1);
      });
    });

    group('removeFavorite', () {
      test('removes file by path and persists updated list', () async {
        when(
          () => mockDataSource.saveFavoritePaths(any()),
        ).thenAnswer((_) async {});

        final result = await repository.removeFavorite('api/auth.md', [
          file2,
          file1,
        ]);

        expect(result, [file2]);
        verify(
          () => mockDataSource.saveFavoritePaths(['api/payments.md']),
        ).called(1);
      });

      test('removes last favorite to result in empty list', () async {
        when(
          () => mockDataSource.saveFavoritePaths(any()),
        ).thenAnswer((_) async {});

        final result = await repository.removeFavorite('api/auth.md', [file1]);

        expect(result, isEmpty);
        verify(() => mockDataSource.saveFavoritePaths([])).called(1);
      });

      test('returns unchanged list when path not found', () async {
        when(
          () => mockDataSource.saveFavoritePaths(any()),
        ).thenAnswer((_) async {});

        final result = await repository.removeFavorite('nonexistent.md', [
          file1,
        ]);

        expect(result, [file1]);
        verify(
          () => mockDataSource.saveFavoritePaths(['api/auth.md']),
        ).called(1);
      });
    });
  });
}
