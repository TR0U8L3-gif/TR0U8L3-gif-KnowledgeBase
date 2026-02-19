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
            child: SingleChildScrollView(
              padding: EdgeInsets.all(SizePadding.base),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _TocProgressBar(
                      itemCount: items.length,
                      activeIndices: activeItemIndices,
                    ),
                    const Gap(SizePadding.base),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (int index = 0; index < items.length; index++)
                            _TocItem(
                              item: items[index],
                              isActive: activeItemIndices.contains(index),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Vertical progress bar that highlights the visible portion of the TOC.
class _TocProgressBar extends StatefulWidget {
  final int itemCount;
  final Set<int> activeIndices;

  const _TocProgressBar({required this.itemCount, required this.activeIndices});

  @override
  State<_TocProgressBar> createState() => _TocProgressBarState();
}

class _TocProgressBarState extends State<_TocProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _startAnimation;
  late Animation<double> _endAnimation;
  double _targetStart = 0;
  double _targetEnd = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppDuration.large);
    final fractions = _computeFractions();
    _targetStart = fractions.$1;
    _targetEnd = fractions.$2;
    _startAnimation = AlwaysStoppedAnimation(_targetStart);
    _endAnimation = AlwaysStoppedAnimation(_targetEnd);
  }

  @override
  void didUpdateWidget(covariant _TocProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final fractions = _computeFractions();
    // Only animate when the target actually changed
    if (fractions.$1 == _targetStart && fractions.$2 == _targetEnd) return;

    // Capture current animated position to lerp from
    final currentStart = _startAnimation.value;
    final currentEnd = _endAnimation.value;

    _startAnimation = Tween<double>(
      begin: currentStart,
      end: fractions.$1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _endAnimation = Tween<double>(
      begin: currentEnd,
      end: fractions.$2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _targetStart = fractions.$1;
    _targetEnd = fractions.$2;
    _controller.forward(from: 0);
  }

  (double, double) _computeFractions() {
    if (widget.itemCount == 0 || widget.activeIndices.isEmpty) {
      return (0, 0);
    }
    final minIndex = widget.activeIndices.reduce((a, b) => a < b ? a : b);
    final maxIndex = widget.activeIndices.reduce((a, b) => a > b ? a : b);
    return (minIndex / widget.itemCount, (maxIndex + 1) / widget.itemCount);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.itemCount == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(left: SizePadding.base),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            size: const Size(3, double.infinity),
            painter: _ProgressBarPainter(
              trackColor: theme.colorScheme.muted.withValues(alpha: 0.3),
              thumbColor: theme.colorScheme.primary,
              startFraction: _startAnimation.value,
              endFraction: _endAnimation.value,
              radius: 1.5,
            ),
          );
        },
      ),
    );
  }
}

class _ProgressBarPainter extends CustomPainter {
  final Color trackColor;
  final Color thumbColor;
  final double startFraction;
  final double endFraction;
  final double radius;

  _ProgressBarPainter({
    required this.trackColor,
    required this.thumbColor,
    required this.startFraction,
    required this.endFraction,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final trackPaint = Paint()..color = trackColor;
    final trackRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );
    canvas.drawRRect(trackRect, trackPaint);

    if (endFraction > startFraction) {
      final thumbPaint = Paint()..color = thumbColor;
      final top = startFraction * size.height;
      final bottom = endFraction * size.height;
      final thumbRect = RRect.fromRectAndRadius(
        Rect.fromLTRB(0, top, size.width, bottom),
        Radius.circular(radius),
      );
      canvas.drawRRect(thumbRect, thumbPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressBarPainter oldDelegate) =>
      trackColor != oldDelegate.trackColor ||
      thumbColor != oldDelegate.thumbColor ||
      startFraction != oldDelegate.startFraction ||
      endFraction != oldDelegate.endFraction;
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
                .withOpacity(isActive ? 1.0 : 0.64),
      ),
    );
  }
}
