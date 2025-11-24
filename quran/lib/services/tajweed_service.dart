import 'package:flutter/material.dart';

/// Tajweed color mapping service
/// Maps Arabic text characters to tajweed rules and applies corresponding colors
class TajweedService {
  // Tajweed rule colors - Darker shades for better visibility
  // High-contrast, vivid Tajweed colors
  static const Color idghamColor = Color(0xFFE53935); // vivid red
  static const Color iqlapColor = Color(0xFF1565C0); // vivid blue
  static const Color ikhfaaColor = Color(0xFF2E7D32); // vivid green
  static const Color maddColor = Color(0xFFFB8C00); // vivid orange
  static const Color qalqalahColor = Color(0xFF8E24AA); // vivid purple
  static const Color ghunnnahColor = Color(0xFFFFC107); // vivid amber
  // Default text color should be white; tajweed colors will override specific letters
  static const Color defaultColor = Color(0xFFFFFFFF);
  static const Color muqattaatColor = Color(0xFF00BCD4); // cyan for muqattaat

  // Arabic characters for Tajweed rules
  // Idgham letters (حروف الادغام)
  static const String idghamLetters = 'يرملونـــــــــــ';

  // Iqlab letter (حرف الاقلاب)
  static const String iqlapLetter = 'ب';

  // Ikhfaa letters (حروف الاخفاء)
  static const String ikhfaaLetters = 'صسظطذتثتنكفقافخهحجشض';

  // Qalqalah letters (حروف القلقلة)
  static const String qalqalahLetters = 'قطبجد';

  // Letters that cause ghunnah (حروف الغنة)
  static const String ghunnnahLetters = 'نم';

  // Huroof al-Muqatta'at (الحروف المقطعة) - Disconnected letters at surah beginnings
  // Map of surah numbers to their disconnected letters
  static const Map<int, String> muqattaatLetters = {
    2: 'الم', // Al-Baqarah
    3: 'الم', // Ali 'Imran
    7: 'المص', // Al-A'raf
    10: 'الر', // Yunus
    11: 'الر', // Hud
    12: 'الر', // Yusuf
    13: 'المر', // Ar-Ra'd
    14: 'الر', // Ibrahim
    15: 'الر', // Al-Hijr
    19: 'كهيعص', // Maryam
    20: 'طه', // Taha
    26: 'طسم', // Ash-Shu'ara
    27: 'طس', // An-Naml
    28: 'طسم', // Al-Qasas
    29: 'الم', // Al-'Ankabut
    30: 'الم', // Ar-Rum
    31: 'الم', // Luqman
    32: 'الم', // As-Sajdah
    36: 'يس', // Ya-Sin
    38: 'ص', // Sad
    40: 'حم', // Ghafir
    41: 'حم', // Fussilat
    42: 'حم', // Ash-Shura
    43: 'حم', // Az-Zukhruf
    44: 'حم', // Ad-Dukhan
    45: 'حم', // Al-Jathiyah
    46: 'حم', // Al-Ahqaf
    50: 'ق', // Qaf
    68: 'ن', // Al-Qalam
  };

  /// Apply Tajweed coloring to Arabic text
  /// Returns a list of TextSpan widgets with appropriate colors
  static List<TextSpan> colorizeAyahText(
    String arabicText, {
    double fontSize = 18,
  }) {
    if (arabicText.isEmpty) {
      return [
        TextSpan(
          text: '',
          style: TextStyle(
            color: defaultColor,
            fontSize: fontSize,
            fontFamily: 'Traditional Arabic',
          ),
        ),
      ];
    }

    List<TextSpan> spans = [];

    for (int i = 0; i < arabicText.length; i++) {
      String char = arabicText[i];
      Color charColor = _getCharColor(char, arabicText, i);

      spans.add(
        TextSpan(
          text: char,
          style: TextStyle(
            color: charColor,
            fontSize: fontSize,
            fontFamily: 'Traditional Arabic',
          ),
        ),
      );
    }

    return spans;
  }

  /// Determine the color for a character based on Tajweed rules
  static Color _getCharColor(String char, String text, int index) {
    // Default to white; only override if a tajweed rule applies
    // Qalqalah letters
    if (qalqalahLetters.contains(char)) return qalqalahColor;

    // Ghunnah (noon & meem)
    if (ghunnnahLetters.contains(char)) return ghunnnahColor;

    // Iqlab: noon before ba
    if (char == 'ن' &&
        index + 1 < text.length &&
        text[index + 1] == iqlapLetter)
      return iqlapColor;

    // Ikhfaa: noon before ikhfaa letters
    if (char == 'ن' &&
        index + 1 < text.length &&
        ikhfaaLetters.contains(text[index + 1]))
      return ikhfaaColor;

    // Idgham: approximate by checking for letters that commonly merge
    if (idghamLetters.contains(char)) return idghamColor;

    // Madd: elongated letters following a vowel
    if ((char == 'ا' || char == 'و' || char == 'ي') &&
        index > 0 &&
        _isVowel(text[index - 1]))
      return maddColor;

    // Huroof al-Muqatta'at coloring when detected as standalone letters
    // (caller may choose to color based on surah context)
    return defaultColor;
  }

  /// Check if a character is a vowel marker
  static bool _isVowel(String char) {
    return char == 'َ' ||
        char == 'ُ' ||
        char == 'ِ' ||
        char == 'ـً' ||
        char == 'ـٌ' ||
        char == 'ـٍ';
  }

  /// Check if a character is part of Huroof al-Muqatta'at for a specific surah
  static bool isMuqattaatLetter(String char, int surahNumber) {
    String? muqattaat = muqattaatLetters[surahNumber];
    return muqattaat != null && muqattaat.contains(char);
  }

  /// Get Tajweed rule name for display
  static String getRuleNameForChar(String char) {
    if (qalqalahLetters.contains(char)) return 'Qalqalah';
    if (ghunnnahLetters.contains(char)) return 'Ghunnah';
    if (idghamLetters.contains(char)) return 'Idgham';
    if (char == 'ا' || char == 'و' || char == 'ي') return 'Madd';
    return 'Default';
  }

  /// Get color descriptions for legend
  static Map<String, Color> getColorLegend() {
    return {
      'Idgham (Merging)': idghamColor,
      'Iqlab (Converting)': iqlapColor,
      'Ikhfaa (Hiding)': ikhfaaColor,
      'Madd (Lengthening)': maddColor,
      'Qalqalah (Bouncing)': qalqalahColor,
      'Ghunnah (Nasal)': ghunnnahColor,
      'Huroof al-Muqatta\'at': muqattaatColor,
    };
  }
}
