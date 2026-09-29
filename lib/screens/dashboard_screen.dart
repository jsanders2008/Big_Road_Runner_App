import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../providers/app_state.dart';
import '../widgets/big_roadrunner_logo.dart';

class DashboardScreen extends StatelessWidget {
  final AppState appState;
  final Function(int) onNavigateToTab;

  const DashboardScreen({
    super.key,
    required this.appState,
    required this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    final profile = appState.profile;
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final numberFormat = NumberFormat('#,##0');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Welcome Banner with BigRoadrunner Logo
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF221A10), Color(0xFF121212)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFFB300).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const BigRoadrunnerLogo(width: 110, height: 60),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Back,',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        profile.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.greenAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            profile.truckNumber,
                            style: const TextStyle(
                              color: Color(0xFFFFC107),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Credentials Alert Banner (if CDL or Medical expiring)
          if (profile.isCdlExpiringSoon || profile.isMedicalExpiringSoon)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[900]?.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Credential Status Notice',
                          style: TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          profile.isCdlExpiringSoon
                              ? 'CDL expires in ${profile.daysUntilCdlExpires} days.'
                              : 'Medical Card expires in ${profile.daysUntilMedicalExpires} days.',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => onNavigateToTab(1), // Go to profile tab
                    child: const Text('VIEW', style: TextStyle(color: Color(0xFFFFC107))),
                  ),
                ],
              ),
            ),

          // Core Performance Metrics Grid
          const Text(
            'FLATBED & FREIGHT METRICS',
            style: TextStyle(
              color: Color(0xFFFFC107),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.45,
            children: [
              _buildMetricCard(
                title: 'Total Mileage',
                value: '${numberFormat.format(appState.totalMilesDriven)} mi',
                icon: Icons.speed_rounded,
                color: Colors.amber,
              ),
              _buildMetricCard(
                title: 'Fuel Expenses',
                value: currencyFormat.format(appState.totalFuelSpent),
                icon: Icons.local_gas_station_rounded,
                color: Colors.deepOrangeAccent,
              ),
              _buildMetricCard(
                title: 'Fleet Avg MPG',
                value: '${appState.overallMpg.toStringAsFixed(1)} MPG',
                icon: Icons.thunderstorm_rounded,
                color: Colors.lightBlueAccent,
              ),
              _buildMetricCard(
                title: 'Logged Runs',
                value: '${appState.trips.length} Runs',
                icon: Icons.assignment_turned_in_rounded,
                color: Colors.greenAccent,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Route Weather Quick Snapshot Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.amber.withOpacity(0.2)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.cloud_sync_rounded, color: Color(0xFFFFC107)),
                          SizedBox(width: 8),
                          Text(
                            'Dispatch Weather Conditions',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                        onPressed: () => onNavigateToTab(3), // Go to Weather tab
                      ),
                    ],
                  ),
                  const Divider(),
                  if (appState.isLoadingWeather)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator(color: Color(0xFFFFC107))),
                    )
                  else if (appState.activeWeatherData != null)
                    Row(
                      children: [
                        Icon(
                          appState.activeWeatherData!.iconData,
                          size: 42,
                          color: appState.activeWeatherData!.iconColor,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${appState.activeWeatherData!.cityName}, ${appState.activeWeatherData!.stateCountry}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                appState.activeWeatherData!.conditionDescription,
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${appState.activeWeatherData!.tempFahrenheit.toStringAsFixed(0)}°F',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFC107),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Recent Trips List Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'RECENT TRIP LOGS',
                style: TextStyle(
                  color: Color(0xFFFFC107),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              TextButton(
                onPressed: () => onNavigateToTab(2), // Go to Trip Logs tab
                child: const Text('View All', style: TextStyle(color: Color(0xFFFFC107))),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (appState.trips.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(
                  child: Text('No trip logs recorded yet. Tap "Trip Logs" to add one!'),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: appState.trips.length > 3 ? 3 : appState.trips.length,
              itemBuilder: (context, index) {
                final trip = appState.trips[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.amber.withOpacity(0.15),
                      child: const Icon(Icons.alt_route_rounded, color: Color(0xFFFFC107)),
                    ),
                    title: Text(
                      '${trip.origin} ➔ ${trip.destination}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    subtitle: Text(
                      '${trip.totalMiles.toStringAsFixed(0)} miles • \$${trip.fuelCost.toStringAsFixed(2)} fuel',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green[900]?.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Text(
                        trip.status,
                        style: const TextStyle(color: Colors.greenAccent, fontSize: 11),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: color.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(color: Colors.grey[400], fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
