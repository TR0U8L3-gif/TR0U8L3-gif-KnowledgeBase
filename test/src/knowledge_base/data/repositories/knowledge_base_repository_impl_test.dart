import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_base/src/knowledge_base/data/data_sources/knowledge_base_local_data_source.dart';
import 'package:knowledge_base/src/knowledge_base/data/repositories/knowledge_base_repository_impl.dart';
import 'package:knowledge_base/src/knowledge_base/domain/entities/knowledge_base_item.dart';

// ── Fake data source ────────────────────────────────────────────────────────

class _FakeDataSource extends KnowledgeBaseLocalDataSource {
  _FakeDataSource(this._markdown);

  final String _markdown;

  @override
  Future<String> loadMarkdownFile(String path) async => _markdown;
}

KnowledgeBaseRepositoryImpl _repoWith(String markdown) =>
    KnowledgeBaseRepositoryImpl(dataSource: _FakeDataSource(markdown));

/// Fake data source with both loadMarkdownFile and loadIndexJson overridden.
class _FakeIndexDataSource extends KnowledgeBaseLocalDataSource {
  _FakeIndexDataSource(this._json);

  final Map<String, dynamic> _json;

  @override
  Future<Map<String, dynamic>> loadIndexJson() async => _json;

  @override
  Future<String> loadMarkdownFile(String path) async => '';
}

// ── Helpers ─────────────────────────────────────────────────────────────────

/// Convenience: load a document and return extracted heading titles.
Future<List<String>> headingTitles(String markdown) async {
  final doc = await _repoWith(markdown).loadDocument('test.md');
  return doc.headings.map((h) => h.title).toList();
}

