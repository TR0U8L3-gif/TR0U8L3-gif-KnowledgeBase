import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:knowledge_base/src/knowledge_base/domain/entities/knowledge_base_item.dart';
import 'package:knowledge_base/src/knowledge_base/domain/repositories/knowledge_base_repository.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/bloc/navigation/navigation_bloc.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/bloc/navigation/navigation_event.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/bloc/navigation/navigation_state.dart';

import '../../../../../helpers/mocks.dart';

// ── Fixture data ──────────────────────────────────────────────────────────────

const _tFile1 = FileItem(
  name: 'Auth',
  path: 'api/auth.md',
  tags: [],
  extension: 'md',
);
const _tFile2 = FileItem(
  name: 'Payments',
  path: 'api/payments.md',
  tags: [],
  extension: 'md',
);
const _tApiDir = DirectoryItem(
  name: 'API',
  path: 'api',
  items: [_tFile1, _tFile2],
);
const _tRootDir = DirectoryItem(name: 'Root', path: '', items: [_tApiDir]);

const _tBcRoot = BreadcrumbEntry(label: 'Root', path: '', isFile: false);
const _tBcApi = BreadcrumbEntry(label: 'API', path: 'api', isFile: false);
const _tBcAuth = BreadcrumbEntry(
  label: 'Auth',
  path: 'api/auth.md',
  isFile: true,
);
const _tBcPayments = BreadcrumbEntry(
  label: 'Payments',
  path: 'api/payments.md',
  isFile: true,
);

final _tBreadcrumbForAuth = [_tBcRoot, _tBcApi, _tBcAuth];
final _tBreadcrumbForPayments = [_tBcRoot, _tBcApi, _tBcPayments];
final _tBreadcrumbForApi = [_tBcRoot, _tBcApi];

// ── Loaded seed state ─────────────────────────────────────────────────────────

NavigationState _loadedSeed({
  FileItem? selectedFile = _tFile1,
  List<BreadcrumbEntry>? breadcrumb,
}) => NavigationState(
  status: NavigationStatus.loaded,
  rootDirectory: _tRootDir,
  allFiles: const [_tFile1, _tFile2],
  selectedFile: selectedFile,
  breadcrumb: breadcrumb ?? _tBreadcrumbForAuth,
  currentPage: 1,
);

