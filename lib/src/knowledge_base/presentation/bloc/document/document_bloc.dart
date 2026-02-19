import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/knowledge_base_repository.dart';
import 'document_event.dart';
import 'document_state.dart';

/// Manages the state of the currently loaded document.
class DocumentBloc extends Bloc<DocumentEvent, DocumentState> {
  final KnowledgeBaseRepository _repository;

  DocumentBloc({required KnowledgeBaseRepository repository})
    : _repository = repository,
      super(const DocumentState()) {
    on<LoadDocument>(_onLoadDocument);
    on<ClearDocument>(_onClearDocument);
  }

  Future<void> _onLoadDocument(
    LoadDocument event,
    Emitter<DocumentState> emit,
  ) async {
    if (state.currentPath == event.path &&
        state.status == DocumentStatus.loaded) {
      return;
    }

    emit(
      state.copyWith(status: DocumentStatus.loading, currentPath: event.path),
    );

    try {
      final content = await _repository.loadDocument(event.path);
      emit(
        DocumentState(
          status: DocumentStatus.loaded,
          content: content,
          currentPath: event.path,
        ),
      );
    } catch (e) {
      emit(
        DocumentState(
          status: DocumentStatus.error,
          currentPath: event.path,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onClearDocument(ClearDocument event, Emitter<DocumentState> emit) {
    emit(const DocumentState());
  }
}
