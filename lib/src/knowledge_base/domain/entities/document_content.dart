/// Represents a parsed document with its raw content and extracted headings.
class DocumentContent {
  final String rawMarkdown;
  final List<DocumentHeading> headings;
  final String? title;
  final String? description;
  final DateTime? lastModified;

  const DocumentContent({
    required this.rawMarkdown,
    required this.headings,
    this.title,
    this.description,
    this.lastModified,
  });

  static const empty = DocumentContent(rawMarkdown: '', headings: []);
}

/// A heading extracted from markdown for the Table of Contents.
class DocumentHeading {
  final String title;
  final int level;

  const DocumentHeading({required this.title, required this.level});
}
