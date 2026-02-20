import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowledge_base/core/utils/responsive.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/bloc/document/document_bloc.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/bloc/document/document_event.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/bloc/document/document_state.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/bloc/navigation/navigation_bloc.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/bloc/navigation/navigation_event.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/bloc/navigation/navigation_state.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/bloc/theme/theme_cubit.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/widgets/table_of_content_widget.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

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

  // ── Drawer helpers ──────────────────────────────────────────────────

  /// Shows the directory tree in a modal drawer (mobile / tablet).
  void _openNavigationDrawer(BuildContext context, NavigationState navState) {
    final treeItems = navState.rootDirectory != null
        ? DirTreeItem.fromKnowledgeBaseItems(
            navState.rootDirectory!.sortedItems,
          )
        : <DirTreeItem>[];

    openDrawer(
      context: context,
      position: OverlayPosition.left,
      builder: (ctx) {
        return Semantics(
          label: 'Navigation drawer',
          child: SizedBox(
            width: 300,
            child: Column(
              children: [
                Container(
                  height: 48,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Navigation').semiBold(),
                      OutlineButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        density: ButtonDensity.icon,
                        child: const Icon(BootstrapIcons.x),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: DirectoriesTreeWidget(
                    items: treeItems,
                    width: 300,
                    selectedFilePath: navState.selectedFile?.path,
                    onFileSelected: (path) {
                      Navigator.of(ctx).pop();
                      context.read<NavigationBloc>().add(SelectFile(path));
                    },
                    onDirectorySelected: (path) {
                      Navigator.of(ctx).pop();
                      context.read<NavigationBloc>().add(SelectDirectory(path));
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Shows the Table of Contents in a modal drawer (mobile / tablet).
  void _openTocDrawer(BuildContext context) {
    final docState = context.read<DocumentBloc>().state;
    final headings = docState.content?.headings ?? [];

    openDrawer(
      context: context,
      position: OverlayPosition.right,
      builder: (ctx) {
        return Semantics(
          label: 'Table of contents drawer',
          child: SizedBox(
            width: 300,
            child: Column(
              children: [
                Container(
                  height: 48,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('On This Page').semiBold(),
                      OutlineButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        density: ButtonDensity.icon,
                        child: const Icon(BootstrapIcons.x),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ValueListenableBuilder<Set<int>>(
                    valueListenable: _visibleHeadingsNotifier,
                    builder: (_, visibleIndices, __) {
                      return TableOfContentWidget(
                        width: 300,
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
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Build ───────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final screen = Responsive.screenSize(context);

    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, navState) {
        return Scaffold(
          headers: [
            HeaderWidget(
              onTapGithub: () {
                launchUrl(
                  Uri.parse('https://github.com/TR0U8L3-gif'),
                  mode: LaunchMode.platformDefault,
                  webOnlyWindowName: '_blank',
                );
              },
              onSelectTheme: (theme) {
                context.read<ThemeCubit>().setThemeMode(theme);
              },
              onToggleSidePanel: () {
                // On mobile/tablet → open drawer, on desktop → toggle inline
                if (screen != ScreenSize.desktop) {
                  _openNavigationDrawer(context, navState);
                } else {
                  context.read<NavigationBloc>().add(const ToggleSidePanel());
                }
              },
              onSearchResultSelected: (filePath) {
                context.read<NavigationBloc>().add(SelectFile(filePath));
              },
              onTocPressed: screen != ScreenSize.desktop
                  ? () => _openTocDrawer(context)
                  : null,
              allFiles: navState.allFiles,
              showSidePanel: navState.showSidePanel,
              screenSize: screen,
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
          child: Semantics(
            label: 'Main content',
            child: _buildContent(context, navState, screen),
          ),
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    NavigationState navState,
    ScreenSize screen,
  ) {
    if (navState.status == NavigationStatus.loading) {
      return Center(
        child: Semantics(
          label: 'Loading documentation',
          child: const CircularProgressIndicator(),
        ),
      );
    }

    if (navState.status == NavigationStatus.error) {
      return Center(
        child: Semantics(
          label: 'Error loading documentation',
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
        ),
      );
    }

    final treeItems = navState.rootDirectory != null
        ? DirTreeItem.fromKnowledgeBaseItems(
            navState.rootDirectory!.sortedItems,
          )
        : <DirTreeItem>[];

    // On mobile: no inline side panels at all — use drawers
    if (screen == ScreenSize.mobile) {
      return Expanded(
        child: CenterPanelWidget(
          visibleHeadingsNotifier: _visibleHeadingsNotifier,
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Side panel: shown on tablet (if toggled) and desktop (if toggled)
        if (navState.showSidePanel && screen != ScreenSize.mobile) ...[
          Semantics(
            label: 'Documentation navigation tree',
            child: DirectoriesTreeWidget(
              items: treeItems,
              width: Responsive.sidePanelWidth(context),
              selectedFilePath: navState.selectedFile?.path,
              onFileSelected: (path) {
                context.read<NavigationBloc>().add(SelectFile(path));
              },
              onDirectorySelected: (path) {
                context.read<NavigationBloc>().add(SelectDirectory(path));
              },
            ),
          ),
          const VerticalDivider(),
        ],
        Expanded(
          flex: 3,
          child: CenterPanelWidget(
            visibleHeadingsNotifier: _visibleHeadingsNotifier,
          ),
        ),
        // TOC: only on desktop when viewing a file
        if (navState.viewMode == ViewMode.file &&
            screen == ScreenSize.desktop) ...[
          const VerticalDivider(),
          Semantics(
            label: 'Table of contents',
            child: BlocBuilder<DocumentBloc, DocumentState>(
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
          ),
        ],
      ],
    );
  }
}
