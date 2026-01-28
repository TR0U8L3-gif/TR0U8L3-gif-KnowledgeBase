import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../widgets/directories_tree_widget.dart';
import '../widgets/center_panel_widget.dart';
import '../widgets/table_of_content_widget.dart';
import '../widgets/header_widget.dart';
import '../widgets/footer_widget.dart';

class KnowledgeBasePage extends StatefulWidget {
  const KnowledgeBasePage({super.key});

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
        HeaderWidget(
          onTapGithub: () {},
          onSelectTheme: (theme) {},
          onToggleSidePanel: _toggleLeftPanel,
          showSidePanel: _showLeftPanel,
        ),
        const Divider(),
      ],
      footers: [
        const Divider(),
        FooterWidget(
          currentPage: _currentPage,
          totalPages: _totalArticles,
          onPageChanged: (value) {
            setState(() {
              _currentPage = value;
            });
          },
        ),
      ],
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_showLeftPanel) ...[
            const DirectoriesTreeWidget(
              items: [
                DirTreeItem(
                  title: 'Getting Started',
                  children: [
                    DirTreeItem(title: 'Introduction'),
                    DirTreeItem(title: 'Installation'),
                    DirTreeItem(title: 'Quick Start'),
                  ],
                ),
                DirTreeItem(
                  title: 'API Documentation',
                  children: [
                    DirTreeItem(title: 'Authentication API'),
                    DirTreeItem(title: 'Payments API'),
                    DirTreeItem(
                      title: 'User Management',
                      children: [
                        DirTreeItem(title: 'Create User'),
                        DirTreeItem(title: 'Update User'),
                        DirTreeItem(
                          title: 'Delete User lorem ipsum se decoyntrum amet',
                        ),
                      ],
                    ),
                  ],
                ),
                DirTreeItem(
                  title: 'Architecture',
                  children: [
                    DirTreeItem(title: 'Overview'),
                    DirTreeItem(title: 'Data Flow'),
                    DirTreeItem(
                      title: 'Infrastructure',
                      children: [
                        DirTreeItem(title: 'Terraform Notes'),
                        DirTreeItem(
                          title: 'Runbooks',
                          children: [
                            DirTreeItem(title: 'On-Call Guide'),
                            DirTreeItem(title: 'Deployment'),
                          ],
                        ),
                      ],
                    ),
                    DirTreeItem(
                      title: 'Security',
                      children: [
                        DirTreeItem(title: 'Threat Model'),
                        DirTreeItem(title: 'Best Practices'),
                      ],
                    ),
                  ],
                ),
                DirTreeItem(
                  title: 'Guides',
                  children: [
                    DirTreeItem(title: 'Local Development'),
                    DirTreeItem(title: 'Testing Guide'),
                    DirTreeItem(title: 'Deployment Guide'),
                  ],
                ),
                DirTreeItem(
                  title: 'Operations',
                  children: [
                    DirTreeItem(title: 'Incident Template'),
                    DirTreeItem(title: 'Release Checklist'),
                    DirTreeItem(title: 'Monitoring'),
                  ],
                ),
              ],
            ),
            const VerticalDivider(),
          ],
          const Expanded(flex: 3, child: CenterPanelWidget()),
          const VerticalDivider(),
          TableOfContentWidget(
            activeItemIndex: 0,
            items: [
              TOCItem(title: 'Authentication API', heading: TOCHeading.h1),
              TOCItem(title: 'Overview', heading: TOCHeading.h2),
              TOCItem(title: 'Authentication Flow', heading: TOCHeading.h2),
              TOCItem(title: 'Initial Login', heading: TOCHeading.h3),
              TOCItem(title: 'Token Refresh', heading: TOCHeading.h1),
              TOCItem(title: 'Endpoints', heading: TOCHeading.h2),
              TOCItem(title: 'POST /api/auth/login', heading: TOCHeading.h3),
              TOCItem(title: 'POST /api/auth/refresh', heading: TOCHeading.h3),
              TOCItem(title: 'POST /api/auth/logout', heading: TOCHeading.h1),
              TOCItem(title: 'GET /api/auth/me', heading: TOCHeading.h2),
              TOCItem(title: 'Security Considerations', heading: TOCHeading.h3),
              TOCItem(title: 'Token Storage', heading: TOCHeading.h4),
              TOCItem(title: 'Rate Limiting', heading: TOCHeading.h5),
              TOCItem(
                title: 'Password Requirements lorem ipsum dolor sit',
                heading: TOCHeading.h6,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
