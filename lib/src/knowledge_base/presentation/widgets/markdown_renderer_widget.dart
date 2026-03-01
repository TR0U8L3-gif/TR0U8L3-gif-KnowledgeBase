import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/widgets/_helpers/heading_key_builder.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/widgets/_helpers/markdown_style_sheet_adapter.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/widgets/tag_chip_widget.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

// ── Markdown renderer widget ────────────────────────────────────────────────

/// Renders raw markdown as a column of shadcn_flutter styled widgets,
/// powered by [flutter_markdown_plus] with full GFM support.
class MarkdownRendererWidget extends StatelessWidget {
  final String markdown;
  final String? title;
  final String? description;
  final DateTime? lastModified;
  final List<GlobalKey>? headingKeys;
  final List<String> tags;

  /// Called when the user taps anywhere on the rendered text area.
  final VoidCallback? onTapText;

  /// Called when the text selection changes within the markdown body.
  final MarkdownOnSelectionChangedCallback? onSelectionChanged;

  const MarkdownRendererWidget({
    required this.markdown,
    this.title,
    this.description,
    this.lastModified,
    this.headingKeys,
    this.tags = const [],
    this.onTapText,
    this.onSelectionChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final headingBuilder = HeadingKeyBuilder(headingKeys: headingKeys);

    return Semantics(
      label: 'Document content${title != null ? ': $title' : ''}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[Text(title!).h1(), const Gap(8)],
          if (lastModified != null) ...[
            Semantics(
              label: 'Last updated ${_formatDate(lastModified!)}',
              child: Text(
                'Last updated: ${_formatDate(lastModified!)}',
              ).muted().small(),
            ),
            const Gap(8),
          ],
          if (description != null) ...[
            Text(description!).lead(),
            const Gap(12),
          ],
          if (tags.isNotEmpty) ...[
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: tags.map((t) => TagChipWidget(tag: t)).toList(),
            ),
            const Gap(24),
          ] else if (description != null) ...[
            const Gap(12),
          ],
          MarkdownBody(
            data: markdown,
            selectable: true,
            extensionSet: md.ExtensionSet.gitHubFlavored,
            styleSheet: shadcnMarkdownStyleSheet(context),
            builders: {
              'h1': headingBuilder,
              'h2': headingBuilder,
              'h3': headingBuilder,
              'h4': headingBuilder,
              'h5': headingBuilder,
              'h6': headingBuilder,
            },
            onTapLink: (text, href, title) => _handleLink(href),
            onTapText: onTapText,
            onSelectionChanged: onSelectionChanged,
          ),
        ],
      ),
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

  Future<void> _handleLink(String? href) async {
    if (href == null || href.isEmpty) return;
    final uri = Uri.tryParse(href);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
