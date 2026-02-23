import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_base/src/knowledge_base/data/data_sources/knowledge_base_local_data_source.dart';
import 'package:knowledge_base/src/knowledge_base/data/repositories/knowledge_base_repository_impl.dart';

// ── Fake data source ────────────────────────────────────────────────────────

class _FakeDataSource extends KnowledgeBaseLocalDataSource {
  _FakeDataSource(this._markdown);

  final String _markdown;

  @override
  Future<String> loadMarkdownFile(String path) async => _markdown;
}

KnowledgeBaseRepositoryImpl _repoWith(String markdown) =>
    KnowledgeBaseRepositoryImpl(dataSource: _FakeDataSource(markdown));

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
}
