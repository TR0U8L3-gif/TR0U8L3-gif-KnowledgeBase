import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Builds a [MarkdownStyleSheet] that maps shadcn_flutter theme tokens
/// (color scheme, typography, scaling) to markdown element styles.
MarkdownStyleSheet shadcnMarkdownStyleSheet(BuildContext context) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final typography = theme.typography;
  final scaling = theme.scaling;

  final monoStyle = TextStyle(fontFamily: 'monospace', fontSize: 14 * scaling);

  return MarkdownStyleSheet(
    // Headings
    h1: typography.h1.copyWith(color: colorScheme.foreground),
    h2: typography.h2.copyWith(color: colorScheme.foreground),
    h3: typography.h3.copyWith(color: colorScheme.foreground),
    h4: typography.h4.copyWith(color: colorScheme.foreground),
    h5: TextStyle(
      fontSize: 14 * scaling,
      fontWeight: FontWeight.w600,
      color: colorScheme.foreground,
    ),
    h6: TextStyle(
      fontSize: 13 * scaling,
      fontWeight: FontWeight.w600,
      color: colorScheme.mutedForeground,
    ),

    // Paragraph
    p: typography.base.copyWith(color: colorScheme.foreground, height: 1.7),

    // Strong & emphasis
    strong: const TextStyle(fontWeight: FontWeight.bold),
    em: const TextStyle(fontStyle: FontStyle.italic),
    del: TextStyle(
      decoration: TextDecoration.lineThrough,
      color: colorScheme.mutedForeground,
    ),

    // Links
    a: TextStyle(
      color: colorScheme.primary,
      decoration: TextDecoration.underline,
    ),

    // Inline code
    code: monoStyle.copyWith(
      backgroundColor: colorScheme.muted.withValues(alpha: 0.3),
    ),

    // Fenced code blocks
    codeblockDecoration: const BoxDecoration(),
    codeblockPadding: EdgeInsets.zero,

    // Blockquote
    blockquote: typography.base.copyWith(
      color: colorScheme.mutedForeground,
      height: 1.6,
    ),
    blockquoteDecoration: BoxDecoration(
      border: Border(left: BorderSide(color: colorScheme.primary, width: 3)),
    ),
    blockquotePadding: EdgeInsets.symmetric(
      horizontal: 16 * scaling,
      vertical: 8 * scaling,
    ),
    // Tables
    tableColumnWidth: const IntrinsicColumnWidth(),
    tableHead: TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 14 * scaling,
      color: colorScheme.foreground,
    ),
    tableBody: TextStyle(fontSize: 14 * scaling, color: colorScheme.foreground),
    tableBorder: TableBorder.all(color: colorScheme.border, width: 0.5),
    tableCellsPadding: EdgeInsets.symmetric(
      horizontal: 12 * scaling,
      vertical: 8 * scaling,
    ),

    // Lists
    listBullet: typography.base.copyWith(color: colorScheme.foreground),
    listIndent: 24 * scaling,

    // Horizontal rule
    horizontalRuleDecoration: BoxDecoration(
      border: Border(top: BorderSide(color: colorScheme.border, width: 0.5)),
    ),

    // Spacing
    h1Padding: EdgeInsets.only(top: 24 * scaling, bottom: 8 * scaling),
    h2Padding: EdgeInsets.only(top: 20 * scaling, bottom: 8 * scaling),
    h3Padding: EdgeInsets.only(top: 16 * scaling, bottom: 4 * scaling),
    h4Padding: EdgeInsets.only(top: 12 * scaling, bottom: 4 * scaling),
    h5Padding: EdgeInsets.only(top: 8 * scaling, bottom: 4 * scaling),
    h6Padding: EdgeInsets.only(top: 8 * scaling, bottom: 4 * scaling),
    pPadding: EdgeInsets.only(bottom: 8 * scaling),
    blockSpacing: 8 * scaling,
  );
}
