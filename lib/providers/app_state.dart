import 'package:flutter/material.dart';

import '../models/driver_profile.dart';
import '../models/trip_log.dart';
import '../services/storage_service.dart';
import '../services/weather_service.dart';

class AppState extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  final WeatherService _weatherService = WeatherService();

  DriverProfile _profile = DriverProfile.defaultProfile();
  List<TripLog> _trips = [];
  bool _isDarkMode = true;
  bool _isLoading = true;

  // Weather state
  RouteWeatherData? _activeWeatherData;
  bool _isLoadingWeather = false;
  String _selectedWeatherCity = 'Dallas, TX';

  // Search filter query for trip logs
  String _tripSearchQuery = '';

  // Getters
  DriverProfile get profile => _profile;
  List<TripLog> get trips => _trips;
  bool get isDarkMode => _isDarkMode;
  bool get isLoading => _isLoading;

  RouteWeatherData? get activeWeatherData => _activeWeatherData;
  bool get isLoadingWeather => _isLoadingWeather;
  String get selectedWeatherCity => _selectedWeatherCity;
  String get tripSearchQuery => _tripSearchQuery;

  /// Filtered list of trips based on search query
  List<TripLog> get filteredTrips {
    if (_tripSearchQuery.trim().isEmpty) {
      return _trips;
    }
    final q = _tripSearchQuery.toLowerCase();
    return _trips.where((t) {
      return t.origin.toLowerCase().contains(q) ||
          t.destination.toLowerCase().contains(q) ||
          t.notes.toLowerCase().contains(q) ||
          t.status.toLowerCase().contains(q);
    }).toList();
  }

  // Derived Analytics Metrics
  double get totalMilesDriven {
    return _trips.fold(0.0, (sum, item) => sum + item.totalMiles);
  }

  double get totalFuelSpent {
    return _trips.fold(0.0, (sum, item) => sum + item.fuelCost);
  }

  double get totalFuelGallons {
    return _trips.fold(0.0, (sum, item) => sum + item.fuelGallons);
  }

  double get overallMpg {
    if (totalFuelGallons <= 0) return 0.0;
    return totalMilesDriven / totalFuelGallons;
  }

  /// Initialize state from local storage and fetch initial route weather
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    _profile = await _storageService.loadProfile();
    _trips = await _storageService.loadTrips();
    _isDarkMode = await _storageService.loadDarkMode();

    _isLoading = false;
    notifyListeners();

    // Fetch initial weather for driver's primary dispatch hub
    fetchWeatherForCity('Dallas, TX');
  }

  /// Toggle dark/light theme
  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    await _storageService.saveDarkMode(_isDarkMode);
  }

  /// Update driver profile
  Future<void> updateProfile(DriverProfile newProfile) async {
    _profile = newProfile;
    notifyListeners();
    await _storageService.saveProfile(_profile);
  }

  /// Add new trip log
  Future<void> addTrip(TripLog trip) async {
    _trips.insert(0, trip);
    notifyListeners();
    await _storageService.saveTrips(_trips);
  }

  /// Delete trip log
  Future<void> deleteTrip(String tripId) async {
    _trips.removeWhere((t) => t.id == tripId);
    notifyListeners();
    await _storageService.saveTrips(_trips);
  }

  /// Set search query for trip filtering
  void setTripSearchQuery(String query) {
    _tripSearchQuery = query;
    notifyListeners();
  }

  /// Fetch live route weather for a city
  Future<void> fetchWeatherForCity(String cityName) async {
    if (cityName.trim().isEmpty) return;
    _selectedWeatherCity = cityName;
    _isLoadingWeather = true;
    notifyListeners();

    try {
      _activeWeatherData = await _weatherService.fetchWeatherForCity(cityName);
    } catch (_) {
      // Keep existing or fallback
    } finally {
      _isLoadingWeather = false;
      notifyListeners();
    }
  }
}
