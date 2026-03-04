import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowledge_base/core/utils/constants.dart';
import 'package:knowledge_base/core/utils/responsive.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/bloc/favorites/favorites_cubit.dart';
import 'package:knowledge_base/src/knowledge_base/presentation/widgets/tag_chip_widget.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../domain/entities/knowledge_base_item.dart';

class HeaderWidget extends StatefulWidget {
  final VoidCallback onToggleSidePanel;
  final VoidCallback onToggleTocPanel;
  final VoidCallback onTapGithub;
  final void Function(ThemeMode?) onSelectTheme;
  final void Function(String filePath) onSearchResultSelected;
  final List<FileItem> allFiles;
  final bool showSidePanel;
  final bool showTocPanel;
  final ScreenSize screenSize;

  /// Fires whenever the window size changes so open popovers can be dismissed.
  final ValueNotifier<Size>? resizeNotifier;

  /// When set to a non-null value from outside, opens the search popover with
  /// that string pre-filled (e.g. `'#flutter'`). The notifier is reset to
  /// `null` after the popover is opened.
  final ValueNotifier<String?>? pendingSearchQuery;

  const HeaderWidget({
    super.key,
    required this.onToggleSidePanel,
    required this.onToggleTocPanel,
    required this.onSelectTheme,
    required this.onTapGithub,
    required this.onSearchResultSelected,
    required this.allFiles,
    required this.showSidePanel,
    required this.showTocPanel,
    this.screenSize = ScreenSize.desktop,
    this.resizeNotifier,
    this.pendingSearchQuery,
  });

  @override
  State<HeaderWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  /// Tracks the currently open overlay so it can be closed on resize.
  OverlayCompleter<void>? _activeOverlay;

  @override
  void initState() {
    super.initState();
    widget.resizeNotifier?.addListener(_onResize);
    widget.pendingSearchQuery?.addListener(_onPendingSearchQuery);
  }

