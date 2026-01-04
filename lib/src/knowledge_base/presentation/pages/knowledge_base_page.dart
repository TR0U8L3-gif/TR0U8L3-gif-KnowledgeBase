import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../widgets/left_panel_widget.dart';
import '../widgets/center_panel_widget.dart';
import '../widgets/table_of_content.dart';
import '../widgets/header_widget.dart';
import '../widgets/footer_widget.dart';

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
        HeaderWidget(
          onToggleLeftPanel: _toggleLeftPanel,
          showLeftPanel: _showLeftPanel,
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
            const LeftPanelWidget(),
            const VerticalDivider(),
          ],
          const Expanded(flex: 3, child: CenterPanelWidget()),
          const VerticalDivider(),
          const SizedBox(
            width: 250,
            child: TableOfContent(
              activeItemIndex: 0,
              items: [
                TOCItem(title: 'Authentication API', heading: TOCHeading.h1),
                TOCItem(title: 'Overview', heading: TOCHeading.h2),
                TOCItem(title: 'Authentication Flow', heading: TOCHeading.h2),
                TOCItem(title: 'Initial Login', heading: TOCHeading.h3),
                TOCItem(title: 'Token Refresh', heading: TOCHeading.h1),
                TOCItem(title: 'Endpoints', heading: TOCHeading.h2),
                TOCItem(title: 'POST /api/auth/login', heading: TOCHeading.h3),
                TOCItem(
                  title: 'POST /api/auth/refresh',
                  heading: TOCHeading.h3,
                ),
                TOCItem(title: 'POST /api/auth/logout', heading: TOCHeading.h1),
                TOCItem(title: 'GET /api/auth/me', heading: TOCHeading.h2),
                TOCItem(
                  title: 'Security Considerations',
                  heading: TOCHeading.h3,
                ),
                TOCItem(title: 'Token Storage', heading: TOCHeading.h4),
                TOCItem(title: 'Rate Limiting', heading: TOCHeading.h5),
                TOCItem(title: 'Password Requirements', heading: TOCHeading.h6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
