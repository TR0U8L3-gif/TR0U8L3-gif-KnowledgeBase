import 'package:shadcn_flutter/shadcn_flutter.dart';

// ── Markdown block types ────────────────────────────────────────────────────

sealed class _MarkdownBlock {
  const _MarkdownBlock();
}

class _HeadingBlock extends _MarkdownBlock {
  final int level;
  final String text;
  const _HeadingBlock({required this.level, required this.text});
}

class _ParagraphBlock extends _MarkdownBlock {
  final String text;
  const _ParagraphBlock(this.text);
}

class _CodeBlock extends _MarkdownBlock {
  final String language;
  final String code;
  const _CodeBlock({required this.language, required this.code});
}

class _TableBlock extends _MarkdownBlock {
  final List<List<String>> rows;
  const _TableBlock(this.rows);
}

class _UnorderedListBlock extends _MarkdownBlock {
  final List<String> items;
  const _UnorderedListBlock(this.items);
}

class _OrderedListBlock extends _MarkdownBlock {
  final List<String> items;
  const _OrderedListBlock(this.items);
}

class _BlockquoteBlock extends _MarkdownBlock {
  final String text;
  const _BlockquoteBlock(this.text);
}

class _HorizontalRuleBlock extends _MarkdownBlock {
  const _HorizontalRuleBlock();
}

// ── Markdown renderer widget ────────────────────────────────────────────────

/// Renders raw markdown as a column of shadcn_flutter styled widgets.
class MarkdownRendererWidget extends StatelessWidget {
  final String markdown;
  final String? title;
  final String? description;
  final DateTime? lastModified;

