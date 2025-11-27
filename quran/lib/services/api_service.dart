import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static const String aladhanBaseUrl = 'https://api.aladhan.com/v1';
  static const String quranBaseUrl = 'https://api.alquran.cloud/v1';
  static const String mapboxBaseUrl = 'https://api.mapbox.com';

  // Load Mapbox API key from environment with safety check
  static String get mapboxApiKey {
    try {
      return dotenv.env['MAPBOX_API_KEY'] ?? '';
    } catch (e) {
      return ''; // Return empty if dotenv not initialized
    }
  }

  // Cache for full Quran Uthmani payload
  static Map<String, dynamic>? _quranCache;

  // Get Prayer Times by City
  static Future<Map<String, dynamic>> getPrayerTimes(
    String city,
    String country,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$aladhanBaseUrl/timingsByCity?city=$city&country=$country&method=2',
        ),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load prayer times');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get Prayer Times by coordinates (timestamped) using Aladhan
  static Future<Map<String, dynamic>> getPrayerTimesByCoords(
    double latitude,
    double longitude, {
    int method = 2,
  }) async {
    try {
      final int timestamp =
          DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
      final url =
          '$aladhanBaseUrl/timings/$timestamp?latitude=$latitude&longitude=$longitude&method=$method';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load prayer times by coords');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get Islamic Date
  static Future<Map<String, dynamic>> getIslamicDate(
    String gregorianDate,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$aladhanBaseUrl/gToH?date=$gregorianDate'),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load Islamic date');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get User's Current Location
  static Future<Position> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are denied');
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get Qibla Direction
  static Future<Map<String, dynamic>> getQiblaDirection(
    double latitude,
    double longitude,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$aladhanBaseUrl/qibla/$latitude/$longitude'),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load Qibla direction');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get full Quran Uthmani (cached)
  static Future<Map<String, dynamic>> getQuranUthmani() async {
    try {
      if (_quranCache != null) return _quranCache!;
      final url = '$quranBaseUrl/quran/quran-uthmani';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        _quranCache = data;
        return data;
      } else {
        throw Exception('Failed to load Quran Uthmani');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get All Surahs (from cached Quran Uthmani)
  static Future<Map<String, dynamic>> getAllSurahs() async {
    try {
      final quran = await getQuranUthmani();
      final data = quran['data'];
      List<dynamic>? surahs;

      if (data is Map && data['surahs'] is List) {
        surahs = data['surahs'] as List<dynamic>;
      } else if (data is List) {
        surahs = data;
      } else if (quran['surahs'] is List) {
        surahs = quran['surahs'] as List<dynamic>;
      } else {
        surahs = [];
      }

      // Ensure each surah has numberOfAyahs calculated from ayahs array
      final enrichedSurahs = surahs.map((surah) {
        if (surah is Map<String, dynamic>) {
          final ayahs = surah['ayahs'] as List<dynamic>? ?? [];
          return {
            ...surah,
            'numberOfAyahs': surah['numberOfAyahs'] ?? ayahs.length,
          };
        }
        return surah;
      }).toList();

      return {'data': enrichedSurahs};
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get Specific Surah (from cached Quran Uthmani)
  static Future<Map<String, dynamic>> getSurah(int surahNumber) async {
    try {
      final quran = await getQuranUthmani();
      final data = quran['data'];
      List<dynamic>? surahs;
      if (data is Map && data['surahs'] is List) {
        surahs = data['surahs'] as List<dynamic>;
      } else if (data is List) {
        surahs = data;
      } else if (quran['surahs'] is List) {
        surahs = quran['surahs'] as List<dynamic>;
      } else {
        surahs = [];
      }

      final surah = surahs.firstWhere((s) {
        final num = (s['number'] is int)
            ? s['number']
            : int.tryParse('${s['number']}');
        return num == surahNumber;
      }, orElse: () => null);

      if (surah == null) throw Exception('Surah not found');
      return {'data': surah};
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get Specific Surah with Edition
  // The quran-uthmani payload already contains Arabic text; editions are not provided here.
  // Fallback to getSurah (returns the Uthmani surah).
  static Future<Map<String, dynamic>> getSurahWithEdition(
    int surahNumber,
    String edition,
  ) async {
    return getSurah(surahNumber);
  }

  // Get Ayat by Surah and Ayat number (from cached Quran Uthmani)
  static Future<Map<String, dynamic>> getAyat(
    int surahNumber,
    int ayatNumber,
  ) async {
    try {
      final surahResp = await getSurah(surahNumber);
      final surah = surahResp['data'] as Map<String, dynamic>;
      final ayahs = surah['ayahs'] as List<dynamic>? ?? [];
      final ayah = ayahs.firstWhere((a) {
        final num = (a['numberInSurah'] is int)
            ? a['numberInSurah']
            : int.tryParse('${a['numberInSurah']}');
        return num == ayatNumber;
      }, orElse: () => null);
      if (ayah == null) throw Exception('Ayah not found');
      return {'data': ayah};
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get Nearby Mosques using Mapbox Geocoding API
  static Future<Map<String, dynamic>> getNearbyMosques(
    double latitude,
    double longitude, {
    int radiusMeters = 5000,
  }) async {
    try {
      // Mapbox forward geocoding to search for mosques nearby
      final response = await http.get(
        Uri.parse(
          '$mapboxBaseUrl/geocoding/v5/mapbox.places/mosque.json?proximity=$longitude,$latitude&limit=10&access_token=$mapboxApiKey',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Mapbox response: $data');

        // Transform Mapbox response to match expected format
        final List<dynamic> features = data['features'] ?? [];
        final List<Map<String, dynamic>> mosques = features.map((feature) {
          final geometry = feature['geometry'] ?? {};
          final coords = geometry['coordinates'] ?? [0, 0];

          return {
            'name': feature['text'] ?? 'Mosque',
            'address': feature['place_name'] ?? 'Unknown',
            'lat': coords[1] as double,
            'lng': coords[0] as double,
            'rating': '4.5',
            'location': feature['place_name'] ?? 'Unknown Location',
            'distance': _calculateDistance(
              latitude,
              longitude,
              coords[1] as double,
              coords[0] as double,
            ),
          };
        }).toList();

        return {'results': mosques, 'status': 'OK'};
      } else {
        throw Exception('Failed to load nearby mosques from Mapbox');
      }
    } catch (e) {
      print('Error fetching mosques from Mapbox: $e');
      throw Exception('Error: $e');
    }
  }

  // Get route between two points using Mapbox Directions API
  // Returns a map with 'path' = List of {'lat', 'lng'}, 'distance', 'duration'
  static Future<Map<String, dynamic>> getRoute(
    double fromLat,
    double fromLng,
    double toLat,
    double toLng,
  ) async {
    try {
      final url =
          '$mapboxBaseUrl/directions/v5/mapbox/driving/$fromLng,$fromLat;$toLng,$toLat?alternatives=false&geometries=geojson&overview=full&access_token=$mapboxApiKey';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic>? routes = data['routes'];
        if (routes != null && routes.isNotEmpty) {
          final route = routes[0];
          final geometry = route['geometry'];
          final List<dynamic> coords = geometry['coordinates'] ?? [];

          final List<Map<String, double>> path = coords.map((c) {
            final double lng = (c[0] as num).toDouble();
            final double lat = (c[1] as num).toDouble();
            return {'lat': lat, 'lng': lng};
          }).toList();

          return {
            'path': path,
            'distance': route['distance'],
            'duration': route['duration'],
            'status': 'OK',
          };
        }
      }

      throw Exception('Failed to fetch route from Mapbox');
    } catch (e) {
      print('Error fetching route from Mapbox: $e');
      throw Exception('Error: $e');
    }
  }

  // Calculate distance between two coordinates (Haversine formula)
  static String _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadiusKm = 6371;

    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);

    double a =
        (math.sin(dLat / 2) * math.sin(dLat / 2)) +
        (math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2));

    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    double distanceKm = earthRadiusKm * c;

    if (distanceKm < 1) {
      return '${(distanceKm * 1000).toStringAsFixed(0)} m';
    } else {
      return '${distanceKm.toStringAsFixed(1)} km';
    }
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (3.1415926535897932 / 180);
  }
}
