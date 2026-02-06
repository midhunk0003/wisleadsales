import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisdeals/core/failure.dart';
import 'package:wisdeals/core/success.dart';
import 'package:wisdeals/data/model/login_model/login_model.dart';
import 'package:wisdeals/domain/repository/auth_repository.dart';
import 'package:wisdeals/main.dart';
import 'package:wisdeals/presentation/provider/home_provider.dart';
import 'package:wisdeals/presentation/provider/lead_provider.dart';
import 'package:wisdeals/presentation/provider/profile_provider.dart';

class AuthProvider extends ChangeNotifier {
  AuthRepository authRepository;

  AuthProvider({required this.authRepository});

  bool _isLoading = false;
  bool _isVisible = true;
  Success? _success;
  Failure? _failure;
  LoginModel? _loginResponse;

  // getter
  bool get isLoading => _isLoading;
  bool get isVisible => _isVisible;
  Success? get success => _success;
  Failure? get failure => _failure;
  LoginModel? get loginResponse => _loginResponse;

  // make password visiblity
  void isVisibleOrNot() {
    _isVisible = !_isVisible;
    print({!_isVisible});
    notifyListeners();
  }

  // make login function
  Future<void> loginProvider(String? email, String? password) async {
    _isLoading = true;
    _failure = null;
    clearAllFailuresAfterLogin();
    notifyListeners();
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? fcmtoken = pref.getString('fcm_token');
    print('FCM Token in Auth Provider: $fcmtoken');
    final result = await authRepository.login(email, password, fcmtoken);
    result.fold(
      (failure) {
        _isLoading = false;
        _failure = failure;
        notifyListeners();
      },
      (success) {
        _isLoading = false;
        _loginResponse = success;
        print('success in provider : ${success}');
        // saveFcmTokenToSharedPrefrence(fcmtoken);
        notifyListeners();
      },
    );
  }

  void clearFailure() {
    print('clear failure called');
    _failure = null;
    notifyListeners();
  }

  void clearAllFailuresAfterLogin() {
    final home = navigatorKey.currentContext!.read<HomeProvider>();
    final lead = navigatorKey.currentContext!.read<LeadProvider>();
    final profile = navigatorKey.currentContext!.read<ProfileProvider>();

    home.clearFailure();
    lead.clearFailure();
    profile.clearFailure();
    notifyListeners();
  }
  // // save the token to sharedprefrence
  // Future<void> saveFcmTokenToSharedPrefrence(String? fcmtoken) async {
  //   _isLoading = true;
  //   notifyListeners();
  //   final SharedPreferences pref = await SharedPreferences.getInstance();
  //   await pref.setString('fcm_token', fcmtoken!);
  //   _isLoading = false;
  //   notifyListeners();
  // }

  Future<void> logOut(context) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.remove('token');
    // Navigate to login screen and remove all previous routes
    final token = pref.getString('token');
    if (token == null || token.isEmpty) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/loginScreen',
        (Route<dynamic> route) => false,
      );
    }
    notifyListeners();
  }
}
