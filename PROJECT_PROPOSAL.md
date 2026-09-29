# Project Proposal: Bigroadrunner LLC

**App Name**: Bigroadrunner  
**Author**: Joshua Sanders  
**Concept**: A dedicated mobile companion app designed for commercial truck drivers and owner-operators to manage professional driver credentials, log trips and fuel expenses, monitor safety alerts, and fetch real-time route weather conditions.

---

## 1. Problem Statement
Commercial truck drivers operate under demanding schedules and strict safety regulations. Managing CDL credentials, medical card expiration dates, mileage logs, fuel expenses, and route weather across separate platforms or paper logbooks is inefficient and prone to error. **Bigroadrunner** solves this problem by providing a centralized, driver-friendly mobile application optimized for cab use with dark-mode high contrast, offline persistence, and live highway weather intelligence.

---

## 2. Target Audience
- Commercial Motor Vehicle (CMV) drivers & long-haul truckers.
- Independent owner-operators and fleet drivers.
- Freight dispatchers needing quick credential verification and trip summary metrics.

---

## 3. Core Features
1. **Driver Profile & Credential Manager**: Displays professional credentials (CDL license, state, expiration date, USDOT/MC numbers, assigned truck unit, and medical card status) with automated alert warnings when credentials require renewal within 60 days.
2. **Trip Log & Mileage Tracker**: Enables drivers to record completed and active hauls with start/end odometer readings, fuel gallon usage, fuel costs, trip status (Delivered, In Transit, Scheduled), and cargo notes.
3. **Live Route Weather REST API Integration**: Queries the Open-Meteo REST API (`http`) to retrieve live temperatures, wind speeds, humidity, weather descriptions, and a 6-hour forecast timeline for dispatch locations along the highway. Includes safety advisories for high winds, rain, or icy conditions.
4. **Performance & Analytics Dashboard**: Provides high-level summary cards displaying total miles driven, total fuel expenditure, average fleet MPG, and quick access to recent trip logs.

---

## 4. Data Model & Public API
- **Data Persistence**: Uses `shared_preferences` (`StorageService`) to persist `DriverProfile`, `TripLog` collections, and `isDarkMode` display settings locally on device so data remains accessible offline.
- **Public REST API**: Integrates with the **Open-Meteo REST API** (`https://api.open-meteo.com` & `https://geocoding-api.open-meteo.com`) via the `http` package for geocoding city names and fetching live weather parameters without requiring an API key.
