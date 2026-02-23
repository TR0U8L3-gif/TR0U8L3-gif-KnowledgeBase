import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/bloc/document/document_event.dart';

void main() {
  group('DocumentEvent', () {
    group('LoadDocument', () {
      test('stores path', () {
        const event = LoadDocument('api/auth.md');
        expect(event.path, 'api/auth.md');
        expect(event, isA<DocumentEvent>());
      });

      test('two events with same path are both LoadDocument', () {
        const e1 = LoadDocument('api/auth.md');
        const e2 = LoadDocument('api/auth.md');
        expect(e1.path, e2.path);
      });
    });

    group('ClearDocument', () {
      test('can be instantiated as const', () {
        const event = ClearDocument();
        expect(event, isA<ClearDocument>());
        expect(event, isA<DocumentEvent>());
      });
    });
  });
}
