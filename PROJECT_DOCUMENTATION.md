**Application Name**: Bigroadrunner  
**Author**: Joshua Sanders  
**Date**: September 28, 2026  

---

## 1. Project Overview

### 1.1 Problem Statement
Commercial truck drivers operate under demanding highway conditions and strict federal compliance regulations. Managing CDL credentials, medical card expiration dates, mileage logs, fuel expenses, and route weather across separate paper logbooks or scattered apps creates inefficiency and safety risks. **Bigroadrunner** solves this by providing a unified, dark-mode, driver-optimized mobile application that consolidates driver credential management, trip/fuel logging, and real-time highway weather intelligence in one place.

### 1.2 Target Audience
This application is designed for long-haul truck drivers, commercial motor vehicle operators, independent freight owner-operators, and dispatchers who require a reliable, high-contrast mobile dashboard to track credentials, log trip metrics, and access live route weather data on the road.

### 1.3 Core Features
● **Feature 1 (Driver Profile & Credential Manager)**: Users can view, update, and manage CDL license details, medical card expiration dates, USDOT numbers, and truck specifications, with automated warning alerts when credentials expire within 60 days.  
● **Feature 2 (Trip Log & Fuel Expense Tracker)**: Users can log completed and active hauls with origin/destination cities, start/end odometer readings, fuel gallon usage, fuel costs, cargo notes, and status indicators (Delivered, In Transit, Scheduled).  
● **Feature 3 (Live Route Weather REST API)**: The app queries the Open-Meteo REST API (`http`) to retrieve real-time temperatures (°F), wind speeds, relative humidity, weather condition descriptions, and 6-hour dispatch forecasts with driving hazard advisories.  
● **Feature 4 (Interactive Animated Splash Screen & Night Mode)**: Includes an intro splash screen with dual animated light sweeps sweeping across the metallic gold Bigroadrunner logo, along with persistent high-contrast dark/light mode toggling for night driving.

---

## 2. Technical Design & Architecture

### 2.1 State Management Strategy
This application utilizes Flutter's native `ChangeNotifier` pattern (`AppState`) combined with `ListenableBuilder` and `AnimatedBuilder` for state management. `AppState` encapsulates application-wide data—including the driver's profile, the filterable list of trip logs, dark mode preferences, and live weather API responses. `ListenableBuilder` widgets at screen roots re-render only dependent UI components when state changes occur. This approach was chosen for its simplicity, high efficiency, zero external framework overhead, and clean separation of business logic from UI widgets.

### 2.2 Data Model
The core data models are `DriverProfile` and `TripLog`. `DriverProfile` encapsulates commercial driver credentials and vehicle specifications. `TripLog` encapsulates individual haul metrics, computing derived properties like total distance, average fleet MPG, and fuel cost per mile.

```dart
// lib/models/driver_profile.dart
class DriverProfile {
  final String name;
  final String cdlNumber;
  final String cdlState;
  final DateTime cdlExpiration;
  final DateTime medicalCardExpiration;
  final String carrierName;
  final String truckNumber;
  final String dotNumber;
  final String emergencyContact;

  DriverProfile({
    required this.name,
    required this.cdlNumber,
    required this.cdlState,
    required this.cdlExpiration,
    required this.medicalCardExpiration,
    required this.carrierName,
    required this.truckNumber,
    required this.dotNumber,
    required this.emergencyContact,
  });

  int get daysUntilCdlExpires =>
      cdlExpiration.difference(DateTime.now()).inDays;

  bool get isCdlExpiringSoon => daysUntilCdlExpires <= 60;

  Map<String, dynamic> toJson() => {
        'name': name,
        'cdlNumber': cdlNumber,
        'cdlState': cdlState,
        'cdlExpiration': cdlExpiration.toIso8601String(),
        'medicalCardExpiration': medicalCardExpiration.toIso8601String(),
        'carrierName': carrierName,
        'truckNumber': truckNumber,
        'dotNumber': dotNumber,
        'emergencyContact': emergencyContact,
      };

  factory DriverProfile.fromJson(Map<String, dynamic> json) => DriverProfile(
        name: json['name'] ?? '',
        cdlNumber: json['cdlNumber'] ?? '',
        cdlState: json['cdlState'] ?? '',
        cdlExpiration: DateTime.parse(json['cdlExpiration']),
        medicalCardExpiration: DateTime.parse(json['medicalCardExpiration']),
        carrierName: json['carrierName'] ?? '',
        truckNumber: json['truckNumber'] ?? '',
        dotNumber: json['dotNumber'] ?? '',
        emergencyContact: json['emergencyContact'] ?? '',
      );
}
```

