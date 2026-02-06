import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardProvider extends ChangeNotifier {
  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isOnboarded', true);
    notifyListeners();
  }
}
