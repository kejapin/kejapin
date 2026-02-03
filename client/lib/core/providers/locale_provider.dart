import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  static const String _prefKey = 'selected_language_code';

  Locale get locale => _locale;

  LocaleProvider() {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString(_prefKey);
    
    if (languageCode != null) {
      if (languageCode.contains('_')) {
        final parts = languageCode.split('_');
        _locale = Locale(parts[0], parts[1]);
      } else {
        _locale = Locale(languageCode);
      }
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;

    _locale = locale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final languageCode = locale.countryCode != null 
        ? '${locale.languageCode}_${locale.countryCode}' 
        : locale.languageCode;
    await prefs.setString(_prefKey, languageCode);
  }

  void clearLocale() {
    _locale = const Locale('en');
    notifyListeners();
  }
}