```dart
// lib/models/trip_log.dart
class TripLog {
  final String id;
  final DateTime date;
  final String origin;
  final String destination;
  final double startOdometer;
  final double endOdometer;
  final double fuelGallons;
  final double fuelCost;
  final String status; // "Delivered", "In Transit", "Scheduled"
  final String notes;

  TripLog({
    required this.id,
    required this.date,
    required this.origin,
    required this.destination,
    required this.startOdometer,
    required this.endOdometer,
    required this.fuelGallons,
    required this.fuelCost,
    required this.status,
    required this.notes,
  });

  double get totalMiles => (endOdometer - startOdometer).clamp(0.0, 999999.0);

  double get avgMpg => (fuelGallons > 0 && totalMiles > 0) ? totalMiles / fuelGallons : 0.0;

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'origin': origin,
        'destination': destination,
        'startOdometer': startOdometer,
        'endOdometer': endOdometer,
        'fuelGallons': fuelGallons,
        'fuelCost': fuelCost,
        'status': status,
        'notes': notes,
      };

  factory TripLog.fromJson(Map<String, dynamic> json) => TripLog(
        id: json['id'],
        date: DateTime.parse(json['date']),
        origin: json['origin'],
        destination: json['destination'],
        startOdometer: (json['startOdometer'] as num).toDouble(),
        endOdometer: (json['endOdometer'] as num).toDouble(),
        fuelGallons: (json['fuelGallons'] as num).toDouble(),
        fuelCost: (json['fuelCost'] as num).toDouble(),
        status: json['status'],
        notes: json['notes'] ?? '',
      );
}
```

### 2.3 Persistence / API Strategy
**Local Data Persistence**:  
The application persists user profile information, trip logs, and dark mode display settings locally on device using the `shared_preferences` package (`StorageService`). Data is serialized into JSON strings (`jsonEncode`) and saved under persistent keys (`bigroadrunner_driver_profile`, `bigroadrunner_trip_logs`, `bigroadrunner_dark_mode`). On application startup, data is automatically restored from storage.

**Web API Integration**:  
The application fetches real-time route weather data using the public **Open-Meteo REST API** via the Flutter `http` package. The primary endpoints consumed are:
- Geocoding Endpoint: `https://geocoding-api.open-meteo.com/v1/search?name={city}&count=1&language=en&format=json`
- Forecast Endpoint: `https://api.open-meteo.com/v1/forecast?latitude={lat}&longitude={lon}&current_weather=true&hourly=temperature_2m,relative_humidity_2m,weather_code&temperature_unit=fahrenheit&wind_speed_unit=mph`

---

### 2.4 Widget Tree Diagram
```
BigroadrunnerApp (StatefulWidget / MaterialApp)
└── ListenableBuilder (listens to AppState)
    └── SplashScreen OR MainNavigation (Scaffold)
        ├── AppBar
        │   ├── BigRoadrunnerLogo (CustomPaint)
        │   ├── Title Column ("BIGROADRUNNER")
        │   └── Theme Toggle IconButton
        ├── IndexedStack (Body)
        │   ├── [Tab 0] DashboardScreen
        │   │   ├── Container (Welcome Banner & Logo)
        │   │   ├── Credential Alert Banner (Conditional)
        │   │   ├── Metrics Grid (4 x MetricCard)
        │   │   ├── Route Weather Snapshot Card
        │   │   └── Recent Trip Activity List
        │   ├── [Tab 1] ProfileScreen
        │   │   ├── Driver Badge Banner
        │   │   ├── Credentials Card (CDL & Medical)
        │   │   ├── Equipment Specs Card (Truck & USDOT)
        │   │   ├── Dark Mode Switch Tile
        │   │   └── "Edit Driver Profile" Button (BottomSheet Form)
        │   ├── [Tab 2] TripLogsScreen
        │   │   ├── Search TextField
        │   │   ├── Summary Header Card
        │   │   ├── Filtered Trip Cards ListView
        │   │   └── FloatingActionButton ("+ LOG NEW TRIP" BottomSheet Form)
        │   └── [Tab 3] RouteWeatherScreen
        │       ├── City Search TextField
        │       ├── Quick City Hub Chips Row
        │       ├── Live Weather Display Card (Temp, Wind, Humidity)
        │       ├── Driving Hazard Road Advisory Card
        │       └── 6-Hour Forecast Horizontal ListView
        └── BottomNavigationBar (4 Navigation Tabs)
```