void main() {
  late MockKnowledgeBaseRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(const DirectoryItem(name: '', path: '', items: []));
    registerFallbackValue('');
  });

  setUp(() {
    mockRepo = MockKnowledgeBaseRepository();
  });

  NavigationBloc buildBloc() => NavigationBloc(repository: mockRepo);

  group('NavigationBloc', () {
    group('initial state', () {
      test('is NavigationState()', () {
        expect(buildBloc().state, const NavigationState());
      });
    });

    // ── LoadIndex ────────────────────────────────────────────────────────────

    group('LoadIndex', () {
      blocTest<NavigationBloc, NavigationState>(
        'emits loading → loaded when index is fetched successfully',
        setUp: () {
          when(() => mockRepo.loadIndex()).thenAnswer((_) async => _tRootDir);
          when(
            () => mockRepo.getAllFiles(_tRootDir),
          ).thenReturn([_tFile1, _tFile2]);
          when(
            () => mockRepo.computeBreadcrumb(_tRootDir, _tFile1.path),
          ).thenReturn(_tBreadcrumbForAuth);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const LoadIndex()),
        expect: () => [
          const NavigationState(status: NavigationStatus.loading),
          NavigationState(
            status: NavigationStatus.loaded,
            rootDirectory: _tRootDir,
            allFiles: const [_tFile1, _tFile2],
            selectedFile: _tFile1,
            breadcrumb: _tBreadcrumbForAuth,
            currentPage: 1,
          ),
        ],
      );

      blocTest<NavigationBloc, NavigationState>(
        'emits loading → error when repository throws',
        setUp: () {
          when(
            () => mockRepo.loadIndex(),
          ).thenThrow(Exception('Network error'));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const LoadIndex()),
        expect: () => [
          const NavigationState(status: NavigationStatus.loading),
          const NavigationState(
            status: NavigationStatus.error,
            errorMessage: 'Exception: Network error',
          ),
        ],
      );

      blocTest<NavigationBloc, NavigationState>(
        'sets empty breadcrumb and no selected file when no files exist',
        setUp: () {
          const emptyRoot = DirectoryItem(name: 'Root', path: '', items: []);
          when(() => mockRepo.loadIndex()).thenAnswer((_) async => emptyRoot);
          when(() => mockRepo.getAllFiles(emptyRoot)).thenReturn([]);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const LoadIndex()),
        expect: () => [
          const NavigationState(status: NavigationStatus.loading),
          const NavigationState(
            status: NavigationStatus.loaded,
            rootDirectory: DirectoryItem(name: 'Root', path: '', items: []),
            allFiles: [],
            selectedFile: null,
            breadcrumb: [],
            currentPage: 1,
          ),
        ],
      );
    });

    // ── SelectFile ───────────────────────────────────────────────────────────

    group('SelectFile', () {
      blocTest<NavigationBloc, NavigationState>(
        'emits state with selected file and updated breadcrumb',
        setUp: () {
          when(
            () => mockRepo.computeBreadcrumb(_tRootDir, _tFile2.path),
          ).thenReturn(_tBreadcrumbForPayments);
        },
        build: buildBloc,
        seed: _loadedSeed,
        act: (bloc) => bloc.add(const SelectFile('api/payments.md')),
        expect: () => [
          NavigationState(
            status: NavigationStatus.loaded,
            rootDirectory: _tRootDir,
            allFiles: const [_tFile1, _tFile2],
            selectedFile: _tFile2,
            selectedDirectory: null,
            viewMode: ViewMode.file,
            breadcrumb: _tBreadcrumbForPayments,
            currentPage: 2,
          ),
        ],
      );

      blocTest<NavigationBloc, NavigationState>(
        'does nothing when rootDirectory is null',
        build: buildBloc,
        // initial state has no rootDirectory
        act: (bloc) => bloc.add(const SelectFile('api/auth.md')),
        expect: () => <NavigationState>[],
      );

      blocTest<NavigationBloc, NavigationState>(
        'does nothing when file path is not found in tree',
        setUp: () {
          when(() => mockRepo.computeBreadcrumb(any(), any())).thenReturn([]);
        },
        build: buildBloc,
        seed: _loadedSeed,
        act: (bloc) => bloc.add(const SelectFile('nonexistent/path.md')),
        expect: () => <NavigationState>[],
      );

      blocTest<NavigationBloc, NavigationState>(
        'clears selectedDirectory when a file is selected',
        setUp: () {
          when(
            () => mockRepo.computeBreadcrumb(_tRootDir, _tFile1.path),
          ).thenReturn(_tBreadcrumbForAuth);
        },
        build: buildBloc,
        seed: () => _loadedSeed().copyWith(selectedDirectory: _tApiDir),
        act: (bloc) => bloc.add(const SelectFile('api/auth.md')),
        expect: () => [
          isA<NavigationState>().having(
            (s) => s.selectedDirectory,
            'selectedDirectory',
            isNull,
          ),
        ],
      );
    });

    // ── SelectDirectory ──────────────────────────────────────────────────────

    group('SelectDirectory', () {
      blocTest<NavigationBloc, NavigationState>(
        'emits state with selected directory and directory view mode',
        setUp: () {
          when(
            () => mockRepo.computeBreadcrumb(_tRootDir, _tApiDir.path),
          ).thenReturn(_tBreadcrumbForApi);
        },
        build: buildBloc,
        seed: _loadedSeed,
        act: (bloc) => bloc.add(const SelectDirectory('api')),
        expect: () => [
          NavigationState(
            status: NavigationStatus.loaded,
            rootDirectory: _tRootDir,
            allFiles: const [_tFile1, _tFile2],
            selectedFile: null,
            selectedDirectory: _tApiDir,
            viewMode: ViewMode.directory,
            breadcrumb: _tBreadcrumbForApi,
            currentPage: 1,
          ),
        ],
      );

      blocTest<NavigationBloc, NavigationState>(
        'does nothing when rootDirectory is null',
        build: buildBloc,
        act: (bloc) => bloc.add(const SelectDirectory('api')),
        expect: () => <NavigationState>[],
      );

      blocTest<NavigationBloc, NavigationState>(
        'does nothing when directory path is not found',
        build: buildBloc,
        seed: _loadedSeed,
        act: (bloc) => bloc.add(const SelectDirectory('nonexistent')),
        expect: () => <NavigationState>[],
      );
    });

    // ── NavigateToBreadcrumb ─────────────────────────────────────────────────

    group('NavigateToBreadcrumb', () {
      blocTest<NavigationBloc, NavigationState>(
        'navigates to a file when breadcrumb entry isFile=true',
        setUp: () {
          when(
            () => mockRepo.computeBreadcrumb(_tRootDir, _tFile1.path),
          ).thenReturn(_tBreadcrumbForAuth);
        },
        build: buildBloc,
        // seed with _tFile2 selected so that switching to _tFile1 actually changes state
        seed: () => _loadedSeed(
          selectedFile: _tFile2,
          breadcrumb: [_tBcRoot, _tBcApi, _tBcAuth],
        ),
        act: (bloc) => bloc.add(const NavigateToBreadcrumb(2)),
        expect: () => [
          isA<NavigationState>()
              .having((s) => s.selectedFile, 'selectedFile', _tFile1)
              .having((s) => s.viewMode, 'viewMode', ViewMode.file),
        ],
      );

      blocTest<NavigationBloc, NavigationState>(
        'navigates to a directory when breadcrumb entry isFile=false',
        setUp: () {
          when(
            () => mockRepo.computeBreadcrumb(_tRootDir, _tApiDir.path),
          ).thenReturn(_tBreadcrumbForApi);
        },
        build: buildBloc,
        seed: () => _loadedSeed(breadcrumb: [_tBcRoot, _tBcApi]),
        act: (bloc) => bloc.add(const NavigateToBreadcrumb(1)),
        expect: () => [
          isA<NavigationState>()
              .having((s) => s.selectedDirectory, 'selectedDirectory', _tApiDir)
              .having((s) => s.viewMode, 'viewMode', ViewMode.directory),
        ],
      );

      blocTest<NavigationBloc, NavigationState>(
        'does nothing when index is out of bounds',
        build: buildBloc,
        seed: () => _loadedSeed(breadcrumb: [_tBcRoot, _tBcAuth]),
        act: (bloc) => bloc.add(const NavigateToBreadcrumb(5)),
        expect: () => <NavigationState>[],
      );

      blocTest<NavigationBloc, NavigationState>(
        'does nothing when index is negative',
        build: buildBloc,
        seed: () => _loadedSeed(breadcrumb: [_tBcRoot, _tBcAuth]),
        act: (bloc) => bloc.add(const NavigateToBreadcrumb(-1)),
        expect: () => <NavigationState>[],
      );
    });

    // ── ToggleSidePanel ──────────────────────────────────────────────────────

    group('ToggleSidePanel', () {
      blocTest<NavigationBloc, NavigationState>(
        'flips showSidePanel from true to false',
        build: buildBloc,
        act: (bloc) => bloc.add(const ToggleSidePanel()),
        expect: () => [const NavigationState(showSidePanel: false)],
      );

      blocTest<NavigationBloc, NavigationState>(
        'flips showSidePanel from false to true',
        build: buildBloc,
        seed: () => const NavigationState(showSidePanel: false),
        act: (bloc) => bloc.add(const ToggleSidePanel()),
        expect: () => [const NavigationState(showSidePanel: true)],
      );

      blocTest<NavigationBloc, NavigationState>(
        'toggling twice restores original value',
        build: buildBloc,
        act: (bloc) {
          bloc.add(const ToggleSidePanel());
          bloc.add(const ToggleSidePanel());
        },
        expect: () => [
          const NavigationState(showSidePanel: false),
          const NavigationState(showSidePanel: true),
        ],
      );
    });

    // ── ToggleTocPanel ───────────────────────────────────────────────────────

    group('ToggleTocPanel', () {
      blocTest<NavigationBloc, NavigationState>(
        'flips showTocPanel from true to false',
        build: buildBloc,
        act: (bloc) => bloc.add(const ToggleTocPanel()),
        expect: () => [const NavigationState(showTocPanel: false)],
      );

      blocTest<NavigationBloc, NavigationState>(
        'flips showTocPanel from false to true',
        build: buildBloc,
        seed: () => const NavigationState(showTocPanel: false),
        act: (bloc) => bloc.add(const ToggleTocPanel()),
        expect: () => [const NavigationState(showTocPanel: true)],
      );
    });

    // ── ChangePage ───────────────────────────────────────────────────────────

    group('ChangePage', () {
      blocTest<NavigationBloc, NavigationState>(
        'selects the correct file for the given page',
        setUp: () {
          when(
            () => mockRepo.computeBreadcrumb(_tRootDir, _tFile2.path),
          ).thenReturn(_tBreadcrumbForPayments);
        },
        build: buildBloc,
        seed: _loadedSeed,
        act: (bloc) => bloc.add(const ChangePage(2)),
        expect: () => [
          isA<NavigationState>()
              .having((s) => s.selectedFile, 'selectedFile', _tFile2)
              .having((s) => s.currentPage, 'currentPage', 2),
        ],
      );

      blocTest<NavigationBloc, NavigationState>(
        'clamps page below 1 to 1 then selects first file',
        setUp: () {
          when(
            () => mockRepo.computeBreadcrumb(_tRootDir, _tFile1.path),
          ).thenReturn(_tBreadcrumbForAuth);
        },
        build: buildBloc,
        // seed with _tFile2 / page 2 so clamping to 1 actually changes selected file
        seed: () => _loadedSeed(selectedFile: _tFile2).copyWith(currentPage: 2),
        act: (bloc) => bloc.add(const ChangePage(0)),
        expect: () => [
          isA<NavigationState>()
              .having((s) => s.selectedFile, 'selectedFile', _tFile1)
              .having((s) => s.currentPage, 'currentPage', 1),
        ],
      );

      blocTest<NavigationBloc, NavigationState>(
        'clamps page above totalFiles to totalFiles',
        setUp: () {
          when(
            () => mockRepo.computeBreadcrumb(_tRootDir, _tFile2.path),
          ).thenReturn(_tBreadcrumbForPayments);
        },
        build: buildBloc,
        seed: _loadedSeed,
        act: (bloc) => bloc.add(const ChangePage(99)),
        expect: () => [
          isA<NavigationState>()
              .having((s) => s.selectedFile, 'selectedFile', _tFile2)
              .having((s) => s.currentPage, 'currentPage', 2),
        ],
      );

      blocTest<NavigationBloc, NavigationState>(
        'does nothing when allFiles is empty',
        build: buildBloc,
        // initial state: allFiles is empty, totalFiles is 0, clamp(1,0) = 0
        act: (bloc) => bloc.add(const ChangePage(1)),
        expect: () => <NavigationState>[],
      );
    });
  });
}
