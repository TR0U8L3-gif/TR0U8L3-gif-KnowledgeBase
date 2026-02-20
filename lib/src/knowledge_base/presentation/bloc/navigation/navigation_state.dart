import 'package:equatable/equatable.dart';

import '../../../domain/entities/knowledge_base_item.dart';
import '../../../domain/repositories/knowledge_base_repository.dart';

enum NavigationStatus { initial, loading, loaded, error }

/// What content type is currently displayed in the center panel.
enum ViewMode { file, directory }

final class NavigationState extends Equatable {
  final NavigationStatus status;
  final DirectoryItem? rootDirectory;
  final FileItem? selectedFile;
  final DirectoryItem? selectedDirectory;
  final ViewMode viewMode;
  final List<BreadcrumbEntry> breadcrumb;
  final List<FileItem> allFiles;
  final int currentPage;
  final bool showSidePanel;
  final bool showTocPanel;
  final String? errorMessage;

  const NavigationState({
    this.status = NavigationStatus.initial,
    this.rootDirectory,
    this.selectedFile,
    this.selectedDirectory,
    this.viewMode = ViewMode.file,
    this.breadcrumb = const [],
    this.allFiles = const [],
    this.currentPage = 1,
    this.showSidePanel = true,
    this.showTocPanel = true,
    this.errorMessage,
  });

  int get currentFileIndex {
    if (selectedFile == null || allFiles.isEmpty) return 1;
    final index = allFiles.indexWhere((f) => f.path == selectedFile!.path);
    return index >= 0 ? index + 1 : 1;
  }

  int get totalFiles => allFiles.length;

  NavigationState copyWith({
    NavigationStatus? status,
    DirectoryItem? rootDirectory,
    FileItem? selectedFile,
    DirectoryItem? selectedDirectory,
    ViewMode? viewMode,
    List<BreadcrumbEntry>? breadcrumb,
    List<FileItem>? allFiles,
    int? currentPage,
    bool? showSidePanel,
    bool? showTocPanel,
    String? errorMessage,
    bool clearSelectedFile = false,
    bool clearSelectedDirectory = false,
  }) {
    return NavigationState(
      status: status ?? this.status,
      rootDirectory: rootDirectory ?? this.rootDirectory,
      selectedFile: clearSelectedFile
          ? null
          : (selectedFile ?? this.selectedFile),
      selectedDirectory: clearSelectedDirectory
          ? null
          : (selectedDirectory ?? this.selectedDirectory),
      viewMode: viewMode ?? this.viewMode,
      breadcrumb: breadcrumb ?? this.breadcrumb,
      allFiles: allFiles ?? this.allFiles,
      currentPage: currentPage ?? this.currentPage,
      showSidePanel: showSidePanel ?? this.showSidePanel,
      showTocPanel: showTocPanel ?? this.showTocPanel,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    rootDirectory,
    selectedFile,
    selectedDirectory,
    viewMode,
    breadcrumb,
    allFiles,
    currentPage,
    showSidePanel,
    showTocPanel,
    errorMessage,
  ];
}
