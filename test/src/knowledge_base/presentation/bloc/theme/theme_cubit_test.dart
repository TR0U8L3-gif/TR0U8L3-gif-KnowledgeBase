import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/bloc/theme/theme_cubit.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/bloc/theme/theme_state.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

void main() {
  group('ThemeCubit', () {
    ThemeCubit buildCubit() => ThemeCubit();

    group('initial state', () {
      test('is ThemeState with ThemeMode.system', () {
        expect(
          buildCubit().state,
          const ThemeState(themeMode: ThemeMode.system),
        );
      });
    });

    group('setThemeMode', () {
      blocTest<ThemeCubit, ThemeState>(
        'emits state with ThemeMode.light',
        build: buildCubit,
        act: (cubit) => cubit.setThemeMode(ThemeMode.light),
        expect: () => [const ThemeState(themeMode: ThemeMode.light)],
      );

      blocTest<ThemeCubit, ThemeState>(
        'emits state with ThemeMode.dark',
        build: buildCubit,
        act: (cubit) => cubit.setThemeMode(ThemeMode.dark),
        expect: () => [const ThemeState(themeMode: ThemeMode.dark)],
      );

      blocTest<ThemeCubit, ThemeState>(
        'emits state with ThemeMode.system',
        build: buildCubit,
        seed: () => const ThemeState(themeMode: ThemeMode.dark),
        act: (cubit) => cubit.setThemeMode(ThemeMode.system),
        expect: () => [const ThemeState(themeMode: ThemeMode.system)],
      );

      blocTest<ThemeCubit, ThemeState>(
        'does not emit when mode is null',
        build: buildCubit,
        act: (cubit) => cubit.setThemeMode(null),
        expect: () => <ThemeState>[],
      );

      blocTest<ThemeCubit, ThemeState>(
        'can toggle between light and dark multiple times',
        build: buildCubit,
        act: (cubit) {
          cubit.setThemeMode(ThemeMode.light);
          cubit.setThemeMode(ThemeMode.dark);
          cubit.setThemeMode(ThemeMode.light);
        },
        expect: () => [
          const ThemeState(themeMode: ThemeMode.light),
          const ThemeState(themeMode: ThemeMode.dark),
          const ThemeState(themeMode: ThemeMode.light),
        ],
      );
    });
  });
}
