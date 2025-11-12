import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;
import '../services/api_service.dart';

class MasjidFinderScreen extends StatefulWidget {
  const MasjidFinderScreen({super.key});

  @override
  State<MasjidFinderScreen> createState() => _MasjidFinderScreenState();
}

class _MasjidFinderScreenState extends State<MasjidFinderScreen> {
  GoogleMapController? _mapController;
  Position? _userLocation;
  List<Map<String, dynamic>> nearbyMosques = [];
  bool isLoading = true;
  bool showMap = true; // Start with map view
  Set<Marker> markers = {};

  // Fallback masjids list if API fails
  final List<Map<String, String>> fallbackMasjids = [
    {
      'name': 'Faisal Mosque',
      'location': 'Islamabad, Pakistan',
      'distance': '2.5 km',
      'rating': '4.8',
    },
    {
      'name': 'Iqbal Mosque',
      'location': 'Rawalpindi, Pakistan',
      'distance': '1.2 km',
      'rating': '4.6',
    },
    {
      'name': 'Al-Haramain Mosque',
      'location': 'Rawalpindi, Pakistan',
      'distance': '3.1 km',
      'rating': '4.5',
    },
    {
      'name': 'Central Mosque',
      'location': 'Rawalpindi, Pakistan',
      'distance': '0.8 km',
      'rating': '4.7',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserLocationAndMosques();
  }

  Future<void> _loadUserLocationAndMosques() async {
    try {
      // Get user's current location
      final position = await ApiService.getCurrentLocation();
      setState(() => _userLocation = position);

      // Add user location marker
      markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: LatLng(position.latitude, position.longitude),
          infoWindow: const InfoWindow(title: 'Your Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );

      // Try to fetch nearby mosques using Google Places API
      try {
        final response = await ApiService.getNearbyMosques(
          position.latitude,
          position.longitude,
          radiusMeters: 5000,
        );

        print('getNearbyMosques response: $response');

        if (response['results'] != null) {
          final results = response['results'] as List;
          print('Found ${results.length} mosques');
          setState(() {
            nearbyMosques = results
                .map(
                  (mosque) => {
                    'name': mosque['name'] ?? 'Unknown Mosque',
                    'lat': mosque['geometry']['location']['lat'] ?? 0.0,
                    'lng': mosque['geometry']['location']['lng'] ?? 0.0,
                    'rating': mosque['rating']?.toString() ?? 'N/A',
                    'location': mosque['vicinity'] ?? 'Unknown Location',
                    'distance': _calculateDistance(
                      position.latitude,
                      position.longitude,
                      mosque['geometry']['location']['lat'],
                      mosque['geometry']['location']['lng'],
                    ),
                  },
                )
                .toList();

            // Add mosque markers
            for (var i = 0; i < nearbyMosques.length; i++) {
              markers.add(
                Marker(
                  markerId: MarkerId('mosque_$i'),
                  position: LatLng(
                    nearbyMosques[i]['lat'],
                    nearbyMosques[i]['lng'],
                  ),
                  infoWindow: InfoWindow(title: nearbyMosques[i]['name']),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed,
                  ),
                ),
              );
            }

            isLoading = false;
          });
        } else {
          print('No results found in API response');
          _useFallbackMosques();
        }
      } catch (e) {
        // Use fallback list if API fails
        print('Google Places API failed, using fallback mosques: $e');
        _useFallbackMosques();
      }
    } catch (e) {
      setState(() => isLoading = false);
      print('Error: $e');
      _showError('Failed to load location. Please enable location services.');
    }
  }

  void _useFallbackMosques() {
    setState(() {
      nearbyMosques = fallbackMasjids
          .map(
            (m) => {
              'name': m['name'] ?? 'Unknown',
              'location': m['location'] ?? 'Unknown',
              'distance': m['distance'] ?? 'N/A',
              'rating': m['rating'] ?? 'N/A',
            },
          )
          .toList();
      isLoading = false;
    });
  }

  String _calculateDistance(
    double userLat,
    double userLng,
    double mosqueLat,
    double mosqueLng,
  ) {
    const double earthRadiusKm = 6371;
    final dLat = _toRadians(mosqueLat - userLat);
    final dLng = _toRadians(mosqueLng - userLng);

    final a =
        (math.sin(dLat / 2) * math.sin(dLat / 2)) +
        (math.cos(_toRadians(userLat)) *
            math.cos(_toRadians(mosqueLat)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2));
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final distance = earthRadiusKm * c;

    if (distance < 1) {
      return '${(distance * 1000).toStringAsFixed(0)} m';
    } else {
      return '${distance.toStringAsFixed(1)} km';
    }
  }

  double _toRadians(double degree) => degree * (3.1415926535897932 / 180);

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1a472a), Color(0xFF0d2818)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with toggle button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Icon(
                            Icons.arrow_back,
                            color: Color(0xFFd4af37),
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Masjid Finder',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (!isLoading)
                      GestureDetector(
                        onTap: () => setState(() => showMap = !showMap),
                        child: Icon(
                          showMap ? Icons.list : Icons.map,
                          color: Color(0xFFd4af37),
                          size: 24,
                        ),
                      ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFd4af37),
                        ),
                      )
                    : (showMap && _userLocation != null)
                    ? _buildMapView()
                    : _buildListView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapView() {
    return GoogleMap(
      onMapCreated: (controller) => _mapController = controller,
      initialCameraPosition: CameraPosition(
        target: LatLng(_userLocation!.latitude, _userLocation!.longitude),
        zoom: 14,
      ),
      markers: markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
    );
  }

  Widget _buildListView() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          // Search Box
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Color(0xFF1a472a).withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFF4a7c5e), width: 1.5),
            ),
            child: TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search mosques...',
                hintStyle: TextStyle(color: Color(0xFF7a9a6b)),
                border: InputBorder.none,
                icon: Icon(Icons.search, color: Color(0xFFd4af37)),
              ),
            ),
          ),
          // Mosques List
          if (nearbyMosques.isEmpty)
            Center(
              child: Text(
                'No mosques found',
                style: TextStyle(color: Colors.white70),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: nearbyMosques.length,
              itemBuilder: (context, index) {
                final mosque = nearbyMosques[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFF1a472a).withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFF4a7c5e), width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              mosque['name'] ?? 'Unknown',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (mosque['rating'] != 'N/A')
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Color(0xFFd4af37),
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  mosque['rating'] ?? '',
                                  style: TextStyle(
                                    color: Color(0xFFd4af37),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Color(0xFF7a9a6b),
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              mosque['location'] ?? 'Unknown',
                              style: TextStyle(
                                color: Color(0xFFb0b0b0),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.directions,
                            color: Color(0xFF7a9a6b),
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            mosque['distance'] ?? 'N/A',
                            style: TextStyle(
                              color: Color(0xFFb0b0b0),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
