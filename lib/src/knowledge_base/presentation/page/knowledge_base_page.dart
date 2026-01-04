import 'package:shadcn_flutter/shadcn_flutter.dart';

class KnowledgeBasePage extends StatefulWidget {
  const KnowledgeBasePage({Key? key}) : super(key: key);

  @override
  _KnowledgeBasePageState createState() => _KnowledgeBasePageState();
}

class _KnowledgeBasePageState extends State<KnowledgeBasePage> {
  bool _showLeftPanel = true;
  int _currentPage = 1;
  final int _totalArticles = 15;

  void _toggleLeftPanel() {
    setState(() {
      _showLeftPanel = !_showLeftPanel;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [
        AppBar(
          title: const Text('Knowledge Base'),
          leading: [
            OutlineButton(
              onPressed: _toggleLeftPanel,
              density: ButtonDensity.icon,
              child: Icon(
                _showLeftPanel
                    ? BootstrapIcons.layoutSidebarInset
                    : BootstrapIcons.layoutSidebar,
              ),
            ),
          ],
          trailing: [
            OutlineButton(
              onPressed: () {},
              density: ButtonDensity.icon,
              child: const Icon(BootstrapIcons.search),
            ),
            OutlineButton(
              onPressed: () {},
              density: ButtonDensity.icon,
              child: const Icon(BootstrapIcons.sunFill),
            ),
            OutlineButton(
              onPressed: () {},
              density: ButtonDensity.icon,
              child: const Icon(BootstrapIcons.circleFill),
            ),
          ],
        ),
        const Divider(),
      ],
      footers: [
        const Divider(),
        AppBar(
          height: 36,
          child: Center(
            child: Pagination(
              page: _currentPage,
              totalPages: _totalArticles,
              maxPages: 3,
              gap: 8,
              onPageChanged: (value) {
                setState(() {
                  _currentPage = value;
                });
              },
            ),
          ),
        ),
      ],
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_showLeftPanel) ...[
            const LeftPanelWidget(),
            const VerticalDivider(),
          ],
          const Expanded(flex: 3, child: CenterPanelWidget()),
          const VerticalDivider(),
          const SizedBox(width: 250, child: RightPanelWidget()),
        ],
      ),
    );
  }
}

// Left Panel - Folder Structure
class LeftPanelWidget extends StatefulWidget {
  const LeftPanelWidget({super.key});

  @override
  State<LeftPanelWidget> createState() => _LeftPanelWidgetState();
}

