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
          const SizedBox(width: 250, child: TableOfContent()),
        ],
      ),
    );
  }
}
