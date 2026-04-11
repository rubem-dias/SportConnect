class NearbyUser {
  const NearbyUser({
    required this.userId,
    required this.name,
    required this.username,
    required this.sports, required this.level, required this.distanceMeters, this.avatar,
    this.isOnline = false,
    this.lat,
    this.lng,
  });

  final String userId;
  final String name;
  final String username;
  final String? avatar;
  final List<String> sports;
  final String level;
  final double distanceMeters;
  final bool isOnline;
  final double? lat;
  final double? lng;

  String get distanceLabel {
    if (distanceMeters < 1000) {
      return '${distanceMeters.toInt()}m';
    }
    return '${(distanceMeters / 1000).toStringAsFixed(1)}km';
  }
}

class NearbyGym {
  const NearbyGym({
    required this.id,
    required this.name,
    required this.distanceMeters, this.address,
    this.photo,
    this.rating,
    this.isOpen,
    this.lat,
    this.lng,
  });

  final String id;
  final String name;
  final String? address;
  final String? photo;
  final double distanceMeters;
  final double? rating;
  final bool? isOpen;
  final double? lat;
  final double? lng;

  String get distanceLabel {
    if (distanceMeters < 1000) return '${distanceMeters.toInt()}m';
    return '${(distanceMeters / 1000).toStringAsFixed(1)}km';
  }
}

enum PrivacyMode { exact, neighborhood, disabled }
