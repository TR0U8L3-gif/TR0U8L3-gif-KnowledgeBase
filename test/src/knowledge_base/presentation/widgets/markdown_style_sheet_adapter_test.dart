import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/widgets/_helpers/markdown_style_sheet_adapter.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

void main() {
  Widget buildApp({required WidgetBuilder builder}) {
    return ShadcnApp(
      theme: ThemeData(colorScheme: ColorSchemes.darkZinc, radius: 0.5),
      home: Builder(builder: builder),
    );
  }

  group('shadcnMarkdownStyleSheet', () {
    testWidgets('returns a non-null MarkdownStyleSheet', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(
        buildApp(
          builder: (context) {
            capturedContext = context;
            return const SizedBox.shrink();
          },
        ),
      );
      await tester.pumpAndSettle();

      final sheet = shadcnMarkdownStyleSheet(capturedContext);
      expect(sheet, isNotNull);
    });

    testWidgets('maps heading styles from theme typography', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(
        buildApp(
          builder: (context) {
            capturedContext = context;
            return const SizedBox.shrink();
          },
        ),
      );
      await tester.pumpAndSettle();

      final sheet = shadcnMarkdownStyleSheet(capturedContext);
      final theme = Theme.of(capturedContext);

      // h1 should use the theme's h1 typography fontSize
      expect(sheet.h1?.fontSize, theme.typography.h1.fontSize);
      expect(sheet.h2?.fontSize, theme.typography.h2.fontSize);
      expect(sheet.h3?.fontSize, theme.typography.h3.fontSize);
    });

    testWidgets('maps link style to primary color', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(
        buildApp(
          builder: (context) {
            capturedContext = context;
            return const SizedBox.shrink();
          },
        ),
      );
      await tester.pumpAndSettle();

      final sheet = shadcnMarkdownStyleSheet(capturedContext);
      final theme = Theme.of(capturedContext);

      expect(sheet.a?.color, theme.colorScheme.primary);
      expect(sheet.a?.decoration, TextDecoration.underline);
    });

    testWidgets('maps blockquote decoration with primary border', (
      tester,
    ) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(
        buildApp(
          builder: (context) {
            capturedContext = context;
            return const SizedBox.shrink();
          },
        ),
      );
      await tester.pumpAndSettle();

      final sheet = shadcnMarkdownStyleSheet(capturedContext);
      final theme = Theme.of(capturedContext);
      final decoration = sheet.blockquoteDecoration as BoxDecoration;
      final border = decoration.border as Border;

      expect(border.left.color, theme.colorScheme.primary);
      expect(border.left.width, 3);
    });

    testWidgets('maps code block decoration with border color', skip: true, (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(
        buildApp(
          builder: (context) {
            capturedContext = context;
            return const SizedBox.shrink();
          },
        ),
      );
      await tester.pumpAndSettle();

      final sheet = shadcnMarkdownStyleSheet(capturedContext);
      final theme = Theme.of(capturedContext);
      final decoration = sheet.codeblockDecoration as BoxDecoration;
      final border = decoration.border as Border;

      expect(border.top.color, theme.colorScheme.border);
    });

    testWidgets('table styles use theme border and scaling', skip: true, (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(
        buildApp(
          builder: (context) {
            capturedContext = context;
            return const SizedBox.shrink();
          },
        ),
      );
      await tester.pumpAndSettle();

      final sheet = shadcnMarkdownStyleSheet(capturedContext);
      final theme = Theme.of(capturedContext);

      expect(sheet.tableHead?.fontWeight, FontWeight.w600);
      expect(sheet.tableHead?.fontSize, 13 * theme.scaling);
      expect(sheet.tableBody?.fontSize, 13 * theme.scaling);
    });
  });
}
