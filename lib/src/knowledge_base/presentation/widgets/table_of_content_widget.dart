import 'package:knowledge_base/core/utils/constants.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class TOCItem {
  /// Title of the item
  final String title;

  /// Heading in the document (H1 - H6)
  final TOCHeading heading;
  const TOCItem({required this.title, required this.heading});
}

enum TOCHeading {
  h1(1),
  h2(2),
  h3(3),
  h4(4),
  h5(5),
  h6(6);

  final int level;
  const TOCHeading(this.level);
  static TOCHeading fromLevel(int level) {
    switch (level) {
      case 1:
        return TOCHeading.h1;
      case 2:
        return TOCHeading.h2;
      case 3:
        return TOCHeading.h3;
      case 4:
        return TOCHeading.h4;
      case 5:
        return TOCHeading.h5;
      case 6:
        return TOCHeading.h6;
      default:
        return TOCHeading.h1;
    }
  }
}

class TableOfContentWidget extends StatelessWidget {
  const TableOfContentWidget({
    required this.items,
    required this.activeItemIndices,
    this.width,
    super.key,
  });

  final Set<int> activeItemIndices;
  final List<TOCItem> items;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? sidePanelWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: navigationSize,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(
              horizontal: SizePadding.large,
              vertical: SizePadding.base,
            ),
            child: const Text('On This Page').semiBold().muted(),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              padding: EdgeInsets.all(SizePadding.base),
              itemBuilder: (_, index) {
                final item = items[index];
                return _TocItem(
                  item: item,
                  isActive: activeItemIndices.contains(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TocItem extends StatelessWidget {
  final TOCItem item;
  final bool isActive;

  const _TocItem({required this.item, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indent = item.heading.level - 1;
    final indentScale = (indent * 0.25);
    return TextButton(
      onPressed: () {},
      density: ButtonDensity.compact,
      child: Row(
        children: [
          AnimatedContainer(
            duration: AppDuration.small,
            margin: const EdgeInsets.only(right: SizePadding.base),
            alignment: Alignment.centerLeft,
            width: SizePadding.base,
            child: !isActive
                ? SizedBox.shrink()
                : Icon(
                    BootstrapIcons.chevronRight,
                    size: SizeIcons.small - indentScale,
                    color: theme.colorScheme.primary,
                  ),
          ),
          Expanded(
            child: Tooltip(
              waitDuration: AppDuration.extraLarge,
              tooltip: TooltipContainer(child: Text(item.title)).call,
              child:
                  Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 14 - indentScale,
                          fontWeight: FontWeight.normal,
                          color: theme.colorScheme.foreground,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                      .withPadding(
                        padding: EdgeInsets.only(
                          left: indent * SizePadding.base - indentScale,
                          top: SizePadding.small,
                          bottom: SizePadding.small,
                        ),
                      )
                      .withOpacity(isActive ? 1.0 : 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
