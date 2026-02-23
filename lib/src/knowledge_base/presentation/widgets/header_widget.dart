import 'package:knowledge_base/core/utils/constants.dart';
import 'package:knowledge_base/core/utils/responsive.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../domain/entities/knowledge_base_item.dart';

class HeaderWidget extends StatelessWidget {
  final VoidCallback onToggleSidePanel;
  final VoidCallback onToggleTocPanel;
  final VoidCallback onTapGithub;
  final void Function(ThemeMode?) onSelectTheme;
  final void Function(String filePath) onSearchResultSelected;
  final List<FileItem> allFiles;
  final bool showSidePanel;
  final bool showTocPanel;
  final ScreenSize screenSize;

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
  });

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
            label: showSidePanel
                ? 'Close navigation panel'
                : 'Open navigation panel',
            child: OutlineButton(
              onPressed: onToggleSidePanel,
              density: ButtonDensity.icon,
              child: Icon(
                isMobileOrSmaller
                    ? BootstrapIcons.list
                    : showSidePanel
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
            label: showTocPanel
                ? 'Close table of contents'
                : 'Open table of contents',
            child: OutlineButton(
              onPressed: onToggleTocPanel,
              density: ButtonDensity.icon,
              child: Icon(
                isMobileOrSmaller
                    ? BootstrapIcons.listNested
                    : showTocPanel
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
                onPressed: onTapGithub,
                density: ButtonDensity.icon,
                child: Icon(BootstrapIcons.github, size: iconSize),
              ),
            ),
        ],
      ),
    );
  }

  void _showSearchPopover(BuildContext context) {
    final theme = Theme.of(context);
    final isMobileOrSmaller = Responsive.isMobileOrSmaller(context);

    showPopover(
      context: context,
      alignment: Alignment.topRight,
      offset: isMobileOrSmaller ? const Offset(0, 12) : const Offset(96, 12),
      overlayBarrier: OverlayBarrier(borderRadius: theme.borderRadiusLg),
      builder: (ctx) => _SearchPopoverContent(
        allFiles: allFiles,
        isMobileOrSmaller: isMobileOrSmaller,
        onFileSelected: (filePath) {
          closeOverlay(ctx);
          onSearchResultSelected(filePath);
        },
      ),
    );
  }

  void _showThemeDropdown(BuildContext context) {
    const menuGap = MenuGap(4);
    final isMobileOrSmaller = Responsive.isMobileOrSmaller(context);
    showDropdown(
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
                onSelectTheme(ThemeMode.system);
                closeOverlay(context);
              },
            ),
            menuGap,
            MenuButton(
              leading: Icon(LucideIcons.sun),
              child: Text('Light'),
              onPressed: (context) {
                onSelectTheme(ThemeMode.light);
                closeOverlay(context);
              },
            ),
            menuGap,
            MenuButton(
              leading: Icon(LucideIcons.moon),
              child: Text('Dark'),
              onPressed: (context) {
                onSelectTheme(ThemeMode.dark);
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
  final void Function(String filePath) onFileSelected;
  final bool isMobileOrSmaller;

  const _SearchPopoverContent({
    required this.allFiles,
    required this.onFileSelected,
    this.isMobileOrSmaller = false,
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
    _filteredFiles = widget.allFiles;
    _controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onSearchChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _controller.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredFiles = widget.allFiles;
      } else {
        _filteredFiles = widget.allFiles
            .where(
              (file) =>
                  file.name.toLowerCase().contains(query) ||
                  file.path.toLowerCase().contains(query),
            )
            .toList();
      }
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
                  placeholder: const Text('Type a filename to search...'),
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
                          return Padding(
                            padding: index == _filteredFiles.length - 1
                                ? EdgeInsets.zero
                                : const EdgeInsets.only(bottom: 8),
                            child: _SearchResultTile(
                              file: file,
                              onTap: () => widget.onFileSelected(file.path),
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

  const _SearchResultTile({required this.file, required this.onTap});

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