  const MarkdownRendererWidget({
    required this.markdown,
    this.title,
    this.description,
    this.lastModified,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final blocks = _parseMarkdown(markdown);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[Text(title!).h1(), const Gap(8)],
        if (lastModified != null) ...[
          Text('Last updated: ${_formatDate(lastModified!)}').muted().small(),
          const Gap(8),
        ],
        if (description != null) ...[Text(description!).lead(), const Gap(24)],
        ...blocks.expand(
          (block) => [_buildBlock(context, block), const Gap(16)],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Widget _buildBlock(BuildContext context, _MarkdownBlock block) {
    return switch (block) {
      _HeadingBlock(:final level, :final text) => _buildHeading(level, text),
      _ParagraphBlock(:final text) => _buildParagraph(context, text),
      _CodeBlock(:final language, :final code) => _buildCodeBlock(
        context,
        language,
        code,
      ),
      _TableBlock(:final rows) => _buildTable(context, rows),
      _UnorderedListBlock(:final items) => _buildUnorderedList(context, items),
      _OrderedListBlock(:final items) => _buildOrderedList(context, items),
      _BlockquoteBlock(:final text) => _buildBlockquote(context, text),
      _HorizontalRuleBlock() => const Divider(),
    };
  }

  Widget _buildHeading(int level, String text) {
    final textWidget = Text(text);
    return switch (level) {
      1 => textWidget.h1(),
      2 => textWidget.h2(),
      3 => textWidget.h3(),
      4 => textWidget.h4(),
      _ => textWidget.h4(),
    };
  }

  Widget _buildParagraph(BuildContext context, String text) {
    final spans = _parseInlineMarkdown(context, text);
    if (spans.length == 1 && spans.first is TextSpan) {
      return Text(text).p();
    }
    return Text.rich(TextSpan(children: spans));
  }

  Widget _buildCodeBlock(BuildContext context, String language, String code) {
    final theme = Theme.of(context);
    return OutlinedContainer(
      child: SelectableText(
        code,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 13 * theme.scaling,
          height: 1.5,
        ),
      ).withPadding(padding: const EdgeInsets.all(4)),
    );
  }

  Widget _buildTable(BuildContext context, List<List<String>> rows) {
    if (rows.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final borderColor = theme.colorScheme.border;
    final headerStyle = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 13 * theme.scaling,
    );
    final cellStyle = TextStyle(fontSize: 13 * theme.scaling);

    return OutlinedContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row
          if (rows.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: borderColor, width: 0.5),
                ),
              ),
              child: Row(
                children: rows.first
                    .map(
                      (cell) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Text(cell.trim(), style: headerStyle),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          // Data rows
          ...rows
              .skip(1)
              .map(
                (row) => Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: borderColor, width: 0.5),
                    ),
                  ),
                  child: Row(
                    children: row
                        .map(
                          (cell) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: Text(cell.trim(), style: cellStyle),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildUnorderedList(BuildContext context, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        final spans = _parseInlineMarkdown(context, item);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('  •  '),
            Expanded(
              child: spans.length == 1
                  ? Text(item).p()
                  : Text.rich(TextSpan(children: spans)),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildOrderedList(BuildContext context, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.asMap().entries.map((entry) {
        final index = entry.key + 1;
        final item = entry.value;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 32, child: Text('$index. ')),
            Expanded(child: Text(item).p()),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildBlockquote(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: theme.colorScheme.primary, width: 3),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(text).p().muted(),
    );
  }

  // ── Inline markdown parsing ───────────────────────────────────────────

  List<InlineSpan> _parseInlineMarkdown(BuildContext context, String text) {
    final spans = <InlineSpan>[];
    final regex = RegExp(
      r'(\*\*(.+?)\*\*)|(\*(.+?)\*)|(`(.+?)`)|(\[(.+?)\]\((.+?)\))',
    );

    int lastEnd = 0;
    for (final match in regex.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }

      if (match.group(2) != null) {
        // Bold
        spans.add(
          TextSpan(
            text: match.group(2),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      } else if (match.group(4) != null) {
        // Italic
        spans.add(
          TextSpan(
            text: match.group(4),
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
        );
      } else if (match.group(6) != null) {
        // Inline code
        final theme = Theme.of(context);
        spans.add(
          TextSpan(
            text: match.group(6),
            style: TextStyle(
              fontFamily: 'monospace',
              backgroundColor: theme.colorScheme.muted.withValues(alpha: 0.3),
              fontSize: 13 * theme.scaling,
            ),
          ),
        );
      } else if (match.group(8) != null) {
        // Link [text](url) -> styled as primary color
        final theme = Theme.of(context);
        spans.add(
          TextSpan(
            text: match.group(8),
            style: TextStyle(
              color: theme.colorScheme.primary,
              decoration: TextDecoration.underline,
            ),
          ),
        );
      }

      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    return spans.isEmpty ? [TextSpan(text: text)] : spans;
  }

  // ── Markdown block parsing ────────────────────────────────────────────

  List<_MarkdownBlock> _parseMarkdown(String markdown) {
    final lines = markdown.split('\n');
    final blocks = <_MarkdownBlock>[];

    int i = 0;
    while (i < lines.length) {
      final line = lines[i];
      final trimmedLine = line.trimLeft();

      // Code block
      if (trimmedLine.startsWith('```')) {
        final language = trimmedLine.substring(3).trim();
        final codeLines = <String>[];
        i++;
        while (i < lines.length && !lines[i].trimLeft().startsWith('```')) {
          codeLines.add(lines[i]);
          i++;
        }
        blocks.add(_CodeBlock(language: language, code: codeLines.join('\n')));
        i++; // skip closing ```
        continue;
      }

      // Heading
      final headingMatch = RegExp(r'^(#{1,6})\s+(.+)$').firstMatch(trimmedLine);
      if (headingMatch != null) {
        blocks.add(
          _HeadingBlock(
            level: headingMatch.group(1)!.length,
            text: headingMatch.group(2)!.trim(),
          ),
        );
        i++;
        continue;
      }

      // Table (pipe-delimited rows)
      if (trimmedLine.contains('|') && trimmedLine.startsWith('|')) {
        final tableLines = <String>[];
        while (i < lines.length &&
            lines[i].trim().contains('|') &&
            lines[i].trim().startsWith('|')) {
          tableLines.add(lines[i]);
          i++;
        }
        final rows = _parseTableRows(tableLines);
        if (rows.isNotEmpty) {
          blocks.add(_TableBlock(rows));
        }
        continue;
      }

      // Unordered list
      if (RegExp(r'^\s*[-*]\s').hasMatch(line)) {
        final listItems = <String>[];
        while (i < lines.length && RegExp(r'^\s*[-*]\s').hasMatch(lines[i])) {
          listItems.add(lines[i].replaceFirst(RegExp(r'^\s*[-*]\s'), ''));
          i++;
        }
        blocks.add(_UnorderedListBlock(listItems));
        continue;
      }

      // Ordered list
      if (RegExp(r'^\s*\d+\.\s').hasMatch(line)) {
        final listItems = <String>[];
        while (i < lines.length && RegExp(r'^\s*\d+\.\s').hasMatch(lines[i])) {
          listItems.add(lines[i].replaceFirst(RegExp(r'^\s*\d+\.\s'), ''));
          i++;
        }
        blocks.add(_OrderedListBlock(listItems));
        continue;
      }

      // Horizontal rule
      if (RegExp(r'^(-{3,}|_{3,}|\*{3,})$').hasMatch(trimmedLine)) {
        blocks.add(const _HorizontalRuleBlock());
        i++;
        continue;
      }

      // Block quote
      if (trimmedLine.startsWith('>')) {
        final quoteLines = <String>[];
        while (i < lines.length && lines[i].trimLeft().startsWith('>')) {
          quoteLines.add(lines[i].replaceFirst(RegExp(r'^\s*>\s?'), ''));
          i++;
        }
        blocks.add(_BlockquoteBlock(quoteLines.join('\n')));
        continue;
      }

      // Empty line
      if (trimmedLine.isEmpty) {
        i++;
        continue;
      }

      // Paragraph: collect consecutive non-special lines
      final paraLines = <String>[];
      while (i < lines.length && _isParagraphLine(lines[i])) {
        paraLines.add(lines[i]);
        i++;
      }
      if (paraLines.isNotEmpty) {
        blocks.add(_ParagraphBlock(paraLines.join(' ')));
      }
    }

    return blocks;
  }

  bool _isParagraphLine(String line) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) return false;
    if (trimmed.startsWith('#')) return false;
    if (trimmed.startsWith('```')) return false;
    if (trimmed.startsWith('>')) return false;
    if (trimmed.startsWith('|') && trimmed.contains('|')) return false;
    if (RegExp(r'^\s*[-*]\s').hasMatch(line)) return false;
    if (RegExp(r'^\s*\d+\.\s').hasMatch(line)) return false;
    if (RegExp(r'^(-{3,}|_{3,}|\*{3,})$').hasMatch(trimmed)) return false;
    return true;
  }

  /// Parses pipe-delimited table lines, skipping separator rows (|---|---|).
  List<List<String>> _parseTableRows(List<String> lines) {
    final rows = <List<String>>[];

    for (final line in lines) {
      final trimmed = line.trim();
      // Skip separator rows
      if (RegExp(r'^\|[\s\-:|]+\|$').hasMatch(trimmed)) continue;

      final cells = trimmed
          .split('|')
          .where((cell) => cell.trim().isNotEmpty)
          .map((cell) => cell.trim())
          .toList();

      if (cells.isNotEmpty) {
        rows.add(cells);
      }
    }

    return rows;
  }
}
