import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_base/src/knowledge_base/domain/entities/document_content.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/bloc/document/document_state.dart';

void main() {
  const tContent = DocumentContent(
    rawMarkdown: '# Hello',
    headings: [DocumentHeading(title: 'Hello', level: 1)],
  );

  group('DocumentState', () {
    test('default constructor sets expected defaults', () {
      const state = DocumentState();
      expect(state.status, DocumentStatus.initial);
      expect(state.content, isNull);
      expect(state.currentPath, isNull);
      expect(state.errorMessage, isNull);
    });

    group('copyWith', () {
      test('copies status', () {
        const state = DocumentState();
        final copy = state.copyWith(status: DocumentStatus.loading);
        expect(copy.status, DocumentStatus.loading);
      });

      test('copies content', () {
        const state = DocumentState();
        final copy = state.copyWith(content: tContent);
        expect(copy.content, tContent);
      });

      test('copies currentPath', () {
        const state = DocumentState();
        final copy = state.copyWith(currentPath: 'api/auth.md');
        expect(copy.currentPath, 'api/auth.md');
      });

      test('copies errorMessage', () {
        const state = DocumentState();
        final copy = state.copyWith(errorMessage: 'error');
        expect(copy.errorMessage, 'error');
      });

      test('preserves unchanged fields', () {
        const state = DocumentState(
          status: DocumentStatus.loaded,
          currentPath: 'api/auth.md',
        );
        final copy = state.copyWith(errorMessage: 'err');
        expect(copy.status, DocumentStatus.loaded);
        expect(copy.currentPath, 'api/auth.md');
      });
    });

    group('Equatable', () {
      test('two default states are equal', () {
        expect(const DocumentState(), equals(const DocumentState()));
      });

      test('states with different status are not equal', () {
        const s1 = DocumentState(status: DocumentStatus.loading);
        const s2 = DocumentState(status: DocumentStatus.loaded);
        expect(s1, isNot(equals(s2)));
      });

      test('states with same path are equal', () {
        const s1 = DocumentState(currentPath: 'api/auth.md');
        const s2 = DocumentState(currentPath: 'api/auth.md');
        expect(s1, equals(s2));
      });

      test('states with different paths are not equal', () {
        const s1 = DocumentState(currentPath: 'api/auth.md');
        const s2 = DocumentState(currentPath: 'api/payments.md');
        expect(s1, isNot(equals(s2)));
      });

      test('states with same content instance are equal', () {
        final s1 = DocumentState(content: tContent);
        final s2 = DocumentState(content: tContent);
        expect(s1, equals(s2));
      });
    });
  });
}
