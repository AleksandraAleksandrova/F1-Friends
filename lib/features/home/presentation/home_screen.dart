import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../core/notifications/local_notification_service.dart";
import "../../leagues/presentation/leagues_screen.dart";
import "../../profile/presentation/profile_screen.dart";
import "../../profile/providers/profile_providers.dart";
import "../../races/presentation/races_screen.dart";

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _index = 0;
  bool _startupPromptShown = false;

  static const _pages = <Widget>[
    LeaguesScreen(),
    RacesScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(profileControllerProvider.notifier).ensureCurrentUserDoc();
      if (_startupPromptShown) {
        return;
      }
      _startupPromptShown = true;
      await Future<void>.delayed(const Duration(milliseconds: 900));
      await LocalNotificationService.showPredictionReminder();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.groups), label: "Leagues"),
          NavigationDestination(icon: Icon(Icons.flag), label: "Races"),
          NavigationDestination(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
