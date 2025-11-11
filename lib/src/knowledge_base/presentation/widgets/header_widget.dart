import 'package:shadcn_flutter/shadcn_flutter.dart';

class HeaderWidget extends StatelessWidget {
  final VoidCallback onToggleSidePanel;
  final VoidCallback onTapGithub;
  final void Function(ThemeMode?) onSelectTheme;
  final bool showSidePanel;

  const HeaderWidget({
    super.key,
    required this.onToggleSidePanel,
    required this.onSelectTheme,
    required this.onTapGithub,
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
            final theme = Theme.of(context);
            showPopover(
              context: context,
              alignment: Alignment.topRight,
              offset: const Offset(96, 12),
              overlayBarrier: OverlayBarrier(
                borderRadius: theme.borderRadiusLg,
              ),
              builder: (ctx) => SurfaceCard(
                surfaceBlur: 10,
                surfaceOpacity: 0.8,
                padding: EdgeInsets.zero,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Search').h4(),
                      Gap(12),
                      TextField(
                        placeholder: const Text('Type to search...'),
                        features: [
                          const InputFeature.clear(),
                          const InputFeature.copy(),
                          const InputFeature.paste(),
                        ],
                      ),
                      Gap(8),
                      Text('Suggested').muted(),
                      Gap(8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _SearchChip(label: 'Authentication API'),
                          _SearchChip(label: 'Payments API'),
                          _SearchChip(label: 'On-call guide'),
                          _SearchChip(label: 'Threat model'),
                        ],
                      ),
                    ],
                  ).withPadding(padding: const EdgeInsets.all(12)),
                ),
              ),
            );
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
}

class _SearchChip extends StatelessWidget {
  final String label;

  const _SearchChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return OutlineButton(
      onPressed: () {},
      density: ButtonDensity.compact,
      child: Text(label).withPadding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      ),
    );
  }
}
