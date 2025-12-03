class AppLocalizations {
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'greeting': 'Assalamu Alaikum,',
      'prayer_times': 'Prayer times',
      'masjid_finder': 'Masjid Finder',
      'al_quran': 'Al-Quran',
      'qibla': 'Qibla',
      'calendar': 'Calendar',
      'tasbeeh': 'Tasbeeh',
      'five_pillars': '5 Pillars',
      'duas': 'Duas',
      'about_us': 'About Us',
      'ai_qa': 'AI Q&A',
      'logout': 'Logout',
      'language': 'Language',
      'logout_confirm': 'Are you sure you want to logout?',
      'cancel': 'Cancel',
      'select_juz': 'Select Juz',
      'tajweed_quran': 'Tajweed Quran (Juz 1–30)',
      'tajweed_subtitle': 'Open Tajweed by individual Juz',
      'quran_translation': 'Quran with Translation (Urdu)',
      'translation_subtitle': 'Read Quran with Urdu translation',
      'juz': 'Juz',
    },
    'ur': {
      'greeting': 'السلام علیکم،',
      'prayer_times': 'نماز کے اوقات',
      'masjid_finder': 'مسجد تلاش کریں',
      'al_quran': 'القرآن',
      'qibla': 'قبلہ',
      'calendar': 'کیلنڈر',
      'tasbeeh': 'تسبیح',
      'five_pillars': '5 ارکان',
      'duas': 'دعائیں',
      'about_us': 'ہمارے بارے میں',
      'ai_qa': 'AI سوال و جواب',
      'logout': 'لاگ آؤٹ',
      'language': 'زبان',
      'logout_confirm': 'کیا آپ واقعی لاگ آؤٹ کرنا چاہتے ہیں؟',
      'cancel': 'منسوخ کریں',
      'select_juz': 'پارہ منتخب کریں',
      'tajweed_quran': 'تجوید قرآن (پارہ 1-30)',
      'tajweed_subtitle': 'انفرادی پارے کے ذریعے تجوید کھولیں',
      'quran_translation': 'ترجمہ کے ساتھ قرآن (اردو)',
      'translation_subtitle': 'اردو ترجمہ کے ساتھ قرآن پڑھیں',
      'juz': 'پارہ',
    },
  };

  final String languageCode;

  AppLocalizations(this.languageCode);

  String translate(String key) {
    return _localizedValues[languageCode]?[key] ?? key;
  }

  static AppLocalizations of(String lang) {
    return AppLocalizations(lang == 'Urdu' ? 'ur' : 'en');
  }
}
