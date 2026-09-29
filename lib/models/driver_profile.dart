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

  int get daysUntilMedicalExpires =>
      medicalCardExpiration.difference(DateTime.now()).inDays;

  bool get isCdlExpiringSoon => daysUntilCdlExpires <= 60;
  bool get isMedicalExpiringSoon => daysUntilMedicalExpires <= 60;

  Map<String, dynamic> toJson() {
    return {
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
  }

  factory DriverProfile.fromJson(Map<String, dynamic> json) {
    return DriverProfile(
      name: json['name'] ?? 'Sam "Roadrunner" Carter',
      cdlNumber: json['cdlNumber'] ?? 'CDL-9048211-TX',
      cdlState: json['cdlState'] ?? 'TX',
      cdlExpiration: json['cdlExpiration'] != null
          ? DateTime.parse(json['cdlExpiration'])
          : DateTime.now().add(const Duration(days: 180)),
      medicalCardExpiration: json['medicalCardExpiration'] != null
          ? DateTime.parse(json['medicalCardExpiration'])
          : DateTime.now().add(const Duration(days: 42)),
      carrierName: json['carrierName'] ?? 'Bigroadrunner Logistics LLC',
      truckNumber: json['truckNumber'] ?? 'Unit #708 - Peterbilt 579',
      dotNumber: json['dotNumber'] ?? 'USDOT 3829014',
      emergencyContact: json['emergencyContact'] ?? 'Dispatch: (800) 555-0199',
    );
  }

  DriverProfile copyWith({
    String? name,
    String? cdlNumber,
    String? cdlState,
    DateTime? cdlExpiration,
    DateTime? medicalCardExpiration,
    String? carrierName,
    String? truckNumber,
    String? dotNumber,
    String? emergencyContact,
  }) {
    return DriverProfile(
      name: name ?? this.name,
      cdlNumber: cdlNumber ?? this.cdlNumber,
      cdlState: cdlState ?? this.cdlState,
      cdlExpiration: cdlExpiration ?? this.cdlExpiration,
      medicalCardExpiration:
          medicalCardExpiration ?? this.medicalCardExpiration,
      carrierName: carrierName ?? this.carrierName,
      truckNumber: truckNumber ?? this.truckNumber,
      dotNumber: dotNumber ?? this.dotNumber,
      emergencyContact: emergencyContact ?? this.emergencyContact,
    );
  }

  static DriverProfile defaultProfile() {
    return DriverProfile(
      name: 'Sam "Roadrunner" Carter',
      cdlNumber: 'CDL-9048211-TX',
      cdlState: 'TX',
      cdlExpiration: DateTime.now().add(const Duration(days: 180)),
      medicalCardExpiration: DateTime.now().add(const Duration(days: 42)),
      carrierName: 'Bigroadrunner Logistics LLC',
      truckNumber: 'Unit #708 - Peterbilt 579',
      dotNumber: 'USDOT 3829014',
      emergencyContact: 'Dispatch: (800) 555-0199',
    );
  }
}
