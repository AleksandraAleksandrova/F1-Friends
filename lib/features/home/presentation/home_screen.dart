import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "../../../l10n/app_localizations.dart";

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

class _HomeScreenState extends ConsumerState<HomeScreen> with WidgetsBindingObserver {
  int _index = 0;
  bool _startupPromptShown = false;
  bool _resumePromptShown = false;

  static const _pages = <Widget>[
    LeaguesScreen(),
    RacesScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(profileControllerProvider.notifier).ensureCurrentUserDoc();
      if (_startupPromptShown) {
        return;
      }
      _startupPromptShown = true;
      await Future<void>.delayed(const Duration(seconds: 2));
      if (!mounted) {
        return;
      }
      final l10n = AppLocalizations.of(context)!;
      await LocalNotificationService.showPredictionReminder(
        title: l10n.notificationsDefaultTitle,
        body: l10n.notificationsStartupBody,
      );
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || _resumePromptShown == true) {
      return;
    }
    _resumePromptShown = true;
    final l10n = AppLocalizations.of(context)!;
    LocalNotificationService.showPredictionReminder(
      title: l10n.notificationsDefaultTitle,
      body: l10n.notificationsStartupBody,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.groups), label: l10n.homeNavLeagues),
          NavigationDestination(icon: const Icon(Icons.flag), label: l10n.homeNavRaces),
          NavigationDestination(icon: const Icon(Icons.person), label: l10n.homeNavProfile),
        ],
      ),
    );
  }
}
