import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static final LanguageService instance = LanguageService._internal();
  LanguageService._internal();

  String _currentLanguage = 'am';
  String get currentLanguage => _currentLanguage;

  static const Map<String, String> languageNames = {
    'am': 'አማርኛ (Amharic)',
    'om': 'Afaan Oromoo',
    'en': 'English',
  };

  static const Map<String, Map<String, String>> _translations = {
    'app_title': {
      'am': 'የቡና ዶክተር',
      'om': 'Doktoora Bunaa',
      'en': 'Coffee Leaf Doctor',
    },
    'app_subtitle': {
      'am': 'የቡና ቅጠል በሽታ መለያ',
      'om': 'Waliin dhukkuba baala bunaa baruu',
      'en': 'Coffee Leaf Disease Detector',
    },
    'tab_scan': {
      'am': 'ምርመራ',
      'om': 'Qorannoo',
      'en': 'Scan',
    },
    'tab_history': {
      'am': 'የምርመራ ታሪክ',
      'om': 'Seenaa Qorannoo',
      'en': 'History',
    },
    'tab_guide': {
      'am': 'የበሽታዎች መመሪያ',
      'om': 'Qajeelfama Dhukkubaa',
      'en': 'Disease Guide',
    },
    'take_photo': {
      'am': 'ካሜራ',
      'om': 'Kaameraa',
      'en': 'Camera',
    },
    'pick_gallery': {
      'am': 'ጋለሪ',
      'om': 'Gaalerii',
      'en': 'Gallery',
    },
    'empty_picker_title': {
      'am': 'የቡና ቅጠል ፎቶ ያንሱ ወይም ይምረጡ',
      'om': 'Suuraa baala bunaa kaasaa ykn filadhaa',
      'en': 'Capture or select a coffee leaf photo',
    },
    'empty_picker_subtitle': {
      'am': 'ካሜራ ወይም ጋለሪ በመጠቀም ቅጠሉን ይመርምሩ',
      'om': 'Kaameraa ykn gaalerii fayyadamuun baala qoradhaa',
      'en': 'Analyze coffee leaves with camera or gallery',
    },
    'analyzing': {
      'am': 'ቅጠሉን በመመርመር ላይ...',
      'om': 'Baala qorachaa jira...',
      'en': 'Analyzing coffee leaf...',
    },
    'confidence': {
      'am': 'እርግጠኝነት',
      'om': 'Mirkaneeffannaa',
      'en': 'Confidence',
    },
    'listen_voice': {
      'am': 'በድምፅ አዳምጥ',
      'om': 'Sagaleen dhaggeeffadhaa',
      'en': 'Listen to Audio',
    },
    'treatment_btn': {
      'am': 'የህክምና እና የመፍትሄ መመሪያ ይመልከቱ',
      'om': 'Qajeelfama yaalaa fi furmaataa ilaalaa',
      'en': 'View Treatment & Medicine Guide',
    },
    'symptoms': {
      'am': 'የበሽታው ምልክቶች',
      'om': 'Mallattoolee Dhukkubichaa',
      'en': 'Symptoms',
    },
    'causes': {
      'am': 'የበሽታው መንስኤ',
      'om': 'Sababa Dhukkubichaa',
      'en': 'Causes',
    },
    'organic_care': {
      'am': 'የባህል እና የተፈጥሮ መፍትሄዎች',
      'om': 'Furmaata Aadaafi Uumamaa',
      'en': 'Organic & Cultural Care',
    },
    'chemical_treatment': {
      'am': 'የኬሚካል ርጭት መመሪያ',
      'om': 'Qajeelfama Biifaa Keemikaalaa',
      'en': 'Chemical Treatment',
    },
    'prevention': {
      'am': 'የመከላከያ እርምጃዎች',
      'om': 'Tarkaanfii Ittisaa',
      'en': 'Prevention',
    },
    'clear_history': {
      'am': 'ታሪክ አጽዳ',
      'om': 'Seenaa haqi',
      'en': 'Clear History',
    },
    'no_history': {
      'am': 'ምንም የተመዘገበ ምርመራ የለም',
      'om': 'Qorannoon galmaa’e hin jiru',
      'en': 'No scan history recorded yet',
    },
    'select_language': {
      'am': 'ቋንቋ ይምረጡ',
      'om': 'Afaan filadhaa',
      'en': 'Select Language',
    },
  };

  String t(String key) {
    return _translations[key]?[_currentLanguage] ??
        _translations[key]?['am'] ??
        key;
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString('selected_language') ?? 'am';
    notifyListeners();
  }

  Future<void> setLanguage(String langCode) async {
    if (_currentLanguage == langCode) return;
    _currentLanguage = langCode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', langCode);
  }
}