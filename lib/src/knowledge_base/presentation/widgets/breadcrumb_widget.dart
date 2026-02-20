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
      return Semantics(
        label: 'Breadcrumb navigation: ${items.first}',
        child: _Container(height: height, child: _EllipsisText(items.first)),
      );
    }

    return Semantics(
      label: 'Breadcrumb navigation: ${items.join(' > ')}',
      child: LayoutBuilder(
        builder: (context, constraints) {
          return _BreadcrumbContent(
            items: items,
            onItemTapped: onItemTapped,
            height: height,
            maxWidth: constraints.maxWidth,
          );
        },
      ),
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
    final theme = Theme.of(context);

    final scaling = theme.scaling;
    final textStyle = theme.typography.small.copyWith(
      fontWeight: FontWeight.w500,
      fontSize: 14 * scaling,
    );

    final availableWidth = maxWidth - 4;
    final separatorWidth = 12.0 + 16 * scaling;

    final sep = _ArrowSeparator(width: separatorWidth);

    final itemsToShow = _calculateItemsToShow(
      context,
      items,
      availableWidth,
      separatorWidth,
      textStyle,
    );

    return _Container(
      height: height,
      child: Row(children: _buildBreadcrumbItems(itemsToShow, sep, textStyle)),
    );
  }

  /// returns list of item indexes to display,
  /// value -1 represents ellipsis
  List<int> _calculateItemsToShow(
    BuildContext context,
    List<String> items,
    double availableWidth,
    double separatorWidth,
    TextStyle textStyle,
  ) {
    final lastIndex = items.length - 1;

    final itemsToShow = <int>[lastIndex];
    final ellipsisWidth = TextHelper.calculateWidth(
      context,
      '...',
      textStyle,
      1,
    );
    final lastItemWidth = TextHelper.calculateWidth(
      context,
      items[lastIndex],
      textStyle,
      1,
    );
    final firstItemWidth =
        TextHelper.calculateWidth(context, items[0], textStyle, 1) +
        separatorWidth;

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

    for (int index = lastIndex - 1; index >= 1; index--) {
      final itemWidth =
          TextHelper.calculateWidth(context, items[index], textStyle, 1) +
          separatorWidth;

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
        widgets.add(Text('...', style: style).muted());
      } else if (itemIndex == items.length - 1) {
        widgets.add(
          Flexible(child: _EllipsisText(items[itemIndex], style: style)),
        );
      } else {
        widgets.add(
          _TextButtonItem(
            text: items[itemIndex],
            onPressed: () => onItemTapped?.call(itemIndex),
            style: style,
          ),
        );
      }

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
      child: const Icon(RadixIcons.chevronRight).iconXSmall.muted(),
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

class _TextButtonItem extends StatelessWidget {
  const _TextButtonItem({
    required this.text,
    required this.onPressed,
    this.style,
  });

  final VoidCallback onPressed;
  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      density: ButtonDensity.compact,
      child: Text(text, maxLines: 1, style: style),
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
