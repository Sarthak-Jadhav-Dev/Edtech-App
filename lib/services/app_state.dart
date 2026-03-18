import 'package:shared_preferences/shared_preferences.dart';

class AppState {
  static Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('first_time') ?? true;
  }

  static Future<void> setNotFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('first_time', false);
  }
}