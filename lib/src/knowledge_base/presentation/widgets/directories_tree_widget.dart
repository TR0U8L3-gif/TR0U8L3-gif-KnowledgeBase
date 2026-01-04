import 'package:knowledge_base/core/utils/constants.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class DirTreeItem {
  final String title;
  final List<DirTreeItem>? children;

  const DirTreeItem({required this.title, this.children});
}

class DirectoriesTreeWidget extends StatefulWidget {
  const DirectoriesTreeWidget({required this.items, super.key});

  final List<DirTreeItem> items;
  @override
  State<DirectoriesTreeWidget> createState() => _DirectoriesTreeWidgetState();
}

class _DirectoriesTreeWidgetState extends State<DirectoriesTreeWidget> {
  List<TreeNode<String>> treeItems = [
    TreeItem(
      data: 'Getting Started',
      expanded: true,
      children: [
        TreeItem(data: 'Introduction'),
        TreeItem(data: 'Installation'),
        TreeItem(data: 'Quick Start'),
      ],
    ),
    TreeItem(
      data: 'API Documentation',
      expanded: true,
      children: [
        TreeItem(data: 'Authentication API'),
        TreeItem(data: 'Payments API'),
        TreeItem(
          data: 'User Management',
          children: [
            TreeItem(data: 'Create User'),
            TreeItem(data: 'Update User'),
            TreeItem(data: 'Delete User'),
          ],
        ),
      ],
    ),
    TreeItem(
      data: 'Architecture',
      children: [
        TreeItem(data: 'Overview'),
        TreeItem(data: 'Data Flow'),
        TreeItem(
          data: 'Infrastructure',
          children: [
            TreeItem(data: 'Terraform Notes'),
            TreeItem(
              data: 'Runbooks',
              children: [
                TreeItem(data: 'On-Call Guide'),
                TreeItem(data: 'Deployment'),
              ],
            ),
          ],
        ),
        TreeItem(
          data: 'Security',
          children: [
            TreeItem(data: 'Threat Model'),
            TreeItem(data: 'Best Practices'),
          ],
        ),
      ],
    ),
    TreeItem(
      data: 'Guides',
      children: [
        TreeItem(data: 'Local Development'),
        TreeItem(data: 'Testing Guide'),
        TreeItem(data: 'Deployment Guide'),
      ],
    ),
    TreeItem(
      data: 'Operations',
      children: [
        TreeItem(data: 'Incident Template'),
        TreeItem(data: 'Release Checklist'),
        TreeItem(data: 'Monitoring'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: sidePanelWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            width: double.infinity,
            height: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Documentation').semiBold(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlineButton(
                      onPressed: () {
                        setState(() {
                          treeItems = treeItems.expandAll();
                        });
                      },
                      density: ButtonDensity.icon,
                      child: const Icon(BootstrapIcons.arrowsExpand, size: 14),
                    ),
                    const Gap(4),
                    OutlineButton(
                      onPressed: () {
                        setState(() {
                          treeItems = treeItems.collapseAll();
                        });
                      },
                      density: ButtonDensity.icon,
                      child: const Icon(BootstrapIcons.arrowsCollapse, size: 14),
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
                  onPressed: () {},
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
                  child: Text(node.data),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
