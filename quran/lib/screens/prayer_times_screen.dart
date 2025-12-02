import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import 'package:intl/intl.dart';

// This screen now requests device location and fetches prayer times for that location.

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  Map<String, dynamic>? prayerTimes;
  bool isLoading = true;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    NotificationService.init();
    NotificationService.requestPermissions();
    _loadPrayerTimes();
  }

  Future<void> _loadPrayerTimes() async {
    setState(() {
      isLoading = true;
      errorMsg = null;
    });

    try {
      // Get device location
      final position = await ApiService.getCurrentLocation();
      final data = await ApiService.getPrayerTimesByCoords(
        position.latitude,
        position.longitude,
      );
      setState(() {
        prayerTimes = data['data']?['timings'];
        isLoading = false;
      });

      // Schedule notifications for today's prayers
      _scheduleTodayNotifications(prayerTimes!);
    } catch (e) {
      print('Error loading prayer times for current location: $e');
      setState(() {
        errorMsg = e.toString();
        isLoading = false;
      });
    }
  }

  void _scheduleTodayNotifications(Map<String, dynamic> timings) {
    final now = DateTime.now();
    final df = DateFormat('HH:mm');
    final entries = <MapEntry<String, String>>[
      MapEntry('Fajr', timings['Fajr'] ?? ''),
      MapEntry('Dhuhr', timings['Dhuhr'] ?? ''),
      MapEntry('Asr', timings['Asr'] ?? ''),
      MapEntry('Maghrib', timings['Maghrib'] ?? ''),
      MapEntry('Isha', timings['Isha'] ?? ''),
    ];

    for (final e in entries) {
      final raw = e.value.replaceAll(' (PKT)', '').replaceAll(' (GMT)', '');
      DateTime? time;
      try {
        final parsed = df.parse(raw);
        time = DateTime(
          now.year,
          now.month,
          now.day,
          parsed.hour,
          parsed.minute,
        );
      } catch (_) {
        continue;
      }
      NotificationService.schedulePrayerNotification(
        idKey: 'prayer_${e.key}_${time.toIso8601String()}',
        title: '${e.key} Time',
        body: 'It\'s time for ${e.key}.',
        scheduledTime: time,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final prayersList = [
      {'name': 'Fajr', 'key': 'Fajr'},
      {'name': 'Sunrise', 'key': 'Sunrise'},
      {'name': 'Dhuhr', 'key': 'Dhuhr'},
      {'name': 'Asr', 'key': 'Asr'},
      {'name': 'Maghrib', 'key': 'Maghrib'},
      {'name': 'Isha', 'key': 'Isha'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0d2818),
      extendBody: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1a472a), Color(0xFF0d2818)],
          ),
        ),
        child: SafeArea(
          top: true,
          bottom: false,
          child: isLoading
              ? Center(
                  child: CircularProgressIndicator(color: Color(0xFFd4af37)),
                )
              : errorMsg != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Error: $errorMsg',
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _loadPrayerTimes,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFd4af37),
                        ),
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.only(left: 16, right: 16, top: 16),
                  child: Column(
                    children: [
                      // Header
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
                            'Prayer Times',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                      // Prayer Times List
                      MediaQuery.removePadding(
                        removeBottom: true,
                        context: context,
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: prayersList.length,
                          itemBuilder: (context, index) {
                            final prayer = prayersList[index];
                            final time = prayerTimes?[prayer['key']] ?? '--:--';
                            return Container(
                              margin: EdgeInsets.only(
                                bottom: index == prayersList.length - 1
                                    ? 0
                                    : 12,
                              ),
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Color(0xFF1a472a).withOpacity(0.6),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Color(0xFF4a7c5e),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    prayer['name'] as String,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    time,
                                    style: TextStyle(
                                      color: Color(0xFFd4af37),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
