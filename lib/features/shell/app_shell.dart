import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../export/screens/export_screen.dart';
import '../library/screens/library_screen.dart';
import '../reader/screens/reader_tab_screen.dart';
import '../tts_player/widgets/mini_player.dart';
import '../voices/screens/voices_screen.dart';
import 'shell_providers.dart';

const _destinations = [
  (icon: Icons.library_books_outlined, selectedIcon: Icons.library_books, label: 'Library'),
  (icon: Icons.menu_book_outlined, selectedIcon: Icons.menu_book, label: 'Reader'),
  (icon: Icons.record_voice_over_outlined, selectedIcon: Icons.record_voice_over, label: 'Voices'),
  (icon: Icons.ios_share_outlined, selectedIcon: Icons.ios_share, label: 'Export'),
];

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(currentTabProvider);
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    final pages = const [
      LibraryScreen(),
      ReaderTabScreen(),
      VoicesScreen(),
      ExportScreen(),
    ];

    final body = Column(
      children: [
        Expanded(child: IndexedStack(index: index, children: pages)),
        const MiniPlayer(),
      ],
    );

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: index,
              onDestinationSelected: (i) => ref.read(currentTabProvider.notifier).state = i,
              labelType: NavigationRailLabelType.all,
              destinations: [
                for (final d in _destinations)
                  NavigationRailDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: Text(d.label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => ref.read(currentTabProvider.notifier).state = i,
        destinations: [
          for (final d in _destinations)
            NavigationDestination(icon: Icon(d.icon), selectedIcon: Icon(d.selectedIcon), label: d.label),
        ],
      ),
    );
  }
}
