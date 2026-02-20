import 'package:knowledge_base/core/utils/constants.dart';
import 'package:knowledge_base/core/utils/responsive.dart';
import 'package:knowledge_base/src/knowledge_base/domain/entities/knowledge_base_item.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Displays a directory's info and a grid of cards for each item it contains.
class DirectoryViewWidget extends StatelessWidget {
  final DirectoryItem directory;
  final ValueChanged<String>? onFileSelected;
  final ValueChanged<String>? onDirectorySelected;

  const DirectoryViewWidget({
    required this.directory,
    this.onFileSelected,
    this.onDirectorySelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final items = directory.sortedItems;

    return SingleChildScrollView(
      padding: Responsive.contentPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Directory header
          Row(
            children: [
              const Icon(BootstrapIcons.folder2Open, size: 28),
              const Gap(12),
              Expanded(child: Text(directory.name).h1()),
            ],
          ),
          if (directory.description != null) ...[
            const Gap(8),
            Text(directory.description!).lead().muted(),
          ],
          const Gap(8),
          Text(
            '${items.length} item${items.length == 1 ? '' : 's'}',
          ).small().muted(),
          const Gap(24),
          const Divider(),
          const Gap(24),

          // Grid of item cards
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = _calculateColumns(constraints.maxWidth);
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: items.map((item) {
                  final cardWidth =
                      (constraints.maxWidth - (crossAxisCount - 1) * 16) /
                      crossAxisCount;
                  return SizedBox(
                    width: cardWidth,
                    child: _ItemCard(
                      item: item,
                      onTap: () {
                        if (item is FileItem) {
                          onFileSelected?.call(item.path);
                        } else if (item is DirectoryItem) {
                          onDirectorySelected?.call(item.path);
                        }
                      },
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  int _calculateColumns(double width) {
    if (width > 900) return 3;
    if (width > 550) return 2;
    return 1;
  }
}

class _ItemCard extends StatelessWidget {
  final KnowledgeBaseItem item;
  final VoidCallback onTap;

  const _ItemCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      label: item is FileItem
          ? 'Open file ${item.name}'
          : 'Open folder ${item.name}',
      child: GestureDetector(
        onTap: onTap,
        child: OutlinedContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Card header with icon and title
              Row(
                children: [
                  _buildIcon(theme),
                  const Gap(10),
                  Expanded(
                    child: Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14 * theme.scaling,
                      ),
                    ),
                  ),
                  Icon(
                    BootstrapIcons.chevronRight,
                    size: SizeIcons.small,
                    color: theme.colorScheme.mutedForeground,
                  ),
                ],
              ),

              // Description
              if (_description != null) ...[
                const Gap(8),
                Text(
                  _description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13 * theme.scaling,
                    color: theme.colorScheme.mutedForeground,
                  ),
                ),
              ],

              // Meta info
              if (item is FileItem) ...[
                const Gap(12),
                _buildFileMeta(context, item as FileItem),
              ] else if (item is DirectoryItem) ...[
                const Gap(12),
                _buildDirectoryMeta(context, item as DirectoryItem),
              ],
            ],
          ).withPadding(padding: const EdgeInsets.all(16)),
        ),
      ),
    );
  }

  Widget _buildIcon(ThemeData theme) {
    if (item is DirectoryItem) {
      return Icon(
        BootstrapIcons.folder2,
        size: SizeIcons.large,
        color: theme.colorScheme.primary,
      );
    }
    return Icon(
      BootstrapIcons.fileText,
      size: SizeIcons.large,
      color: theme.colorScheme.primary,
    );
  }

  String? get _description {
    if (item is FileItem) return (item as FileItem).description;
    if (item is DirectoryItem) return (item as DirectoryItem).description;
    return null;
  }

  Widget _buildFileMeta(BuildContext context, FileItem file) {
    final theme = Theme.of(context);
    final metaStyle = TextStyle(
      fontSize: 12 * theme.scaling,
      color: theme.colorScheme.mutedForeground,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tags
        if (file.tags.isNotEmpty)
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: file.tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.muted.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 11 * theme.scaling,
                    color: theme.colorScheme.mutedForeground,
                  ),
                ),
              );
            }).toList(),
          ),

        // Dates row
        if (file.lastModified != null || file.created != null) ...[
          const Gap(8),
          Row(
            children: [
              Icon(
                BootstrapIcons.clock,
                size: 12,
                color: theme.colorScheme.mutedForeground,
              ),
              const Gap(4),
              if (file.lastModified != null)
                Flexible(
                  child: Text(
                    'Modified: ${_formatDate(file.lastModified!)}',
                    style: metaStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ],

        // Extension
        if (file.extension.isNotEmpty) ...[
          const Gap(4),
          Row(
            children: [
              Icon(
                BootstrapIcons.fileEarmarkText,
                size: 12,
                color: theme.colorScheme.mutedForeground,
              ),
              const Gap(4),
              Text('.${file.extension}', style: metaStyle),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDirectoryMeta(BuildContext context, DirectoryItem dir) {
    final theme = Theme.of(context);
    final metaStyle = TextStyle(
      fontSize: 12 * theme.scaling,
      color: theme.colorScheme.mutedForeground,
    );

    final fileCount = dir.items.whereType<FileItem>().length;
    final dirCount = dir.items.whereType<DirectoryItem>().length;

    return Row(
      children: [
        Icon(
          BootstrapIcons.files,
          size: 12,
          color: theme.colorScheme.mutedForeground,
        ),
        const Gap(4),
        Text(
          '${fileCount > 0 ? '$fileCount file${fileCount == 1 ? '' : 's'}' : ''}'
          '${fileCount > 0 && dirCount > 0 ? ', ' : ''}'
          '${dirCount > 0 ? '$dirCount folder${dirCount == 1 ? '' : 's'}' : ''}',
          style: metaStyle,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
