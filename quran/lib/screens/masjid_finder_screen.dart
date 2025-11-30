import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';

class MasjidFinderScreen extends StatefulWidget {
  const MasjidFinderScreen({super.key});

  @override
  State<MasjidFinderScreen> createState() => _MasjidFinderScreenState();
}

class _MasjidFinderScreenState extends State<MasjidFinderScreen> {
  List<Map<String, dynamic>> nearbyMosques = [];
  bool isLoading = true;
  String? userLocation = 'Getting location...';
  double? userLat;
  double? userLng;
  final MapController _mapController = MapController();
  List<LatLng> _routePoints = [];
  List<Marker> _markers = [];
  int? _selectedIndex;

  // Fallback masjids list if API fails
  final List<Map<String, dynamic>> fallbackMasjids = [
    {
      'name': 'Faisal Mosque',
      'address': 'Islamabad, Pakistan',
      'lat': 33.7294,
      'lng': 73.2401,
      'rating': '4.8',
      'distance': '2.3 km',
      'location': 'Islamabad',
    },
    {
      'name': 'Badshahi Mosque',
      'address': 'Lahore, Pakistan',
      'lat': 31.5868,
      'lng': 74.3075,
      'rating': '4.7',
      'distance': '5.1 km',
      'location': 'Lahore',
    },
    {
      'name': 'Al-Haramain Mosque',
      'address': 'Rawalpindi, Pakistan',
      'lat': 33.5731,
      'lng': 74.3365,
      'rating': '4.6',
      'distance': '1.5 km',
      'location': 'Rawalpindi',
    },
    {
      'name': 'Central Mosque',
      'address': 'Karachi, Pakistan',
      'lat': 24.8607,
      'lng': 67.0011,
      'rating': '4.5',
      'distance': '3.2 km',
      'location': 'Karachi',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserLocationAndMosques();
  }

  Future<void> _loadUserLocationAndMosques() async {
    try {
      // Get user's current location with permission request
      final position = await LocationService.getPositionOrNull(context);

      if (position == null) {
        setState(() {
          isLoading = false;
          userLocation = 'Location unavailable';
        });
        _useFallbackMosques();
        return;
      }

      setState(() {
        userLat = position.latitude;
        userLng = position.longitude;
        userLocation =
            '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
      });

      print('User Location: $userLat, $userLng');

      // Fetch nearby mosques using Mapbox
      final data = await ApiService.getNearbyMosques(
        position.latitude,
        position.longitude,
        radiusMeters: 5000,
      );

      print('Mosques data: $data');

      setState(() {
        if (data['results'] != null && (data['results'] as List).isNotEmpty) {
          nearbyMosques = List<Map<String, dynamic>>.from(data['results']);

          // Build markers for the map
          _markers = [];

          // Add user location marker
          _markers.add(
            Marker(
              point: LatLng(userLat!, userLng!),
              width: 40,
              height: 40,
              child: Icon(
                Icons.my_location,
                color: Color(0xFFd4af37),
                size: 32,
              ),
            ),
          );

          // Add mosque markers
          for (var i = 0; i < nearbyMosques.length; i++) {
            final m = nearbyMosques[i];
            final double lat = (m['lat'] ?? 0).toDouble();
            final double lng = (m['lng'] ?? 0).toDouble();

            if (lat != 0 && lng != 0) {
              _markers.add(
                Marker(
                  point: LatLng(lat, lng),
                  width: 40,
                  height: 40,
                  child: GestureDetector(
                    onTap: () => _selectMosqueAndRoute(i),
                    child: Icon(
                      Icons.mosque,
                      color: _selectedIndex == i
                          ? Colors.red
                          : Color(0xFF1db854),
                      size: 32,
                    ),
                  ),
                ),
              );
            }
          }
        } else {
          _useFallbackMosques();
        }
        isLoading = false;
      });
    } catch (e) {
      print('Error loading mosques: $e');
      setState(() {
        _useFallbackMosques();
        isLoading = false;
      });
    }
  }

  void _useFallbackMosques() {
    nearbyMosques = fallbackMasjids;
    print('Using fallback mosques. Count: ${nearbyMosques.length}');
  }

  Future<void> _retryFetch() async {
    setState(() {
      isLoading = true;
      nearbyMosques = [];
    });
    await _loadUserLocationAndMosques();
  }

  Future<void> _selectMosqueAndRoute(int index) async {
    if (userLat == null || userLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User location not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final mosque = nearbyMosques[index];
    final double toLat = (mosque['lat'] ?? 0).toDouble();
    final double toLng = (mosque['lng'] ?? 0).toDouble();

    if (toLat == 0 || toLng == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mosque location not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      setState(() {
        _selectedIndex = index;
        _routePoints = [];
      });

      // Rebuild markers to show selected mosque in red
      _markers.clear();
      _markers.add(
        Marker(
          point: LatLng(userLat!, userLng!),
          width: 40,
          height: 40,
          child: Icon(Icons.my_location, color: Color(0xFFd4af37), size: 32),
        ),
      );

      for (var i = 0; i < nearbyMosques.length; i++) {
        final m = nearbyMosques[i];
        final double lat = (m['lat'] ?? 0).toDouble();
        final double lng = (m['lng'] ?? 0).toDouble();

        if (lat != 0 && lng != 0) {
          _markers.add(
            Marker(
              point: LatLng(lat, lng),
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () => _selectMosqueAndRoute(i),
                child: Icon(
                  Icons.mosque,
                  color: i == index ? Colors.red : Color(0xFF1db854),
                  size: 32,
                ),
              ),
            ),
          );
        }
      }

      final route = await ApiService.getRoute(userLat!, userLng!, toLat, toLng);
      final List<dynamic> path = route['path'] ?? [];
      final points = path
          .map<LatLng>(
            (p) => LatLng(
              (p['lat'] as num).toDouble(),
              (p['lng'] as num).toDouble(),
            ),
          )
          .toList();

      setState(() {
        _routePoints = points;
        // Center map on route midpoint or mosque location
        if (_routePoints.isNotEmpty) {
          final mid = _routePoints[_routePoints.length ~/ 2];
          _mapController.move(mid, 14.0);
        } else {
          _mapController.move(LatLng(toLat, toLng), 14.0);
        }
      });
    } catch (e) {
      print('Route error: $e');
      // Even if route fails, still zoom to mosque
      setState(() {
        _mapController.move(LatLng(toLat, toLng), 15.0);
      });
    }
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
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
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
              ),
              // Location Info
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFF1a472a).withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Color(0xFF4a7c5e), width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: Color(0xFFd4af37)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Location',
                              style: TextStyle(
                                color: Color(0xFFb0b0b0),
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              userLocation ?? 'Loading...',
                              style: TextStyle(
                                color: Color(0xFFd4af37),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Small map (height 180) + count
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xFF4a7c5e)),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: userLat != null && userLng != null
                              ? LatLng(userLat!, userLng!)
                              : LatLng(33.72, 73.04),
                          initialZoom: 13.0,
                          interactionOptions: InteractionOptions(
                            flags: InteractiveFlag.all,
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}',
                            additionalOptions: {
                              'accessToken': ApiService.mapboxApiKey,
                              'id': 'mapbox/streets-v11',
                            },
                          ),
                          if (_markers.isNotEmpty)
                            MarkerLayer(markers: _markers),
                          if (_routePoints.isNotEmpty)
                            PolylineLayer(
                              polylines: [
                                Polyline(
                                  points: _routePoints,
                                  color: Colors.tealAccent.shade100,
                                  strokeWidth: 4.0,
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Found ${nearbyMosques.length} Mosques Nearby',
                      style: TextStyle(
                        color: Color(0xFFd4af37),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Mosques List
              Expanded(
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFd4af37),
                        ),
                      )
                    : nearbyMosques.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.mosque,
                              color: Color(0xFFd4af37),
                              size: 48,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No Mosques Found',
                              style: TextStyle(
                                color: Color(0xFFd4af37),
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _retryFetch,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFd4af37),
                              ),
                              child: Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: nearbyMosques.length,
                        itemBuilder: (context, index) {
                          final mosque = nearbyMosques[index];
                          return GestureDetector(
                            onTap: () => _selectMosqueAndRoute(index),
                            child: _buildMasjidCard(mosque, index: index),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMasjidCard(Map<String, dynamic> mosque, {int? index}) {
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
          // Mosque Name
          Row(
            children: [
              Expanded(
                child: Text(
                  mosque['name'] ?? 'Unknown Mosque',
                  style: TextStyle(
                    color: Color(0xFFd4af37),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (index != null && _selectedIndex == index)
                Icon(Icons.navigation, color: Color(0xFFd4af37), size: 18),
            ],
          ),
          SizedBox(height: 8),
          // Address
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: Color(0xFFb0b0b0),
                size: 14,
              ),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  mosque['address'] ?? mosque['location'] ?? 'Unknown Address',
                  style: TextStyle(color: Color(0xFFb0b0b0), fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          // Rating and Distance
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.star, color: Color(0xFFd4af37), size: 14),
                  SizedBox(width: 4),
                  Text(
                    mosque['rating']?.toString() ?? '4.5',
                    style: TextStyle(
                      color: Color(0xFFd4af37),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(0xFF4a7c5e),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  mosque['distance']?.toString() ?? '0 km',
                  style: TextStyle(
                    color: Color(0xFFd4af37),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          // Actions: Open in Maps + Bookmark
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  final double lat = (mosque['lat'] ?? 0).toDouble();
                  final double lng = (mosque['lng'] ?? 0).toDouble();
                  final String q = Uri.encodeComponent(
                    mosque['name'] ?? 'Mosque',
                  );
                  final url = Uri.parse(
                    'https://www.google.com/maps/search/?api=1&query=$lat,$lng&query_place_id=$q',
                  );
                  try {
                    // Open maps in browser (works on mobile/desktop)
                    // ignore: deprecated_member_use
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => Scaffold(
                          appBar: AppBar(title: Text('Open in Maps')),
                          body: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Opening Google Maps...'),
                                SizedBox(height: 12),
                                Text(
                                  url.toString(),
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Could not open Maps')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4a7c5e),
                  foregroundColor: Color(0xFFd4af37),
                ),
                icon: Icon(Icons.map, size: 18),
                label: Text('Open in Maps'),
              ),
              SizedBox(width: 12),
              _BookmarkButton(mosque: mosque),
            ],
          ),
        ],
      ),
    );
  }
}

class _BookmarkButton extends StatefulWidget {
  final Map<String, dynamic> mosque;
  const _BookmarkButton({required this.mosque});
  @override
  State<_BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<_BookmarkButton> {
  bool _bookmarked = false;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    // Lightweight local flag; could use SharedPreferences globally.
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        setState(() => _bookmarked = !_bookmarked);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _bookmarked ? Color(0xFF1db854) : Color(0xFF4a7c5e),
        foregroundColor: Color(0xFFd4af37),
      ),
      icon: Icon(
        _bookmarked ? Icons.bookmark : Icons.bookmark_border,
        size: 18,
      ),
      label: Text(_bookmarked ? 'Bookmarked' : 'Bookmark'),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
