import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_base/src/knowledge_base/domain/entities/knowledge_base_item.dart';
import 'package:knowledge_base/src/knowledge_base/domain/repositories/knowledge_base_repository.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/bloc/navigation/navigation_state.dart';

void main() {
  const tFile1 = FileItem(
    name: 'Auth',
    path: 'api/auth.md',
    tags: [],
    extension: 'md',
  );
  const tFile2 = FileItem(
    name: 'Payments',
    path: 'api/payments.md',
    tags: [],
    extension: 'md',
  );
  const tRootDir = DirectoryItem(
    name: 'Root',
    path: '',
    items: [tFile1, tFile2],
  );
  const tApiDir = DirectoryItem(name: 'API', path: 'api', items: [tFile1]);

  group('NavigationState', () {
    test('default constructor sets expected defaults', () {
      const state = NavigationState();
      expect(state.status, NavigationStatus.initial);
      expect(state.rootDirectory, isNull);
      expect(state.selectedFile, isNull);
      expect(state.selectedDirectory, isNull);
      expect(state.viewMode, ViewMode.file);
      expect(state.breadcrumb, isEmpty);
      expect(state.allFiles, isEmpty);
      expect(state.currentPage, 1);
      expect(state.showSidePanel, isTrue);
      expect(state.showTocPanel, isTrue);
      expect(state.errorMessage, isNull);
    });

    group('copyWith', () {
      test('copies status', () {
        const state = NavigationState();
        final copy = state.copyWith(status: NavigationStatus.loading);
        expect(copy.status, NavigationStatus.loading);
        expect(copy.currentPage, 1); // unchanged
      });

      test('copies rootDirectory', () {
        const state = NavigationState();
        final copy = state.copyWith(rootDirectory: tRootDir);
        expect(copy.rootDirectory, tRootDir);
      });

      test('copies selectedFile', () {
        const state = NavigationState();
        final copy = state.copyWith(selectedFile: tFile1);
        expect(copy.selectedFile, tFile1);
      });

      test('copies selectedDirectory', () {
        const state = NavigationState();
        final copy = state.copyWith(selectedDirectory: tRootDir);
        expect(copy.selectedDirectory, tRootDir);
      });

      test('copies viewMode', () {
        const state = NavigationState();
        final copy = state.copyWith(viewMode: ViewMode.directory);
        expect(copy.viewMode, ViewMode.directory);
      });

      test('copies currentPage', () {
        const state = NavigationState();
        final copy = state.copyWith(currentPage: 3);
        expect(copy.currentPage, 3);
      });

      test('copies showSidePanel', () {
        const state = NavigationState();
        final copy = state.copyWith(showSidePanel: false);
        expect(copy.showSidePanel, isFalse);
      });

      test('copies showTocPanel', () {
        const state = NavigationState();
        final copy = state.copyWith(showTocPanel: false);
        expect(copy.showTocPanel, isFalse);
      });

      test('copies errorMessage', () {
        const state = NavigationState();
        final copy = state.copyWith(errorMessage: 'Something went wrong');
        expect(copy.errorMessage, 'Something went wrong');
      });

      test('clearSelectedFile sets selectedFile to null', () {
        final state = NavigationState().copyWith(selectedFile: tFile1);
        final copy = state.copyWith(clearSelectedFile: true);
        expect(copy.selectedFile, isNull);
      });

      test('clearSelectedDirectory sets selectedDirectory to null', () {
        final state = NavigationState().copyWith(selectedDirectory: tRootDir);
        final copy = state.copyWith(clearSelectedDirectory: true);
        expect(copy.selectedDirectory, isNull);
      });

      test('preserves unchanged fields', () {
        const state = NavigationState(currentPage: 2, showSidePanel: false);
        final copy = state.copyWith(status: NavigationStatus.loaded);
        expect(copy.currentPage, 2);
        expect(copy.showSidePanel, isFalse);
      });
    });

    group('computed getters', () {
      test('totalFiles returns allFiles length', () {
        final state = NavigationState(allFiles: [tFile1, tFile2]);
        expect(state.totalFiles, 2);
      });

      test('totalFiles returns 0 when allFiles is empty', () {
        const state = NavigationState();
        expect(state.totalFiles, 0);
      });

      test('currentFileIndex returns 1-based index of selectedFile', () {
        final state = NavigationState(
          allFiles: [tFile1, tFile2],
          selectedFile: tFile2,
        );
        expect(state.currentFileIndex, 2);
      });

      test('currentFileIndex returns 1 when selectedFile is null', () {
        final state = NavigationState(allFiles: [tFile1, tFile2]);
        expect(state.currentFileIndex, 1);
      });

      test('currentFileIndex returns 1 when allFiles is empty', () {
        final state = NavigationState(selectedFile: tFile1);
        expect(state.currentFileIndex, 1);
      });

      test(
        'currentFileIndex returns 1 when selectedFile is not in allFiles',
        () {
          final state = NavigationState(
            allFiles: [tFile2],
            selectedFile: tFile1,
          );
          expect(state.currentFileIndex, 1);
        },
      );
    });

    group('Equatable', () {
      test('two default states are equal', () {
        expect(const NavigationState(), equals(const NavigationState()));
      });

      test('states with different status are not equal', () {
        const s1 = NavigationState(status: NavigationStatus.loading);
        const s2 = NavigationState(status: NavigationStatus.loaded);
        expect(s1, isNot(equals(s2)));
      });

      test('states with same selectedFile are equal', () {
        final s1 = NavigationState(selectedFile: tFile1);
        final s2 = NavigationState(selectedFile: tFile1);
        expect(s1.props, equals(s2.props));
      });

      test('breadcrumb list is part of props', () {
        const bc = BreadcrumbEntry(label: 'Root', path: '', isFile: false);
        final s1 = NavigationState(breadcrumb: [bc]);
        final s2 = NavigationState(breadcrumb: [bc]);
        expect(s1, equals(s2));
      });
    });
  });
}
