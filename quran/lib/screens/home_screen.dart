import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import 'prayer_times_screen.dart';
import 'masjid_finder_screen.dart';
import 'al_quran_screen.dart';
import 'qibla_screen.dart';
import 'calendar_screen.dart';
import 'tasbeeh_screen.dart';
import 'five_pillars_screen.dart';
import 'duas_screen.dart';
import 'about_us_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String location = 'Rawalpindi, Pakistan';
  String currentTime = '00:00';
  String currentDate = '';
  String islamicDate = '';
  String asarTime = '00:00';
  Map<String, dynamic>? prayerTimes;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeHome();
  }

  Future<void> _initializeHome() async {
    try {
      const String city = 'Rawalpindi';
      const String country = 'Pakistan';

      // Get prayer times
      final prayerData = await ApiService.getPrayerTimes(city, country);

      // Get Islamic date
      final now = DateTime.now();
      final formattedDate =
          '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
      final islamicData = await ApiService.getIslamicDate(formattedDate);

      setState(() {
        prayerTimes = prayerData['data']?['timings'];
        asarTime = prayerTimes?['Asr'] ?? '00:00';

        final hijri = islamicData['data']?['hijri'];
        islamicDate =
            '${hijri?['day']} ${hijri?['month']?['en']} ${hijri?['year']} AH';

        isLoading = false;
      });

      // Update time every second
      _updateTime();
    } catch (e) {
      print('Error initializing home: $e');
      setState(() {
        isLoading = false;
      });
      _updateTime();
    }
  }

  void _updateTime() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          currentTime = DateFormat('HH:mm').format(DateTime.now());
          currentDate = DateFormat(
            'EEEE, dd MMM',
          ).format(DateTime.now()).toString();
        });
        _updateTime();
      }
    });
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
          child: isLoading
              ? Center(
                  child: CircularProgressIndicator(color: Color(0xFFd4af37)),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    children: [
                      // Top Bar - Location and Settings
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Color(0xFFd4af37),
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                location,
                                style: TextStyle(
                                  color: Color(0xFFd4af37),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.settings,
                              color: Color(0xFFd4af37),
                              size: 20,
                            ),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      // Decorative Top Pattern
                      Container(
                        height: 40,
                        child: Center(
                          child: Text(
                            '✦ ✦ ✦',
                            style: TextStyle(
                              color: Color(0xFFd4af37),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      // Time and Date Card
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 40,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFF1a472a).withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Color(0xFF4a7c5e),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            // Time
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  currentTime,
                                  style: TextStyle(
                                    color: Color(0xFFd4af37),
                                    fontSize: 56,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'ASAR\nPM',
                                  style: TextStyle(
                                    color: Color(0xFFd4af37),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            // Gregorian Date
                            Text(
                              currentDate,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            // Islamic Date
                            Text(
                              islamicDate,
                              style: TextStyle(
                                color: Color(0xFFb0b0b0),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30),
                      // Menu Grid
                      GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.0,
                        children: [
                          _buildMenuItem(
                            icon: Icons.schedule,
                            label: 'Prayer Times',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PrayerTimesScreen(),
                              ),
                            ),
                          ),
                          _buildMenuItem(
                            icon: Icons.location_city,
                            label: 'Masjid Finder',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const MasjidFinderScreen(),
                              ),
                            ),
                          ),
                          _buildMenuItem(
                            icon: Icons.menu_book,
                            label: 'Al-Quran',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AlQuranScreen(),
                              ),
                            ),
                          ),
                          _buildMenuItem(
                            icon: Icons.compass_calibration,
                            label: 'Qibla',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const QiblaScreen(),
                              ),
                            ),
                          ),
                          _buildMenuItem(
                            icon: Icons.calendar_today,
                            label: 'Calendar',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CalendarScreen(),
                              ),
                            ),
                          ),
                          _buildMenuItem(
                            icon: Icons.settings_voice,
                            label: 'Tasbeeh',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TasbeehScreen(),
                              ),
                            ),
                          ),
                          _buildMenuItem(
                            icon: Icons.diamond,
                            label: '5 Pillars',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const FivePillarsScreen(),
                              ),
                            ),
                          ),
                          _buildMenuItem(
                            icon: Icons.favorite,
                            label: 'Duas',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DuasScreen(),
                              ),
                            ),
                          ),
                          _buildMenuItem(
                            icon: Icons.info,
                            label: 'About Us',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AboutUsScreen(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF1a472a).withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Color(0xFF4a7c5e), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Color(0xFFd4af37), size: 40),
            SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
