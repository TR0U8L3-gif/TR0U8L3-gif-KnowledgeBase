import 'package:knowledge_base/core/utils/constants.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class TableOfContent extends StatelessWidget {
  const TableOfContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: navigationSize,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.all(SizePadding.base),
          child: const Text('On This Page').semiBold().muted(),
        ),
        const Divider(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(SizePadding.base),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TocItem(level: 1, title: 'Authentication API', isActive: true),
                _TocItem(level: 2, title: 'Overview'),
                _TocItem(level: 2, title: 'Authentication Flow'),
                _TocItem(level: 3, title: 'Initial Login', indent: 1),
                _TocItem(level: 3, title: 'Token Refresh', indent: 1),
                _TocItem(level: 2, title: 'Endpoints'),
                _TocItem(level: 3, title: 'POST /api/auth/login', indent: 1),
                _TocItem(level: 3, title: 'POST /api/auth/refresh', indent: 2),
                _TocItem(level: 3, title: 'POST /api/auth/logout', indent: 3),
                _TocItem(level: 3, title: 'GET /api/auth/me', indent: 4),
                _TocItem(level: 2, title: 'Security Considerations', isActive: true,),
                _TocItem(level: 4, title: 'Token Storage', indent: 1, isActive: true,),
                _TocItem(level: 4, title: 'Rate Limiting', indent: 2, isActive: true,),
                _TocItem(level: 4, title: 'Password Requirements', indent: 3, isActive: true,),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TocItem extends StatelessWidget {
  final int level;
  final String title;
  final int indent;
  final bool isActive;

  const _TocItem({
    required this.level,
    required this.title,
    this.indent = 0,
    this.isActive = false,
  }) : assert(indent >= 0, 'Indent must be non-negative');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indentScale = (level / 2);
    return TextButton(
      onPressed: () {},
      density: ButtonDensity.compact,
      child: Row(
        children: [
          AnimatedContainer(
            duration: AppDuration.short,
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
            child:
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14 - indentScale,
                    fontWeight: FontWeight.normal,
                    color: isActive
                        ? theme.colorScheme.primary
                        : theme.colorScheme.foreground,
                  ),
                ).withPadding(
                  padding: EdgeInsets.only(
                    left: indent * SizePadding.base,
                    top: SizePadding.small,
                    bottom: SizePadding.small,
                  ),
                ),
          ),
        ],
      ),
    );
  }
}
