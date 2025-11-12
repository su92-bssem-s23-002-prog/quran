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
                        'The Qur\'an App is a comprehensive Islamic application designed to help Muslims connect with their faith. It provides essential Islamic tools and resources including prayer times, Qibla direction, Islamic calendar, and the complete Qur\'an.',
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
                        'Get accurate prayer times based on your location',
                      ),
                      _buildFeatureItem(
                        Icons.location_on,
                        'Masjid Finder',
                        'Find nearby mosques in your area',
                      ),
                      _buildFeatureItem(
                        Icons.menu_book,
                        'Al-Quran',
                        'Read the holy Qur\'an',
                      ),
                      _buildFeatureItem(
                        Icons.explore,
                        'Qibla Direction',
                        'Find the direction of Mecca',
                      ),
                      _buildFeatureItem(
                        Icons.calendar_today,
                        'Islamic Calendar',
                        'View Islamic dates and months',
                      ),
                      _buildFeatureItem(
                        Icons.favorite,
                        'Tasbeeh Counter',
                        'Islamic prayer counter',
                      ),
                      _buildFeatureItem(
                        Icons.info,
                        'Five Pillars',
                        'Learn about the pillars of Islam',
                      ),
                      _buildFeatureItem(
                        Icons.auto_stories,
                        'Duas',
                        'Islamic prayers and supplications',
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
                        'Prayer times & Islamic dates',
                      ),
                      _buildResourceItem(
                        'Qur\'an Cloud API',
                        'Complete Qur\'an text',
                      ),
                      _buildResourceItem('Geolocator', 'Location services'),
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
                        'For support or feedback, please reach out to us at: support@quranapp.com',
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
                    '© 2024 Qur\'an App. All rights reserved.',
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
