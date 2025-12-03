import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../services/api_service.dart';
import '../localization/app_localizations.dart';
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
import 'ai_chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String currentTime = '00:00';
  String currentDate = '';
  String islamicDate = '';
  String username = '';
  bool isLoading = true;
  Timer? _timer;
  String _language = 'English';

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
    try {
      // Get username from Firebase Auth
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        username = user.displayName ?? 'User';
      }

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

      _updateTime();
      // Load saved language preference
      try {
        final prefs = await SharedPreferences.getInstance();
        final saved = prefs.getString('app_language');
        if (saved != null && mounted) {
          setState(() => _language = saved);
        }
      } catch (_) {}
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

  void _showProfileBottomSheet() {
    final user = FirebaseAuth.instance.currentUser;
    final userEmail = user?.email ?? '';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1a472a), Color(0xFF0d2818)],
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.only(top: 12, bottom: 20),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Color(0xFFd4af37).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Profile Picture
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFd4af37), Color(0xFFb8941f)],
                  ),
                  border: Border.all(color: Color(0xFFd4af37), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFd4af37).withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    username.isNotEmpty ? username[0].toUpperCase() : 'U',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0d2818),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              // Username
              Text(
                username,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 6),
              // Email
              Text(
                userEmail,
                style: TextStyle(fontSize: 14, color: Color(0xFFb0b0b0)),
              ),
              SizedBox(height: 24),
              Divider(color: Color(0xFF4a7c5e), thickness: 1, height: 1),
              // Language Selection
              StatefulBuilder(
                builder: (context, setModalState) {
                  final loc = AppLocalizations.of(_language);
                  return ListTile(
                    leading: const Icon(
                      Icons.language,
                      color: Color(0xFFd4af37),
                    ),
                    title: Text(
                      loc.translate('language'),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          ChoiceChip(
                            label: const Text('English'),
                            selected: _language == 'English',
                            selectedColor: const Color(0xFFd4af37),
                            backgroundColor: const Color(0xFF1a472a),
                            labelStyle: TextStyle(
                              color: _language == 'English'
                                  ? Colors.white
                                  : const Color(0xFFd4af37),
                            ),
                            onSelected: (v) async {
                              if (!v) return;
                              setModalState(() => _language = 'English');
                              setState(() => _language = 'English');
                              try {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setString(
                                  'app_language',
                                  'English',
                                );
                              } catch (_) {}
                            },
                          ),
                          const SizedBox(width: 12),
                          ChoiceChip(
                            label: const Text('اردو'),
                            selected: _language == 'Urdu',
                            selectedColor: const Color(0xFFd4af37),
                            backgroundColor: const Color(0xFF1a472a),
                            labelStyle: TextStyle(
                              color: _language == 'Urdu'
                                  ? Colors.white
                                  : const Color(0xFFd4af37),
                            ),
                            onSelected: (v) async {
                              if (!v) return;
                              setModalState(() => _language = 'Urdu');
                              setState(() => _language = 'Urdu');
                              try {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setString('app_language', 'Urdu');
                              } catch (_) {}
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              Divider(color: Color(0xFF4a7c5e), thickness: 1, height: 1),
              // Logout Option
              Builder(
                builder: (context) {
                  final loc = AppLocalizations.of(_language);
                  return ListTile(
                    leading: Icon(Icons.logout, color: Colors.red),
                    title: Text(
                      loc.translate('logout'),
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Color(0xFF1a472a),
                          title: Text(
                            loc.translate('logout'),
                            style: TextStyle(color: Colors.white),
                          ),
                          content: Text(
                            loc.translate('logout_confirm'),
                            style: TextStyle(color: Colors.white70),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(
                                loc.translate('cancel'),
                                style: TextStyle(color: Color(0xFFd4af37)),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(
                                loc.translate('logout'),
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
                          await FirebaseAuth.instance.signOut();
                        }
                        try {
                          await FacebookAuth.instance.logOut();
                        } catch (_) {}
                        if (mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                            (route) => false,
                          );
                        }
                      }
                    },
                  );
                },
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(_language);
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
                      // Top Bar - User Profile
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${loc.translate('greeting')}\n$username',
                              style: TextStyle(
                                color: Color(0xFFd4af37),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                height: 1.3,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _showProfileBottomSheet,
                            child: Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFd4af37),
                                    Color(0xFFb8941f),
                                  ],
                                ),
                                border: Border.all(
                                  color: Color(0xFFd4af37),
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  username.isNotEmpty
                                      ? username[0].toUpperCase()
                                      : 'U',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0d2818),
                                  ),
                                ),
                              ),
                            ),
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
                            label: loc.translate('prayer_times'),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PrayerTimesScreen(),
                              ),
                            ),
                          ),
                          _buildMenuItem(
                            icon: Icons.location_city,
                            label: loc.translate('masjid_finder'),
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
                            label: loc.translate('al_quran'),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AlQuranScreen(),
                              ),
                            ),
                          ),
                          _buildMenuItem(
                            icon: Icons.compass_calibration,
                            label: loc.translate('qibla'),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const QiblaScreen(),
                              ),
                            ),
                          ),
                          _buildMenuItem(
                            icon: Icons.calendar_today,
                            label: loc.translate('calendar'),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CalendarScreen(),
                              ),
                            ),
                          ),
                          _buildMenuItemSvg(
                            asset: 'assets/icons/tasbeeh.svg',
                            label: loc.translate('tasbeeh'),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TasbeehScreen(),
                              ),
                            ),
                          ),
                          _buildMenuItem(
                            icon: Icons.diamond,
                            label: loc.translate('five_pillars'),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const FivePillarsScreen(),
                              ),
                            ),
                          ),
                          _buildMenuItemSvg(
                            asset: 'assets/icons/duas.svg',
                            label: loc.translate('duas'),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DuasScreen(),
                              ),
                            ),
                          ),
                          _buildMenuItem(
                            icon: Icons.psychology,
                            label: loc.translate('ai_qa'),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AiChatScreen(),
                              ),
                            ),
                          ),
                          _buildMenuItem(
                            icon: Icons.info,
                            label: loc.translate('about_us'),
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
