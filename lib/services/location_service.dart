import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static LocationService? _instance;
  static LocationService get instance =>
      _instance ??= LocationService._internal();
  LocationService._internal();

  // Dummy dealer locations (dalam aplikasi nyata, ini dari API)
  static const List<DealerLocation> _dummyDealers = [
    DealerLocation(
      id: 1,
      name: 'Dealer Toyota Sudirman',
      address: 'Jl. Sudirman No. 123, Jakarta Pusat',
      latitude: -6.2088,
      longitude: 106.8456,
      phone: '021-12345678',
      brands: ['Toyota', 'Lexus'],
    ),
    DealerLocation(
      id: 2,
      name: 'Dealer Honda Kelapa Gading',
      address: 'Jl. Kelapa Gading Raya No. 45, Jakarta Utara',
      latitude: -6.1584,
      longitude: 106.9055,
      phone: '021-87654321',
      brands: ['Honda'],
    ),
    DealerLocation(
      id: 3,
      name: 'Dealer Mitsubishi Kuningan',
      address: 'Jl. Kuningan Barat No. 67, Jakarta Selatan',
      latitude: -6.2297,
      longitude: 106.8302,
      phone: '021-11223344',
      brands: ['Mitsubishi'],
    ),
    DealerLocation(
      id: 4,
      name: 'Dealer Nissan Kemang',
      address: 'Jl. Kemang Raya No. 89, Jakarta Selatan',
      latitude: -6.2615,
      longitude: 106.8106,
      phone: '021-55667788',
      brands: ['Nissan', 'Infiniti'],
    ),
    DealerLocation(
      id: 5,
      name: 'Dealer Suzuki Cibubur',
      address: 'Jl. Raya Cibubur No. 101, Depok',
      latitude: -6.3751,
      longitude: 106.8650,
      phone: '021-99887766',
      brands: ['Suzuki'],
    ),
  ];

  /// Check and request location permissions
  Future<bool> checkAndRequestPermissions() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return false;
      }

      // Check permission status
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return false;
      }

      return true;
    } catch (e) {
      print('Error checking permissions: $e');
      return false;
    }
  }

  /// Get current user location
  Future<Position?> getCurrentLocation() async {
    try {
      bool hasPermission = await checkAndRequestPermissions();
      if (!hasPermission) {
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );

      return position;
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  /// Calculate distance between two points in kilometers
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
          startLatitude,
          startLongitude,
          endLatitude,
          endLongitude,
        ) /
        1000; // Convert to kilometers
  }

  /// Get nearest dealers based on current location
  Future<List<DealerWithDistance>> getNearestDealers({
    Position? userLocation,
    int? limit,
    double? maxDistanceKm,
  }) async {
    try {
      Position? currentPosition = userLocation ?? await getCurrentLocation();

      if (currentPosition == null) {
        // If can't get location, return all dealers without distance calculation
        return _dummyDealers
            .map((dealer) => DealerWithDistance(
                  dealer: dealer,
                  distanceKm: null,
                ))
            .take(limit ?? _dummyDealers.length)
            .toList();
      }

      // Calculate distances and sort by nearest
      List<DealerWithDistance> dealersWithDistance =
          _dummyDealers.map((dealer) {
        double distance = calculateDistance(
          currentPosition.latitude,
          currentPosition.longitude,
          dealer.latitude,
          dealer.longitude,
        );

        return DealerWithDistance(
          dealer: dealer,
          distanceKm: distance,
        );
      }).toList();

      // Sort by distance (nearest first)
      dealersWithDistance.sort((a, b) {
        if (a.distanceKm == null && b.distanceKm == null) return 0;
        if (a.distanceKm == null) return 1;
        if (b.distanceKm == null) return -1;
        return a.distanceKm!.compareTo(b.distanceKm!);
      });

      // Filter by max distance if specified
      if (maxDistanceKm != null) {
        dealersWithDistance = dealersWithDistance
            .where(
                (d) => d.distanceKm != null && d.distanceKm! <= maxDistanceKm)
            .toList();
      }

      // Limit results if specified
      if (limit != null && dealersWithDistance.length > limit) {
        dealersWithDistance = dealersWithDistance.take(limit).toList();
      }

      return dealersWithDistance;
    } catch (e) {
      print('Error getting nearest dealers: $e');
      return [];
    }
  }

  /// Get dealers by brand
  List<DealerLocation> getDealersByBrand(String brand) {
    return _dummyDealers
        .where((dealer) => dealer.brands
            .any((b) => b.toLowerCase().contains(brand.toLowerCase())))
        .toList();
  }

  /// Get dealer by ID
  DealerLocation? getDealerById(int id) {
    try {
      return _dummyDealers.firstWhere((dealer) => dealer.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Open location settings
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// Open app settings
  Future<void> openAppSettings() async {
    await openAppSettings();
  }

  /// Format distance for display
  static String formatDistance(double? distanceKm) {
    if (distanceKm == null) return 'Jarak tidak diketahui';

    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()} m';
    } else {
      return '${distanceKm.toStringAsFixed(1)} km';
    }
  }

  /// Check if location services are available
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Get location permission status
  Future<LocationPermission> getLocationPermission() async {
    return await Geolocator.checkPermission();
  }
}

/// Model for dealer location
class DealerLocation {
  final int id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String phone;
  final List<String> brands;

  const DealerLocation({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.brands,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'brands': brands,
    };
  }

  factory DealerLocation.fromMap(Map<String, dynamic> map) {
    return DealerLocation(
      id: map['id'],
      name: map['name'],
      address: map['address'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      phone: map['phone'],
      brands: List<String>.from(map['brands']),
    );
  }
}

/// Model for dealer with calculated distance
class DealerWithDistance {
  final DealerLocation dealer;
  final double? distanceKm;

  DealerWithDistance({
    required this.dealer,
    this.distanceKm,
  });

  String get formattedDistance => LocationService.formatDistance(distanceKm);
}
