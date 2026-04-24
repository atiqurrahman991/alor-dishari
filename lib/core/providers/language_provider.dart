import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { english, bengali }

extension AppLanguageExt on AppLanguage {
  String get code  => this == AppLanguage.english ? 'en' : 'bn';
  String get label => this == AppLanguage.english ? 'English' : 'বাংলা';
}

const String _kLangKey = 'app_language';

class LanguageNotifier extends StateNotifier<AppLanguage> {
  LanguageNotifier(AppLanguage initial) : super(initial);

  Future<void> toggle() async {
    state = state == AppLanguage.english
        ? AppLanguage.bengali
        : AppLanguage.english;
    await _persist(state);
  }

  Future<void> setLanguage(AppLanguage lang) async {
    state = lang;
    await _persist(lang);
  }

  bool get isBengali => state == AppLanguage.bengali;

  Future<void> _persist(AppLanguage lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLangKey, lang.code);
  }
}

final languageProvider =
    StateNotifierProvider<LanguageNotifier, AppLanguage>((ref) {
  return LanguageNotifier(AppLanguage.bengali); // default: Bengali
});

Future<AppLanguage> loadSavedLanguage() async {
  final prefs = await SharedPreferences.getInstance();
  final code  = prefs.getString(_kLangKey);
  return code == 'en' ? AppLanguage.english : AppLanguage.bengali;
}