Future<List<int>> headingLevels(String markdown) async {
  final doc = await _repoWith(markdown).loadDocument('test.md');
  return doc.headings.map((h) => h.level).toList();
}

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('KnowledgeBaseRepositoryImpl._extractHeadings', () {
    // ── Basic heading recognition ──────────────────────────────────────────

    test('extracts a single top-level heading', () async {
      const md = '# Hello World';
      expect(await headingTitles(md), ['Hello World']);
    });

    test('extracts headings at all six levels', () async {
      const md = '''
# H1
## H2
### H3
#### H4
##### H5
###### H6
''';
      expect(await headingTitles(md), ['H1', 'H2', 'H3', 'H4', 'H5', 'H6']);
      expect(await headingLevels(md), [1, 2, 3, 4, 5, 6]);
    });

    test('preserves heading order', () async {
      const md = '''
## Setup
### Install
## Troubleshooting
''';
      expect(await headingTitles(md), ['Setup', 'Install', 'Troubleshooting']);
    });

    test('returns empty list when there are no headings', () async {
      const md = 'Just a paragraph.\n\nAnother paragraph.';
      expect(await headingTitles(md), isEmpty);
    });

    // ── Code-block exclusion (the regression) ─────────────────────────────

    test(
      'does NOT treat bash comment lines inside code blocks as headings',
      () async {
        const md = '''
## Setup
```bash
# bootstrap
make bootstrap

# start services
docker compose up -d
```
## Teardown
''';
        // Only the two real markdown headings should be extracted.
        expect(await headingTitles(md), ['Setup', 'Teardown']);
      },
    );

    test('excludes headings inside multiple consecutive code blocks', () async {
      const md = '''
# Real Heading
```bash
# not a heading
echo hello
```
Some text.
```python
# also not a heading
print('hi')
```
## Another Real Heading
''';
      expect(await headingTitles(md), ['Real Heading', 'Another Real Heading']);
    });

    test('correctly handles code block that ends at last line', () async {
      const md = '''
# Intro
```sh
# inside block
''';
      // The code block is never closed, so the line inside it should be skipped.
      expect(await headingTitles(md), ['Intro']);
    });

    test('resumes heading extraction after a code block closes', () async {
      const md = '''
## Before
```
# ignored
```
## After
''';
      expect(await headingTitles(md), ['Before', 'After']);
    });

    // ── local-dev.md regression scenario ──────────────────────────────────

    test(
      'local-dev.md: bash comments inside code blocks are not counted as headings',
      () async {
        const localDevMd = '''
# Local Development Guide

## Prereqs
- macOS 13+
- Docker Desktop

## Setup
```bash
# bootstrap
make bootstrap

# start services (postgres, redis, kafka)
docker compose up -d db cache kafka
```

## Environment
Create `.env.local` in repo root.

## Testing
- Unit: `make test`

## Troubleshooting
- Ports busy?

## References
- [Architecture overview](../architecture/overview.md)
''';

        final titles = await headingTitles(localDevMd);

        // The two bash comments ("# bootstrap", "# start services …") must NOT
        // appear in the extracted headings.
        expect(titles, [
          'Local Development Guide',
          'Prereqs',
          'Setup',
          'Environment',
          'Testing',
          'Troubleshooting',
          'References',
        ]);
      },
    );

    test(
      'local-dev.md: heading count matches the number of keyed widgets the renderer would create',
      () async {
        // The renderer skips code-block contents when building _HeadingBlock
        // widgets. This test asserts that _extractHeadings produces exactly the
        // same count so that GlobalKey indices are never out of range.
        const localDevMd = '''
# Local Development Guide

## Prereqs
Some prereqs.

## Setup
```bash
# bootstrap
make bootstrap

# start services (postgres, redis, kafka)
docker compose up -d
```

## Environment
Some env info.

## Testing
Some testing info.

## Troubleshooting
Some troubleshooting.

## References
Some references.
''';

        final doc = await _repoWith(localDevMd).loadDocument('test.md');

        // 7 real markdown headings, 0 bash comment lines
        expect(doc.headings.length, 7);
      },
    );

    // ── Frontmatter stripping ──────────────────────────────────────────────

    test('headings inside YAML frontmatter are not extracted', () async {
      const md = '''---
name: My Doc
description: A guide
---
# Real Heading
## Second Heading
''';
      expect(await headingTitles(md), ['Real Heading', 'Second Heading']);
    });

    // ── Edge cases ─────────────────────────────────────────────────────────

    test('heading with no space after # is ignored', () async {
      const md = '#NoSpace\n## Valid';
      expect(await headingTitles(md), ['Valid']);
    });

    test('inline code containing # does not create a heading', () async {
      const md = 'Use `# not a heading` in your config.\n## Real';
      expect(await headingTitles(md), ['Real']);
    });
  });

  // ── loadIndex ────────────────────────────────────────────────────────────

  group('KnowledgeBaseRepositoryImpl.loadIndex', () {
    test('parses a flat directory from JSON index', () async {
      final repo = KnowledgeBaseRepositoryImpl(
        dataSource: _FakeIndexDataSource({
          'directory': {
            'type': 'directory',
            'name': 'Root',
            'path': '',
            'items': [
              {
                'type': 'file',
                'name': 'Auth',
                'path': 'api/auth.md',
                'tags': <String>[],
                'extension': 'md',
              },
            ],
          },
        }),
      );
      final root = await repo.loadIndex();
      expect(root.name, 'Root');
      expect(root.items.length, 1);
      expect(root.items.first.name, 'Auth');
    });

    test('parses nested directory structure from JSON index', () async {
      final repo = KnowledgeBaseRepositoryImpl(
        dataSource: _FakeIndexDataSource({
          'directory': {
            'type': 'directory',
            'name': 'Root',
            'path': '',
            'items': [
              {
                'type': 'directory',
                'name': 'API',
                'path': 'api',
                'items': [
                  {
                    'type': 'file',
                    'name': 'Auth',
                    'path': 'api/auth.md',
                    'tags': <String>[],
                    'extension': 'md',
                  },
                ],
              },
            ],
          },
        }),
      );
      final root = await repo.loadIndex();
      expect(root.name, 'Root');
      expect(root.items.length, 1);
      final apiDir = root.items.first as DirectoryItem;
      expect(apiDir.name, 'API');
      expect(apiDir.items.length, 1);
    });

    test('returns empty directory when items list is absent', () async {
      final repo = KnowledgeBaseRepositoryImpl(
        dataSource: _FakeIndexDataSource({
          'directory': {'type': 'directory', 'name': 'Root', 'path': ''},
        }),
      );
      final root = await repo.loadIndex();
      expect(root.items, isEmpty);
    });
  });

  // ── getAllFiles ──────────────────────────────────────────────────────────

  group('KnowledgeBaseRepositoryImpl.getAllFiles', () {
    final repo = KnowledgeBaseRepositoryImpl(dataSource: _FakeDataSource(''));

    const file1 = FileItem(
      name: 'Auth',
      path: 'api/auth.md',
      tags: [],
      extension: 'md',
    );
    const file2 = FileItem(
      name: 'Payments',
      path: 'api/payments.md',
      tags: [],
      extension: 'md',
    );
    const file3 = FileItem(
      name: 'Local Dev',
      path: 'guides/local-dev.md',
      tags: [],
      extension: 'md',
    );

    test('returns all files from a flat directory', () {
      const root = DirectoryItem(name: 'Root', path: '', items: [file1, file2]);
      final files = repo.getAllFiles(root);
      expect(files.map((f) => f.name).toList(), ['Auth', 'Payments']);
    });

    test('returns files from nested directories (DFS order)', () {
      const apiDir = DirectoryItem(
        name: 'API',
        path: 'api',
        items: [file1, file2],
      );
      const guidesDir = DirectoryItem(
        name: 'Guides',
        path: 'guides',
        items: [file3],
      );
      const root = DirectoryItem(
        name: 'Root',
        path: '',
        items: [apiDir, guidesDir],
      );
      final files = repo.getAllFiles(root);
      expect(files.map((f) => f.name).toList(), [
        'Auth',
        'Payments',
        'Local Dev',
      ]);
    });

    test('returns empty list for empty root directory', () {
      const root = DirectoryItem(name: 'Root', path: '', items: []);
      expect(repo.getAllFiles(root), isEmpty);
    });

    test('respects sortedItems order for directories with order list', () {
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
      const root = DirectoryItem(name: 'Root', path: '', items: [dir]);
      final files = repo.getAllFiles(root);
      expect(files.map((f) => f.name).toList(), ['A', 'B']);
    });
  });

  // ── computeBreadcrumb ────────────────────────────────────────────────────

  group('KnowledgeBaseRepositoryImpl.computeBreadcrumb', () {
    final repo = KnowledgeBaseRepositoryImpl(dataSource: _FakeDataSource(''));

    const file1 = FileItem(
      name: 'Auth',
      path: 'api/auth.md',
      tags: [],
      extension: 'md',
    );
    const apiDir = DirectoryItem(name: 'API', path: 'api', items: [file1]);
    const root = DirectoryItem(name: 'Root', path: '', items: [apiDir]);

    test('returns breadcrumb to a file', () {
      final bc = repo.computeBreadcrumb(root, 'api/auth.md');
      expect(bc.length, 3);
      expect(bc[0].label, 'Root');
      expect(bc[0].isFile, isFalse);
      expect(bc[1].label, 'API');
      expect(bc[1].isFile, isFalse);
      expect(bc[2].label, 'Auth');
      expect(bc[2].isFile, isTrue);
    });

    test('returns breadcrumb to a directory', () {
      final bc = repo.computeBreadcrumb(root, 'api');
      expect(bc.length, 2);
      expect(bc[0].label, 'Root');
      expect(bc[1].label, 'API');
      expect(bc[1].isFile, isFalse);
    });

    test('returns empty list when path is not found', () {
      final bc = repo.computeBreadcrumb(root, 'nonexistent/path.md');
      expect(bc, isEmpty);
    });

    test('returns single entry when target is the root directory', () {
      final bc = repo.computeBreadcrumb(root, '');
      expect(bc.length, 1);
      expect(bc.first.label, 'Root');
      expect(bc.first.path, '');
      expect(bc.first.isFile, isFalse);
    });

    test('breadcrumb paths are correct', () {
      final bc = repo.computeBreadcrumb(root, 'api/auth.md');
      expect(bc.map((e) => e.path).toList(), ['', 'api', 'api/auth.md']);
    });
  });

  // ── _stripFrontmatter ────────────────────────────────────────────────────

  group('KnowledgeBaseRepositoryImpl._stripFrontmatter', () {
    Future<String> stripResult(String md) async {
      final doc = await _repoWith(md).loadDocument('test.md');
      return doc.rawMarkdown;
    }

    test('strips frontmatter block', () async {
      const md = '---\ntitle: Doc\n---\n# Heading\nContent.';
      final result = await stripResult(md);
      expect(result, startsWith('# Heading'));
    });

    test('returns markdown unchanged when no frontmatter', () async {
      const md = '# Heading\nContent.';
      final result = await stripResult(md);
      expect(result, md);
    });

    test('returns markdown unchanged when first line is not ---', () async {
      const md = 'Just content.\n---\nStill content.\n---';
      final result = await stripResult(md);
      expect(result, md);
    });

    test(
      'returns markdown unchanged when frontmatter is never closed',
      () async {
        const md = '---\ntitle: Doc\n# Not stripped';
        final result = await stripResult(md);
        expect(result, md);
      },
    );

    test('trims leading whitespace after frontmatter', () async {
      const md = '---\ntitle: Doc\n---\n\n\n# Heading';
      final result = await stripResult(md);
      expect(result.trimLeft(), startsWith('# Heading'));
    });
  });
}
