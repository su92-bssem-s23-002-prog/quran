import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SurahDetailScreen extends StatefulWidget {
  final int surahNumber;
  final String surahName;
  final int numberOfAyahs;

  const SurahDetailScreen({
    super.key,
    required this.surahNumber,
    required this.surahName,
    required this.numberOfAyahs,
  });

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
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
                      widget.surahName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Surah Info
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF1a472a).withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xFF4a7c5e), width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          'Surah No.',
                          style: TextStyle(
                            color: Color(0xFF7a9a6b),
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${widget.surahNumber}',
                          style: TextStyle(
                            color: Color(0xFFd4af37),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(width: 1, height: 40, color: Color(0xFF4a7c5e)),
                    Column(
                      children: [
                        Text(
                          'Total Ayahs',
                          style: TextStyle(
                            color: Color(0xFF7a9a6b),
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${widget.numberOfAyahs}',
                          style: TextStyle(
                            color: Color(0xFFd4af37),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Options Title
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Select Reading Mode',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 16),
              // Three Options
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // Option 1: Tajweed Quran
                    _buildOptionCard(
                      title: 'Tajweed Quran',
                      subtitle: 'With Tajweed color rules applied',
                      icon: Icons.color_lens,
                      color: Color(0xFF1db854),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TajweedQuranReaderScreen(
                              surahNumber: widget.surahNumber,
                              surahName: widget.surahName,
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 16),
                    // Option 2: Tajweed Rules
                    _buildOptionCard(
                      title: 'Tajweed Rules',
                      subtitle: 'Learn Tajweed rules and explanations',
                      icon: Icons.school,
                      color: Color(0xFFd4af37),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TajweedRulesScreen(
                              surahNumber: widget.surahNumber,
                              surahName: widget.surahName,
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 16),
                    // Option 3: Plain Quran
                    _buildOptionCard(
                      title: 'Quran Text',
                      subtitle: 'Read the Qur\'an text with translation',
                      icon: Icons.menu_book,
                      color: Color(0xFF4a7c5e),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuranTextReaderScreen(
                              surahNumber: widget.surahNumber,
                              surahName: widget.surahName,
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

  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 2),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 32),
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Color(0xFFb0b0b0), fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }
}

// ============ Tajweed Quran Reader Screen ============
class TajweedQuranReaderScreen extends StatefulWidget {
  final int surahNumber;
  final String surahName;

  const TajweedQuranReaderScreen({
    super.key,
    required this.surahNumber,
    required this.surahName,
  });

  @override
  State<TajweedQuranReaderScreen> createState() =>
      _TajweedQuranReaderScreenState();
}

class _TajweedQuranReaderScreenState extends State<TajweedQuranReaderScreen> {
  List<Map<String, dynamic>> ayahs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSurahAyahs();
  }

  Future<void> _loadSurahAyahs() async {
    try {
      final data = await ApiService.getSurah(widget.surahNumber);
      setState(() {
        ayahs = List<Map<String, dynamic>>.from(data['data']?['ayahs'] ?? []);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print('Error loading surahs: $e');
    }
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tajweed Quran',
                            style: TextStyle(
                              color: Color(0xFFd4af37),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.surahName,
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Ayahs List
              Expanded(
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFd4af37),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        itemCount: ayahs.length,
                        itemBuilder: (context, index) {
                          final ayah = ayahs[index];
                          return Container(
                            margin: EdgeInsets.only(bottom: 16),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Color(0xFF1a472a).withOpacity(0.6),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Color(0xFF4a7c5e),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Ayah number
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF1db854),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Ayah ${ayah['numberInSurah']}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 12),
                                // Arabic text with color-coded Tajweed rules
                                Text(
                                  ayah['text'] ?? '',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: Color(0xFFd4af37),
                                    fontSize: 18,
                                    fontFamily: 'Traditional Arabic',
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                SizedBox(height: 8),
                                // Tajweed legend info
                                Text(
                                  'Tajweed colors applied for proper Qur\'anic recitation',
                                  style: TextStyle(
                                    color: Color(0xFF7a9a6b),
                                    fontSize: 10,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============ Tajweed Rules Screen ============
class TajweedRulesScreen extends StatefulWidget {
  final int surahNumber;
  final String surahName;

  const TajweedRulesScreen({
    super.key,
    required this.surahNumber,
    required this.surahName,
  });

  @override
  State<TajweedRulesScreen> createState() => _TajweedRulesScreenState();
}

class _TajweedRulesScreenState extends State<TajweedRulesScreen> {
  final List<Map<String, String>> tajweedRules = [
    {
      'title': 'Idgham',
      'description':
          'Merging of letters. When two similar letters come together, they merge into one letter with a doubled sound.',
      'example': 'Merging the noon with the noon that follows',
    },
    {
      'title': 'Iqlab',
      'description':
          'Converting the noon or tanwin before the letter ba (ب) into a meem (م) that precedes the ba.',
      'example': 'Changing noon to meem before ba',
    },
    {
      'title': 'Ikhfaa',
      'description':
          'Hidden pronunciation. When noon or tanwin comes before one of the 15 letters of Ikhfaa, it is pronounced with a hidden nasal sound.',
      'example': 'Hiding the noon sound before other letters',
    },
    {
      'title': 'Madd',
      'description':
          'Lengthening of vowels. The long vowels (alif, waw, ya) are elongated based on Tajweed rules.',
      'example': 'Extending the vowel sounds for proper rhythm',
    },
    {
      'title': 'Qalqalah',
      'description':
          'The strong reverberation of certain letters. These letters are: Qaf, Taa, Ba, Jim, Dal.',
      'example': 'The bouncing sound of certain letters',
    },
    {
      'title': 'Ghunnah',
      'description':
          'A nasal twang that comes from the nose when pronouncing noon (ن) or meem (م).',
      'example': 'The nasal sound in noon and meem',
    },
  ];

  int? expandedIndex;

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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tajweed Rules',
                            style: TextStyle(
                              color: Color(0xFFd4af37),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Learn proper Qur\'anic recitation',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Rules List
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: tajweedRules.length,
                  itemBuilder: (context, index) {
                    final rule = tajweedRules[index];
                    final isExpanded = expandedIndex == index;

                    return GestureDetector(
                      onTap: () => setState(
                        () => expandedIndex = isExpanded ? null : index,
                      ),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Color(0xFF1a472a).withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isExpanded
                                ? Color(0xFFd4af37)
                                : Color(0xFF4a7c5e),
                            width: isExpanded ? 2 : 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      rule['title']!,
                                      style: TextStyle(
                                        color: Color(0xFFd4af37),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    isExpanded
                                        ? Icons.expand_less
                                        : Icons.expand_more,
                                    color: Color(0xFFd4af37),
                                  ),
                                ],
                              ),
                            ),
                            if (isExpanded)
                              Container(
                                padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: Color(0xFF4a7c5e),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 12),
                                    Text(
                                      rule['description']!,
                                      style: TextStyle(
                                        color: Color(0xFFb0b0b0),
                                        fontSize: 13,
                                        height: 1.6,
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Color(0xFF0d2818),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Color(0xFF4a7c5e),
                                          width: 1,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Example:',
                                            style: TextStyle(
                                              color: Color(0xFFd4af37),
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 6),
                                          Text(
                                            rule['example']!,
                                            style: TextStyle(
                                              color: Color(0xFF7a9a6b),
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============ Plain Quran Text Reader Screen ============
class QuranTextReaderScreen extends StatefulWidget {
  final int surahNumber;
  final String surahName;

  const QuranTextReaderScreen({
    super.key,
    required this.surahNumber,
    required this.surahName,
  });

  @override
  State<QuranTextReaderScreen> createState() => _QuranTextReaderScreenState();
}

class _QuranTextReaderScreenState extends State<QuranTextReaderScreen> {
  List<Map<String, dynamic>> ayahs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSurahAyahs();
  }

  Future<void> _loadSurahAyahs() async {
    try {
      final data = await ApiService.getSurah(widget.surahNumber);
      setState(() {
        ayahs = List<Map<String, dynamic>>.from(data['data']?['ayahs'] ?? []);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print('Error loading surahs: $e');
    }
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Qur\'an Text',
                            style: TextStyle(
                              color: Color(0xFFd4af37),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.surahName,
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Ayahs List
              Expanded(
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFd4af37),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        itemCount: ayahs.length,
                        itemBuilder: (context, index) {
                          final ayah = ayahs[index];
                          return Container(
                            margin: EdgeInsets.only(bottom: 16),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Color(0xFF1a472a).withOpacity(0.6),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Color(0xFF4a7c5e),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Ayah number
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF1db854),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Ayah ${ayah['numberInSurah']}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 12),
                                // Arabic text
                                Text(
                                  ayah['text'] ?? '',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: Color(0xFFd4af37),
                                    fontSize: 18,
                                    fontFamily: 'Traditional Arabic',
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
