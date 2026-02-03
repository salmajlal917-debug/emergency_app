class EmergencyContact {
  final String name;
  final String phoneNumber;
  final String? relationship;

  EmergencyContact({
    required this.name,
    required this.phoneNumber,
    this.relationship,
  });
}

class EmergencyService {
  final String name;
  final String phoneNumber;
  final String type;
  final String icon;

  EmergencyService({
    required this.name,
    required this.phoneNumber,
    required this.type,
    required this.icon,
  });
}

class LocationData {
  final double latitude;
  final double longitude;
  final String address;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.address,
  });
}
