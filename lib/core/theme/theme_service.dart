import 'package:flutter/material.dart';
import '../../services/local_storage_service.dart';

class ThemeService {
  final LocalStorageService _localStorage;
  late final ValueNotifier<ThemeMode> themeModeNotifier;

  ThemeService(this._localStorage) {
    final savedMode = _localStorage.getThemeMode();
    final initialMode = _parseThemeMode(savedMode);
    themeModeNotifier = ValueNotifier<ThemeMode>(initialMode);
  }

  ThemeMode get themeMode => themeModeNotifier.value;

  bool isDark(BuildContext context) {
    if (themeMode == ThemeMode.dark) return true;
    if (themeMode == ThemeMode.light) return false;
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
  }

  void setThemeMode(ThemeMode mode) {
    if (themeModeNotifier.value == mode) return;
    themeModeNotifier.value = mode;
    _localStorage.saveThemeMode(_themeModeToString(mode));
  }

  ThemeMode _parseThemeMode(String mode) {
    switch (mode) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.light:
        return 'light';
      default:
        return 'system';
    }
  }
}
