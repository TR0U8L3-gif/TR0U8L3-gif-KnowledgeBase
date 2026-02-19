sealed class DocumentEvent {
  const DocumentEvent();
}

/// Loads a markdown document from the given [path].
final class LoadDocument extends DocumentEvent {
  final String path;
  const LoadDocument(this.path);
}

/// Clears the currently loaded document.
final class ClearDocument extends DocumentEvent {
  const ClearDocument();
}
