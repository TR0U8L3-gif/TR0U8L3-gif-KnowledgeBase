import 'package:knowledge_base/core/utils/helpers/text_helper.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class BreadcrumbWidget extends StatelessWidget {
  const BreadcrumbWidget({
    required this.items,
    this.onItemTapped,
    this.height = 48,
    super.key,
  });

  final double height;
  final List<String> items;
  final void Function(int)? onItemTapped;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    if (items.length == 1) {
      return _Container(height: height, child: _EllipsisText(items.first));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return _BreadcrumbContent(
          items: items,
          onItemTapped: onItemTapped,
          height: height,
          maxWidth: constraints.maxWidth,
        );
      },
    );
  }
}

class _BreadcrumbContent extends StatelessWidget {
  const _BreadcrumbContent({
    required this.items,
    required this.onItemTapped,
    required this.height,
    required this.maxWidth,
  });

  final List<String> items;
  final void Function(int)? onItemTapped;
  final double height;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final padding = 16.0 * 2;
    final availableWidth = maxWidth - padding;
    final scaling = Theme.of(context).scaling;
    final separatorWidth = 12.0 + 16 * scaling;
    final sep = _ArrowSeparator(width: separatorWidth);

    final itemsToShow = _calculateItemsToShow(
      context,
      items,
      availableWidth,
      separatorWidth,
    );

    if (itemsToShow.length == 1) {
      return _Container(height: height, child: _EllipsisText(items.first));
    }

    return _Container(
      height: height,
      child: Row(children: _buildBreadcrumbItems(itemsToShow, sep, null)),
    );
  }

  /// returns list of item indexes to show, -1 represents ellipsis
  List<int> _calculateItemsToShow(
    BuildContext context,
    List<String> items,
    double availableWidth,
    double separatorWidth, [
    TextStyle? style,
  ]) {
    if (items.isEmpty) {
      return [];
    }

    final lastIndex = items.length - 1;

    if (items.length == 1) {
      return [0];
    }
    final textStyle = style ?? DefaultTextStyle.of(context).style;
    final itemsToShow = <int>[lastIndex];
    final ellipsisWidth = TextHelper.calculateWidth('...', textStyle);
    final lastItemWidth = TextHelper.calculateWidth(
      items[lastIndex],
      textStyle,
    );
    final firstItemWidth =
        TextHelper.calculateWidth(items[0], textStyle) + separatorWidth;

    double usedWidth = firstItemWidth + separatorWidth + lastItemWidth;

    if (items.length >= 2) {
      if (usedWidth <= availableWidth) {
        itemsToShow.insert(0, 0);
      } else {
        return [-1, lastIndex];
      }
    }

    if (items.length == 2) {
      return itemsToShow;
    }

    int index = lastIndex - 1;
    for (index; index >= 1; index--) {
      final itemWidth =
          TextHelper.calculateWidth(items[index], textStyle) + separatorWidth;

      if (usedWidth + itemWidth < availableWidth) {
        itemsToShow.insert(1, index);
        usedWidth += itemWidth;
      } else {
        final ellipsisItemWidth = ellipsisWidth + separatorWidth;
        if (usedWidth + ellipsisItemWidth < availableWidth) {
          itemsToShow.insert(1, -1);
        } else {
          if (itemsToShow.length > 2) {
            itemsToShow[1] = -1;
          } else {
            itemsToShow[0] = -1;
          }
        }
        break;
      }
    }

    return itemsToShow;
  }

  List<Widget> _buildBreadcrumbItems(
    List<int> itemsToShow,
    Widget separator,
    TextStyle? style,
  ) {
    final widgets = <Widget>[];

    for (int i = 0; i < itemsToShow.length; i++) {
      final itemIndex = itemsToShow[i];

      if (itemIndex == -1) {
        // Ellipsis
        widgets.add(Text('...', style: style));
      } else if (itemIndex == items.length - 1) {
        // Last item always as text
        widgets.add(
          Flexible(child: _EllipsisText(items[itemIndex], style: style)),
        );
      } else {
        // Other items as buttons
        widgets.add(
          TextButton(
            onPressed: () => onItemTapped?.call(itemIndex),
            density: ButtonDensity.compact,
            child: Text(items[itemIndex], style: style),
          ),
        );
      }

      // Add separator after each item except the last
      if (i < itemsToShow.length - 1) {
        widgets.add(separator);
      }
    }

    return widgets;
  }
}

class _ArrowSeparator extends StatelessWidget {
  const _ArrowSeparator({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: width,
      child: const Icon(RadixIcons.chevronRight).muted(),
    );
  }
}

class _EllipsisText extends StatelessWidget {
  const _EllipsisText(this.text, {this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: style,
    );
  }
}

class _Container extends StatelessWidget {
  const _Container({this.height, required this.child});

  final double? height;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: child,
    );
  }
}
