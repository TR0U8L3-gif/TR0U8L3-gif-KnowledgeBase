import 'package:knowledge_base/core/utils/responsive.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class FooterWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  const FooterWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Semantics(
      label: 'Page navigation, page $currentPage of $totalPages',
      child: AppBar(
        height: 36,
        child: Center(
          child: Pagination(
            page: currentPage,
            totalPages: totalPages,
            maxPages: isMobile ? 1 : 3,
            gap: isMobile ? 4 : 8,
            onPageChanged: onPageChanged,
          ),
        ),
      ),
    );
  }
}
