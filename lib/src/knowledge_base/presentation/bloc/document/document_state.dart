import 'package:equatable/equatable.dart';

import '../../../domain/entities/document_content.dart';

enum DocumentStatus { initial, loading, loaded, error }

final class DocumentState extends Equatable {
  final DocumentStatus status;
  final DocumentContent? content;
  final String? currentPath;
  final String? errorMessage;

  const DocumentState({
    this.status = DocumentStatus.initial,
    this.content,
    this.currentPath,
    this.errorMessage,
  });

  DocumentState copyWith({
    DocumentStatus? status,
    DocumentContent? content,
    String? currentPath,
    String? errorMessage,
  }) {
    return DocumentState(
      status: status ?? this.status,
      content: content ?? this.content,
      currentPath: currentPath ?? this.currentPath,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, content, currentPath, errorMessage];
}
