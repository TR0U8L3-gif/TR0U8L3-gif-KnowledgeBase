import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/bloc/navigation/navigation_event.dart';

void main() {
  group('NavigationEvent', () {
    group('LoadIndex', () {
      test('can be instantiated as const', () {
        const event = LoadIndex();
        expect(event, isA<LoadIndex>());
        expect(event, isA<NavigationEvent>());
      });
    });

    group('SelectFile', () {
      test('stores filePath', () {
        const event = SelectFile('api/auth.md');
        expect(event.filePath, 'api/auth.md');
        expect(event, isA<NavigationEvent>());
      });
    });

    group('SelectDirectory', () {
      test('stores directoryPath', () {
        const event = SelectDirectory('api');
        expect(event.directoryPath, 'api');
        expect(event, isA<NavigationEvent>());
      });
    });

    group('NavigateToBreadcrumb', () {
      test('stores index', () {
        const event = NavigateToBreadcrumb(2);
        expect(event.index, 2);
        expect(event, isA<NavigationEvent>());
      });
    });

    group('ToggleSidePanel', () {
      test('can be instantiated as const', () {
        const event = ToggleSidePanel();
        expect(event, isA<NavigationEvent>());
      });
    });

    group('ToggleTocPanel', () {
      test('can be instantiated as const', () {
        const event = ToggleTocPanel();
        expect(event, isA<NavigationEvent>());
      });
    });

    group('ChangePage', () {
      test('stores page', () {
        const event = ChangePage(3);
        expect(event.page, 3);
        expect(event, isA<NavigationEvent>());
      });
    });
  });
}
