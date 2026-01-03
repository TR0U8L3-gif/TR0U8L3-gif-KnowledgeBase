import 'package:shadcn_flutter/shadcn_flutter.dart';

class KnowledgeBasePage extends StatefulWidget {
  const KnowledgeBasePage({Key? key}) : super(key: key);

  @override
  _KnowledgeBasePageState createState() => _KnowledgeBasePageState();
}

class _KnowledgeBasePageState extends State<KnowledgeBasePage> {
  // Simple counter to demonstrate updating content inside the Scaffold body.
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Show an indeterminate progress indicator in the header area (for demo purposes).
      loadingProgressIndeterminate: true,
      loadingProgress: 0.8,
      headers: [
        AppBar(
          title: const Text('Counter App'),
          subtitle: const Text('A simple counter app'),
          leading: [
            OutlineButton(
              onPressed: () {},
              density: ButtonDensity.icon,
              child: const Icon(Icons.menu),
            ),
          ],
          trailing: [
            OutlineButton(
              onPressed: () {},
              density: ButtonDensity.icon,
              child: const Icon(Icons.search),
            ),
            OutlineButton(
              onPressed: () {},
              density: ButtonDensity.icon,
              child: const Icon(Icons.add),
            ),
          ],
        ),
        // Divider between the header and the body.
        const Divider(),
      ],
      footers: [PaginationExample1()],
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TreeExample1(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Breadcrumb(
                  // Use a built-in arrow separator for a conventional look.
                  separator: Breadcrumb.arrowSeparator,
                  children: [
                    TextButton(
                      onPressed: () {},
                      density: ButtonDensity.compact,
                      child: const Text('Home'),
                    ),
                    const MoreDots(),
                    TextButton(
                      onPressed: () {},
                      density: ButtonDensity.compact,
                      child: const Text('Components'),
                    ),
                    // Final segment as a non-interactive label.
                    const Text('Breadcrumb'),
                  ],
                ).withPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        // The .p() extension adds default padding around the widget.
                        const Text(
                          'You have pushed the button this many times:',
                        ).p(),
                        Text('$_counter').h1(),
                        PrimaryButton(
                          onPressed: _incrementCounter,
                          density: ButtonDensity.icon,
                          child: const Icon(Icons.add),
                        ).p(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          StepsExample1(),
        ],
      ),
    );
  }
}

class TreeExample1 extends StatefulWidget {
  const TreeExample1({super.key});

  @override
  State<TreeExample1> createState() => _TreeExample1State();
}

