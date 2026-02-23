import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_base/src/knowledge_base/domain/entities/document_content.dart';

void main() {
  group('DocumentContent', () {
    test('can be constructed with required fields', () {
      const content = DocumentContent(rawMarkdown: '# Hello', headings: []);
      expect(content.rawMarkdown, '# Hello');
      expect(content.headings, isEmpty);
      expect(content.title, isNull);
      expect(content.description, isNull);
      expect(content.lastModified, isNull);
    });

    test('can be constructed with all optional fields', () {
      final lastMod = DateTime(2024, 1, 15);
      final content = DocumentContent(
        rawMarkdown: '# Hello\n\nContent.',
        headings: [const DocumentHeading(title: 'Hello', level: 1)],
        title: 'Hello',
        description: 'A test document.',
        lastModified: lastMod,
      );
      expect(content.rawMarkdown, '# Hello\n\nContent.');
      expect(content.headings.length, 1);
      expect(content.title, 'Hello');
      expect(content.description, 'A test document.');
      expect(content.lastModified, lastMod);
    });

    test('empty constant has empty rawMarkdown and no headings', () {
      expect(DocumentContent.empty.rawMarkdown, '');
      expect(DocumentContent.empty.headings, isEmpty);
      expect(DocumentContent.empty.title, isNull);
      expect(DocumentContent.empty.description, isNull);
      expect(DocumentContent.empty.lastModified, isNull);
    });

    test('empty is the same const reference every time', () {
      expect(identical(DocumentContent.empty, DocumentContent.empty), isTrue);
    });
  });

  group('DocumentHeading', () {
    test('stores title and level', () {
      const h = DocumentHeading(title: 'Overview', level: 2);
      expect(h.title, 'Overview');
      expect(h.level, 2);
    });

    test('supports levels 1 through 6', () {
      for (int level = 1; level <= 6; level++) {
        final h = DocumentHeading(title: 'H$level', level: level);
        expect(h.level, level);
      }
    });
  });
}
