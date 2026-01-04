import 'package:shadcn_flutter/shadcn_flutter.dart';

class HeaderWidget extends StatelessWidget {
  final VoidCallback onToggleLeftPanel;
  final bool showLeftPanel;

  const HeaderWidget({
    super.key,
    required this.onToggleLeftPanel,
    required this.showLeftPanel,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Knowledge Base'),
      leading: [
        OutlineButton(
          onPressed: onToggleLeftPanel,
          density: ButtonDensity.icon,
          child: Icon(
            showLeftPanel
                ? BootstrapIcons.layoutSidebarInset
                : BootstrapIcons.layoutSidebar,
          ),
        ),
      ],
      trailing: [
        OutlineButton(
          onPressed: () {},
          density: ButtonDensity.icon,
          child: const Icon(BootstrapIcons.search),
        ),
        OutlineButton(
          onPressed: () {},
          density: ButtonDensity.icon,
          child: const Icon(BootstrapIcons.sunFill),
        ),
        OutlineButton(
          onPressed: () {},
          density: ButtonDensity.icon,
          child: const Icon(BootstrapIcons.circleFill),
        ),
      ],
    );
  }
}
