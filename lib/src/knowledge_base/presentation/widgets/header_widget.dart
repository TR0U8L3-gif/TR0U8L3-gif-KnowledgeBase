import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../domain/entities/knowledge_base_item.dart';

class HeaderWidget extends StatelessWidget {
  final VoidCallback onToggleSidePanel;
  final VoidCallback onTapGithub;
  final void Function(ThemeMode?) onSelectTheme;
  final void Function(String filePath) onSearchResultSelected;
  final List<FileItem> allFiles;
  final bool showSidePanel;

  const HeaderWidget({
    super.key,
    required this.onToggleSidePanel,
    required this.onSelectTheme,
    required this.onTapGithub,
    required this.onSearchResultSelected,
    required this.allFiles,
    required this.showSidePanel,
  });

  @override
  Widget build(BuildContext context) {
    const menuGap = MenuGap(4);

    return AppBar(
      title: const Text(
        'Knowledge Base',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: const Text(
        'Explore my comprehensive documentation',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      leading: [
        OutlineButton(
          onPressed: onToggleSidePanel,
          density: ButtonDensity.icon,
          child: Icon(
            showSidePanel
                ? BootstrapIcons.layoutSidebarInset
                : BootstrapIcons.layoutSidebar,
          ),
        ),
      ],
      trailing: [
        OutlineButton(
          onPressed: () {
            _showSearchPopover(context);
          },
          density: ButtonDensity.icon,
          child: const Icon(BootstrapIcons.search),
        ),
        OutlineButton(
          onPressed: () async {
            await showDropdown<ThemeMode?>(
              context: context,
              alignment: Alignment.topRight,
              offset: const Offset(52, 8),
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
                        closeOverlay(context, ThemeMode.system);
                      },
                    ),
                    menuGap,
                    MenuButton(
                      leading: Icon(LucideIcons.sun),
                      child: Text('Light'),
                      onPressed: (context) {
                        closeOverlay(context, ThemeMode.light);
                      },
                    ),
                    menuGap,
                    MenuButton(
                      leading: Icon(LucideIcons.moon),
                      child: Text('Dark'),
                      onPressed: (context) {
                        closeOverlay(context, ThemeMode.dark);
                      },
                    ),
                    menuGap,
                  ],
                );
              },
            ).then((completer) {
              completer.future.then(onSelectTheme);
            });
          },
          density: ButtonDensity.icon,
          child: const Icon(BootstrapIcons.sunFill),
        ),
        OutlineButton(
          onPressed: onTapGithub,
          density: ButtonDensity.icon,
          child: const Icon(BootstrapIcons.github),
        ),
      ],
    );
  }

  void _showSearchPopover(BuildContext context) {
    final theme = Theme.of(context);
    showPopover(
      context: context,
      alignment: Alignment.topRight,
      offset: const Offset(96, 12),
      overlayBarrier: OverlayBarrier(borderRadius: theme.borderRadiusLg),
      builder: (ctx) => _SearchPopoverContent(
        allFiles: allFiles,
        onFileSelected: (filePath) {
          closeOverlay(ctx);
          onSearchResultSelected(filePath);
        },
      ),
    );
  }
}

class _SearchPopoverContent extends StatefulWidget {
  final List<FileItem> allFiles;
  final void Function(String filePath) onFileSelected;

  const _SearchPopoverContent({
    required this.allFiles,
    required this.onFileSelected,
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
    return SurfaceCard(
      surfaceBlur: 10,
      surfaceOpacity: 0.8,
      padding: EdgeInsets.zero,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Search Files').h4(),
            const Gap(12),
            TextField(
              controller: _controller,
              placeholder: const Text('Type a filename to search...'),
              features: [const InputFeature.clear()],
            ),
            const Gap(8),
            Text(
              _controller.text.isEmpty
                  ? 'All files'
                  : '${_filteredFiles.length} result${_filteredFiles.length == 1 ? '' : 's'}',
            ).muted(),
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
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final FileItem file;
  final VoidCallback onTap;

  const _SearchResultTile({required this.file, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlineButton(
      onPressed: onTap,
      child:
          Row(
            children: [
              const Icon(BootstrapIcons.fileEarmarkText, size: 16),
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
    );
  }
}
