import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

class LocationService {
  static Future<bool> ensureLocationEnabled(BuildContext context) async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnack(context, 'Location services are disabled');
      return false;
    }
    return true;
  }

  static Future<bool> ensurePermissionGranted(BuildContext context) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _showSnack(context, 'Location permission denied. Enable it in Settings.');
      return false;
    }
    return true;
  }

  static Future<Position?> getPositionOrNull(BuildContext context) async {
    final enabled = await ensureLocationEnabled(context);
    if (!enabled) return null;
    final granted = await ensurePermissionGranted(context);
    if (!granted) return null;
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (_) {
      _showSnack(context, 'Failed to get location. Try again.');
      return null;
    }
  }

  static void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
