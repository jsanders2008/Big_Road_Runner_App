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

  double get avgMpg {
    if (fuelGallons <= 0 || totalMiles <= 0) return 0.0;
    return totalMiles / fuelGallons;
  }

  double get costPerMile {
    if (totalMiles <= 0 || fuelCost <= 0) return 0.0;
    return fuelCost / totalMiles;
  }

  Map<String, dynamic> toJson() {
    return {
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
  }

  factory TripLog.fromJson(Map<String, dynamic> json) {
    return TripLog(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      origin: json['origin'] ?? 'Origin',
      destination: json['destination'] ?? 'Destination',
      startOdometer: (json['startOdometer'] ?? 0.0).toDouble(),
      endOdometer: (json['endOdometer'] ?? 0.0).toDouble(),
      fuelGallons: (json['fuelGallons'] ?? 0.0).toDouble(),
      fuelCost: (json['fuelCost'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'Delivered',
      notes: json['notes'] ?? '',
    );
  }

  TripLog copyWith({
    String? id,
    DateTime? date,
    String? origin,
    String? destination,
    double? startOdometer,
    double? endOdometer,
    double? fuelGallons,
    double? fuelCost,
    String? status,
    String? notes,
  }) {
    return TripLog(
      id: id ?? this.id,
      date: date ?? this.date,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      startOdometer: startOdometer ?? this.startOdometer,
      endOdometer: endOdometer ?? this.endOdometer,
      fuelGallons: fuelGallons ?? this.fuelGallons,
      fuelCost: fuelCost ?? this.fuelCost,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  static List<TripLog> defaultSampleTrips() {
    final now = DateTime.now();
    return [
      TripLog(
        id: '101',
        date: now.subtract(const Duration(days: 1)),
        origin: 'Dallas, TX',
        destination: 'Atlanta, GA',
        startOdometer: 142100,
        endOdometer: 142880,
        fuelGallons: 118.5,
        fuelCost: 438.45,
        status: 'Delivered',
        notes: 'Dry van load #8841. On-time drop-off at Atlanta Hub.',
      ),
      TripLog(
        id: '102',
        date: now.subtract(const Duration(days: 3)),
        origin: 'El Paso, TX',
        destination: 'Phoenix, AZ',
        startOdometer: 141670,
        endOdometer: 142100,
        fuelGallons: 64.0,
        fuelCost: 236.80,
        status: 'Delivered',
        notes: 'Reefer load at 34°F. Smooth drive across I-10.',
      ),
      TripLog(
        id: '103',
        date: now.subtract(const Duration(days: 5)),
        origin: 'Houston, TX',
        destination: 'New Orleans, LA',
        startOdometer: 141320,
        endOdometer: 141670,
        fuelGallons: 52.0,
        fuelCost: 192.40,
        status: 'Delivered',
        notes: 'Heavy rain around Baton Rouge. Driver check-in complete.',
      ),
    ];
  }
}
