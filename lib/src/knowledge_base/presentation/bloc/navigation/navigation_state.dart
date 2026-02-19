import 'package:equatable/equatable.dart';

import '../../../domain/entities/knowledge_base_item.dart';
import '../../../domain/repositories/knowledge_base_repository.dart';

enum NavigationStatus { initial, loading, loaded, error }

final class NavigationState extends Equatable {
  final NavigationStatus status;
  final DirectoryItem? rootDirectory;
  final FileItem? selectedFile;
  final List<BreadcrumbEntry> breadcrumb;
  final List<FileItem> allFiles;
  final int currentPage;
  final bool showSidePanel;
  final String? errorMessage;

  const NavigationState({
    this.status = NavigationStatus.initial,
    this.rootDirectory,
    this.selectedFile,
    this.breadcrumb = const [],
    this.allFiles = const [],
    this.currentPage = 1,
    this.showSidePanel = true,
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
    List<BreadcrumbEntry>? breadcrumb,
    List<FileItem>? allFiles,
    int? currentPage,
    bool? showSidePanel,
    String? errorMessage,
  }) {
    return NavigationState(
      status: status ?? this.status,
      rootDirectory: rootDirectory ?? this.rootDirectory,
      selectedFile: selectedFile ?? this.selectedFile,
      breadcrumb: breadcrumb ?? this.breadcrumb,
      allFiles: allFiles ?? this.allFiles,
      currentPage: currentPage ?? this.currentPage,
      showSidePanel: showSidePanel ?? this.showSidePanel,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    rootDirectory,
    selectedFile,
    breadcrumb,
    allFiles,
    currentPage,
    showSidePanel,
    errorMessage,
  ];
}
