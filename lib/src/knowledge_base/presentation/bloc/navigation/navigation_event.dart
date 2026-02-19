sealed class NavigationEvent {
  const NavigationEvent();
}

/// Triggered on app start to load the index.json file.
final class LoadIndex extends NavigationEvent {
  const LoadIndex();
}

/// Triggered when a file is selected in the tree or via pagination.
final class SelectFile extends NavigationEvent {
  final String filePath;
  const SelectFile(this.filePath);
}

/// Triggered when a breadcrumb directory entry is tapped.
final class NavigateToBreadcrumb extends NavigationEvent {
  final int index;
  const NavigateToBreadcrumb(this.index);
}

/// Toggles the left side panel visibility.
final class ToggleSidePanel extends NavigationEvent {
  const ToggleSidePanel();
}

/// Changes the current pagination page.
final class ChangePage extends NavigationEvent {
  final int page;
  const ChangePage(this.page);
}
