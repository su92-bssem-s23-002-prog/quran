import 'package:flutter/material.dart';

class MasjidFinderScreen extends StatelessWidget {
  const MasjidFinderScreen({super.key});

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
                      'Masjid Finder',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Coming Soon Message
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.mosque, color: Color(0xFFd4af37), size: 80),
                      SizedBox(height: 24),
                      Text(
                        'Coming Soon',
                        style: TextStyle(
                          color: Color(0xFFd4af37),
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          'We are working on bringing you the best Masjid Finder experience',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFb0b0b0),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
