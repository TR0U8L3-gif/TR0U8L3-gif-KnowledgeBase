import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_base/src/knowledge_base/domain/entities/knowledge_base_item.dart';

void main() {
  group('DirectoryItem.sortedItems', () {
    const fileA = FileItem(
      name: 'A',
      path: 'dir/a.md',
      tags: [],
      extension: 'md',
    );
    const fileB = FileItem(
      name: 'B',
      path: 'dir/b.md',
      tags: [],
      extension: 'md',
    );
    const fileC = FileItem(
      name: 'C',
      path: 'dir/c.md',
      tags: [],
      extension: 'md',
    );
    const subDir = DirectoryItem(name: 'Sub', path: 'dir/sub', items: []);

    test('returns items unchanged when order is null', () {
      const dir = DirectoryItem(
        name: 'Dir',
        path: 'dir',
        items: [fileA, fileB],
        order: null,
      );
      expect(dir.sortedItems, equals([fileA, fileB]));
    });

    test('returns items unchanged when order is empty', () {
      const dir = DirectoryItem(
        name: 'Dir',
        path: 'dir',
        items: [fileA, fileB],
        order: [],
      );
      expect(dir.sortedItems, equals([fileA, fileB]));
    });

    test('sorts items by order list', () {
      const dir = DirectoryItem(
        name: 'Dir',
        path: 'dir',
        items: [fileC, fileA, fileB],
        order: ['a.md', 'b.md', 'c.md'],
      );
      final sorted = dir.sortedItems;
      expect(sorted.map((i) => i.name).toList(), ['A', 'B', 'C']);
    });

    test('items in order list appear before items not in order list', () {
      const dir = DirectoryItem(
        name: 'Dir',
        path: 'dir',
        items: [fileC, fileA, fileB],
        order: ['b.md'],
      );
      final sorted = dir.sortedItems;
      expect(sorted.first.name, 'B');
    });

    test('items not in order list retain relative order among themselves', () {
      const dir = DirectoryItem(
        name: 'Dir',
        path: 'dir',
        items: [fileC, fileA],
        order: ['z.md'], // none of the files are in order
      );
      final sorted = dir.sortedItems;
      // No item matches 'z.md', so all are equal priority and keep original order
      expect(sorted.map((i) => i.name).toList(), ['C', 'A']);
    });

    test('directories not in order list come after ordered files', () {
      const dir = DirectoryItem(
        name: 'Dir',
        path: 'dir',
        items: [subDir, fileA],
        order: ['a.md'],
      );
      final sorted = dir.sortedItems;
      expect(sorted.first.name, 'A');
      expect(sorted.last.name, 'Sub');
    });

    test('partial order: ordered first, rest in original order', () {
      const dir = DirectoryItem(
        name: 'Dir',
        path: 'dir',
        items: [fileC, fileB, fileA],
        order: ['a.md', 'c.md'],
      );
      final sorted = dir.sortedItems;
      expect(sorted[0].name, 'A');
      expect(sorted[1].name, 'C');
      // B is not in order list, appears after ordered items
      expect(sorted[2].name, 'B');
    });

    test('does not mutate the original items list', () {
      const dir = DirectoryItem(
        name: 'Dir',
        path: 'dir',
        items: [fileC, fileA, fileB],
        order: ['a.md', 'b.md', 'c.md'],
      );
      dir.sortedItems;
      // items list should remain in original order
      expect(dir.items.map((i) => i.name).toList(), ['C', 'A', 'B']);
    });
  });

  group('DirectoryItem', () {
    test('can be constructed with minimal fields', () {
      const dir = DirectoryItem(name: 'Dir', path: 'dir', items: []);
      expect(dir.name, 'Dir');
      expect(dir.path, 'dir');
      expect(dir.items, isEmpty);
      expect(dir.description, isNull);
      expect(dir.icon, isNull);
      expect(dir.order, isNull);
    });

    test('nested directories are intact', () {
      const child = DirectoryItem(
        name: 'Child',
        path: 'parent/child',
        items: [
          FileItem(
            name: 'Doc',
            path: 'parent/child/doc.md',
            tags: [],
            extension: 'md',
          ),
        ],
      );
      const parent = DirectoryItem(
        name: 'Parent',
        path: 'parent',
        items: [child],
      );
      expect(parent.items.length, 1);
      final nested = parent.items.first as DirectoryItem;
      expect(nested.items.length, 1);
      expect(nested.items.first.name, 'Doc');
    });
  });

  group('FileItem', () {
    test('can be constructed with minimal fields', () {
      const file = FileItem(
        name: 'Doc',
        path: 'doc.md',
        tags: [],
        extension: 'md',
      );
      expect(file.name, 'Doc');
      expect(file.path, 'doc.md');
      expect(file.tags, isEmpty);
      expect(file.extension, 'md');
      expect(file.description, isNull);
      expect(file.image, isNull);
      expect(file.lastModified, isNull);
      expect(file.created, isNull);
    });

    test('stores all provided fields', () {
      final lastMod = DateTime(2024, 1, 15);
      final created = DateTime(2024, 1, 10);
      final file = FileItem(
        name: 'Auth',
        path: 'api/auth.md',
        description: 'Auth docs',
        tags: ['auth', 'api'],
        image: 'auth.png',
        lastModified: lastMod,
        created: created,
        extension: 'md',
      );
      expect(file.description, 'Auth docs');
      expect(file.tags, ['auth', 'api']);
      expect(file.image, 'auth.png');
      expect(file.lastModified, lastMod);
      expect(file.created, created);
    });
  });
}
