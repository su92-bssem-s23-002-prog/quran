import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'surah_detail_screen.dart';

class AlQuranScreen extends StatefulWidget {
  const AlQuranScreen({super.key});

  @override
  State<AlQuranScreen> createState() => _AlQuranScreenState();
}

class _AlQuranScreenState extends State<AlQuranScreen> {
  List<dynamic> surahs = [];
  List<dynamic> filteredSurahs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSurahs();
  }

  Future<void> _loadSurahs() async {
    try {
      final data = await ApiService.getAllSurahs();
      print('getAllSurahs response: $data');
      setState(() {
        // The Al-Quran Cloud API returns the list of surahs under the 'data' key.
        // Provide a few fallbacks in case the shape differs.
        List<dynamic> list = [];
        if (data.containsKey('data') && data['data'] is List) {
          list = List<dynamic>.from(data['data']);
        } else if (data.containsKey('surahs') && data['surahs'] is List) {
          list = List<dynamic>.from(data['surahs']);
        }
        surahs = list;
        filteredSurahs = surahs;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print('Error loading surahs: $e');
    }
  }

  void _filterSurahs(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredSurahs = surahs;
      } else {
        filteredSurahs = surahs
            .where(
              (surah) =>
                  surah['englishName'].toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
                  surah['number'].toString().contains(query),
            )
            .toList();
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
              // Search Box
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Color(0xFF1a472a).withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFF4a7c5e), width: 1.5),
                  ),
                  child: TextField(
                    style: TextStyle(color: Colors.white),
                    onChanged: _filterSurahs,
                    decoration: InputDecoration(
                      hintText: 'Search surahs...',
                      hintStyle: TextStyle(color: Color(0xFF7a9a6b)),
                      border: InputBorder.none,
                      icon: Icon(Icons.search, color: Color(0xFFd4af37)),
                    ),
                  ),
                ),
              ),
              // Surahs List
              Expanded(
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFd4af37),
                        ),
                      )
                    : (filteredSurahs.isEmpty
                          ? Center(
                              child: Text(
                                'No surahs found',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              itemCount: filteredSurahs.length,
                              itemBuilder: (context, index) {
                                final surah = filteredSurahs[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SurahDetailScreen(
                                          surahNumber: surah['number'],
                                          surahName: surah['englishName'] ?? '',
                                          numberOfAyahs: surah['numberOfAyahs'],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: 12),
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
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: Color(0xFF4a7c5e),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: Color(0xFFd4af37),
                                              width: 1,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              surah['number'].toString(),
                                              style: TextStyle(
                                                color: Color(0xFFd4af37),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                surah['englishName'] ?? '',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                '${surah['numberOfAyahs']} ayahs',
                                                style: TextStyle(
                                                  color: Color(0xFFb0b0b0),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          color: Color(0xFF4a7c5e),
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
