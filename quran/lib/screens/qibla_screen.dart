import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
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
  double? _accuracy;
  double? _distanceToMecca;
  double? _userLat;
  double? _userLon;
  StreamSubscription<CompassEvent?>? _compassSub;
  bool _wasAligned = false;

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
              _accuracy = event.accuracy;
            });
            _checkAlignment();
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
      final pos = await LocationService.getPositionOrNull(context);

      final lat = pos?.latitude ?? 33.5731;
      final lon = pos?.longitude ?? 74.3365;

      setState(() {
        _userLat = lat;
        _userLon = lon;
      });

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

      // Calculate distance to Mecca (21.4225, 39.8262)
      final distance = _calculateDistance(lat, lon, 21.4225, 39.8262);

      setState(() {
        qiblaDirection = direction;
        _distanceToMecca = distance;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print('Error loading qibla direction: $e');
      _showError('Failed to load Qibla direction');
    }
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371; // Earth's radius in kilometers
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  double _toRadians(double degrees) {
    return degrees * math.pi / 180;
  }

  void _checkAlignment() {
    if (qiblaDirection == null || _heading == null) return;

    final difference = ((qiblaDirection! - _heading!) % 360).abs();
    final isAligned = difference < 5 || difference > 355; // Within 5 degrees

    if (isAligned && !_wasAligned) {
      // Just became aligned - trigger haptic feedback
      HapticFeedback.mediumImpact();
      _wasAligned = true;
    } else if (!isAligned && _wasAligned) {
      _wasAligned = false;
    }
  }

  bool _isAligned() {
    if (qiblaDirection == null || _heading == null) return false;
    final difference = ((qiblaDirection! - _heading!) % 360).abs();
    return difference < 5 || difference > 355;
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
              // Distance and Alignment Status
              if (!isLoading && _distanceToMecca != null)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _isAligned()
                          ? Color(0xFF1db854).withOpacity(0.2)
                          : Color(0xFF1a472a).withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isAligned()
                            ? Color(0xFF1db854)
                            : Color(0xFF4a7c5e),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Color(0xFFd4af37),
                              size: 20,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Distance to Mecca',
                              style: TextStyle(
                                color: Color(0xFFb0b0b0),
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '${_distanceToMecca!.toStringAsFixed(0)} km',
                              style: TextStyle(
                                color: Color(0xFFd4af37),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 1,
                          height: 50,
                          color: Color(0xFF4a7c5e),
                        ),
                        Column(
                          children: [
                            Icon(
                              _isAligned()
                                  ? Icons.check_circle
                                  : Icons.my_location,
                              color: _isAligned()
                                  ? Color(0xFF1db854)
                                  : Color(0xFFd4af37),
                              size: 20,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Status',
                              style: TextStyle(
                                color: Color(0xFFb0b0b0),
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              _isAligned() ? 'Aligned!' : 'Searching...',
                              style: TextStyle(
                                color: _isAligned()
                                    ? Color(0xFF1db854)
                                    : Color(0xFFd4af37),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              // Calibration Warning
              if (!isLoading && _accuracy != null && _accuracy! < 0)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange, width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange, size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Calibrate compass: Move device in figure-8 pattern',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
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
                              // Animated Qibla Needle with Kaaba Icon
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
                                    // Kaaba Icon at top
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: _isAligned()
                                            ? Color(0xFF1db854)
                                            : Color(0xFFd4af37),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                (_isAligned()
                                                        ? Color(0xFF1db854)
                                                        : Color(0xFFd4af37))
                                                    .withOpacity(0.5),
                                            blurRadius: 10,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.mosque,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    // Needle line
                                    Container(
                                      width: 4,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: _isAligned()
                                              ? [
                                                  Color(0xFF1db854),
                                                  Color(
                                                    0xFF1db854,
                                                  ).withOpacity(0.3),
                                                ]
                                              : [
                                                  Color(0xFFd4af37),
                                                  Color(
                                                    0xFFd4af37,
                                                  ).withOpacity(0.3),
                                                ],
                                        ),
                                      ),
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
                          SizedBox(height: 32),
                          // Qibla Bearing Display
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 40),
                            child: Container(
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
                                  if (_userLat != null && _userLon != null)
                                    Padding(
                                      padding: EdgeInsets.only(top: 8),
                                      child: Text(
                                        'From ${_userLat!.toStringAsFixed(2)}°, ${_userLon!.toStringAsFixed(2)}°',
                                        style: TextStyle(
                                          color: Color(0xFFb0b0b0),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          // Instructions
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              _isAligned()
                                  ? '✓ Facing Qibla - Ready for Prayer'
                                  : 'Slowly rotate your device until the compass aligns',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _isAligned()
                                    ? Color(0xFF1db854)
                                    : Color(0xFFb0b0b0),
                                fontSize: 14,
                                fontWeight: _isAligned()
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
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
