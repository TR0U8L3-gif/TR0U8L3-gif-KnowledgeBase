import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Deterministic tag-to-color mapping using a curated shadcn palette.
class TagColors {
  TagColors._();

  static final _palette = <Color>[
    Colors.red.shade300,
    Colors.red.shade500,
    Colors.red.shade700,
    Colors.orange.shade300,
    Colors.orange.shade500,
    Colors.orange.shade700,
    Colors.amber.shade300,
    Colors.amber.shade500,
    Colors.amber.shade700,
    Colors.yellow.shade300,
    Colors.yellow.shade500,
    Colors.yellow.shade700,
    Colors.lime.shade300,
    Colors.lime.shade500,
    Colors.lime.shade700,
    Colors.green.shade300,
    Colors.green.shade500,
    Colors.green.shade700,
    Colors.emerald.shade300,
    Colors.emerald.shade500,
    Colors.emerald.shade700,
    Colors.teal.shade300,
    Colors.teal.shade500,
    Colors.teal.shade700,
    Colors.cyan.shade300,
    Colors.cyan.shade500,
    Colors.cyan.shade700,
    Colors.sky.shade300,
    Colors.sky.shade500,
    Colors.sky.shade700,
    Colors.blue.shade300,
    Colors.blue.shade500,
    Colors.blue.shade700,
    Colors.indigo.shade300,
    Colors.indigo.shade500,
    Colors.indigo.shade700,
    Colors.violet.shade300,
    Colors.violet.shade500,
    Colors.violet.shade700,
    Colors.purple.shade300,
    Colors.purple.shade500,
    Colors.purple.shade700,
    Colors.fuchsia.shade300,
    Colors.fuchsia.shade500,
    Colors.fuchsia.shade700,
    Colors.pink.shade300,
    Colors.pink.shade500,
    Colors.pink.shade700,
    Colors.rose.shade300,
    Colors.rose.shade500,
    Colors.rose.shade700,
  ];

  /// Returns a deterministic color for the given [tag] based on its code-unit
  /// sum modulo the palette length.
  static Color forTag(String tag) {
    final hash = tag.codeUnits.fold<int>(0, (sum, unit) => sum + unit);
    return _palette[hash % _palette.length];
  }
}
