import 'dart:io';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wisdeals/app_update_version.dart/app_update_version_repository.dart';
import 'package:wisdeals/core/failure.dart';
import 'package:wisdeals/core/success.dart';
import 'package:wisdeals/data/model/app_update_version_model/app_update_version_model.dart';

class AppUpdateVersionProvider extends ChangeNotifier {
  final AppUpdateVersionRepository appUpdateVersionRepository;
  AppUpdateVersionProvider({required this.appUpdateVersionRepository});

  bool _isLoading = false;
  bool _isUpdate = false;
  Failure? _failure;
  Success? _success;
  AppUpdateVersionModel? _appUpdateVersionModel;

  // getter
  bool get isLoading => _isLoading;
  bool get isUpdate => _isUpdate;
  Failure? get failure => _failure;
  Success? get success => _success;
  AppUpdateVersionModel? get appUpdateVersionModel => _appUpdateVersionModel;

  void clearFailure() {
    _failure = null;
    notifyListeners();
  }

  Future<void> fetchUpdateResponce() async {
    _isLoading = true;
    _failure = null;
    _appUpdateVersionModel = null;
    notifyListeners();

    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('token');
    print('token : ${token}');

    final result = await appUpdateVersionRepository.getAppUpdateVersion(token);

    result.fold(
      (failure) {
        _isLoading = false;
        _failure = failure;
        print('failure : update app provider  : $_failure');
        notifyListeners();
      },
      (success) {
        _isLoading = false;
        _appUpdateVersionModel = success;
        print('response : update app provider  : $_appUpdateVersionModel');
        notifyListeners();
      },
    );
  }

  Future<bool> checkForUpdate(BuildContext context) async {
    if (_appUpdateVersionModel!.data != null) {
      // Assuming the first item in the list is the latest version
      final packageInfo = await PackageInfo.fromPlatform();
      final latestVersionAndroid = _appUpdateVersionModel!.data!.androidVersion;
      final latestVersionIos = _appUpdateVersionModel!.data!.iosVersion;
      print('Current app version: ${packageInfo.version}');
      print('Latest available version Android: $latestVersionAndroid');
      print('Latest available version Ios: $latestVersionIos');
      // Here you would typically compare with the current app version
      // For demonstration, let's assume current version is "1.0.0"
      const currentVersion = "1.0.0";

      if (latestVersionAndroid != packageInfo.version.toString()) {
        print('from app version: ${packageInfo.version.toString()}');
        print('Update available version from api: $latestVersionAndroid');
        showUpdateDialog(
          context,
          _appUpdateVersionModel!.data!.forceUpdate!,
          _appUpdateVersionModel!.data!.message,
          _appUpdateVersionModel!.data!.updateUrlAndroid,
          _appUpdateVersionModel!.data!.updateUrlIos,
        );
        _isUpdate = true;
        notifyListeners();
        return true;
      } else {
        print('App is up to date.');
        _isUpdate = false;
        notifyListeners();
        return false;
      }
    } else {
      print('No update information available.');
      _isUpdate = false;
      notifyListeners();
      return false;
    }
  }
}

Future<void> showUpdateDialog(
  BuildContext context,
  bool forceUpdate,
  String? message,
  String? updateUrlAndroid,
  String? updateUrlIos,
) async {
  showDialog(
    context: context,
    barrierDismissible: !forceUpdate, // can't dismiss if force update
    builder:
        (context) => WillPopScope(
          onWillPop:
              () async => !forceUpdate, // block back button if force update
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: Colors.white,
            titlePadding: const EdgeInsets.only(top: 20),
            title: Column(
              children: [
                // Icon / Illustration
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  child: const Icon(
                    Icons.system_update_alt,
                    size: 40,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Update Available 🚀",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            content: Text(
              message ??
                  'A new version of the app is available.\nPlease update to continue.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
                color: Colors.black87,
              ),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actionsPadding: const EdgeInsets.only(
              bottom: 15,
              right: 15,
              left: 15,
            ),
            actions: [
              if (!forceUpdate)
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(color: Colors.grey),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Later",
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                onPressed: () async {
                  final url =
                      Platform.isIOS
                          ? Uri.parse(updateUrlIos!)
                          : Uri.parse(updateUrlAndroid!);

                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    throw "Could not launch $url";
                  }
                },
                child: const Text(
                  "Update Now",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
  );
}
