import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/announcement_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/branch_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/poll_provider.dart';
import '../admin/admin_dashboard_screen.dart';
import '../announcements/announcement_feed_screen.dart';
import '../events/event_list_screen.dart';
import '../notifications/notification_screen.dart';
import '../polls/poll_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  static const _titles = [
    'Announcements',
    'Polls',
    'Events',
    'Notifications',
    'Admin',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = context.read<AuthProvider>().profile;
      if (profile != null) {
        context.read<NotificationProvider>().startListening(profile.id);
        context.read<BranchProvider>().loadBranches();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isAdmin = authProvider.isAdmin;
    final unreadCount =
        context.watch<NotificationProvider>().unreadCount;

    final tabs = <Widget>[
      const AnnouncementFeedScreen(),
      const PollScreen(),
      const EventListScreen(),
      const NotificationScreen(),
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
      BottomNavigationBarItem(
        icon: Badge(
          isLabelVisible: unreadCount > 0,
          label: Text('$unreadCount'),
          child: const Icon(Icons.notifications_outlined),
        ),
        activeIcon: Badge(
          isLabelVisible: unreadCount > 0,
          label: Text('$unreadCount'),
          child: const Icon(Icons.notifications),
        ),
        label: 'Alerts',
      ),
      if (isAdmin)
        const BottomNavigationBarItem(
          icon: Icon(Icons.admin_panel_settings_outlined),
          activeIcon: Icon(Icons.admin_panel_settings),
          label: 'Admin',
        ),
    ];

    final safeIndex = _currentIndex < tabs.length ? _currentIndex : 0;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AnnouncementProvider()),
        ChangeNotifierProvider(create: (_) => PollProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(_titles[safeIndex]),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sign out',
              onPressed: () => authProvider.signOut(),
            ),
          ],
        ),
        body: IndexedStack(index: safeIndex, children: tabs),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: safeIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          type: BottomNavigationBarType.fixed,
          items: navItems,
        ),
      ),
    );
  }
}