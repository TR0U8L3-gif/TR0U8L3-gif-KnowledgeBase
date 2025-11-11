import 'package:flutter/foundation.dart';
import 'package:knowledge_base/core/utils/constants.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class DirTreeItem {
  final String title;
  final List<DirTreeItem>? children;

  const DirTreeItem({required this.title, this.children});
}

class DirectoriesTreeWidget extends StatefulWidget {
  const DirectoriesTreeWidget({required this.items, this.width, super.key});

  final List<DirTreeItem> items;
  final double? width;
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

  _generateTreeItems(List<DirTreeItem> items) {
    return items
        .map(
          (e) => TreeItem(
            data: e.title,
            children: e.children != null ? _generateTreeItems(e.children!) : <TreeItem<String>>[],
          ),
        )
        .toList();
  }

  var treeItems = <TreeNode<String>>[];

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
            child: TreeView(
              nodes: treeItems,
              onSelectionChanged: TreeView.defaultSelectionHandler(treeItems, (
                value,
              ) {
                setState(() {
                  treeItems = value;
                });
              }),
              builder: (context, node) {
                return TreeItemView(
                  leading: node.leaf
                      ? const Icon(BootstrapIcons.fileText, size: 16)
                      : Icon(
                          node.expanded
                              ? BootstrapIcons.folder2Open
                              : BootstrapIcons.folder2,
                          size: 16,
                        ),
                  onExpand: TreeView.defaultItemExpandHandler(treeItems, node, (
                    value,
                  ) {
                    setState(() {
                      treeItems = value;
                    });
                  }),
                  child: Tooltip(
                    waitDuration: AppDuration.extraLarge,
                    tooltip: TooltipContainer(child: Text(node.data)).call,
                    child: Text(
                      node.data,
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
