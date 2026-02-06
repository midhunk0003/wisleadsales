import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisdeals/main.dart';

class AuthService {
  static Future<void> forceLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Navigate to login screen
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/loginScreen',
      (route) => false,
    );

    // Show SnackBar after navigation
    Future.delayed(const Duration(milliseconds: 300), () {
      final context = navigatorKey.currentContext;
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Session expired. Please login again."),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    });
  }
}
