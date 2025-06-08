import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';

class LBSScreen extends StatefulWidget {
  @override
  _LBSScreenState createState() => _LBSScreenState();
}

class _LBSScreenState extends State<LBSScreen> {
  final LocationService _locationService = LocationService.instance;

  bool _isLoading = false;
  bool _hasLocationPermission = false;
  Position? _currentPosition;
  List<DealerWithDistance> _nearbyDealers = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndLoadDealers();
  }

  Future<void> _checkPermissionsAndLoadDealers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check if location services are enabled first
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _hasLocationPermission = false;
          _errorMessage =
              'Layanan lokasi tidak aktif. Aktifkan GPS untuk mendapatkan dealer terdekat.';
        });
        await _loadDealersWithoutLocation();
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Check permission status
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _hasLocationPermission = false;
          _errorMessage = permission == LocationPermission.deniedForever
              ? 'Izin lokasi ditolak permanen. Buka pengaturan untuk mengaktifkan.'
              : 'Izin lokasi diperlukan untuk menampilkan dealer terdekat dengan jarak akurat.';
        });
        await _loadDealersWithoutLocation();
      } else {
        // Permission granted
        setState(() {
          _hasLocationPermission = true;
        });
        await _loadCurrentLocationAndDealers();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: $e';
        _hasLocationPermission = false;
      });
      await _loadDealersWithoutLocation();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCurrentLocationAndDealers() async {
    try {
      Position? position = await _locationService.getCurrentLocation();

      if (position != null) {
        setState(() {
          _currentPosition = position;
        });

        List<DealerWithDistance> dealers =
            await _locationService.getNearestDealers(
          userLocation: position,
          limit: 10,
        );

        setState(() {
          _nearbyDealers = dealers;
        });
      } else {
        setState(() {
          _errorMessage = 'Tidak dapat mendapatkan lokasi saat ini';
        });
        await _loadDealersWithoutLocation();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error mendapatkan lokasi: $e';
      });
      await _loadDealersWithoutLocation();
    }
  }

  Future<void> _loadDealersWithoutLocation() async {
    try {
      List<DealerWithDistance> dealers =
          await _locationService.getNearestDealers();
      setState(() {
        _nearbyDealers = dealers;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error memuat data dealer: $e';
      });
    }
  }

  Future<void> _requestLocationPermission() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Layanan lokasi tidak aktif. Silakan aktifkan GPS di pengaturan.';
        });

        // Show dialog to open location settings
        bool openSettings = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Layanan Lokasi Tidak Aktif'),
              content: Text(
                  'Untuk menggunakan fitur dealer terdekat, silakan aktifkan layanan lokasi (GPS) pada perangkat Anda.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text('Buka Pengaturan'),
                ),
              ],
            );
          },
        );

        if (openSettings == true) {
          await _openLocationSettings();
        }
        return;
      }

      // Check permission status
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        // Request permission
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoading = false;
            _hasLocationPermission = false;
            _errorMessage =
                'Izin lokasi ditolak. Fitur dealer terdekat tidak dapat digunakan.';
          });
          await _loadDealersWithoutLocation();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoading = false;
          _hasLocationPermission = false;
          _errorMessage =
              'Izin lokasi ditolak secara permanen. Silakan aktifkan di pengaturan aplikasi.';
        });

        // Show dialog to open app settings
        bool openSettings = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Izin Lokasi Diperlukan'),
              content: Text(
                  'Izin lokasi ditolak secara permanen. Untuk menggunakan fitur dealer terdekat, silakan aktifkan izin lokasi di pengaturan aplikasi.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text('Buka Pengaturan'),
                ),
              ],
            );
          },
        );

        if (openSettings == true) {
          await Geolocator.openAppSettings();
        }
        await _loadDealersWithoutLocation();
        return;
      }

      // Permission granted, proceed to get location
      setState(() {
        _hasLocationPermission = true;
      });

      await _loadCurrentLocationAndDealers();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Terjadi kesalahan saat meminta izin lokasi: $e';
      });
      await _loadDealersWithoutLocation();
    }
  }

  Future<void> _openLocationSettings() async {
    try {
      await Geolocator.openLocationSettings();

      // Wait a bit for user to potentially enable location
      await Future.delayed(Duration(seconds: 1));

      // Re-check permissions after settings
      await _checkPermissionsAndLoadDealers();
    } catch (e) {
      print('Error opening location settings: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tidak dapat membuka pengaturan lokasi'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Dealer Terdekat'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _checkPermissionsAndLoadDealers,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _checkPermissionsAndLoadDealers,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Mencari dealer terdekat...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null && _nearbyDealers.isEmpty) {
      return _buildErrorState();
    }

    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location Status Card
          _buildLocationStatusCard(),

          SizedBox(height: 16),

          // Dealers List
          if (_nearbyDealers.isNotEmpty) ...[
            Text(
              'Dealer Mobil Terdekat',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 12),
            ...List.generate(
              _nearbyDealers.length,
              (index) => _buildDealerCard(_nearbyDealers[index]),
            ),
          ] else ...[
            _buildEmptyState(),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationStatusCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _hasLocationPermission
                      ? Icons.location_on
                      : Icons.location_off,
                  color: _hasLocationPermission ? Colors.green : Colors.red,
                  size: 24,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _hasLocationPermission
                        ? 'Lokasi Aktif'
                        : 'Lokasi Tidak Aktif',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _hasLocationPermission
                          ? Colors.green[700]
                          : Colors.red[700],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            if (_currentPosition != null) ...[
              Text(
                'Koordinat: ${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                'Akurasi: ${_currentPosition!.accuracy.toStringAsFixed(1)} meter',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ] else if (!_hasLocationPermission) ...[
              Text(
                'Berikan izin lokasi untuk mendapatkan dealer terdekat dengan jarak yang akurat.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _requestLocationPermission,
                icon: Icon(Icons.location_on),
                label: Text('Aktifkan Lokasi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDealerCard(DealerWithDistance dealerWithDistance) {
    final dealer = dealerWithDistance.dealer;

    return Card(
      elevation: 3,
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with name and distance
            Row(
              children: [
                Expanded(
                  child: Text(
                    dealer.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                if (dealerWithDistance.distanceKm != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      dealerWithDistance.formattedDistance,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(height: 8),

            // Address
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    dealer.address,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 8),

            // Phone
            Row(
              children: [
                Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                SizedBox(width: 4),
                Text(
                  dealer.phone,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),

            SizedBox(height: 8),

            // Brands
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: dealer.brands
                  .map((brand) => Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          brand,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ))
                  .toList(),
            ),

            SizedBox(height: 12),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _callDealer(dealer.phone),
                    icon: Icon(Icons.phone, size: 18),
                    label: Text('Telepon'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green[700],
                      side: BorderSide(color: Colors.green[700]!),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openMaps(dealer),
                    icon: Icon(Icons.directions, size: 18),
                    label: Text('Rute'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red[400],
            ),
            SizedBox(height: 16),
            Text(
              'Terjadi Kesalahan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Error tidak diketahui',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _checkPermissionsAndLoadDealers,
              icon: Icon(Icons.refresh),
              label: Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
              ),
            ),
            if (!_hasLocationPermission) ...[
              SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _openLocationSettings,
                icon: Icon(Icons.settings),
                label: Text('Buka Pengaturan'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue[700],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_searching,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'Tidak Ada Dealer Ditemukan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Belum ada dealer mobil di area ini',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _callDealer(String phoneNumber) {
    // Remove any formatting from phone number
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Telepon Dealer'),
          content: Text('Apakah Anda ingin menelepon $phoneNumber?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // In a real app, you would use url_launcher to make the call
                // launch('tel:$cleanNumber');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('Fitur telepon akan membuka aplikasi telepon'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
              child: Text('Telepon'),
            ),
          ],
        );
      },
    );
  }

  void _openMaps(DealerLocation dealer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Buka Peta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Buka rute ke ${dealer.name}?'),
              SizedBox(height: 8),
              Text(
                dealer.address,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Koordinat: ${dealer.latitude.toStringAsFixed(4)}, ${dealer.longitude.toStringAsFixed(4)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // In a real app, you would use url_launcher to open maps
                // String url = 'https://www.google.com/maps/search/?api=1&query=${dealer.latitude},${dealer.longitude}';
                // launch(url);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Fitur peta akan membuka Google Maps'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text('Buka Peta'),
            ),
          ],
        );
      },
    );
  }
}
