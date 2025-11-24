import 'package:flutter/material.dart';
import '../screens/reading_mode_selection_screen.dart';

class AlQuranScreen extends StatefulWidget {
  const AlQuranScreen({super.key});

  @override
  State<AlQuranScreen> createState() => _AlQuranScreenState();
}

class _AlQuranScreenState extends State<AlQuranScreen> {
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
                      'Al-Quran',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Select Reading Mode Title
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Text(
                  'Select Reading Mode',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Three Reading Mode Options
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // Option 1: Quran Text (Plain Text)
                    _buildModeCard(
                      title: 'Quran Text',
                      subtitle: 'Simple text for easy reading',
                      icon: Icons.menu_book,
                      color: Color(0xFF4a7c5e),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReadingModeSelectionScreen(
                              readingMode: 'plain_text',
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 16),
                    // Option 2: Tajweed Rules
                    _buildModeCard(
                      title: 'Tajweed Rules',
                      subtitle: 'Learn Tajweed rules with explanations',
                      icon: Icons.school,
                      color: Color(0xFFd4af37),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReadingModeSelectionScreen(
                              readingMode: 'tajweed_rules',
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 16),
                    // Option 3: Tajweed Quran (Colored)
                    _buildModeCard(
                      title: 'Tajweed Quran',
                      subtitle: 'Colored text with Tajweed rules',
                      icon: Icons.color_lens,
                      color: Color(0xFF1db854),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReadingModeSelectionScreen(
                              readingMode: 'tajweed_quran',
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 2),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 36),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(color: Color(0xFFb0b0b0), fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 18),
          ],
        ),
      ),
    );
  }
}
