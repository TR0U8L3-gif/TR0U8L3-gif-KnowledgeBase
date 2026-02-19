import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/bloc/document/document_bloc.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/bloc/document/document_state.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/bloc/navigation/navigation_bloc.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/bloc/navigation/navigation_event.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/bloc/navigation/navigation_state.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/widgets/breadcrumb_widget.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/widgets/markdown_renderer_widget.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Center panel displaying breadcrumb navigation and rendered document content.
class CenterPanelWidget extends StatelessWidget {
  const CenterPanelWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BlocBuilder<NavigationBloc, NavigationState>(
          buildWhen: (prev, curr) => prev.breadcrumb != curr.breadcrumb,
          builder: (context, navState) {
            final labels = navState.breadcrumb.map((e) => e.label).toList();
            return BreadcrumbWidget(
              items: labels,
              onItemTapped: (index) {
                context.read<NavigationBloc>().add(NavigateToBreadcrumb(index));
              },
            );
          },
        ),
        const Divider(),
        Expanded(
          child: BlocBuilder<DocumentBloc, DocumentState>(
            builder: (context, docState) {
              return switch (docState.status) {
                DocumentStatus.initial => const Center(
                  child: Text('Select a document from the tree'),
                ),
                DocumentStatus.loading => const Center(
                  child: CircularProgressIndicator(),
                ),
                DocumentStatus.error => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(BootstrapIcons.exclamationTriangle),
                      const Gap(8),
                      Text(
                        docState.errorMessage ?? 'Failed to load document',
                      ).muted(),
                    ],
                  ),
                ),
                DocumentStatus.loaded => _DocumentContent(docState: docState),
              };
            },
          ),
        ),
      ],
    );
  }
}

class _DocumentContent extends StatelessWidget {
  final DocumentState docState;

  const _DocumentContent({required this.docState});

  @override
  Widget build(BuildContext context) {
    final content = docState.content;
    if (content == null) {
      return const Center(child: Text('No content available'));
    }

    return BlocBuilder<NavigationBloc, NavigationState>(
      buildWhen: (prev, curr) => prev.selectedFile != curr.selectedFile,
      builder: (context, navState) {
        final file = navState.selectedFile;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: MarkdownRendererWidget(
            markdown: content.rawMarkdown,
            title: file?.name,
            description: file?.description,
            lastModified: file?.lastModified,
          ),
        );
      },
    );
  }
}
