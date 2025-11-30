import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
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
import 'login_screen.dart';
import '../services/google_auth_service.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String currentTime = '00:00';
  String currentDate = '';
  String islamicDate = '';
  bool isLoading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initializeHome();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _initializeHome() async {
    // Just initialize time and date, no location request
    try {
      // Get Islamic date
      final now = DateTime.now();
      final formattedDate =
          '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
      final islamicData = await ApiService.getIslamicDate(formattedDate);

      setState(() {
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
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          currentTime = DateFormat('HH:mm').format(DateTime.now());
          currentDate = DateFormat('EEEE, dd MMM').format(DateTime.now());
        });
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
                      // Top Bar - Settings Only
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          PopupMenuButton<String>(
                            icon: Icon(
                              Icons.more_vert,
                              color: Color(0xFFd4af37),
                              size: 20,
                            ),
                            color: Color(0xFF1a472a),
                            onSelected: (value) async {
                              if (value == 'logout') {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: Color(0xFF1a472a),
                                    title: Text(
                                      'Logout',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    content: Text(
                                      'Are you sure you want to logout?',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(
                                            color: Color(0xFFd4af37),
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: Text(
                                          'Logout',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  try {
                                    await GoogleAuthService().signOut();
                                  } catch (_) {
                                    // fallback to Firebase signOut
                                    await FirebaseAuth.instance.signOut();
                                  }
                                  try {
                                    await FacebookAuth.instance.logOut();
                                  } catch (_) {}
                                  if (mounted) {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginScreen(),
                                      ),
                                      (route) => false,
                                    );
                                  }
                                }
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'logout',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.logout,
                                      color: Colors.red,
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Logout',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
                          _buildMenuItemSvg(
                            asset: 'assets/icons/prayer.svg',
                            label: 'Prayer times',
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
                          _buildMenuItemSvg(
                            asset: 'assets/icons/quran.svg',
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
                          _buildMenuItemSvg(
                            asset: 'assets/icons/tasbeeh.svg',
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
                          _buildMenuItemSvg(
                            asset: 'assets/icons/duas.svg',
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

  Widget _buildMenuItemSvg({
    required String asset,
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
            SvgPicture.asset(
              asset,
              color: Color(0xFFd4af37),
              width: 40,
              height: 40,
            ),
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
