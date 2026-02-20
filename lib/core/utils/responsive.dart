import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Responsive breakpoints following common device widths.
///
/// - **mobile**: < 600px  (phones)
/// - **tablet**: 600–1023px (tablets, small laptops)
/// - **desktop**: ≥ 1024px (desktops, large laptops)
enum ScreenSize { mobile, tablet, desktop }

class Responsive {
  Responsive._();

  // ── Breakpoint thresholds ───────────────────────────────────────────
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;

  /// Minimum touch target size per WCAG 2.5.8 (Level AA) — 44×44 CSS px.
  static const double minTouchTarget = 44;

  // ── Queries ─────────────────────────────────────────────────────────
  static ScreenSize screenSize(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < mobileBreakpoint) return ScreenSize.mobile;
    if (width < tabletBreakpoint) return ScreenSize.tablet;
    return ScreenSize.desktop;
  }

  static bool isMobile(BuildContext context) =>
      screenSize(context) == ScreenSize.mobile;

  static bool isTablet(BuildContext context) =>
      screenSize(context) == ScreenSize.tablet;

  static bool isDesktop(BuildContext context) =>
      screenSize(context) == ScreenSize.desktop;

  static bool isMobileOrTablet(BuildContext context) =>
      screenSize(context) != ScreenSize.desktop;

  // ── Adaptive values ─────────────────────────────────────────────────

  /// Returns a value based on the current screen size.
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    required T desktop,
  }) {
    return switch (screenSize(context)) {
      ScreenSize.mobile => mobile,
      ScreenSize.tablet => tablet ?? desktop,
      ScreenSize.desktop => desktop,
    };
  }

  /// Content padding that scales with screen size.
  static EdgeInsets contentPadding(BuildContext context) {
    return switch (screenSize(context)) {
      ScreenSize.mobile => const EdgeInsets.all(12),
      ScreenSize.tablet => const EdgeInsets.all(16),
      ScreenSize.desktop => const EdgeInsets.all(24),
    };
  }

  /// Side panel width — returns 0 on mobile (uses drawer instead).
  static double sidePanelWidth(BuildContext context) {
    return switch (screenSize(context)) {
      ScreenSize.mobile => 0,
      ScreenSize.tablet => 240,
      ScreenSize.desktop => 280,
    };
  }
}
