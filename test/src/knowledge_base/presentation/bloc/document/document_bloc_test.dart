import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:knowledge_base/src/knowledge_base/domain/entities/document_content.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/bloc/document/document_bloc.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/bloc/document/document_event.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/bloc/document/document_state.dart';

import '../../../../../helpers/mocks.dart';

const _tPath = 'api/auth.md';
const _tOtherPath = 'api/payments.md';
const _tContent = DocumentContent(
  rawMarkdown: '# Auth\n\nContent.',
  headings: [DocumentHeading(title: 'Auth', level: 1)],
);

void main() {
  late MockKnowledgeBaseRepository mockRepo;

  setUp(() {
    mockRepo = MockKnowledgeBaseRepository();
  });

  DocumentBloc buildBloc() => DocumentBloc(repository: mockRepo);

  group('DocumentBloc', () {
    group('initial state', () {
      test('is DocumentState()', () {
        expect(buildBloc().state, const DocumentState());
      });
    });

    // ── LoadDocument ──────────────────────────────────────────────────────────

    group('LoadDocument', () {
      blocTest<DocumentBloc, DocumentState>(
        'emits loading → loaded on success',
        setUp: () {
          when(
            () => mockRepo.loadDocument(_tPath),
          ).thenAnswer((_) async => _tContent);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const LoadDocument(_tPath)),
        expect: () => [
          const DocumentState(
            status: DocumentStatus.loading,
            currentPath: _tPath,
          ),
          const DocumentState(
            status: DocumentStatus.loaded,
            content: _tContent,
            currentPath: _tPath,
          ),
        ],
      );

      blocTest<DocumentBloc, DocumentState>(
        'emits loading → error on failure',
        setUp: () {
          when(
            () => mockRepo.loadDocument(_tPath),
          ).thenThrow(Exception('File not found'));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const LoadDocument(_tPath)),
        expect: () => [
          const DocumentState(
            status: DocumentStatus.loading,
            currentPath: _tPath,
          ),
          const DocumentState(
            status: DocumentStatus.error,
            currentPath: _tPath,
            errorMessage: 'Exception: File not found',
          ),
        ],
      );

      blocTest<DocumentBloc, DocumentState>(
        'does not reload when same path is already loaded',
        setUp: () {
          when(
            () => mockRepo.loadDocument(_tPath),
          ).thenAnswer((_) async => _tContent);
        },
        build: buildBloc,
        seed: () => const DocumentState(
          status: DocumentStatus.loaded,
          content: _tContent,
          currentPath: _tPath,
        ),
        act: (bloc) => bloc.add(const LoadDocument(_tPath)),
        expect: () => <DocumentState>[], // no emissions
        verify: (_) => verifyNever(() => mockRepo.loadDocument(_tPath)),
      );

      blocTest<DocumentBloc, DocumentState>(
        'reloads when path changes',
        setUp: () {
          when(
            () => mockRepo.loadDocument(_tOtherPath),
          ).thenAnswer((_) async => _tContent);
        },
        build: buildBloc,
        seed: () => const DocumentState(
          status: DocumentStatus.loaded,
          content: _tContent,
          currentPath: _tPath,
        ),
        act: (bloc) => bloc.add(const LoadDocument(_tOtherPath)),
        expect: () => [
          const DocumentState(
            status: DocumentStatus.loading,
            content: _tContent, // kept from copyWith
            currentPath: _tOtherPath,
          ),
          const DocumentState(
            status: DocumentStatus.loaded,
            content: _tContent,
            currentPath: _tOtherPath,
          ),
        ],
      );

      blocTest<DocumentBloc, DocumentState>(
        'reloads when status is not loaded (even for same path)',
        setUp: () {
          when(
            () => mockRepo.loadDocument(_tPath),
          ).thenAnswer((_) async => _tContent);
        },
        build: buildBloc,
        seed: () => const DocumentState(
          status: DocumentStatus.error,
          currentPath: _tPath,
          errorMessage: 'Previous error',
        ),
        act: (bloc) => bloc.add(const LoadDocument(_tPath)),
        expect: () => [
          isA<DocumentState>().having(
            (s) => s.status,
            'status',
            DocumentStatus.loading,
          ),
          isA<DocumentState>().having(
            (s) => s.status,
            'status',
            DocumentStatus.loaded,
          ),
        ],
      );
    });

    // ── ClearDocument ─────────────────────────────────────────────────────────

    group('ClearDocument', () {
      blocTest<DocumentBloc, DocumentState>(
        'resets to initial state',
        build: buildBloc,
        seed: () => const DocumentState(
          status: DocumentStatus.loaded,
          content: _tContent,
          currentPath: _tPath,
        ),
        act: (bloc) => bloc.add(const ClearDocument()),
        expect: () => [const DocumentState()],
      );

      blocTest<DocumentBloc, DocumentState>(
        'does nothing when already in initial state',
        build: buildBloc,
        act: (bloc) => bloc.add(const ClearDocument()),
        // ClearDocument always emits const DocumentState()
        // which equals the existing initial state
        // But since Bloc emits regardless, we expect one emission
        expect: () => [const DocumentState()],
      );
    });
  });
}
