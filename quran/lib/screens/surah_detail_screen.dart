import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/tajweed_service.dart';
import '../widgets/app_scaffold.dart';

// Consolidated, minimal Surah detail + readers implementation.
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
    return AppScaffold(
      title: widget.surahName,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: const Icon(Icons.arrow_back, color: Color(0xFFd4af37)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 8),
            _buildOptionCard(
              title: 'Tajweed Quran',
              subtitle: 'With Tajweed color rules',
              icon: Icons.color_lens,
              color: const Color(0xFF1db854),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TajweedQuranReaderScreen(
                    surahNumber: widget.surahNumber,
                    surahName: widget.surahName,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildOptionCard(
              title: 'Tajweed Rules',
              subtitle: 'Learn Tajweed rules',
              icon: Icons.school,
              color: const Color(0xFFd4af37),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TajweedRulesScreen()),
              ),
            ),
            const SizedBox(height: 8),
            _buildOptionCard(
              title: 'Quran Text',
              subtitle: "Plain Qur'an text",
              icon: Icons.menu_book,
              color: const Color(0xFF4a7c5e),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QuranTextReaderScreen(
                    surahNumber: widget.surahNumber,
                    surahName: widget.surahName,
                  ),
                ),
              ),
            ),
          ],
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
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.6)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Tajweed Reader ---
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
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await ApiService.getSurah(widget.surahNumber);
      setState(() {
        ayahs = List<Map<String, dynamic>>.from(data['data']?['ayahs'] ?? []);
        isLoading = false;
      });
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  String _getAyahText(Map<String, dynamic> ayah) =>
      (ayah['text'] ??
              ayah['textUthmani'] ??
              ayah['arab'] ??
              ayah['arabic'] ??
              '')
          .toString();

  bool _firstAyahIsBasmalah() {
    if (ayahs.isEmpty) return false;
    final first = _getAyahText(ayahs.first);
    return first.contains('بسم') || first.contains('﷽');
  }

  @override
  Widget build(BuildContext context) {
    final basmalah = _firstAyahIsBasmalah();

    return AppScaffold(
      title: widget.surahName,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: const Icon(Icons.arrow_back, color: Color(0xFFd4af37)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Legend header showing tajweed colors and meanings
                  _buildLegend(),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: ayahs.length,
                      itemBuilder: (context, index) {
                        final ayahText = _getAyahText(ayahs[index]);
                        final showBasmalahInline = basmalah && index == 0;
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF07160f).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: showBasmalahInline
                              ? Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    ayahText,
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontFamily: 'Traditional Arabic',
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : RichText(
                                  textAlign: TextAlign.right,
                                  text: TextSpan(
                                    children: TajweedService.colorizeAyahText(
                                      ayahText,
                                      fontSize: 26,
                                    ),
                                  ),
                                ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildLegend() {
    final legend = TajweedService.getColorLegend();
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: legend.entries.map((e) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 16, height: 16, color: e.value),
            const SizedBox(width: 6),
            Text(e.key, style: const TextStyle(color: Colors.white70)),
          ],
        );
      }).toList(),
    );
  }
}

// --- Tajweed Rules (simple placeholder) ---
class TajweedRulesScreen extends StatelessWidget {
  const TajweedRulesScreen({super.key});

  static const Map<String, String> _rules = {
    'Ghunnah':
        'Ghunnah is a nasal sound produced with the nasal passage open for two counts; it occurs on noon and meem in specific contexts (e.g., meem shamsiyah, idgham with ghunnah).',
    'Idgham':
        'Idgham means merging one letter into another so that two letters are pronounced as one; it appears when noon sakinah or tanween meets certain letters.',
    'Qalqalah':
        'Qalqalah is a slight bouncing sound produced on specific consonants when they are in a sukoon or at the end of words (e.g., ق ط ب ج د).',
    'Ikhfaa':
        'Ikhfaa means hiding: the noon sound is partially concealed and pronounced between full izhar and full idgham (with a nasal quality).',
    'Iqlab':
        'Iqlab is converting the noon sound into a meem sound when followed by the letter ب, producing a light nasal sound and often indicated by a small meem above the noon.',
    'Madd':
        'Madd (lengthening) requires elongating the vowel for a specified number of counts when certain letters or signs appear; there are various types with different lengths.',
  };

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Tajweed Rules',
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: const Icon(Icons.arrow_back, color: Color(0xFFd4af37)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(
          children: _rules.entries.map((e) {
            return Card(
              color: const Color(0xFF092216),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.key,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      e.value,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// --- Plain Quran text reader ---
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
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await ApiService.getSurah(widget.surahNumber);
      setState(() {
        ayahs = List<Map<String, dynamic>>.from(data['data']?['ayahs'] ?? []);
        isLoading = false;
      });
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  String _getAyahText(Map<String, dynamic> ayah) =>
      (ayah['text'] ??
              ayah['textUthmani'] ??
              ayah['arab'] ??
              ayah['arabic'] ??
              '')
          .toString();

  bool _firstAyahIsBasmalah() {
    if (ayahs.isEmpty) return false;
    final first = _getAyahText(ayahs.first);
    return first.contains('بسم') || first.contains('﷽');
  }

  @override
  Widget build(BuildContext context) {
    final basmalah = _firstAyahIsBasmalah();

    return AppScaffold(
      title: widget.surahName,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: const Icon(Icons.arrow_back, color: Color(0xFFd4af37)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: ListView.builder(
                itemCount: ayahs.length,
                itemBuilder: (context, index) {
                  final ayahText = _getAyahText(ayahs[index]);
                  final showBasmalahInline = basmalah && index == 0;
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF07160f).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: showBasmalahInline
                        ? Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              ayahText,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 26,
                                fontFamily: 'Traditional Arabic',
                                color: Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            ayahText,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontFamily: 'Traditional Arabic',
                            ),
                          ),
                  );
                },
              ),
            ),
    );
  }
}
