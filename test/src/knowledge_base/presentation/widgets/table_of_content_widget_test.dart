import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/widgets/table_of_content_widget.dart';

void main() {
  group('TOCHeading', () {
    group('fromLevel', () {
      test('returns h1 for level 1', () {
        expect(TOCHeading.fromLevel(1), TOCHeading.h1);
      });

      test('returns h2 for level 2', () {
        expect(TOCHeading.fromLevel(2), TOCHeading.h2);
      });

      test('returns h3 for level 3', () {
        expect(TOCHeading.fromLevel(3), TOCHeading.h3);
      });

      test('returns h4 for level 4', () {
        expect(TOCHeading.fromLevel(4), TOCHeading.h4);
      });

      test('returns h5 for level 5', () {
        expect(TOCHeading.fromLevel(5), TOCHeading.h5);
      });

      test('returns h6 for level 6', () {
        expect(TOCHeading.fromLevel(6), TOCHeading.h6);
      });

      test('returns h1 for invalid level (0)', () {
        expect(TOCHeading.fromLevel(0), TOCHeading.h1);
      });

      test('returns h1 for level > 6', () {
        expect(TOCHeading.fromLevel(7), TOCHeading.h1);
      });

      test('returns h1 for negative level', () {
        expect(TOCHeading.fromLevel(-1), TOCHeading.h1);
      });
    });

    group('level property', () {
      test('each enum value has the correct level', () {
        expect(TOCHeading.h1.level, 1);
        expect(TOCHeading.h2.level, 2);
        expect(TOCHeading.h3.level, 3);
        expect(TOCHeading.h4.level, 4);
        expect(TOCHeading.h5.level, 5);
        expect(TOCHeading.h6.level, 6);
      });
    });
  });

  group('TOCItem', () {
    test('stores title and heading', () {
      const item = TOCItem(title: 'Overview', heading: TOCHeading.h2);
      expect(item.title, 'Overview');
      expect(item.heading, TOCHeading.h2);
    });
  });
}
