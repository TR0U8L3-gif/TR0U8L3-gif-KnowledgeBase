import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_base/src/knowledge_base/domain/entities/knowledge_base_item.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/widgets/directories_tree_widget.dart';

void main() {
  group('DirTreeItem', () {
    group('fromKnowledgeBaseItems', () {
      test('converts empty list to empty tree', () {
        final result = DirTreeItem.fromKnowledgeBaseItems([]);
        expect(result, isEmpty);
      });

      test('converts a single FileItem to a leaf DirTreeItem', () {
        const file = FileItem(
          name: 'Auth',
          path: 'api/auth.md',
          tags: [],
          extension: 'md',
        );
        final result = DirTreeItem.fromKnowledgeBaseItems([file]);
        expect(result.length, 1);
        expect(result.first.title, 'Auth');
        expect(result.first.path, 'api/auth.md');
        expect(result.first.isFile, isTrue);
        expect(result.first.children, isNull);
      });

      test('converts a DirectoryItem to a DirTreeItem with children', () {
        const file = FileItem(
          name: 'Auth',
          path: 'api/auth.md',
          tags: [],
          extension: 'md',
        );
        const dir = DirectoryItem(name: 'API', path: 'api', items: [file]);
        final result = DirTreeItem.fromKnowledgeBaseItems([dir]);
        expect(result.length, 1);
        final dirItem = result.first;
        expect(dirItem.title, 'API');
        expect(dirItem.path, 'api');
        expect(dirItem.isFile, isFalse);
        expect(dirItem.children?.length, 1);
        expect(dirItem.children?.first.title, 'Auth');
        expect(dirItem.children?.first.isFile, isTrue);
      });

      test('converts nested directories recursively', () {
        const file = FileItem(
          name: 'Doc',
          path: 'a/b/doc.md',
          tags: [],
          extension: 'md',
        );
        const inner = DirectoryItem(name: 'B', path: 'a/b', items: [file]);
        const outer = DirectoryItem(name: 'A', path: 'a', items: [inner]);
        final result = DirTreeItem.fromKnowledgeBaseItems([outer]);
        expect(result.length, 1);
        final outerItem = result.first;
        expect(outerItem.title, 'A');
        expect(outerItem.children?.length, 1);
        final innerItem = outerItem.children?.first;
        expect(innerItem?.title, 'B');
        expect(innerItem?.children?.length, 1);
        expect(innerItem?.children?.first.title, 'Doc');
      });

      test('converts mixed files and directories', () {
        const file = FileItem(
          name: 'Guide',
          path: 'guide.md',
          tags: [],
          extension: 'md',
        );
        const dir = DirectoryItem(name: 'API', path: 'api', items: []);
        final result = DirTreeItem.fromKnowledgeBaseItems([file, dir]);
        expect(result.length, 2);
        expect(result[0].isFile, isTrue);
        expect(result[1].isFile, isFalse);
      });

      test('respects sortedItems ordering for directories with order', () {
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
        const dir = DirectoryItem(
          name: 'Dir',
          path: 'dir',
          items: [fileB, fileA],
          order: ['a.md', 'b.md'],
        );
        final result = DirTreeItem.fromKnowledgeBaseItems([dir]);
        final children = result.first.children!;
        expect(children[0].title, 'A');
        expect(children[1].title, 'B');
      });
    });

    group('equality', () {
      test('two leaf items with same values are equal', () {
        const a = DirTreeItem(title: 'Auth', path: 'api/auth.md', isFile: true);
        const b = DirTreeItem(title: 'Auth', path: 'api/auth.md', isFile: true);
        expect(a, equals(b));
      });

      test('items with different paths are not equal', () {
        const a = DirTreeItem(title: 'Auth', path: 'a.md', isFile: true);
        const b = DirTreeItem(title: 'Auth', path: 'b.md', isFile: true);
        expect(a, isNot(equals(b)));
      });

      test('file and directory with same path are not equal', () {
        const a = DirTreeItem(title: 'Dir', path: 'dir', isFile: false);
        const b = DirTreeItem(title: 'Dir', path: 'dir', isFile: true);
        expect(a, isNot(equals(b)));
      });
    });
  });

  group('TOCHeading.fromLevel', () {
    // Imported indirectly from table_of_content_widget, but DirTreeItem tests
    // suffice for widget model coverage here.
  });
}
