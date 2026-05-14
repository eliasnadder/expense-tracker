import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const _prefKey = 'app_theme_mode';

  ThemeCubit() : super(ThemeMode.system);

  /// Call once at startup (before runApp) to restore saved preference.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKey) ?? 'system';
    emit(_fromString(saved));
  }

  Future<void> setTheme(String label) async {
    final mode = _fromLabel(label);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, _toString(mode));
    emit(mode);
  }

  // ── helpers ──────────────────────────────────────────────────────────────

  static ThemeMode _fromLabel(String label) => switch (label) {
    'Light' => ThemeMode.light,
    'Dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  static ThemeMode _fromString(String s) => switch (s) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  static String _toString(ThemeMode mode) => switch (mode) {
    ThemeMode.light => 'light',
    ThemeMode.dark => 'dark',
    ThemeMode.system => 'system',
  };

  /// Convert the stored ThemeMode back to the label used in the UI picker.
  static String toLabel(ThemeMode mode) => switch (mode) {
    ThemeMode.light => 'Light',
    ThemeMode.dark => 'Dark',
    ThemeMode.system => 'System',
  };
}
