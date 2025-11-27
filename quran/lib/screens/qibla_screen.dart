import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  double? qiblaDirection;
  bool isLoading = true;
  double? _heading;
  StreamSubscription<CompassEvent?>? _compassSub;

  @override
  void initState() {
    super.initState();
    _loadQiblaDirection();
    _startCompass();
  }

  void _startCompass() {
    // Web compass not supported in this version - would need conditional imports
    // For now, only mobile compass works
    if (kIsWeb) {
      print('Compass not available on web platform');
      return;
    }

    // Mobile: use flutter_compass
    try {
      if (FlutterCompass.events != null) {
        _compassSub = FlutterCompass.events!.listen((event) {
          if (event.heading != null) {
            setState(() {
              _heading = event.heading;
            });
          }
        });
      } else {
        print('FlutterCompass.events is null on this platform/emulator.');
      }
    } catch (e) {
      print('Compass not available: $e');
    }
  }

  Future<void> _loadQiblaDirection() async {
    try {
      Position? pos;
      try {
        pos = await ApiService.getCurrentLocation();
      } catch (e) {
        print('Could not get device location, falling back to default: $e');
        pos = null;
      }

      final lat = pos?.latitude ?? 33.5731;
      final lon = pos?.longitude ?? 74.3365;
      final data = await ApiService.getQiblaDirection(lat, lon);
      print('getQiblaDirection response: $data');

      double direction = 0.0;
      try {
        if (data.containsKey('data') && data['data'] is Map) {
          direction = (data['data']['direction'] as num?)?.toDouble() ?? 0.0;
        } else if (data.containsKey('direction')) {
          direction = (data['direction'] as num?)?.toDouble() ?? 0.0;
        }
      } catch (_) {
        direction = 0.0;
      }

      setState(() {
        qiblaDirection = direction;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print('Error loading qibla direction: $e');
      _showError('Failed to load Qibla direction');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  double _computeRelativeRadians() {
    final q = (qiblaDirection ?? 0.0);
    final h = (_heading ?? 0.0);
    // needle rotation = (qiblaBearing - deviceHeading) degrees -> convert to radians
    final relative = (q - h);
    return relative * (3.1415926535897932 / 180);
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
                      'Qibla Direction',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Compass
              Expanded(
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFd4af37),
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Compass Circle
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer Circle
                              Container(
                                width: 280,
                                height: 280,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Color(0xFFd4af37),
                                    width: 3,
                                  ),
                                ),
                              ),
                              // Inner Circle
                              Container(
                                width: 240,
                                height: 240,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF1a472a).withOpacity(0.6),
                                  border: Border.all(
                                    color: Color(0xFF4a7c5e),
                                    width: 2,
                                  ),
                                ),
                              ),
                              // Compass Labels
                              Positioned(
                                top: 30,
                                child: Text(
                                  'N',
                                  style: TextStyle(
                                    color: Color(0xFFd4af37),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 30,
                                child: Text(
                                  'S',
                                  style: TextStyle(
                                    color: Color(0xFFd4af37),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 30,
                                child: Text(
                                  'W',
                                  style: TextStyle(
                                    color: Color(0xFFd4af37),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 30,
                                child: Text(
                                  'E',
                                  style: TextStyle(
                                    color: Color(0xFFd4af37),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              // Animated Qibla Needle
                              TweenAnimationBuilder<double>(
                                tween: Tween(
                                  begin: 0.0,
                                  end: _computeRelativeRadians(),
                                ),
                                duration: const Duration(milliseconds: 300),
                                builder: (context, angle, child) {
                                  return Transform.rotate(
                                    angle: angle,
                                    child: child,
                                  );
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 60,
                                      color: Color(0xFFd4af37),
                                    ),
                                    SizedBox(height: 40),
                                    Container(
                                      width: 4,
                                      height: 20,
                                      color: Color(0xFF1db854),
                                    ),
                                  ],
                                ),
                              ),
                              // Center Circle
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFd4af37),
                                  border: Border.all(
                                    color: Color(0xFF1a472a),
                                    width: 3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24),
                          // Debug heading display
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      'Device Heading',
                                      style: TextStyle(
                                        color: Color(0xFFb0b0b0),
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      '${_heading?.toStringAsFixed(1) ?? '—'}°',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      'Qibla Bearing',
                                      style: TextStyle(
                                        color: Color(0xFFb0b0b0),
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      '${qiblaDirection?.toStringAsFixed(1) ?? '—'}°',
                                      style: TextStyle(
                                        color: Color(0xFFd4af37),
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          // Direction Text
                          Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Color(0xFF1a472a).withOpacity(0.6),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Color(0xFF4a7c5e),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Qibla Direction',
                                  style: TextStyle(
                                    color: Color(0xFFb0b0b0),
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '${qiblaDirection?.toStringAsFixed(1) ?? '—'}°',
                                  style: TextStyle(
                                    color: Color(0xFFd4af37),
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _compassSub?.cancel();
    super.dispose();
  }
}
