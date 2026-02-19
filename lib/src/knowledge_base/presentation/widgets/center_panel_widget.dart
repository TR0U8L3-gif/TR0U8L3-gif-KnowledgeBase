import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/bloc/document/document_bloc.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/bloc/document/document_state.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/bloc/navigation/navigation_bloc.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/bloc/navigation/navigation_event.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/bloc/navigation/navigation_state.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/widgets/breadcrumb_widget.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/widgets/directory_view_widget.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/widgets/markdown_renderer_widget.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Center panel displaying breadcrumb navigation and rendered document content
/// or directory view depending on the current [ViewMode].
class CenterPanelWidget extends StatelessWidget {
  const CenterPanelWidget({this.visibleHeadingsNotifier, super.key});

  final ValueNotifier<Set<int>>? visibleHeadingsNotifier;

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
          child: BlocBuilder<NavigationBloc, NavigationState>(
            buildWhen: (prev, curr) =>
                prev.viewMode != curr.viewMode ||
                prev.selectedDirectory != curr.selectedDirectory ||
                prev.selectedFile != curr.selectedFile,
            builder: (context, navState) {
              if (navState.viewMode == ViewMode.directory &&
                  navState.selectedDirectory != null) {
                return DirectoryViewWidget(
                  directory: navState.selectedDirectory!,
                  onFileSelected: (path) {
                    context.read<NavigationBloc>().add(SelectFile(path));
                  },
                  onDirectorySelected: (path) {
                    context.read<NavigationBloc>().add(SelectDirectory(path));
                  },
                );
              }
              return BlocBuilder<DocumentBloc, DocumentState>(
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
                    DocumentStatus.loaded => _DocumentContent(
                      docState: docState,
                      visibleHeadingsNotifier: visibleHeadingsNotifier,
                    ),
                  };
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DocumentContent extends StatefulWidget {
  final DocumentState docState;
  final ValueNotifier<Set<int>>? visibleHeadingsNotifier;

  const _DocumentContent({
    required this.docState,
    this.visibleHeadingsNotifier,
  });

  @override
  State<_DocumentContent> createState() => _DocumentContentState();
}

class _DocumentContentState extends State<_DocumentContent> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _scrollViewKey = GlobalKey();
  List<GlobalKey> _headingKeys = [];

  @override
  void initState() {
    super.initState();
    _initHeadingKeys();
    _scrollController.addListener(_updateVisibleHeadings);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _updateVisibleHeadings(),
    );
  }

  @override
  void didUpdateWidget(covariant _DocumentContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.docState.content != widget.docState.content) {
      _initHeadingKeys();
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _updateVisibleHeadings(),
      );
    }
  }

  void _initHeadingKeys() {
    final headingCount = widget.docState.content?.headings.length ?? 0;
    _headingKeys = List.generate(headingCount, (_) => GlobalKey());
  }

  void _updateVisibleHeadings() {
    if (!mounted) return;
    final notifier = widget.visibleHeadingsNotifier;
    if (notifier == null) return;
    if (_headingKeys.isEmpty) {
      if (notifier.value.isNotEmpty) notifier.value = {};
      return;
    }

    final scrollViewRenderBox =
        _scrollViewKey.currentContext?.findRenderObject() as RenderBox?;
    if (scrollViewRenderBox == null) return;

    final viewportOffset = scrollViewRenderBox.localToGlobal(Offset.zero);
    final viewportTop = viewportOffset.dy;
    final viewportBottom = viewportTop + scrollViewRenderBox.size.height;

    final visibleIndices = <int>{};

    for (int i = 0; i < _headingKeys.length; i++) {
      final renderBox =
          _headingKeys[i].currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) continue;

      final headingOffset = renderBox.localToGlobal(Offset.zero);
      final headingTop = headingOffset.dy;
      final headingBottom = headingTop + renderBox.size.height;

      if (headingBottom > viewportTop && headingTop < viewportBottom) {
        visibleIndices.add(i);
      }
    }

    // If no headings are visible, find the last heading above the viewport
    if (visibleIndices.isEmpty) {
      int closestAbove = -1;
      double closestDistance = double.infinity;

      for (int i = 0; i < _headingKeys.length; i++) {
        final renderBox =
            _headingKeys[i].currentContext?.findRenderObject() as RenderBox?;
        if (renderBox == null) continue;

        final headingOffset = renderBox.localToGlobal(Offset.zero);
        final headingBottom = headingOffset.dy + renderBox.size.height;

        if (headingBottom <= viewportTop) {
          final distance = viewportTop - headingBottom;
          if (distance < closestDistance) {
            closestDistance = distance;
            closestAbove = i;
          }
        }
      }

      if (closestAbove >= 0) {
        visibleIndices.add(closestAbove);
      }
    }

    // Only notify when the set actually changed to avoid redundant rebuilds
    final current = notifier.value;
    if (current.length != visibleIndices.length ||
        !current.containsAll(visibleIndices)) {
      notifier.value = visibleIndices;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = widget.docState.content;
    if (content == null) {
      return const Center(child: Text('No content available'));
    }

    return BlocBuilder<NavigationBloc, NavigationState>(
      buildWhen: (prev, curr) => prev.selectedFile != curr.selectedFile,
      builder: (context, navState) {
        final file = navState.selectedFile;
        return SingleChildScrollView(
          key: _scrollViewKey,
          controller: _scrollController,
          padding: const EdgeInsets.all(24),
          child: MarkdownRendererWidget(
            markdown: content.rawMarkdown,
            title: file?.name,
            description: file?.description,
            lastModified: file?.lastModified,
            headingKeys: _headingKeys,
          ),
        );
      },
    );
  }
}
