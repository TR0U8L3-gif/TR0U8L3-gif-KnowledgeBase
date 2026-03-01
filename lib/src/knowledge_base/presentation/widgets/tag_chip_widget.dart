import 'package:knowledge_base/core/utils/tag_colors.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// A small color-coded chip that displays a single tag name.
///
/// The background, border, and text color are derived deterministically from
/// the tag string via [TagColors.forTag].
///
/// Provide [onTap] to make the chip interactive (e.g. open a tag search).
class TagChipWidget extends StatelessWidget {
  final String tag;

  /// Optional callback invoked when the chip is tapped.
  final VoidCallback? onTap;

  const TagChipWidget({required this.tag, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = TagColors.forTag(tag);

    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        tag,
        style: TextStyle(
          fontSize: 11 * theme.scaling,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );

    if (onTap == null) return chip;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(onTap: onTap, child: chip),
    );
  }
}
