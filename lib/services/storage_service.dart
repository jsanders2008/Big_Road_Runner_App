import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/driver_profile.dart';
import '../models/trip_log.dart';

class StorageService {
  static const String _keyProfile = 'bigroadrunner_driver_profile';
  static const String _keyTrips = 'bigroadrunner_trip_logs';
  static const String _keyDarkMode = 'bigroadrunner_dark_mode';

  /// Save driver profile locally
  Future<bool> saveProfile(DriverProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(profile.toJson());
    return await prefs.setString(_keyProfile, jsonStr);
  }

  /// Load driver profile from local storage, fallback to default
  Future<DriverProfile> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyProfile);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final Map<String, dynamic> map = jsonDecode(jsonStr);
        return DriverProfile.fromJson(map);
      } catch (_) {
        // Fallback on parse error
      }
    }
    final defaultProf = DriverProfile.defaultProfile();
    await saveProfile(defaultProf);
    return defaultProf;
  }

  /// Save list of trip logs locally
  Future<bool> saveTrips(List<TripLog> trips) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = trips.map((t) => t.toJson()).toList();
    final jsonStr = jsonEncode(jsonList);
    return await prefs.setString(_keyTrips, jsonStr);
  }

  /// Load list of trip logs from local storage, fallback to sample trips
  Future<List<TripLog>> loadTrips() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyTrips);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(jsonStr);
        return list.map((item) => TripLog.fromJson(item)).toList();
      } catch (_) {
        // Fallback on parse error
      }
    }
    final defaultTrips = TripLog.defaultSampleTrips();
    await saveTrips(defaultTrips);
    return defaultTrips;
  }

  /// Save dark mode preference
  Future<bool> saveDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(_keyDarkMode, isDark);
  }

  /// Load dark mode preference
  Future<bool> loadDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDarkMode) ?? true; // Default to dark mode for Bigroadrunner
  }
}
