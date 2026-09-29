import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CityLocation {
  final String name;
  final String stateCountry;
  final double latitude;
  final double longitude;

  CityLocation({
    required this.name,
    required this.stateCountry,
    required this.latitude,
    required this.longitude,
  });
}

class RouteWeatherData {
  final String cityName;
  final String stateCountry;
  final double tempFahrenheit;
  final double windSpeedMph;
  final int weatherCode;
  final int humidity;
  final String conditionDescription;
  final IconData iconData;
  final Color iconColor;
  final List<HourlyForecast> hourlyForecasts;

  RouteWeatherData({
    required this.cityName,
    required this.stateCountry,
    required this.tempFahrenheit,
    required this.windSpeedMph,
    required this.weatherCode,
    required this.humidity,
    required this.conditionDescription,
    required this.iconData,
    required this.iconColor,
    required this.hourlyForecasts,
  });
}

class HourlyForecast {
  final String timeString;
  final double tempF;
  final int weatherCode;

  HourlyForecast({
    required this.timeString,
    required this.tempF,
    required this.weatherCode,
  });
}

class WeatherService {
  /// Geocode city name to lat/long using Open-Meteo Geocoding REST API
  Future<CityLocation?> geocodeCity(String cityName) async {
    final query = Uri.encodeComponent(cityName.trim());
    final url = Uri.parse(
        'https://geocoding-api.open-meteo.com/v1/search?name=$query&count=1&language=en&format=json');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['results'] != null && (data['results'] as List).isNotEmpty) {
          final first = data['results'][0];
          final String name = first['name'] ?? cityName;
          final String admin = first['admin1'] ?? first['country'] ?? '';
          final double lat = (first['latitude'] as num).toDouble();
          final double lon = (first['longitude'] as num).toDouble();
          return CityLocation(
            name: name,
            stateCountry: admin,
            latitude: lat,
            longitude: lon,
          );
        }
      }
    } catch (_) {
      // Return null on failure or offline
    }
    return null;
  }

  /// Fetch live weather and forecast from Open-Meteo Forecast REST API
  Future<RouteWeatherData> fetchWeatherForCity(String cityName) async {
    CityLocation? location = await geocodeCity(cityName);

    // Fallback coordinates (Dallas, TX) if city not found or offline
    final double lat = location?.latitude ?? 32.7767;
    final double lon = location?.longitude ?? -96.7970;
    final String resolvedCity = location?.name ?? cityName;
    final String resolvedState = location?.stateCountry ?? 'TX';

    final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true&hourly=temperature_2m,relative_humidity_2m,weather_code&temperature_unit=fahrenheit&wind_speed_unit=mph');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final currentWeather = data['current_weather'];

        final double tempF = (currentWeather['temperature'] as num).toDouble();
        final double windMph = (currentWeather['windspeed'] as num).toDouble();
        final int code = (currentWeather['weathercode'] as num).toInt();

        int humidity = 50;
        final hourlyMap = data['hourly'];
        if (hourlyMap != null && hourlyMap['relative_humidity_2m'] != null) {
          final humList = hourlyMap['relative_humidity_2m'] as List;
          if (humList.isNotEmpty) {
            humidity = (humList[0] as num).toInt();
          }
        }

        // Parse 6-hour forecast points
        final List<HourlyForecast> forecast = [];
        if (hourlyMap != null &&
            hourlyMap['time'] != null &&
            hourlyMap['temperature_2m'] != null) {
          final times = hourlyMap['time'] as List;
          final temps = hourlyMap['temperature_2m'] as List;
          final codes = hourlyMap['weather_code'] as List;

          final int maxCount = times.length < 8 ? times.length : 8;
          for (int i = 0; i < maxCount; i += 2) {
            final String rawTime = times[i].toString();
            final String timeLabel = rawTime.contains('T')
                ? rawTime.split('T')[1].substring(0, 5)
                : '$i:00';
            forecast.add(HourlyForecast(
              timeString: timeLabel,
              tempF: (temps[i] as num).toDouble(),
              weatherCode: (codes[i] as num).toInt(),
            ));
          }
        }

        final info = _interpretWeatherCode(code);

        return RouteWeatherData(
          cityName: resolvedCity,
          stateCountry: resolvedState,
          tempFahrenheit: tempF,
          windSpeedMph: windMph,
          weatherCode: code,
          humidity: humidity,
          conditionDescription: info.description,
          iconData: info.icon,
          iconColor: info.color,
          hourlyForecasts: forecast,
        );
      }
    } catch (_) {
      // Fallback on error/offline
    }

    // Default offline/demo payload
    final info = _interpretWeatherCode(0);
    return RouteWeatherData(
      cityName: resolvedCity,
      stateCountry: resolvedState,
      tempFahrenheit: 74.5,
      windSpeedMph: 9.2,
      weatherCode: 0,
      humidity: 45,
      conditionDescription: 'Clear Highways (Offline Mode)',
      iconData: info.icon,
      iconColor: info.color,
      hourlyForecasts: [
        HourlyForecast(timeString: '12:00', tempF: 75.0, weatherCode: 0),
        HourlyForecast(timeString: '14:00', tempF: 78.0, weatherCode: 1),
        HourlyForecast(timeString: '16:00', tempF: 77.0, weatherCode: 2),
        HourlyForecast(timeString: '18:00', tempF: 71.0, weatherCode: 0),
      ],
    );
  }

  _WeatherInfo _interpretWeatherCode(int code) {
    switch (code) {
      case 0:
        return _WeatherInfo('Clear Sky / Sunny', Icons.wb_sunny, Colors.amber);
      case 1:
      case 2:
        return _WeatherInfo('Partly Cloudy', Icons.wb_cloudy, Colors.lightBlue);
      case 3:
        return _WeatherInfo('Overcast', Icons.cloud, Colors.blueGrey);
      case 45:
      case 48:
        return _WeatherInfo('Foggy / Low Visibility', Icons.blur_on, Colors.blueGrey);
      case 51:
      case 53:
      case 55:
        return _WeatherInfo('Light Drizzle', Icons.water_drop, Colors.cyan);
      case 61:
      case 63:
      case 65:
        return _WeatherInfo('Rain / Wet Roads', Icons.grain, Colors.blue);
      case 71:
      case 73:
      case 75:
        return _WeatherInfo('Snowfall / Icy Road Alert', Icons.ac_unit, Colors.lightBlueAccent);
      case 80:
      case 81:
      case 82:
        return _WeatherInfo('Heavy Rain Showers', Icons.thunderstorm, Colors.indigo);
      case 95:
      case 96:
      case 99:
        return _WeatherInfo('Severe Thunderstorm Warning', Icons.flash_on, Colors.deepOrange);
      default:
        return _WeatherInfo('Fair Route Conditions', Icons.wb_sunny, Colors.amber);
    }
  }
}

class _WeatherInfo {
  final String description;
  final IconData icon;
  final Color color;

  _WeatherInfo(this.description, this.icon, this.color);
}
