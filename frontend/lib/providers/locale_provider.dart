import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  static const String _localeKey = 'locale';
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  /// List of supported locales
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('fr'),
    // Add more locales as needed
    // Locale('es'),
    // Locale('de'),
    // Locale('it'),
    // Locale('ja'),
    // Locale('zh'),
  ];

  /// Language names mapped to locale codes
  static const Map<String, String> languageNames = {
    'en': 'English',
    'fr': 'Français',
    // 'es': 'Español',
    // 'de': 'Deutsch',
    // 'it': 'Italiano',
    // 'ja': '日本語',
    // 'zh': '中文',
  };

  LocaleProvider() {
    _loadLocale();
  }

  /// Load the saved locale from shared preferences
  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localeCode = prefs.getString(_localeKey);
      if (localeCode != null) {
        final locale = Locale(localeCode);
        if (supportedLocales.contains(locale)) {
          _locale = locale;
          notifyListeners();
        }
      }
    } catch (e) {
      // If there's an error loading preferences, use default (English)
      debugPrint('Error loading locale preference: $e');
    }
  }

  /// Set a new locale
  Future<void> setLocale(Locale locale) async {
    if (!supportedLocales.contains(locale) || _locale == locale) {
      return;
    }

    _locale = locale;
    notifyListeners();
    await _saveLocale();
  }

  /// Save the current locale to shared preferences
  Future<void> _saveLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, _locale.languageCode);
    } catch (e) {
      // If there's an error saving preferences, continue without saving
      debugPrint('Error saving locale preference: $e');
    }
  }

  /// Get the display name for a given locale
  String getLanguageName(Locale locale) {
    return languageNames[locale.languageCode] ?? locale.languageCode;
  }

  /// Get all supported languages with their display names
  Map<Locale, String> getSupportedLanguages() {
    return {
      for (final locale in supportedLocales) locale: getLanguageName(locale)
    };
  }
}
