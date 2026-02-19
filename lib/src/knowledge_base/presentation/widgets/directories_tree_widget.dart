import 'package:flutter/foundation.dart';
import 'package:knowledge_base/core/utils/constants.dart';
import 'package:knowledge_base/src/knowledge_base/domain/entities/knowledge_base_item.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Presentation model for tree nodes, carrying display title and file path.
class DirTreeItem {
  final String title;
  final String path;
  final bool isFile;
  final List<DirTreeItem>? children;

  const DirTreeItem({
    required this.title,
    required this.path,
    this.isFile = false,
    this.children,
  });

  /// Creates tree items from domain [KnowledgeBaseItem] entities.
  static List<DirTreeItem> fromKnowledgeBaseItems(
    List<KnowledgeBaseItem> items,
  ) {
    return items.map((item) {
      if (item is DirectoryItem) {
        return DirTreeItem(
          title: item.name,
          path: item.path,
          isFile: false,
          children: fromKnowledgeBaseItems(item.sortedItems),
        );
      } else if (item is FileItem) {
        return DirTreeItem(title: item.name, path: item.path, isFile: true);
      }
      throw ArgumentError('Unknown KnowledgeBaseItem type: $item');
    }).toList();
  }
}

class DirectoriesTreeWidget extends StatefulWidget {
  const DirectoriesTreeWidget({
    required this.items,
    this.width,
    this.selectedFilePath,
    this.onFileSelected,
    super.key,
  });

  final List<DirTreeItem> items;
  final double? width;
  final String? selectedFilePath;
  final ValueChanged<String>? onFileSelected;

  @override
  State<DirectoriesTreeWidget> createState() => _DirectoriesTreeWidgetState();
}

class _DirectoriesTreeWidgetState extends State<DirectoriesTreeWidget> {
  @override
  void initState() {
    super.initState();
    treeItems = _generateTreeItems(widget.items);
  }

  @override
  void didUpdateWidget(covariant DirectoriesTreeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.items, widget.items)) {
      treeItems = _generateTreeItems(widget.items);
    }
  }

  @override
  void dispose() {
    treeItems.clear();
    super.dispose();
  }

  List<TreeNode<DirTreeItem>> _generateTreeItems(List<DirTreeItem> items) {
    return items
        .map(
          (e) => TreeItem<DirTreeItem>(
            data: e,
            children: e.children != null
                ? _generateTreeItems(e.children!)
                : <TreeItem<DirTreeItem>>[],
          ),
        )
        .toList();
  }

  var treeItems = <TreeNode<DirTreeItem>>[];

  void _collapseAll() {
    setState(() {
      treeItems = treeItems.collapseAll();
    });
  }

  void _expandAll() {
    setState(() {
      treeItems = treeItems.expandAll();
    });
  }

  void _handleSelectionChanged(List<TreeNode<DirTreeItem>> updatedNodes) {
    setState(() {
      treeItems = updatedNodes;
    });
    final selectedFile = _findSelectedFile(updatedNodes);
    if (selectedFile != null) {
      widget.onFileSelected?.call(selectedFile.path);
    }
  }

  DirTreeItem? _findSelectedFile(List<TreeNode<DirTreeItem>> nodes) {
    for (final node in nodes) {
      if (node is TreeItem<DirTreeItem>) {
        if (node.selected && node.data.isFile) {
          return node.data;
        }
      }
      if (node.children.isNotEmpty) {
        final found = _findSelectedFile(
          node.children.cast<TreeNode<DirTreeItem>>(),
        );
        if (found != null) return found;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? sidePanelWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: SizePadding.large,
              vertical: SizePadding.base,
            ),
            width: double.infinity,
            height: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Documentation').semiBold().muted(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlineButton(
                      onPressed: _expandAll,
                      density: ButtonDensity.icon,
                      child: const Icon(
                        BootstrapIcons.arrowsExpand,
                        size: 14,
                      ).muted(),
                    ),
                    const Gap(4),
                    OutlineButton(
                      onPressed: _collapseAll,
                      density: ButtonDensity.icon,
                      child: const Icon(
                        BootstrapIcons.arrowsCollapse,
                        size: 14,
                      ).muted(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: TreeView<DirTreeItem>(
              nodes: treeItems,
              onSelectionChanged: TreeView.defaultSelectionHandler<DirTreeItem>(
                treeItems,
                _handleSelectionChanged,
              ),
              builder: (context, node) {
                return TreeItemView(
                  leading: node.data.isFile
                      ? const Icon(BootstrapIcons.fileText, size: 16)
                      : Icon(
                          node.expanded
                              ? BootstrapIcons.folder2Open
                              : BootstrapIcons.folder2,
                          size: 16,
                        ),
                  onExpand: TreeView.defaultItemExpandHandler<DirTreeItem>(
                    treeItems,
                    node,
                    (value) {
                      setState(() {
                        treeItems = value;
                      });
                    },
                  ),
                  child: Tooltip(
                    waitDuration: AppDuration.extraLarge,
                    tooltip: TooltipContainer(
                      child: Text(node.data.title),
                    ).call,
                    child: Text(
                      node.data.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
