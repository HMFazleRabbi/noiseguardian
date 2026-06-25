import 'package:flutter/material.dart';

/// Notifies [MaterialApp] when the user changes locale in Settings.
class AppLocaleNotifier extends ChangeNotifier {
  Locale? _locale;

  Locale? get locale => _locale;

  void setLocale(Locale? locale) {
    if (_locale == locale) {
      return;
    }
    _locale = locale;
    notifyListeners();
  }
}
