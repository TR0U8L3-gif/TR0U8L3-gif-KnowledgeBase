import 'package:shadcn_flutter/shadcn_flutter.dart';

class RightPanelWidget extends StatelessWidget {
  const RightPanelWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 48,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.all(12),
          child: const Text('On This Page').semiBold(),
        ),
        const Divider(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                _TocItem(level: 3, title: 'POST /api/auth/refresh', indent: 1),
                _TocItem(level: 3, title: 'POST /api/auth/logout', indent: 1),
                _TocItem(level: 3, title: 'GET /api/auth/me', indent: 1),
                _TocItem(level: 2, title: 'Security Considerations'),
                _TocItem(level: 4, title: 'Token Storage', indent: 2),
                _TocItem(level: 4, title: 'Rate Limiting', indent: 2),
                _TocItem(level: 4, title: 'Password Requirements', indent: 2),
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
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextButton(
      onPressed: () {},
      density: ButtonDensity.compact,
      child: Row(
        children: [
          if (isActive)
            Container(
              width: 2,
              height: 16,
              color: theme.colorScheme.primary,
              margin: const EdgeInsets.only(right: 8),
            ),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: level == 1 ? 13 : 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.foreground,
              ),
            ),
          ),
        ],
      ),
    ).withPadding(
      padding: EdgeInsets.only(left: indent * 12.0, top: 4, bottom: 4),
    );
  }
}
