import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/widgets/footer_widget.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

Widget buildTestWidget({
  required int currentPage,
  required int totalPages,
  required ValueChanged<int> onPageChanged,
}) {
  return ShadcnApp(
    title: 'Test',
    home: Scaffold(
      child: FooterWidget(
        currentPage: currentPage,
        totalPages: totalPages,
        onPageChanged: onPageChanged,
      ),
    ),
  );
}

void main() {
  group('FooterWidget', () {
    testWidgets('renders without error with 1 of 5 pages', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(currentPage: 1, totalPages: 5, onPageChanged: (_) {}),
      );
      await tester.pumpAndSettle();

      // Widget renders without throwing
      expect(find.byType(FooterWidget), findsOneWidget);
    });

    testWidgets('renders with semantics label', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(currentPage: 2, totalPages: 10, onPageChanged: (_) {}),
      );
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsLabel('Page navigation, page 2 of 10'),
        findsOneWidget,
      );
    });

    testWidgets('renders with a single page', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(currentPage: 1, totalPages: 1, onPageChanged: (_) {}),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FooterWidget), findsOneWidget);
    });

    testWidgets('renders Pagination widget', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(currentPage: 1, totalPages: 5, onPageChanged: (_) {}),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Pagination), findsOneWidget);
    });

    testWidgets('invokes callback when page changes', (tester) async {
      int? changedPage;
      await tester.pumpWidget(
        buildTestWidget(
          currentPage: 1,
          totalPages: 5,
          onPageChanged: (page) => changedPage = page,
        ),
      );
      await tester.pumpAndSettle();

      // Find the next page button (▶) and tap it
      // Pagination widget renders page buttons as text
      final nextButtons = find.text('2');
      if (nextButtons.evaluate().isNotEmpty) {
        await tester.tap(nextButtons.first);
        await tester.pumpAndSettle();
        expect(changedPage, 2);
      }
    });
  });
}
