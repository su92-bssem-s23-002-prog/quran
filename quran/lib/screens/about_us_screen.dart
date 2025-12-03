import 'package:flutter/material.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
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
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      'About Us',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                // App Logo Section
                Center(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Color(0xFF1a472a).withOpacity(0.6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Color(0xFF4a7c5e), width: 2),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Qur\'an App',
                          style: TextStyle(
                            color: Color(0xFFd4af37),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Version 1.0.0',
                          style: TextStyle(
                            color: Color(0xFFb0b0b0),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 28),
                // Description
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFF1a472a).withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFF4a7c5e), width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'About This App',
                        style: TextStyle(
                          color: Color(0xFFd4af37),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'The Qur\'an App is a comprehensive Islamic application designed to help Muslims connect with their faith. It provides essential Islamic tools and resources including prayer times, Qibla direction, Islamic calendar, digital Tasbeeh counter, and complete Qur\'an with Tajweed in 30 Juz.',
                        style: TextStyle(
                          color: Color(0xFFb0b0b0),
                          fontSize: 13,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                // Features
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFF1a472a).withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFF4a7c5e), width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Features',
                        style: TextStyle(
                          color: Color(0xFFd4af37),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      _buildFeatureItem(
                        Icons.schedule,
                        'Prayer Times',
                        'Accurate prayer times based on your GPS location with notifications',
                      ),
                      _buildFeatureItem(
                        Icons.location_city,
                        'Masjid Finder',
                        'Find nearby mosques on an interactive map',
                      ),
                      _buildFeatureItem(
                        Icons.menu_book,
                        'Al-Quran (30 Juz)',
                        'Read Tajweed Quran in 30 parts and full Quran with Urdu translation',
                      ),
                      _buildFeatureItem(
                        Icons.explore,
                        'Qibla Compass',
                        'Real-time compass showing direction to Kaaba in Mecca',
                      ),
                      _buildFeatureItem(
                        Icons.calendar_today,
                        'Islamic Calendar',
                        'View current Hijri date with conversion',
                      ),
                      _buildFeatureItem(
                        Icons.repeat,
                        'Digital Tasbeeh',
                        'Electronic counter for dhikr and tasbih',
                      ),
                      _buildFeatureItem(
                        Icons.star,
                        'Five Pillars of Islam',
                        'Educational content about Islam\'s fundamental pillars',
                      ),
                      _buildFeatureItem(
                        Icons.auto_stories,
                        'Duas Collection',
                        'Important Islamic supplications and prayers',
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                // Credits
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFF1a472a).withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFF4a7c5e), width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resources & APIs',
                        style: TextStyle(
                          color: Color(0xFFd4af37),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      _buildResourceItem(
                        'Aladhan API',
                        'Prayer times, Qibla direction & Islamic calendar',
                      ),
                      _buildResourceItem(
                        'Google Maps',
                        'Interactive maps for masjid finder',
                      ),
                      _buildResourceItem(
                        'Firebase',
                        'Authentication with Google & Facebook sign-in',
                      ),
                      _buildResourceItem(
                        'Flutter PDF Viewer',
                        'Quran PDF reading experience',
                      ),
                      _buildResourceItem(
                        'Geolocator & Compass',
                        'Location services and Qibla direction',
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                // Contact
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFF1a472a).withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFF4a7c5e), width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contact & Support',
                        style: TextStyle(
                          color: Color(0xFFd4af37),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'For support or feedback, please reach out to us at:\nshahzaibhassancp270@gmail.com',
                        style: TextStyle(
                          color: Color(0xFFb0b0b0),
                          fontSize: 13,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                // Copyright
                Center(
                  child: Text(
                    '© 2025 Qur\'an App. All rights reserved.',
                    style: TextStyle(color: Color(0xFF7a9a6b), fontSize: 12),
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

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Color(0xFFd4af37), size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Color(0xFFd4af37),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(color: Color(0xFF7a9a6b), fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceItem(String name, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Color(0xFFd4af37),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: Color(0xFFd4af37),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(color: Color(0xFF7a9a6b), fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
