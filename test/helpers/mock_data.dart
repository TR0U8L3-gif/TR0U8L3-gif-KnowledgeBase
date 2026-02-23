import 'package:knowledge_base/src/knowledge_base/domain/entities/document_content.dart';
import 'package:knowledge_base/src/knowledge_base/domain/entities/knowledge_base_item.dart';
import 'package:knowledge_base/src/knowledge_base/domain/repositories/knowledge_base_repository.dart';

// ── Files ────────────────────────────────────────────────────────────────────

const tFile1 = FileItem(
  name: 'Auth',
  path: 'api/auth.md',
  description: 'Authentication docs',
  tags: ['auth', 'api'],
  extension: 'md',
  lastModified: null,
  created: null,
);

const tFile2 = FileItem(
  name: 'Payments',
  path: 'api/payments.md',
  description: 'Payments docs',
  tags: ['payments', 'api'],
  extension: 'md',
  lastModified: null,
  created: null,
);

const tFileGuide = FileItem(
  name: 'Local Dev',
  path: 'guides/local-dev.md',
  description: 'Local development guide',
  tags: ['dev'],
  extension: 'md',
);

// ── Directories ───────────────────────────────────────────────────────────────

const tApiDir = DirectoryItem(
  name: 'API',
  path: 'api',
  description: 'API documentation',
  items: [tFile1, tFile2],
);

const tGuidesDir = DirectoryItem(
  name: 'Guides',
  path: 'guides',
  items: [tFileGuide],
);

const tRootDir = DirectoryItem(
  name: 'Root',
  path: '',
  items: [tApiDir, tGuidesDir],
);

// ── Document content ─────────────────────────────────────────────────────────

const tDocContent = DocumentContent(
  rawMarkdown: '# Hello\n\nSome content.',
  headings: [DocumentHeading(title: 'Hello', level: 1)],
  title: 'Hello',
);

const tEmptyDocContent = DocumentContent.empty;

// ── Breadcrumbs ───────────────────────────────────────────────────────────────

const tBreadcrumbRoot = BreadcrumbEntry(label: 'Root', path: '', isFile: false);

const tBreadcrumbApi = BreadcrumbEntry(
  label: 'API',
  path: 'api',
  isFile: false,
);

const tBreadcrumbAuth = BreadcrumbEntry(
  label: 'Auth',
  path: 'api/auth.md',
  isFile: true,
);

final tBreadcrumb = [tBreadcrumbRoot, tBreadcrumbApi, tBreadcrumbAuth];

// ── JSON fixtures ─────────────────────────────────────────────────────────────

const tFileJson = {
  'type': 'file',
  'name': 'Auth',
  'path': 'api/auth.md',
  'description': 'Authentication docs',
  'tags': ['auth', 'api'],
  'extension': 'md',
  'last_modified': '2024-01-15T10:00:00.000Z',
  'created': '2024-01-10T08:00:00.000Z',
};

const tDirectoryJson = {
  'type': 'directory',
  'name': 'API',
  'path': 'api',
  'description': 'API documentation',
  'items': [tFileJson],
  'order': ['auth.md'],
};

const tIndexJson = {
  'directory': {
    'type': 'directory',
    'name': 'Root',
    'path': '',
    'items': [tDirectoryJson],
  },
};
