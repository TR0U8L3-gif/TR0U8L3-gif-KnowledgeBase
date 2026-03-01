import 'package:knowledge_base/core/utils/tag_colors.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// A small color-coded chip that displays a single tag name.
///
/// The background, border, and text color are derived deterministically from
/// the tag string via [TagColors.forTag].
class TagChipWidget extends StatelessWidget {
  final String tag;

  const TagChipWidget({required this.tag, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = TagColors.forTag(tag);

    return Container(
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
  }
}