class _TreeExample1State extends State<TreeExample1> {
  bool expandIcon = false;
  bool usePath = true;
  bool recursiveSelection = false;
  List<TreeNode<String>> treeItems = [
    TreeItem(
      data: 'Apple',
      expanded: true,
      children: [
        TreeItem(
          data: 'Red Apple',
          children: [
            TreeItem(data: 'Red Apple 1'),
            TreeItem(data: 'Red Apple 2'),
          ],
        ),
        TreeItem(data: 'Green Apple'),
      ],
    ),
    TreeItem(
      data: 'Banana',
      children: [
        TreeItem(data: 'Yellow Banana'),
        TreeItem(
          data: 'Green Banana',
          children: [
            TreeItem(data: 'Green Banana 1'),
            TreeItem(data: 'Green Banana 2'),
            TreeItem(data: 'Green Banana 3'),
          ],
        ),
      ],
    ),
    TreeItem(
      data: 'Cherry',
      children: [
        TreeItem(data: 'Red Cherry'),
        TreeItem(data: 'Green Cherry'),
      ],
    ),
    TreeItem(data: 'Date'),
    // Tree Root acts as a parent node with no data,
    // it will flatten the children into the parent node
    TreeRoot(
      children: [
        TreeItem(
          data: 'Elderberry',
          children: [
            TreeItem(data: 'Black Elderberry'),
            TreeItem(data: 'Red Elderberry'),
          ],
        ),
        TreeItem(
          data: 'Fig',
          children: [
            TreeItem(data: 'Green Fig'),
            TreeItem(data: 'Purple Fig'),
          ],
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedContainer(
          child: SizedBox(
            height: 300,
            width: 250,
            child: TreeView(
              // Show a separate expand/collapse icon when true; otherwise use row affordance.
              expandIcon: expandIcon,
              shrinkWrap: true,
              // When true, selecting a parent can affect children (see below toggle).
              recursiveSelection: recursiveSelection,
              nodes: treeItems,
              // Draw connecting lines either as path curves or straight lines.
              branchLine: usePath ? BranchLine.path : BranchLine.line,
              // Use a built-in handler to update selection state across nodes.
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
                  trailing: node.leaf
                      ? Container(
                          width: 16,
                          height: 16,
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(),
                        )
                      : null,
                  leading: node.leaf
                      ? const Icon(BootstrapIcons.fileImage)
                      : Icon(
                          node.expanded
                              ? BootstrapIcons.folder2Open
                              : BootstrapIcons.folder2,
                        ),
                  // Expand/collapse handling; updates treeItems with new expanded state.
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
        ),
        const Gap(16),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PrimaryButton(
              onPressed: () {
                setState(() {
                  treeItems = treeItems.expandAll();
                });
              },
              child: const Text('Expand All'),
            ),
            const Gap(8),
            PrimaryButton(
              onPressed: () {
                setState(() {
                  treeItems = treeItems.collapseAll();
                });
              },
              child: const Text('Collapse All'),
            ),
          ],
        ),
        const Gap(8),
        Checkbox(
          state: expandIcon ? CheckboxState.checked : CheckboxState.unchecked,
          onChanged: (value) {
            setState(() {
              expandIcon = value == CheckboxState.checked;
            });
          },
          trailing: const Text('Expand Icon'),
        ),
        const Gap(8),
        Checkbox(
          state: usePath ? CheckboxState.checked : CheckboxState.unchecked,
          onChanged: (value) {
            setState(() {
              usePath = value == CheckboxState.checked;
            });
          },
          trailing: const Text('Use Path Branch Line'),
        ),
        const Gap(8),
        Checkbox(
          state: recursiveSelection
              ? CheckboxState.checked
              : CheckboxState.unchecked,
          onChanged: (value) {
            setState(() {
              recursiveSelection = value == CheckboxState.checked;
              if (recursiveSelection) {
                // Update nodes so parent/child reflect selected state recursively.
                treeItems = treeItems.updateRecursiveSelection();
              }
            });
          },
          trailing: const Text('Recursive Selection'),
        ),
      ],
    );
  }
}

class PaginationExample1 extends StatefulWidget {
  const PaginationExample1({super.key});

  @override
  State<PaginationExample1> createState() => _PaginationExample1State();
}

class _PaginationExample1State extends State<PaginationExample1> {
  int page = 1;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Pagination(
        page: page,
        totalPages: 20,
        // Limit how many page buttons are visible at once (rest via ellipsis).
        onPageChanged: (value) {
          setState(() {
            page = value;
          });
        },
        maxPages: 3,
      ).withPadding(padding: const EdgeInsets.all(8)),
    );
  }
}

class StepsExample1 extends StatelessWidget {
  const StepsExample1({super.key});

  @override
  Widget build(BuildContext context) {
    return Steps(
      // Static steps list with titles and supporting content lines.
      children: [
        StepItem(
          title: Text('Create a project'),
          content: [
            Text('Create a new project in the project manager.'),
            Text('Add the required files to the project.'),
          ],
        ),
        StepItem(
          title: Text('Add dependencies'),
          content: [
            Text('Add the required dependencies to the project.'),
          ],
        ),
        StepItem(
          title: Text('Run the project'),
          content: [
            Text('Run the project in the project manager.'),
          ],
        ),
      ],
    );
  }
}