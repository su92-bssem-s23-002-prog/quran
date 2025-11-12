import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

class ApiService {
  static const String aladhanBaseUrl = 'http://api.aladhan.com/v1';
  static const String quranBaseUrl = 'https://api.alquran.cloud/v1';
  static const String googlePlacesBaseUrl =
      'https://maps.googleapis.com/maps/api/place';
  // Replace with your Google Places API key from Google Cloud Console
  static const String googlePlacesApiKey = 'YOUR_GOOGLE_PLACES_API_KEY';

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

  // Get All Surahs
  static Future<Map<String, dynamic>> getAllSurahs() async {
    try {
      final response = await http.get(Uri.parse('$quranBaseUrl/surah'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load Surahs');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get Specific Surah
  static Future<Map<String, dynamic>> getSurah(int surahNumber) async {
    try {
      final response = await http.get(
        Uri.parse('$quranBaseUrl/surah/$surahNumber'),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load Surah');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get Specific Surah with Edition
  static Future<Map<String, dynamic>> getSurahWithEdition(
    int surahNumber,
    String edition,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$quranBaseUrl/surah/$surahNumber/$edition'),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load Surah');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get Ayat by Surah and Ayat number
  static Future<Map<String, dynamic>> getAyat(
    int surahNumber,
    int ayatNumber,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$quranBaseUrl/ayah/$surahNumber:$ayatNumber'),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load Ayat');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get Nearby Mosques using Google Places API
  static Future<Map<String, dynamic>> getNearbyMosques(
    double latitude,
    double longitude, {
    int radiusMeters = 5000,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$googlePlacesBaseUrl/nearbysearch/json?location=$latitude,$longitude&radius=$radiusMeters&keyword=mosque&key=$googlePlacesApiKey',
        ),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load nearby mosques');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
