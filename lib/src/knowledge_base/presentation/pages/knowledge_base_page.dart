import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/bloc/document/document_bloc.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/bloc/document/document_event.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/bloc/document/document_state.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/bloc/navigation/navigation_bloc.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/bloc/navigation/navigation_event.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/bloc/navigation/navigation_state.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/widgets/table_of_content_widget.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../widgets/directories_tree_widget.dart';
import '../widgets/center_panel_widget.dart';
import '../widgets/header_widget.dart';
import '../widgets/footer_widget.dart';

/// Main page that orchestrates all panels and connects them via BLoC.
class KnowledgeBasePage extends StatelessWidget {
  const KnowledgeBasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<NavigationBloc, NavigationState>(
      listenWhen: (prev, curr) =>
          prev.selectedFile != curr.selectedFile ||
          prev.viewMode != curr.viewMode,
      listener: (context, state) {
        // When a file is selected and viewMode is file, load the document
        if (state.viewMode == ViewMode.file && state.selectedFile != null) {
          context.read<DocumentBloc>().add(
            LoadDocument(state.selectedFile!.path),
          );
        }
      },
      child: const _KnowledgeBaseView(),
    );
  }
}

class _KnowledgeBaseView extends StatefulWidget {
  const _KnowledgeBaseView();

  @override
  State<_KnowledgeBaseView> createState() => _KnowledgeBaseViewState();
}

class _KnowledgeBaseViewState extends State<_KnowledgeBaseView> {
  final ValueNotifier<Set<int>> _visibleHeadingsNotifier = ValueNotifier({});

  @override
  void dispose() {
    _visibleHeadingsNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, navState) {
        return Scaffold(
          headers: [
            HeaderWidget(
              onTapGithub: () {},
              onSelectTheme: (theme) {},
              onToggleSidePanel: () {
                context.read<NavigationBloc>().add(const ToggleSidePanel());
              },
              showSidePanel: navState.showSidePanel,
            ),
            const Divider(),
          ],
          footers: [
            const Divider(),
            FooterWidget(
              currentPage: navState.currentFileIndex,
              totalPages: navState.totalFiles,
              onPageChanged: (value) {
                context.read<NavigationBloc>().add(ChangePage(value));
              },
            ),
          ],
          child: _buildContent(context, navState),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, NavigationState navState) {
    if (navState.status == NavigationStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (navState.status == NavigationStatus.error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(BootstrapIcons.exclamationTriangle),
            const Gap(8),
            Text(
              navState.errorMessage ?? 'Failed to load documentation',
            ).muted(),
          ],
        ),
      );
    }

    final treeItems = navState.rootDirectory != null
        ? DirTreeItem.fromKnowledgeBaseItems(
            navState.rootDirectory!.sortedItems,
          )
        : <DirTreeItem>[];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (navState.showSidePanel) ...[
          DirectoriesTreeWidget(
            items: treeItems,
            selectedFilePath: navState.selectedFile?.path,
            onFileSelected: (path) {
              context.read<NavigationBloc>().add(SelectFile(path));
            },
            onDirectorySelected: (path) {
              context.read<NavigationBloc>().add(SelectDirectory(path));
            },
          ),
          const VerticalDivider(),
        ],
        Expanded(
          flex: 3,
          child: CenterPanelWidget(
            visibleHeadingsNotifier: _visibleHeadingsNotifier,
          ),
        ),
        // Only show TOC when viewing a file document
        if (navState.viewMode == ViewMode.file) ...[
          const VerticalDivider(),
          BlocBuilder<DocumentBloc, DocumentState>(
            buildWhen: (prev, curr) => prev.content != curr.content,
            builder: (context, docState) {
              final headings = docState.content?.headings ?? [];
              return ValueListenableBuilder<Set<int>>(
                valueListenable: _visibleHeadingsNotifier,
                builder: (context, visibleIndices, _) {
                  return TableOfContentWidget(
                    activeItemIndices: visibleIndices,
                    items: headings
                        .map(
                          (h) => TOCItem(
                            title: h.title,
                            heading: TOCHeading.fromLevel(h.level),
                          ),
                        )
                        .toList(),
                  );
                },
              );
            },
          ),
        ],
      ],
    );
  }
}