  @override
  void didUpdateWidget(covariant HeaderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.resizeNotifier != widget.resizeNotifier) {
      oldWidget.resizeNotifier?.removeListener(_onResize);
      widget.resizeNotifier?.addListener(_onResize);
    }
    if (oldWidget.pendingSearchQuery != widget.pendingSearchQuery) {
      oldWidget.pendingSearchQuery?.removeListener(_onPendingSearchQuery);
      widget.pendingSearchQuery?.addListener(_onPendingSearchQuery);
    }
  }

  @override
  void dispose() {
    widget.resizeNotifier?.removeListener(_onResize);
    widget.pendingSearchQuery?.removeListener(_onPendingSearchQuery);
    super.dispose();
  }

  void _onResize() {
    final overlay = _activeOverlay;
    if (overlay != null && !overlay.isCompleted) {
      overlay.remove();
      _activeOverlay = null;
    }
  }

  void _onPendingSearchQuery() {
    final query = widget.pendingSearchQuery?.value;
    if (query != null) {
      widget.pendingSearchQuery!.value = null;
      _showSearchPopover(context, initialQuery: query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobileOrSmaller = Responsive.isMobileOrSmaller(context);
    final iconSize = isMobileOrSmaller ? SizeIcons.medium : SizeIcons.large;

    return Semantics(
      label: 'Application header',
      child: AppBar(
        padding: isMobileOrSmaller ? const EdgeInsets.all(8) : null,
        title: const Text(
          'Knowledge Base',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: isMobileOrSmaller
            ? null
            : const Text(
                'Explore my comprehensive documentation',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
        leading: [
          Semantics(
            button: true,
            label: widget.showSidePanel
                ? 'Close navigation panel'
                : 'Open navigation panel',
            child: OutlineButton(
              onPressed: widget.onToggleSidePanel,
              density: ButtonDensity.icon,
              child: Icon(
                isMobileOrSmaller
                    ? BootstrapIcons.list
                    : widget.showSidePanel
                    ? BootstrapIcons.layoutSidebarInset
                    : BootstrapIcons.layoutSidebar,
                size: iconSize,
              ),
            ),
          ),
        ],
        trailing: [
          // TOC button — always visible
          Semantics(
            button: true,
            label: widget.showTocPanel
                ? 'Close table of contents'
                : 'Open table of contents',
            child: OutlineButton(
              onPressed: widget.onToggleTocPanel,
              density: ButtonDensity.icon,
              child: Icon(
                isMobileOrSmaller
                    ? BootstrapIcons.listNested
                    : widget.showTocPanel
                    ? BootstrapIcons.layoutSidebarInsetReverse
                    : BootstrapIcons.layoutSidebarReverse,
                size: iconSize,
              ),
            ),
          ),
          Semantics(
            button: true,
            label: 'Search documentation',
            child: OutlineButton(
              onPressed: () {
                _showSearchPopover(context);
              },
              density: ButtonDensity.icon,
              child: Icon(BootstrapIcons.search, size: iconSize),
            ),
          ),
          Semantics(
            button: true,
            label: 'Change color theme',
            child: OutlineButton(
              onPressed: () {
                _showThemeDropdown(context);
              },
              density: ButtonDensity.icon,
              child: Icon(BootstrapIcons.sunFill, size: iconSize),
            ),
          ),
          if (!isMobileOrSmaller)
            Semantics(
              button: true,
              label: 'Open GitHub profile',
              child: OutlineButton(
                onPressed: widget.onTapGithub,
                density: ButtonDensity.icon,
                child: Icon(BootstrapIcons.github, size: iconSize),
              ),
            ),
        ],
      ),
    );
  }

  void _showSearchPopover(BuildContext context, {String? initialQuery}) {
    final theme = Theme.of(context);
    final isMobileOrSmaller = Responsive.isMobileOrSmaller(context);

    _activeOverlay = showPopover(
      context: context,
      alignment: Alignment.topRight,
      offset: isMobileOrSmaller ? const Offset(0, 12) : const Offset(96, 12),
      overlayBarrier: OverlayBarrier(borderRadius: theme.borderRadiusLg),
      builder: (ctx) => _SearchPopoverContent(
        allFiles: widget.allFiles,
        savedFiles: context.read<FavoritesCubit>().state.favorites,
        isMobileOrSmaller: isMobileOrSmaller,
        initialQuery: initialQuery,
        onFileSelected: (filePath) {
          closeOverlay(ctx);
          widget.onSearchResultSelected(filePath);
        },
      ),
    );
  }

  void _showThemeDropdown(BuildContext context) {
    const menuGap = MenuGap(4);
    final isMobileOrSmaller = Responsive.isMobileOrSmaller(context);
    _activeOverlay = showDropdown(
      context: context,
      alignment: Alignment.topRight,
      offset: isMobileOrSmaller ? const Offset(0, 12) : const Offset(52, 12),
      consumeOutsideTaps: true,
      builder: (ctx) {
        return DropdownMenu(
          surfaceBlur: 10,
          surfaceOpacity: 0.6,
          children: [
            MenuLabel(child: Text('Select Theme')),
            MenuDivider(),
            menuGap,
            MenuButton(
              leading: Icon(LucideIcons.sunMoon),
              child: Text('System'),
              onPressed: (context) {
                widget.onSelectTheme(ThemeMode.system);
                closeOverlay(context);
              },
            ),
            menuGap,
            MenuButton(
              leading: Icon(LucideIcons.sun),
              child: Text('Light'),
              onPressed: (context) {
                widget.onSelectTheme(ThemeMode.light);
                closeOverlay(context);
              },
            ),
            menuGap,
            MenuButton(
              leading: Icon(LucideIcons.moon),
              child: Text('Dark'),
              onPressed: (context) {
                widget.onSelectTheme(ThemeMode.dark);
                closeOverlay(context);
              },
            ),
            menuGap,
          ],
        );
      },
    );
  }
}

class _SearchPopoverContent extends StatefulWidget {
  final List<FileItem> allFiles;
  final List<FileItem> savedFiles;
  final void Function(String filePath) onFileSelected;
  final bool isMobileOrSmaller;
  final String? initialQuery;

  const _SearchPopoverContent({
    required this.allFiles,
    required this.onFileSelected,
    this.savedFiles = const [],
    this.isMobileOrSmaller = false,
    this.initialQuery,
  });

  @override
  State<_SearchPopoverContent> createState() => _SearchPopoverContentState();
}

class _SearchPopoverContentState extends State<_SearchPopoverContent> {
  final TextEditingController _controller = TextEditingController();
  List<FileItem> _filteredFiles = [];

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialQuery ?? '';
    _filteredFiles = _filterFiles(_controller.text);
    _controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onSearchChanged);
    _controller.dispose();
    super.dispose();
  }

  List<FileItem> _filterFiles(String query) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return widget.allFiles;
    if (q.startsWith('/saved')) {
      final subQuery = () {
        try {
          return q.substring(6).trim();
        } catch (_) {
          return '';
        }
      }();
      if (subQuery.isEmpty) return widget.savedFiles;
      if (subQuery.startsWith('#')) {
        final tagQuery = subQuery.substring(1).trim();
        if (tagQuery.isEmpty) return widget.savedFiles;
        return widget.savedFiles
            .where(
              (file) =>
                  file.tags.any((t) => t.toLowerCase().contains(tagQuery)),
            )
            .toList();
      }
      return widget.savedFiles
          .where(
            (file) =>
                file.name.toLowerCase().contains(subQuery) ||
                file.path.toLowerCase().contains(subQuery),
          )
          .toList();
    }

    if (q.startsWith('#')) {
      final tagQuery = q.substring(1).trim();
      if (tagQuery.isEmpty) return widget.allFiles;
      return widget.allFiles
          .where(
            (file) => file.tags.any((t) => t.toLowerCase().contains(tagQuery)),
          )
          .toList();
    }
    return widget.allFiles
        .where(
          (file) =>
              file.name.toLowerCase().contains(q) ||
              file.path.toLowerCase().contains(q),
        )
        .toList();
  }

  void _onSearchChanged() {
    setState(() {
      _filteredFiles = _filterFiles(_controller.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Search files dialog',
      child: SurfaceCard(
        surfaceBlur: 10,
        surfaceOpacity: 0.8,
        padding: EdgeInsets.zero,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: widget.isMobileOrSmaller
                ? MediaQuery.sizeOf(context).width - 18
                : 560,
            maxHeight: widget.isMobileOrSmaller
                ? MediaQuery.sizeOf(context).height * 0.60
                : 420,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Search Files').h4(),
              const Gap(12),
              Semantics(
                label: 'Search input',
                textField: true,
                child: TextField(
                  controller: _controller,
                  placeholder: const Text(
                    'Search by name, #tag, or /saved ...',
                  ),
                  features: [const InputFeature.clear()],
                ),
              ),
              const Gap(8),
              Semantics(
                liveRegion: true,
                child: Text(
                  _controller.text.isEmpty
                      ? 'All files'
                      : '${_filteredFiles.length} result${_filteredFiles.length == 1 ? '' : 's'}',
                ).muted(),
              ),
              const Gap(8),
              Flexible(
                child: _filteredFiles.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: Text('No files found').muted()),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _filteredFiles.length,
                        itemBuilder: (context, index) {
                          final file = _filteredFiles[index];
                          final isTagSearchInFiles = _controller.text
                              .trim()
                              .startsWith('#');
                          final isTagSearchInSaved =
                              _controller.text.trim().startsWith('/saved') &&
                              () {
                                try {
                                  return _controller.text
                                      .trim()
                                      .substring(6)
                                      .trim()
                                      .startsWith('#');
                                } catch (_) {
                                  return false;
                                }
                              }();
                          final isTagSearch =
                              isTagSearchInFiles || isTagSearchInSaved;
                          return Padding(
                            padding: index == _filteredFiles.length - 1
                                ? EdgeInsets.zero
                                : const EdgeInsets.only(bottom: 8),
                            child: _SearchResultTile(
                              file: file,
                              onTap: () => widget.onFileSelected(file.path),
                              showTags: isTagSearch,
                              onTagTapped: (tag) {
                                _controller.text = '#$tag';
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ).withPadding(padding: const EdgeInsets.all(12)),
        ),
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final FileItem file;
  final VoidCallback onTap;
  final bool showTags;

  /// Called when a tag chip inside this tile is tapped.
  final void Function(String tag)? onTagTapped;

  const _SearchResultTile({
    required this.file,
    required this.onTap,
    this.showTags = false,
    this.onTagTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Open file ${file.name}',
      child: OutlineButton(
        onPressed: onTap,
        child:
            Row(
              children: [
                ExcludeSemantics(
                  child: const Icon(BootstrapIcons.fileEarmarkText, size: 16),
                ),
                const Gap(8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        file.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ).semiBold(),
                      Text(
                        file.path,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ).muted().xSmall(),
                      if (showTags && file.tags.isNotEmpty) ...[
                        const Gap(4),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: file.tags
                              .map(
                                (t) => TagChipWidget(
                                  tag: t,
                                  onTap: onTagTapped != null
                                      ? () => onTagTapped!(t)
                                      : null,
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ).withPadding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            ),
      ),
    );
  }
}
