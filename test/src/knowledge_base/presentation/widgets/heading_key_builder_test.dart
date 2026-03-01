import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/widgets/_helpers/heading_key_builder.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:shadcn_flutter/shadcn_flutter.dart';

void main() {
  group('HeadingKeyBuilder', () {
    test('wraps headings with KeyedSubtree using provided keys', () {
      final keys = [GlobalKey(), GlobalKey(), GlobalKey()];
      final builder = HeadingKeyBuilder(headingKeys: keys);

      final element = md.Element('h1', [md.Text('Title')]);
      final style = const TextStyle(fontSize: 24);

      final widget0 = builder.visitElementAfter(element, style);
      expect(widget0, isA<KeyedSubtree>());
      expect((widget0 as KeyedSubtree).key, keys[0]);

      final widget1 = builder.visitElementAfter(element, style);
      expect(widget1, isA<KeyedSubtree>());
      expect((widget1 as KeyedSubtree).key, keys[1]);

      final widget2 = builder.visitElementAfter(element, style);
      expect(widget2, isA<KeyedSubtree>());
      expect((widget2 as KeyedSubtree).key, keys[2]);
    });

    test('returns plain Text when keys are exhausted', () {
      final keys = [GlobalKey()];
      final builder = HeadingKeyBuilder(headingKeys: keys);
      final element = md.Element('h2', [md.Text('A')]);
      final style = const TextStyle(fontSize: 20);

      // First call: uses the key
      final w0 = builder.visitElementAfter(element, style);
      expect(w0, isA<KeyedSubtree>());

      // Second call: no more keys, returns plain Text
      final w1 = builder.visitElementAfter(element, style);
      expect(w1, isA<Text>());
      expect(w1, isNot(isA<KeyedSubtree>()));
    });

    test('returns plain Text when headingKeys is null', () {
      final builder = HeadingKeyBuilder(headingKeys: null);
      final element = md.Element('h3', [md.Text('Heading')]);
      final style = const TextStyle(fontSize: 18);

      final widget = builder.visitElementAfter(element, style);
      expect(widget, isA<Text>());
      expect(widget, isNot(isA<KeyedSubtree>()));
    });

    test('reset() resets the internal heading index', () {
      final keys = [GlobalKey(), GlobalKey()];
      final builder = HeadingKeyBuilder(headingKeys: keys);
      final element = md.Element('h1', [md.Text('H')]);
      final style = const TextStyle(fontSize: 24);

      builder.visitElementAfter(element, style);
      builder.visitElementAfter(element, style);

      // Both keys consumed
      final w = builder.visitElementAfter(element, style);
      expect(w, isA<Text>());

      builder.reset();

      // After reset, keys are reused from index 0
      final w2 = builder.visitElementAfter(element, style);
      expect(w2, isA<KeyedSubtree>());
      expect((w2 as KeyedSubtree).key, keys[0]);
    });

    test('each KeyedSubtree child is a Text widget with correct style', () {
      final keys = [GlobalKey()];
      final builder = HeadingKeyBuilder(headingKeys: keys);
      final element = md.Element('h1', [md.Text('My Heading')]);
      final style = const TextStyle(fontSize: 32, fontWeight: FontWeight.bold);

      final widget = builder.visitElementAfter(element, style) as KeyedSubtree;
      final text = widget.child as Text;
      expect(text.data, 'My Heading');
      expect(text.style, style);
    });
  });
}
