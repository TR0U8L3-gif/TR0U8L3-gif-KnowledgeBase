import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_base/src/knowledge_base/data/models/knowledge_base_item_model.dart';
import 'package:knowledge_base/src/knowledge_base/domain/entities/knowledge_base_item.dart';

void main() {
  group('KnowledgeBaseItemModel.fromJson', () {
    group('file items', () {
      test('parses all fields from valid file JSON', () {
        final json = {
          'type': 'file',
          'name': 'Auth Guide',
          'path': 'api/auth.md',
          'description': 'Authentication documentation',
          'tags': ['auth', 'security'],
          'image': 'auth-cover.png',
          'extension': 'md',
          'last_modified': '2024-01-15T10:00:00.000Z',
          'created': '2024-01-10T08:00:00.000Z',
        };
        final item = KnowledgeBaseItemModel.fromJson(json) as FileItem;
        expect(item.name, 'Auth Guide');
        expect(item.path, 'api/auth.md');
        expect(item.description, 'Authentication documentation');
        expect(item.tags, ['auth', 'security']);
        expect(item.image, 'auth-cover.png');
        expect(item.extension, 'md');
        expect(item.lastModified, DateTime.parse('2024-01-15T10:00:00.000Z'));
        expect(item.created, DateTime.parse('2024-01-10T08:00:00.000Z'));
      });

      test('returns empty list for missing tags', () {
        final json = {
          'type': 'file',
          'name': 'Doc',
          'path': 'doc.md',
          'extension': 'txt',
        };
        final item = KnowledgeBaseItemModel.fromJson(json) as FileItem;
        expect(item.tags, isEmpty);
      });

      test('returns null for optional fields when absent', () {
        final json = {'type': 'file', 'name': 'Doc', 'path': 'doc.md'};
        final item = KnowledgeBaseItemModel.fromJson(json) as FileItem;
        expect(item.description, isNull);
        expect(item.image, isNull);
        expect(item.lastModified, isNull);
        expect(item.created, isNull);
        expect(item.extension, '');
      });

      test('returns null dates when date strings are missing', () {
        final json = {
          'type': 'file',
          'name': 'Doc',
          'path': 'doc.md',
          'last_modified': null,
          'created': null,
          'tags': <String>[],
          'extension': 'md',
        };
        final item = KnowledgeBaseItemModel.fromJson(json) as FileItem;
        expect(item.lastModified, isNull);
        expect(item.created, isNull);
      });

      test('returns null for unparseable date string', () {
        final json = {
          'type': 'file',
          'name': 'Doc',
          'path': 'doc.md',
          'last_modified': 'not-a-date',
          'extension': 'md',
          'tags': <String>[],
        };
        final item = KnowledgeBaseItemModel.fromJson(json) as FileItem;
        expect(item.lastModified, isNull);
      });
    });

    group('directory items', () {
      test('parses all directory fields', () {
        final json = {
          'type': 'directory',
          'name': 'API',
          'path': 'api',
          'description': 'API documentation',
          'icon': '📚',
          'order': ['auth.md', 'payments.md'],
          'items': [
            {
              'type': 'file',
              'name': 'Auth',
              'path': 'api/auth.md',
              'tags': <String>[],
              'extension': 'md',
            },
          ],
        };
        final item = KnowledgeBaseItemModel.fromJson(json) as DirectoryItem;
        expect(item.name, 'API');
        expect(item.path, 'api');
        expect(item.description, 'API documentation');
        expect(item.icon, '📚');
        expect(item.order, ['auth.md', 'payments.md']);
        expect(item.items.length, 1);
      });

      test('handles missing items array', () {
        final json = {'type': 'directory', 'name': 'Empty', 'path': 'empty'};
        final item = KnowledgeBaseItemModel.fromJson(json) as DirectoryItem;
        expect(item.items, isEmpty);
      });

      test('handles missing order field', () {
        final json = {
          'type': 'directory',
          'name': 'Dir',
          'path': 'dir',
          'items': <Map<String, dynamic>>[],
        };
        final item = KnowledgeBaseItemModel.fromJson(json) as DirectoryItem;
        expect(item.order, isNull);
      });

      test('parses nested directory structure', () {
        final json = {
          'type': 'directory',
          'name': 'Docs',
          'path': 'docs',
          'items': [
            {
              'type': 'directory',
              'name': 'API',
              'path': 'docs/api',
              'items': [
                {
                  'type': 'file',
                  'name': 'Auth',
                  'path': 'docs/api/auth.md',
                  'tags': <String>[],
                  'extension': 'md',
                },
              ],
            },
          ],
        };
        final root = KnowledgeBaseItemModel.fromJson(json) as DirectoryItem;
        expect(root.items.length, 1);
        final nested = root.items.first as DirectoryItem;
        expect(nested.name, 'API');
        expect(nested.items.length, 1);
        expect(nested.items.first.name, 'Auth');
      });

      test('empty items array parsed correctly', () {
        final json = {
          'type': 'directory',
          'name': 'Dir',
          'path': 'dir',
          'items': <Map<String, dynamic>>[],
        };
        final item = KnowledgeBaseItemModel.fromJson(json) as DirectoryItem;
        expect(item.items, isEmpty);
      });
    });
  });
}
