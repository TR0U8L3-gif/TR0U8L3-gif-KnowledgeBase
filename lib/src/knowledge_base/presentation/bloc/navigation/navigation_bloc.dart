import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/knowledge_base_item.dart';
import '../../../domain/repositories/knowledge_base_repository.dart';
import 'navigation_event.dart';
import 'navigation_state.dart';

/// Manages navigation state: tree structure, file selection, breadcrumb, pagination.
class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  final KnowledgeBaseRepository _repository;

  NavigationBloc({required KnowledgeBaseRepository repository})
    : _repository = repository,
      super(const NavigationState()) {
    on<LoadIndex>(_onLoadIndex);
    on<SelectFile>(_onSelectFile);
    on<SelectDirectory>(_onSelectDirectory);
    on<NavigateToBreadcrumb>(_onNavigateToBreadcrumb);
    on<ToggleSidePanel>(_onToggleSidePanel);
    on<ChangePage>(_onChangePage);
  }

  Future<void> _onLoadIndex(
    LoadIndex event,
    Emitter<NavigationState> emit,
  ) async {
    emit(state.copyWith(status: NavigationStatus.loading));

    try {
      final root = await _repository.loadIndex();
      final allFiles = _repository.getAllFiles(root);

      FileItem? firstFile;
      if (allFiles.isNotEmpty) {
        firstFile = allFiles.first;
      }

      final breadcrumb = firstFile != null
          ? _repository.computeBreadcrumb(root, firstFile.path)
          : <BreadcrumbEntry>[];

      emit(
        state.copyWith(
          status: NavigationStatus.loaded,
          rootDirectory: root,
          allFiles: allFiles,
          selectedFile: firstFile,
          breadcrumb: breadcrumb,
          currentPage: 1,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: NavigationStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onSelectFile(SelectFile event, Emitter<NavigationState> emit) {
    final root = state.rootDirectory;
    if (root == null) return;

    final file = _findFileByPath(root, event.filePath);
    if (file == null) return;

    final breadcrumb = _repository.computeBreadcrumb(root, event.filePath);
    final pageIndex = state.allFiles.indexWhere(
      (f) => f.path == event.filePath,
    );

    emit(
      state.copyWith(
        selectedFile: file,
        viewMode: ViewMode.file,
        clearSelectedDirectory: true,
        breadcrumb: breadcrumb,
        currentPage: pageIndex >= 0 ? pageIndex + 1 : state.currentPage,
      ),
    );
  }

  void _onSelectDirectory(
    SelectDirectory event,
    Emitter<NavigationState> emit,
  ) {
    final root = state.rootDirectory;
    if (root == null) return;

    final directory = _findDirectoryByPath(root, event.directoryPath);
    if (directory == null) return;

    final breadcrumb = _repository.computeBreadcrumb(root, event.directoryPath);

    emit(
      state.copyWith(
        selectedDirectory: directory,
        viewMode: ViewMode.directory,
        clearSelectedFile: true,
        breadcrumb: breadcrumb,
      ),
    );
  }

  void _onNavigateToBreadcrumb(
    NavigateToBreadcrumb event,
    Emitter<NavigationState> emit,
  ) {
    if (event.index >= 0 && event.index < state.breadcrumb.length) {
      final entry = state.breadcrumb[event.index];
      if (entry.isFile) {
        add(SelectFile(entry.path));
      } else {
        add(SelectDirectory(entry.path));
      }
    }
  }

  void _onToggleSidePanel(
    ToggleSidePanel event,
    Emitter<NavigationState> emit,
  ) {
    emit(state.copyWith(showSidePanel: !state.showSidePanel));
  }

  void _onChangePage(ChangePage event, Emitter<NavigationState> emit) {
    final page = event.page.clamp(1, state.totalFiles);
    if (page > 0 && page <= state.allFiles.length) {
      final file = state.allFiles[page - 1];
      add(SelectFile(file.path));
    }
  }

  FileItem? _findFileByPath(KnowledgeBaseItem item, String path) {
    if (item is FileItem && item.path == path) return item;
    if (item is DirectoryItem) {
      for (final child in item.items) {
        final found = _findFileByPath(child, path);
        if (found != null) return found;
      }
    }
    return null;
  }

  DirectoryItem? _findDirectoryByPath(KnowledgeBaseItem item, String path) {
    if (item is DirectoryItem) {
      if (item.path == path) return item;
      for (final child in item.items) {
        final found = _findDirectoryByPath(child, path);
        if (found != null) return found;
      }
    }
    return null;
  }
}
