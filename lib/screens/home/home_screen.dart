import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/announcement_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/poll_provider.dart';
import '../admin/admin_dashboard_screen.dart';
import '../announcements/announcement_feed_screen.dart';
import '../events/event_list_screen.dart';
import '../polls/poll_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  static const _titles = ['Announcements', 'Polls', 'Events', 'Admin'];

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isAdmin = authProvider.isAdmin;

    // Providers now live ABOVE the IndexedStack, so every tab
    // (including Admin) can access AnnouncementProvider and PollProvider.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AnnouncementProvider()),
        ChangeNotifierProvider(create: (_) => PollProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
      ],
      child: _HomeScreenBody(
        isAdmin: isAdmin,
        currentIndex: _currentIndex,
        titles: _titles,
        onTabChanged: (index) => setState(() => _currentIndex = index),
        onSignOut: () => authProvider.signOut(),
      ),
    );
  }
}

class _HomeScreenBody extends StatelessWidget {
  final bool isAdmin;
  final int currentIndex;
  final List<String> titles;
  final ValueChanged<int> onTabChanged;
  final VoidCallback onSignOut;

  const _HomeScreenBody({
    required this.isAdmin,
    required this.currentIndex,
    required this.titles,
    required this.onTabChanged,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = <Widget>[
      const AnnouncementFeedScreen(),
      const PollScreen(),
      const EventListScreen(),
      if (isAdmin) const AdminDashboardScreen(),
    ];

    final navItems = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
        icon: Icon(Icons.campaign_outlined),
        activeIcon: Icon(Icons.campaign),
        label: 'Feed',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.poll_outlined),
        activeIcon: Icon(Icons.poll),
        label: 'Polls',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.event_outlined),
        activeIcon: Icon(Icons.event),
        label: 'Events',
      ),
      if (isAdmin)
        const BottomNavigationBarItem(
          icon: Icon(Icons.admin_panel_settings_outlined),
          activeIcon: Icon(Icons.admin_panel_settings),
          label: 'Admin',
        ),
    ];

    final safeIndex = currentIndex < tabs.length ? currentIndex : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[safeIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: onSignOut,
          ),
        ],
      ),
      body: IndexedStack(index: safeIndex, children: tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: safeIndex,
        onTap: onTabChanged,
        type: BottomNavigationBarType.fixed,
        items: navItems,
      ),
    );
  }
}