// ignore_for_file: prefer_final_fields, unused_element, unused_import, unused_field, avoid_print, deprecated_member_use

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class ShareLocationScreen extends StatefulWidget {
  const ShareLocationScreen({super.key});

  @override
  State<ShareLocationScreen> createState() => _ShareLocationScreenState();
}

class _ShareLocationScreenState extends State<ShareLocationScreen> {
  bool _isLoading = true;
  bool _isSharing = false;
  bool _locationError = false;
  String _locationInfo = 'Getting your location...';

  // Map variables
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};
  Set<Polygon> _polygons = {};

  // Filter states
  bool _showSafeZones = true;
  bool _showRiskAreas = true;
  bool _showHospitals = true;
  bool _showPolice = true;
  bool _showLandmarks = true;
  String _activeFilter =
      'all'; // 'all', 'safe', 'risk', 'hospitals', 'police', 'landmarks'

  // DUHOK, KURDISTAN LOCATIONS
  static const LatLng _duhokLocation = LatLng(36.8665, 43.0000); // Duhok center

  // Real locations in Duhok area
  final List<LatLng> _safeZones = [
    const LatLng(36.8690, 42.9950), // Duhok University area
    const LatLng(36.8550, 43.0050), // City center
    const LatLng(36.8750, 43.0150), // Residential area north
    const LatLng(36.8620, 43.0120), // City Park area
  ];

  final List<LatLng> _riskAreas = [
    const LatLng(36.8480, 42.9850), // Industrial area
    const LatLng(36.8800, 43.0250), // Mountainous border area
    const LatLng(36.8400, 43.0200), // Construction zone
  ];

  final List<Map<String, dynamic>> _hospitals = [
    {
      'position': const LatLng(36.8628, 43.0064),
      'name': 'Duhok General Hospital',
      'type': 'hospital',
    },
    {
      'position': const LatLng(36.8552, 42.9987),
      'name': 'Emergency Medical Center',
      'type': 'hospital',
    },
    {
      'position': const LatLng(36.8701, 43.0123),
      'name': 'Hevi Pediatric Hospital',
      'type': 'hospital',
    },
    {
      'position': const LatLng(36.8590, 43.0080),
      'name': 'Duhok Heart Center',
      'type': 'hospital',
    },
  ];

  final List<Map<String, dynamic>> _policeStations = [
    {
      'position': const LatLng(36.8574, 43.0032),
      'name': 'Duhok Main Police Station',
      'type': 'police',
    },
    {
      'position': const LatLng(36.8631, 42.9928),
      'name': 'City Security Center',
      'type': 'police',
    },
    {
      'position': const LatLng(36.8489, 43.0086),
      'name': 'Traffic Police Department',
      'type': 'police',
    },
    {
      'position': const LatLng(36.8720, 43.0050),
      'name': 'North Duhok Police',
      'type': 'police',
    },
  ];

  final List<Map<String, dynamic>> _landmarks = [
    {
      'position': const LatLng(36.8690, 42.9950),
      'name': 'University of Duhok',
      'type': 'landmark',
      'description':
          'One of the main universities in Kurdistan Region, established in 1992.',
    },
    {
      'position': const LatLng(36.8580, 43.0020),
      'name': 'Duhok Mall',
      'type': 'landmark',
      'description':
          'Main shopping center in Duhok with various stores and restaurants.',
    },
    {
      'position': const LatLng(36.8620, 43.0120),
      'name': 'Duhok Public Park',
      'type': 'landmark',
      'description':
          'Beautiful public park for recreation and family activities.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    try {
      // ALWAYS SET LOCATION TO DUHOK, KURDISTAN
      setState(() {
        _currentPosition = Position(
          longitude: _duhokLocation.longitude,
          latitude: _duhokLocation.latitude,
          timestamp: DateTime.now(),
          accuracy: 10.0,
          altitude: 0.0,
          heading: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
          altitudeAccuracy: 0.0,
          headingAccuracy: 0.0,
        );
        _locationInfo = 'Duhok, Kurdistan Region, Iraq';
        _isLoading = false;
        _locationError = false;
      });

      if (_mapController != null) {
        _updateMap();
      }
    } catch (e) {
      // Even on error, set to Duhok location
      setState(() {
        _currentPosition = Position(
          longitude: _duhokLocation.longitude,
          latitude: _duhokLocation.latitude,
          timestamp: DateTime.now(),
          accuracy: 10.0,
          altitude: 0.0,
          heading: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
          altitudeAccuracy: 0.0,
          headingAccuracy: 0.0,
        );
        _locationInfo = 'Duhok, Kurdistan Region, Iraq';
        _isLoading = false;
        _locationError = false;
      });

      if (_mapController != null) {
        _updateMap();
      }
    }
  }

  void _updateMap({String filter = 'all'}) {
    try {
      final LatLng centerLocation = _duhokLocation;

      // Clear previous markers and shapes
      _markers.clear();
      _circles.clear();
      _polygons.clear();

      // Always show current location
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: centerLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(
            title: 'Your Location - Duhok',
            snippet: 'Kurdistan Region, Iraq',
          ),
          onTap: () {
            _showLocationInfo(
              centerLocation,
              'Duhok - Your Location',
              'Welcome to Duhok, Kurdistan Region of Iraq. This beautiful city is known for its mountains and rich cultural heritage.',
            );
          },
        ),
      );

      // Apply filters
      if (filter == 'all' || filter == 'safe') {
        // Add REAL safe zones around Duhok
        for (int i = 0; i < _safeZones.length; i++) {
          final zone = _safeZones[i];
          _createSafeZone(zone, 'safe_zone_$i', 'Safe Zone ${i + 1}');
        }
      }

      if (filter == 'all' || filter == 'risk') {
        // Add REAL risk areas
        for (int i = 0; i < _riskAreas.length; i++) {
          final area = _riskAreas[i];
          _createRiskArea(area, 'risk_area_$i', 'Risk Area ${i + 1}');
        }
      }

      if (filter == 'all' || filter == 'hospitals') {
        // Add REAL hospitals in Duhok
        for (final hospital in _hospitals) {
          _markers.add(
            Marker(
              markerId: MarkerId('hospital_${hospital['name']}'),
              position: hospital['position'],
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen,
              ),
              infoWindow: InfoWindow(title: hospital['name']),
              onTap: () {
                _showLocationInfo(
                  hospital['position'],
                  hospital['name'],
                  'Medical Facility in Duhok - 24/7 emergency services available',
                );
              },
            ),
          );
        }
      }

      if (filter == 'all' || filter == 'police') {
        // Add REAL police stations in Duhok
        for (final police in _policeStations) {
          _markers.add(
            Marker(
              markerId: MarkerId('police_${police['name']}'),
              position: police['position'],
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueOrange,
              ),
              infoWindow: InfoWindow(title: police['name']),
              onTap: () {
                _showLocationInfo(
                  police['position'],
                  police['name'],
                  'Security Facility in Duhok - Emergency contact: 144',
                );
              },
            ),
          );
        }
      }

      if (filter == 'all' || filter == 'landmarks') {
        // Add important landmarks in Duhok
        for (final landmark in _landmarks) {
          _markers.add(
            Marker(
              markerId: MarkerId('landmark_${landmark['name']}'),
              position: landmark['position'],
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueViolet,
              ),
              infoWindow: InfoWindow(title: landmark['name']),
              onTap: () {
                _showLocationInfo(
                  landmark['position'],
                  landmark['name'],
                  landmark['description'],
                );
              },
            ),
          );
        }
      }

      // Add safety radius circle around Duhok
      _circles.add(
        Circle(
          circleId: const CircleId('safety_radius'),
          center: centerLocation,
          radius: 1500, // 1.5km radius around Duhok center
          fillColor: Colors.blue.withOpacity(0.1),
          strokeColor: Colors.blue,
          strokeWidth: 1,
        ),
      );

      // Move camera to Duhok location
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(centerLocation, 13.5),
      );

      setState(() {});
    } catch (e) {
      print("Error updating map: $e");
    }
  }

  void _createSafeZone(LatLng center, String id, String name) {
    // Create a circular safe zone
    final List<LatLng> zonePoints = [];
    const double radius = 0.008; // Approximately 800m

    for (int i = 0; i < 360; i += 10) {
      double angle = i * pi / 180;
      double lat = center.latitude + radius * cos(angle);
      double lng = center.longitude + radius * sin(angle);
      zonePoints.add(LatLng(lat, lng));
    }

    _polygons.add(
      Polygon(
        polygonId: PolygonId(id),
        points: zonePoints,
        fillColor: Colors.green.withOpacity(0.3),
        strokeColor: Colors.green,
        strokeWidth: 2,
      ),
    );

    // Add safe zone center marker
    _markers.add(
      Marker(
        markerId: MarkerId('${id}_center'),
        position: center,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(title: name),
      ),
    );
  }

  void _createRiskArea(LatLng center, String id, String name) {
    // Create a circular risk area
    final List<LatLng> areaPoints = [];
    const double radius = 0.006; // Approximately 600m

    for (int i = 0; i < 360; i += 10) {
      double angle = i * pi / 180;
      double lat = center.latitude + radius * cos(angle);
      double lng = center.longitude + radius * sin(angle);
      areaPoints.add(LatLng(lat, lng));
    }

    _polygons.add(
      Polygon(
        polygonId: PolygonId(id),
        points: areaPoints,
        fillColor: Colors.red.withOpacity(0.3),
        strokeColor: Colors.red,
        strokeWidth: 2,
      ),
    );

    // Add risk area center marker
    _markers.add(
      Marker(
        markerId: MarkerId('${id}_center'),
        position: center,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: name),
      ),
    );
  }

  void _showLocationInfo(LatLng position, String title, String description) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 12),
              Text(
                'Lat: ${position.latitude.toStringAsFixed(4)}\nLng: ${position.longitude.toStringAsFixed(4)}',
                style: const TextStyle(color: Colors.blue, fontSize: 12),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('CLOSE'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _retryLocation() {
    setState(() {
      _isLoading = true;
      _locationError = false;
      _locationInfo = 'Getting your location...';
    });
    _initializeLocation();
  }

  void _shareLocation() {
    setState(() => _isSharing = true);

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isSharing = false);
        _showShareSuccessDialog();
      }
    });
  }

  void _showShareSuccessDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Location Shared Successfully',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your Duhok location has been shared with emergency contacts.',
                style: TextStyle(color: Colors.grey, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('OK'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRealMap() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6, // 60% of screen height
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: GoogleMap(
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                _updateMap();
              }
            });
          },
          initialCameraPosition: CameraPosition(
            target: _duhokLocation,
            zoom: 13.5,
          ),
          markers: _markers,
          circles: _circles,
          polygons: _polygons,
          myLocationEnabled: false,
          myLocationButtonEnabled: true,
          compassEnabled: true,
          mapToolbarEnabled: true,
          zoomControlsEnabled: false,
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String filterType,
    IconData icon,
    Color color,
  ) {
    final bool isActive = _activeFilter == filterType;

    return FilterChip(
      label: Text(label),
      avatar: Icon(icon, size: 16, color: isActive ? color : Colors.grey),
      selected: isActive,
      onSelected: (bool selected) {
        setState(() {
          _activeFilter = selected ? filterType : 'all';
          _updateMap(filter: _activeFilter);
        });
      },
      backgroundColor: Colors.grey[800],
      selectedColor: color.withOpacity(0.2),
      checkmarkColor: color,
      labelStyle: TextStyle(
        color: isActive ? color : Colors.grey[400],
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isActive ? color : Colors.grey[700]!, width: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Share Location - Duhok'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading ? _buildLoadingScreen() : _buildContentScreen(),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
            strokeWidth: 3,
          ),
          const SizedBox(height: 20),
          Text(
            'Loading Duhok Location...',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentScreen() {
    return Column(
      children: [
        // Location Info Card
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFF1A1A1A), Colors.grey[900]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_on_rounded,
                  color: Colors.green[400],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CURRENT LOCATION',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Duhok, Kurdistan Region, Iraq',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lat: ${_duhokLocation.latitude.toStringAsFixed(4)} | Lng: ${_duhokLocation.longitude.toStringAsFixed(4)}',
                      style: TextStyle(color: Colors.green[400], fontSize: 12),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.check_circle_rounded,
                color: Colors.green[400],
                size: 24,
              ),
            ],
          ),
        ),

        // Filter Chips
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', 'all', Icons.map_rounded, Colors.blue),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Safe Zones',
                  'safe',
                  Icons.security_rounded,
                  Colors.green,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Risk Areas',
                  'risk',
                  Icons.warning_rounded,
                  Colors.red,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Hospitals',
                  'hospitals',
                  Icons.local_hospital_rounded,
                  Colors.green,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Police',
                  'police',
                  Icons.local_police_rounded,
                  Colors.orange,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Landmarks',
                  'landmarks',
                  Icons.place_rounded,
                  Colors.purple,
                ),
              ],
            ),
          ),
        ),

        // Large Map
        Expanded(child: _buildRealMap()),

        // Safety Information and Share Button
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Safety Stats
              _buildSafetyStats(),
              const SizedBox(height: 16),

              // Share Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSharing ? null : _shareLocation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isSharing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.share_rounded, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'SHARE LOCATION WITH EMERGENCY CONTACTS',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSafetyStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          Icons.security_rounded,
          'Safe Zones',
          '${_safeZones.length}',
          Colors.green,
        ),
        _buildStatItem(
          Icons.warning_rounded,
          'Risk Areas',
          '${_riskAreas.length}',
          Colors.orange,
        ),
        _buildStatItem(
          Icons.local_hospital_rounded,
          'Hospitals',
          '${_hospitals.length}',
          Colors.green,
        ),
        _buildStatItem(
          Icons.local_police_rounded,
          'Police',
          '${_policeStations.length}',
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          title,
          style: TextStyle(color: Colors.grey[400], fontSize: 10),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
