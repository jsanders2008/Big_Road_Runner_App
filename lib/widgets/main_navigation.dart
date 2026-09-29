import 'package:flutter/material.dart';

import '../providers/app_state.dart';
import '../screens/dashboard_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/route_weather_screen.dart';
import '../screens/trip_logs_screen.dart';
import 'big_roadrunner_logo.dart';

class MainNavigation extends StatefulWidget {
  final AppState appState;

  const MainNavigation({
    super.key,
    required this.appState,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.appState,
      builder: (context, _) {
        final List<Widget> screens = [
          DashboardScreen(
            appState: widget.appState,
            onNavigateToTab: _onTabTapped,
          ),
          ProfileScreen(appState: widget.appState),
          TripLogsScreen(appState: widget.appState),
          RouteWeatherScreen(appState: widget.appState),
        ];

        return Scaffold(
          appBar: AppBar(
            elevation: 2,
            backgroundColor: const Color(0xFF141414),
            title: Row(
              children: [
                const BigRoadrunnerLogo(width: 85, height: 42),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'BIGROADRUNNER',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFFFC107),
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      _getTabTitle(_currentIndex),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(
                  widget.appState.isDarkMode
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  color: const Color(0xFFFFC107),
                ),
                tooltip: 'Toggle Theme',
                onPressed: () => widget.appState.toggleDarkMode(),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0x33FFB300), width: 1.0),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _onTabTapped,
              type: BottomNavigationBarType.fixed,
              backgroundColor: const Color(0xFF141414),
              selectedItemColor: const Color(0xFFFFC107),
              unselectedItemColor: Colors.grey[600],
              selectedFontSize: 11,
              unselectedFontSize: 11,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_rounded),
                  activeIcon: Icon(Icons.dashboard_rounded, color: Color(0xFFFFC107)),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.badge_rounded),
                  activeIcon: Icon(Icons.badge_rounded, color: Color(0xFFFFC107)),
                  label: 'Profile',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.local_shipping_rounded),
                  activeIcon: Icon(Icons.local_shipping_rounded, color: Color(0xFFFFC107)),
                  label: 'Trip Logs',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.cloud_sync_rounded),
                  activeIcon: Icon(Icons.cloud_sync_rounded, color: Color(0xFFFFC107)),
                  label: 'Weather API',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getTabTitle(int index) {
    switch (index) {
      case 0:
        return 'Driver Dashboard';
      case 1:
        return 'CDL Profile & Specs';
      case 2:
        return 'Trip & Fuel Logs';
      case 3:
        return 'Live Route Weather API';
      default:
        return 'Driver Companion';
    }
  }
}
