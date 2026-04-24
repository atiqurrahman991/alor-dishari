import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kThemeKey = 'app_theme_mode';

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier(ThemeMode initial) : super(initial);

  Future<void> toggle() async {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await _persist(state);
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    await _persist(mode);
  }

  bool get isDark => state == ThemeMode.dark;

  Future<void> _persist(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeKey, mode.name);
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier(ThemeMode.light);
});

Future<ThemeMode> loadSavedTheme() async {
  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString(_kThemeKey);
  switch (saved) {
    case 'dark':   return ThemeMode.dark;
    case 'system': return ThemeMode.system;
    default:       return ThemeMode.light;
  }
}
