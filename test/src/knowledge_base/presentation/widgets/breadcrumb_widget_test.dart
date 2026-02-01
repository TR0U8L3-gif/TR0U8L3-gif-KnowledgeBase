import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/widgets/breadcrumb_widget.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

void main() {
  Widget buildTestWidget({
    required List<String> items,
    double? width,
    void Function(int)? onItemTapped,
  }) {
    final widget = BreadcrumbWidget(items: items, onItemTapped: onItemTapped);

    return ShadcnApp(
      title: 'Test',
      home: Scaffold(
        child: width != null ? SizedBox(width: width, child: widget) : widget,
      ),
    );
  }

  group('BreadcrumbWidget', () {
    testWidgets('renders nothing when items list is empty', (tester) async {
      await tester.pumpWidget(buildTestWidget(items: []));
      await tester.pumpAndSettle();

      expect(find.byType(Text), findsNothing);
      expect(find.byIcon(RadixIcons.chevronRight), findsNothing);
    });

    testWidgets('renders single item as text without button', (tester) async {
      await tester.pumpWidget(buildTestWidget(items: ['Home']));
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.byType(TextButton), findsNothing);
    });

    testWidgets(
      'renders multiple items with separators and clickable buttons',
      (tester) async {
        int? tappedIndex;
        await tester.pumpWidget(
          buildTestWidget(
            items: ['A', 'B', 'C'],
            width: 600,
            onItemTapped: (index) => tappedIndex = index,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(Text), findsNWidgets(3));
        expect(find.byIcon(RadixIcons.chevronRight), findsNWidgets(2));
        expect(find.byType(TextButton), findsNWidgets(2));

        await tester.tap(find.byType(TextButton).first);
        await tester.pumpAndSettle();
        expect(tappedIndex, equals(0));
      },
    );

    testWidgets('shows ellipsis and hides middle items when space is limited', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(
          items: [
            'Home',
            'Folder1',
            'Folder2',
            'Folder3',
            'Folder4',
            'CurrentPage',
          ],
          width: 220,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('CurrentPage'), findsOneWidget);
      expect(find.text('...'), findsOneWidget);
    });

    testWidgets('two items that do not fit show ellipsis and last only', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(
          items: ['VeryLongFirstItemName', 'VeryLongSecondItemName'],
          width: 120,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('VeryLongSecondItemName'), findsOneWidget);
      expect(find.text('...'), findsOneWidget);
      expect(find.text('VeryLongFirstItemName'), findsNothing);
    });

    testWidgets('handles many items and narrow widths gracefully', (
      tester,
    ) async {
      final items = List.generate(10, (i) => 'Item$i');
      await tester.pumpWidget(buildTestWidget(items: items, width: 300));
      await tester.pumpAndSettle();

      expect(find.text('Item9'), findsOneWidget);
      expect(find.text('...'), findsOneWidget);
    });

    testWidgets('replaces middle items with ellipsis progressively', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(
          items: [
            'First',
            'SecondMiddle',
            'ThirdMiddle',
            'FourthMiddle',
            'Last',
          ],
          width: 250,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('First'), findsOneWidget);
      expect(find.text('Last'), findsOneWidget);
    });

    testWidgets('updates correctly when items change', (tester) async {
      await tester.pumpWidget(buildTestWidget(items: ['A', 'B'], width: 400));
      await tester.pumpAndSettle();
      expect(find.text('A'), findsOneWidget);

      await tester.pumpWidget(
        buildTestWidget(items: ['X', 'Y', 'Z'], width: 400),
      );
      await tester.pumpAndSettle();
      expect(find.text('A'), findsNothing);
      expect(find.text('X'), findsOneWidget);
    });
  });
}
