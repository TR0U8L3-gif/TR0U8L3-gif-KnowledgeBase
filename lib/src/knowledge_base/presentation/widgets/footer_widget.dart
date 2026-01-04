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
    return AppBar(
      height: 36,
      child: Center(
        child: Pagination(
          page: currentPage,
          totalPages: totalPages,
          maxPages: 3,
          gap: 8,
          onPageChanged: onPageChanged,
        ),
      ),
    );
  }
}
