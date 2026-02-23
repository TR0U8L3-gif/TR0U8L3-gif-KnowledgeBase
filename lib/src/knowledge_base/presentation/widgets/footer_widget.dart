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
    final isMobileOrSmaller = Responsive.isMobileOrSmaller(context);
    final isPhone = Responsive.isPhone(context);

    return Semantics(
      label: 'Page navigation, page $currentPage of $totalPages',
      child: AppBar(
        height: 36,
        padding: isMobileOrSmaller
            ? EdgeInsets.all(8)
            : null,
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Pagination(
              page: currentPage,
              totalPages: totalPages,
              maxPages: isPhone
                  ? 1
                  : isMobileOrSmaller
                  ? 2
                  : 3,
              gap: 8,
              onPageChanged: onPageChanged,
              showSkipToFirstPage: !isMobileOrSmaller,
              showSkipToLastPage: !isMobileOrSmaller,
            ),
          ),
        ),
      ),
    );
  }
}
