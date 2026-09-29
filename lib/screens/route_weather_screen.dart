import 'package:flutter/material.dart';

import '../providers/app_state.dart';
import '../services/weather_service.dart';

class RouteWeatherScreen extends StatefulWidget {
  final AppState appState;

  const RouteWeatherScreen({
    super.key,
    required this.appState,
  });

  @override
  State<RouteWeatherScreen> createState() => _RouteWeatherScreenState();
}

class _RouteWeatherScreenState extends State<RouteWeatherScreen> {
  final TextEditingController _cityController = TextEditingController();

  final List<String> _quickCities = [
    'Dallas, TX',
    'Atlanta, GA',
    'Chicago, IL',
    'Denver, CO',
    'Phoenix, AZ',
    'Seattle, WA',
  ];

  @override
  void initState() {
    super.initState();
    _cityController.text = widget.appState.selectedWeatherCity;
  }

  void _searchCity(String city) {
    if (city.trim().isNotEmpty) {
      widget.appState.fetchWeatherForCity(city.trim());
    }
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weather = widget.appState.activeWeatherData;
    final isLoading = widget.appState.isLoadingWeather;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // City Search Bar
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    hintText: 'Enter dispatch city (e.g., Chicago, IL)...',
                    prefixIcon: const Icon(Icons.location_city, color: Color(0xFFFFC107)),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search, color: Color(0xFFFFC107)),
                      onPressed: () => _searchCity(_cityController.text),
                    ),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (val) => _searchCity(val),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Quick City Hub Chips
          SizedBox(
            height: 38,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _quickCities.length,
              itemBuilder: (context, index) {
                final city = _quickCities[index];
                final isSelected = widget.appState.selectedWeatherCity.toLowerCase() == city.toLowerCase();
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(
                      city,
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.black : const Color(0xFFFFC107),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selectedColor: const Color(0xFFFFC107),
                    backgroundColor: const Color(0xFF1E1E1E),
                    checkmarkColor: Colors.black,
                    onSelected: (_) {
                      _cityController.text = city;
                      _searchCity(city);
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // Main Live Weather Display Card
          if (isLoading)
            const Card(
              child: SizedBox(
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Color(0xFFFFC107)),
                      SizedBox(height: 12),
                      Text('Fetching live satellite weather via Open-Meteo REST API...'),
                    ],
                  ),
                ),
              ),
            )
          else if (weather != null) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E1F10), Color(0xFF141414)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFFB300), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: weather.iconColor.withOpacity(0.2),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            weather.cityName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            weather.stateCountry,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFFFFC107),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC107).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFFC107)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.wifi_tethering, size: 14, color: Color(0xFFFFC107)),
                            SizedBox(width: 4),
                            Text(
                              'REST API Live',
                              style: TextStyle(
                                color: Color(0xFFFFC107),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Icon(weather.iconData, size: 64, color: weather.iconColor),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${weather.tempFahrenheit.toStringAsFixed(0)}°F',
                            style: const TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFFC107),
                            ),
                          ),
                          Text(
                            weather.conditionDescription,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Wind & Humidity Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildWeatherSubStat(
                        icon: Icons.air_rounded,
                        label: 'WIND SPEED',
                        value: '${weather.windSpeedMph.toStringAsFixed(1)} mph',
                      ),
                      _buildWeatherSubStat(
                        icon: Icons.water_drop_rounded,
                        label: 'HUMIDITY',
                        value: '${weather.humidity}%',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Driver Road Advisory Card
            _buildDriverRoadAdvisory(weather),
            const SizedBox(height: 20),

            // Hourly Route Forecast Header
            const Text(
              '6-HOUR DISPATCH FORECAST',
              style: TextStyle(
                color: Color(0xFFFFC107),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),

            if (weather.hourlyForecasts.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: weather.hourlyForecasts.length,
                  itemBuilder: (context, index) {
                    final item = weather.hourlyForecasts[index];
                    return Container(
                      width: 80,
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.withOpacity(0.15)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item.timeString,
                            style: TextStyle(color: Colors.grey[400], fontSize: 11),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${item.tempF.toStringAsFixed(0)}°',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFFFFC107),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildWeatherSubStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFFFFC107), size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(color: Colors.grey[400], fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildDriverRoadAdvisory(RouteWeatherData weather) {
    String advisoryTitle;
    String advisoryText;
    Color advisoryColor;
    IconData advisoryIcon;

    if (weather.windSpeedMph > 25) {
      advisoryTitle = 'HIGH WIND ADVISORY';
      advisoryText = 'Winds exceeding 25 mph. Maintain firm grip on wheel for empty flatbed / high-cube vans.';
      advisoryColor = Colors.orangeAccent;
      advisoryIcon = Icons.warning_amber_rounded;
    } else if (weather.weatherCode >= 71) {
      advisoryTitle = 'SNOW & ICE ADVISORY';
      advisoryText = 'Freezing road temperatures detected. Ensure tire chains are ready and reduce highway speed.';
      advisoryColor = Colors.lightBlueAccent;
      advisoryIcon = Icons.ac_unit_rounded;
    } else if (weather.weatherCode >= 61) {
      advisoryTitle = 'WET ROAD ADVISORY';
      advisoryText = 'Active rainfall along route. Increase braking distance for loaded semi trucks.';
      advisoryColor = Colors.cyanAccent;
      advisoryIcon = Icons.grain_rounded;
    } else {
      advisoryTitle = 'FAIR HIGHWAY CONDITIONS';
      advisoryText = 'Optimum road conditions reported along current dispatch route. Safe trucking!';
      advisoryColor = Colors.greenAccent;
      advisoryIcon = Icons.check_circle_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: advisoryColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: advisoryColor, width: 1.0),
      ),
      child: Row(
        children: [
          Icon(advisoryIcon, color: advisoryColor, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  advisoryTitle,
                  style: TextStyle(color: advisoryColor, fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  advisoryText,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
