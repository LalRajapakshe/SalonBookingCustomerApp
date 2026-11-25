import 'package:flutter/material.dart';

import '../../features/bookings/screens/my_bookings_screen.dart';
import '../../features/explore/screens/explore_screen.dart';
import '../../features/feedback/screens/feedback_gate.dart';
import '../../features/home/screens/customer_home_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../state/app_controller.dart';
import '../state/app_scope.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final body = switch (app.tabIndex) {
      AppTab.explore => const ExploreScreen(),
      AppTab.bookings => const MyBookingsScreen(),
      AppTab.profile => const ProfileScreen(),
      _ => const CustomerHomeScreen(),
    };

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: FeedbackGate(child: body),
      bottomNavigationBar: NavigationBar(
        selectedIndex: app.tabIndex,
        onDestinationSelected: app.setTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome_rounded),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event_rounded),
            label: 'Bookings',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