class _LeftPanelWidgetState extends State<LeftPanelWidget> {
  List<TreeNode<String>> treeItems = [
    TreeItem(
      data: 'Getting Started',
      expanded: true,
      children: [
        TreeItem(data: 'Introduction'),
        TreeItem(data: 'Installation'),
        TreeItem(data: 'Quick Start'),
      ],
    ),
    TreeItem(
      data: 'API Documentation',
      expanded: true,
      children: [
        TreeItem(data: 'Authentication API'),
        TreeItem(data: 'Payments API'),
        TreeItem(
          data: 'User Management',
          children: [
            TreeItem(data: 'Create User'),
            TreeItem(data: 'Update User'),
            TreeItem(data: 'Delete User'),
          ],
        ),
      ],
    ),
    TreeItem(
      data: 'Architecture',
      children: [
        TreeItem(data: 'Overview'),
        TreeItem(data: 'Data Flow'),
        TreeItem(
          data: 'Infrastructure',
          children: [
            TreeItem(data: 'Terraform Notes'),
            TreeItem(
              data: 'Runbooks',
              children: [
                TreeItem(data: 'On-Call Guide'),
                TreeItem(data: 'Deployment'),
              ],
            ),
          ],
        ),
        TreeItem(
          data: 'Security',
          children: [
            TreeItem(data: 'Threat Model'),
            TreeItem(data: 'Best Practices'),
          ],
        ),
      ],
    ),
    TreeItem(
      data: 'Guides',
      children: [
        TreeItem(data: 'Local Development'),
        TreeItem(data: 'Testing Guide'),
        TreeItem(data: 'Deployment Guide'),
      ],
    ),
    TreeItem(
      data: 'Operations',
      children: [
        TreeItem(data: 'Incident Template'),
        TreeItem(data: 'Release Checklist'),
        TreeItem(data: 'Monitoring'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            height: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Documentation').semiBold(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlineButton(
                      onPressed: () {
                        setState(() {
                          treeItems = treeItems.expandAll();
                        });
                      },
                      density: ButtonDensity.icon,
                      child: const Icon(BootstrapIcons.arrowsExpand, size: 14),
                    ),
                    const Gap(4),
                    OutlineButton(
                      onPressed: () {
                        setState(() {
                          treeItems = treeItems.collapseAll();
                        });
                      },
                      density: ButtonDensity.icon,
                      child: const Icon(BootstrapIcons.arrowsCollapse, size: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: TreeView(
              nodes: treeItems,
              onSelectionChanged: TreeView.defaultSelectionHandler(
                treeItems,
                (value) {
                  setState(() {
                    treeItems = value;
                  });
                },
              ),
              builder: (context, node) {
                return TreeItemView(
                  onPressed: () {},
                  leading: node.leaf
                      ? const Icon(BootstrapIcons.fileText, size: 16)
                      : Icon(
                          node.expanded
                              ? BootstrapIcons.folder2Open
                              : BootstrapIcons.folder2,
                          size: 16,
                        ),
                  onExpand: TreeView.defaultItemExpandHandler(
                    treeItems,
                    node,
                    (value) {
                      setState(() {
                        treeItems = value;
                      });
                    },
                  ),
                  child: Text(node.data),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Center Panel - Article Content
class CenterPanelWidget extends StatelessWidget {
  const CenterPanelWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 48,
          alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Breadcrumb(
            separator: Breadcrumb.arrowSeparator,
            children: [
              TextButton(
                onPressed: () {},
                density: ButtonDensity.compact,
                child: const Text('Home'),
              ),
              TextButton(
                onPressed: () {},
                density: ButtonDensity.compact,
                child: const Text('API Documentation'),
              ),
              const Text('Authentication API'),
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Authentication API').h1(),
                const Gap(8),
                const Text('Last updated: January 4, 2026').muted().small(),
                const Gap(24),
                const Text(
                  'Authentication endpoints including login, refresh, logout and user information retrieval.',
                ).lead(),
                const Gap(32),
                const Text('Overview').h2(),
                const Gap(12),
                const Text(
                  'The Authentication API provides a comprehensive set of endpoints for managing user authentication and sessions. '
                  'It supports JWT-based authentication with refresh token rotation and secure session management.',
                ).p(),
                const Gap(16),
                const Text(
                  'All endpoints require HTTPS and return JSON responses. Authentication tokens are issued as HTTP-only cookies '
                  'for enhanced security.',
                ).p(),
                const Gap(32),
                const Text('Authentication Flow').h2(),
                const Gap(12),
                const Text('Initial Login').h3(),
                const Gap(8),
                const Text(
                  '1. User submits credentials to /api/auth/login\n'
                  '2. Server validates credentials\n'
                  '3. Server issues access token (15min) and refresh token (7 days)\n'
                  '4. Tokens stored as HTTP-only cookies',
                ).p(),
                const Gap(24),
                const Text('Token Refresh').h3(),
                const Gap(8),
                const Text(
                  'Access tokens expire after 15 minutes. The client should monitor the token expiration '
                  'and request a new access token using the refresh token before expiration.',
                ).p(),
                const Gap(32),
                const Text('Endpoints').h2(),
                const Gap(12),
                const Text('POST /api/auth/login').h3(),
                const Gap(8),
                const Text('Authenticate a user and receive tokens.').p(),
                const Gap(8),
                OutlinedContainer(
                  child: const Text(
                    '{\n'
                    '  "email": "user@example.com",\n'
                    '  "password": "secure_password"\n'
                    '}',
                  ).p(),
                ),
                const Gap(24),
                const Text('POST /api/auth/refresh').h3(),
                const Gap(8),
                const Text('Refresh an expired access token.').p(),
                const Gap(24),
                const Text('POST /api/auth/logout').h3(),
                const Gap(8),
                const Text(
                  'Invalidate the current session and clear authentication cookies.',
                ).p(),
                const Gap(24),
                const Text('GET /api/auth/me').h3(),
                const Gap(8),
                const Text(
                  'Retrieve the currently authenticated user information.',
                ).p(),
                const Gap(32),
                const Text('Security Considerations').h2(),
                const Gap(12),
                const Text('Token Storage').h4(),
                const Gap(8),
                const Text(
                  'Tokens are stored as HTTP-only cookies to prevent XSS attacks. The SameSite attribute '
                  'is set to Strict to prevent CSRF attacks.',
                ).p(),
                const Gap(16),
                const Text('Rate Limiting').h4(),
                const Gap(8),
                const Text(
                  'Login attempts are rate-limited to 5 attempts per 15 minutes per IP address. '
                  'After exceeding the limit, the IP is temporarily blocked.',
                ).p(),
                const Gap(16),
                const Text('Password Requirements').h4(),
                const Gap(8),
                const Text(
                  'Passwords must be at least 12 characters long and include uppercase, lowercase, '
                  'numbers, and special characters.',
                ).p(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Right Panel - Table of Contents
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
          child: const Text(
            'On This Page',
          ).semiBold()
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
