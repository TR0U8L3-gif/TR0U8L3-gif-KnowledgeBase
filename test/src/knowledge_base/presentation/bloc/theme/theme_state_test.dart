import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/bloc/theme/theme_state.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

void main() {
  group('ThemeState', () {
    test('default themeMode is system', () {
      const state = ThemeState();
      expect(state.themeMode, ThemeMode.system);
    });

    test('can be constructed with explicit themeMode', () {
      const state = ThemeState(themeMode: ThemeMode.dark);
      expect(state.themeMode, ThemeMode.dark);
    });

    group('copyWith', () {
      test('copies themeMode', () {
        const state = ThemeState(themeMode: ThemeMode.system);
        final copy = state.copyWith(themeMode: ThemeMode.light);
        expect(copy.themeMode, ThemeMode.light);
      });

      test('preserves themeMode when not specified', () {
        const state = ThemeState(themeMode: ThemeMode.dark);
        final copy = state.copyWith();
        expect(copy.themeMode, ThemeMode.dark);
      });
    });

    group('Equatable', () {
      test('two states with same themeMode are equal', () {
        const s1 = ThemeState(themeMode: ThemeMode.light);
        const s2 = ThemeState(themeMode: ThemeMode.light);
        expect(s1, equals(s2));
      });

      test('two states with different themeMode are not equal', () {
        const s1 = ThemeState(themeMode: ThemeMode.light);
        const s2 = ThemeState(themeMode: ThemeMode.dark);
        expect(s1, isNot(equals(s2)));
      });

      test('default states are equal', () {
        expect(const ThemeState(), equals(const ThemeState()));
      });
    });
  });
}
