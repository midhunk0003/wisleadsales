import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisdeals/core/failure.dart';
import 'package:wisdeals/core/success.dart';
import 'package:wisdeals/data/model/home_model/home_model.dart';
import 'package:wisdeals/domain/repository/home_repository.dart';
import 'package:wisdeals/services/auth_services.dart';

class HomeProvider extends ChangeNotifier {
  final HomeRepository homeRepository;
  final LocalAuthentication auth = LocalAuthentication();

  HomeProvider({required this.homeRepository});

  GoogleMapController? mapController;

  /// LIVE LOCATION STREAM
  StreamSubscription<Position>? userPositionStream;
  Timer? _sendLocationTimer;
  // ----------------- STATE -----------------
  bool _isLoading = false;
  bool _isLoadingAuth = false;
  bool _hasClockin = false;

  Failure? _failure;
  Success? _success;
  HomeDataModel? _homeData;

  // LOCATION + TRACKING
  LatLng? currentPosition;
  LatLng? lastPosition;
  double totalDistance = 0.0;

  // sharedPreferences data
  LatLng? _currentPositionPrefData;
  double _totalDistancePrefData = 0.0;

  //
  Set<Marker> markers = {};
  double? _latitude;
  double? _longitude;

  // ----------------- GETTERS -----------------
  bool get isLoading => _isLoading;
  bool get isLoadingAuth => _isLoadingAuth;
  bool get hasClockin => _hasClockin;
  Failure? get failure => _failure;
  Success? get success => _success;
  HomeDataModel? get homeData => _homeData;
  // sharedPreferences data
  LatLng? get currentPositionPrefData => _currentPositionPrefData;
  double get totalDistancePrefData => _totalDistancePrefData;
  double? get latitude => _latitude;
  double? get longitude => _longitude;

  // ----------------- INTERNAL HELPERS -----------------

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setAuthLoading(bool value) {
    _isLoadingAuth = value;
    notifyListeners();
  }

  void _setFailure(Failure? failure) {
    _failure = failure;
    notifyListeners();
  }

  void _setSuccess(Success? success) {
    _success = success;
    notifyListeners();
  }

  String _distanceInKmString() {
    // totalDistance is in meters -> convert to km with 3 decimals
    return (totalDistance / 1000).toStringAsFixed(3);
  }

  // ----------------- PUBLIC HELPERS -----------------
  void clearFailure() {
    _failure = null;
    notifyListeners();
  }

  // ----------------- HOME DATA -----------------
  Future<void> getHomePro() async {
    _setLoading(true);
    _setFailure(null);

    try {
      final SharedPreferences pref = await SharedPreferences.getInstance();
      final String? token = pref.getString('token');

      final result = await homeRepository.getHomeData(token);
      result.fold(
        (failure) async {
          if (failure is AuthFailure) {
            print('vvvvvvvvvvvvvvvvvvvv...${failure.message}');
            await AuthService.forceLogout();
          }
          _setLoading(false);
          _setFailure(failure);
        },
        (success) {
          _setLoading(false);
          _homeData = success;

          // You can derive hasClockin from API data if needed
          _hasClockin = success.status == true;
          if (_hasClockin) {
            _startTracking();
          } else {
            stopLocationTracking();
          }
          notifyListeners();
        },
      );
    } catch (e) {
      _setLoading(false);
      // _setFailure();
    }
  }

  // ----------------- Send Latitude and Longitude pro -----------------
  Future<void> sendLatitudeAndLongPro(
    String? latitude,
    String? longitude,
  ) async {
    print('adding .......... lat and long ${latitude}${longitude}');
    _setLoading(true);
    _setFailure(null);
    _setSuccess(null);

    try {
      final SharedPreferences pref = await SharedPreferences.getInstance();
      final String? token = pref.getString('token');

      final result = await homeRepository.sendLatitudeAndLongitude(
        token,
        latitude,
        longitude,
      );

      result.fold(
        (failure) async {
          if (failure is AuthFailure) {
            print('vvvvvvvvvvvvvvvvvvvv...${failure.message}');
            await AuthService.forceLogout();
          }
          _setLoading(false);
          _setFailure(failure);
        },
        (success) {
          _setLoading(false);
          _setSuccess(success);
          _startTracking();
        },
      );
    } catch (e) {
      _setLoading(false);
      // _setFailure(Failure(message: 'Something went wrong. Please try again.'));
    }
  }

  void _startSendLocationTimer() {
    _sendLocationTimer?.cancel();
    _sendLocationTimer = Timer.periodic(const Duration(minutes: 30), (_) {
      if (currentPosition != null) {
        sendLatitudeAndLongPro(
          currentPosition!.latitude.toString(),
          currentPosition!.longitude.toString(),
        );
      }
    });
  }

  // ----------------- CLOCK IN -----------------
  Future<void> clockInPro() async {
    _setLoading(true);
    _setFailure(null);
    _setSuccess(null);

    try {
      final SharedPreferences pref = await SharedPreferences.getInstance();
      final String? token = pref.getString('token');

      final result = await homeRepository.clockIn(
        token,
        latitude?.toString() ?? '',
        longitude?.toString() ?? '',
        (_totalDistancePrefData / 1000).toStringAsFixed(2) ??
            _distanceInKmString(),
      );

      result.fold(
        (failure) async {
          if (failure is AuthFailure) {
            print('vvvvvvvvvvvvvvvvvvvv...${failure.message}');
            await AuthService.forceLogout();
          }
          _setLoading(false);
          _setFailure(failure);
        },
        (success) {
          _setLoading(false);
          _setSuccess(success);
          _hasClockin = true;
          _startTracking();
          getHomePro();
        },
      );
    } catch (e) {
      _setLoading(false);
      // _setFailure(Failure(message: 'Something went wrong. Please try again.'));
    }
  }

  // ----------------- CLOCK OUT -----------------
  Future<void> clockOutPro() async {
    _setLoading(true);
    _setFailure(null);
    _setSuccess(null);

    try {
      final SharedPreferences pref = await SharedPreferences.getInstance();
      final String? token = pref.getString('token');

      final result = await homeRepository.ClockOut(
        token,
        latitude?.toString() ?? '',
        longitude?.toString() ?? '',
        (_totalDistancePrefData / 1000).toStringAsFixed(2) ??
            _distanceInKmString(),
      );

      result.fold(
        (failure) async {
          if (failure is AuthFailure) {
            print('vvvvvvvvvvvvvvvvvvvv...${failure.message}');
            await AuthService.forceLogout();
          }
          _setLoading(false);
          _setFailure(failure);
        },
        (success) async {
          _setLoading(false);
          _setSuccess(success);
          _hasClockin = false;
          await stopLocationTracking();
          await getHomePro();
        },
      );
    } catch (e) {
      _setLoading(false);
      // Use a concrete Failure subclass instead of abstract Failure
      // _setFailure(Failure(message: 'Something went wrong. Please try again.'));
    }
  }

  // ----------------- BIOMETRIC AUTH + CLOCK -----------------
  Future<void> authenticateAndClock(BuildContext context) async {
    try {
      _setAuthLoading(true);
      _setFailure(null);
      _setSuccess(null);

      // Ensure latest home data
      if (_homeData == null) {
        await getHomePro();
      }

      // 1️⃣ Check device support
      final bool isSupported = await auth.isDeviceSupported();
      if (!isSupported) {
        _showInfo(
          context,
          "Secure authentication is not available on this device.\n\n"
          "Please enable a secure screen lock such as Fingerprint, Pattern, or Password to continue.",
        );
        return;
      }

      // 2️⃣ Check available biometrics
      final biometrics = await auth.getAvailableBiometrics();
      final bool hasBiometrics = biometrics.isNotEmpty;

      final bool canAuthenticate = await auth.canCheckBiometrics || isSupported;

      if (!canAuthenticate) {
        _showInfo(context, "Authentication is not available on this device.");
        return;
      }

      // 3️⃣ Authenticate
      final bool didAuthenticate = await auth.authenticate(
        localizedReason:
            hasBiometrics
                ? "Scan your fingerprint / face ID to continue"
                : "Enter your device PIN / Pattern / Password to continue",
        options: AuthenticationOptions(
          biometricOnly: hasBiometrics, // 👈 KEY CHANGE
          stickyAuth: true,
        ),
      );

      if (!didAuthenticate) {
        _setAuthLoading(false);
        return;
      }

      // 4️⃣ Get current location
      final bool locationOk = await _getCurrentLocation(context);
      if (!locationOk) {
        _setAuthLoading(false);
        return;
      }

      // 5️⃣ Decide clock-in / clock-out
      if (_homeData?.status == true) {
        await clockOutPro();
      } else {
        if (_homeData?.clockOut == null) {
          await clockInPro();
        } else {
          _setSuccess(null);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.close, color: Colors.white),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Attendance already marked for today.',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              elevation: 8,
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(14)),
              ),
            ),
          );
        }
      }

      // 6️⃣ Success message
      if (_success != null) {
        final bool isAlready = _success!.message.toLowerCase().contains(
          'already',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  isAlready ? Icons.close : Icons.check_circle,
                  color: Colors.white,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _success!.message,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor:
                isAlready ? Colors.red.shade500 : Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            elevation: 8,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
      }

      // 7️⃣ Failure message
      if (_failure != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_failure!.message ?? 'Something went wrong'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      _setAuthLoading(false);
    }
  }

  // // ----------------- BIOMETRIC AUTH + CLOCK -----------------
  // Future<void> authenticateAndClock(BuildContext context) async {
  //   try {
  //     _setAuthLoading(true);
  //     _setFailure(null);
  //     _setSuccess(null);

  //     // Ensure we have latest home data (status / clockOut)
  //     if (_homeData == null) {
  //       await getHomePro();
  //     }

  //     /// 2️⃣ Enrolled biometrics
  //     final biometrics = await auth.getAvailableBiometrics();
  //     if (biometrics.isEmpty) {
  //       _showInfo(
  //         context,
  //         "No fingerprint or face ID found.\nPlease enable it in Settings → Security.",
  //       );
  //       return;
  //     }
  //     final canBio = await auth.canCheckBiometrics;
  //     final canAuthenticate = canBio || await auth.isDeviceSupported();

  //     /// 1️⃣ Device support
  //     final isSupported = await auth.isDeviceSupported();
  //     if (!isSupported) {
  //       _showInfo(
  //         context,
  //         "Biometric authentication is not supported on this device.",
  //       );
  //       return;
  //     }
  //     if (!canAuthenticate) {
  //       _setAuthLoading(false);
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("Biometrics not available")),
  //       );
  //       return;
  //     }

  //     final didAuthenticate = await auth.authenticate(
  //       localizedReason: "Scan to continue",
  //       options: const AuthenticationOptions(
  //         biometricOnly: true,
  //         stickyAuth: true,
  //       ),
  //     );

  //     if (!didAuthenticate) {
  //       _setAuthLoading(false);
  //       return;
  //     }

  //     // Get fresh location for clock in/out
  //     final locationOk = await _getCurrentLocation();
  //     if (!locationOk) {
  //       _setAuthLoading(false);
  //       return;
  //     }

  //     // Decide clock-in vs clock-out
  //     if (_homeData?.status == true) {
  //       // Already clocked in -> clock out
  //       await clockOutPro();
  //     } else {
  //       // Not clocked in
  //       if (_homeData?.clockOut == null) {
  //         await clockInPro();
  //       } else {
  //         // Already completed both in & out today
  //         _setSuccess(null);
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Row(
  //               children: [
  //                 const Icon(Icons.close, color: Colors.white),
  //                 const SizedBox(width: 10),
  //                 const Expanded(
  //                   child: Text(
  //                     'Attendance already marked for today.',
  //                     style: TextStyle(color: Colors.white),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             backgroundColor: Colors.red.shade500,
  //             behavior: SnackBarBehavior.floating,
  //             elevation: 8,
  //             margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
  //             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(14),
  //             ),
  //           ),
  //         );
  //       }
  //     }

  //     // Show success message (if any)
  //     if (_success != null) {
  //       final isAlready = _success!.message.contains('Already');

  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Row(
  //             children: [
  //               Icon(
  //                 isAlready ? Icons.close : Icons.check_circle,
  //                 color: Colors.white,
  //               ),
  //               const SizedBox(width: 10),
  //               Expanded(
  //                 child: Text(
  //                   _success!.message,
  //                   style: const TextStyle(color: Colors.white),
  //                 ),
  //               ),
  //             ],
  //           ),
  //           backgroundColor:
  //               isAlready ? Colors.red.shade500 : Colors.green.shade600,
  //           behavior: SnackBarBehavior.floating,
  //           elevation: 8,
  //           margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
  //           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(14),
  //           ),
  //         ),
  //       );
  //     }

  //     // Show failure (if any)
  //     if (_failure != null) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(_failure!.message ?? 'Something went wrong'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text("Error: $e")));
  //   } finally {
  //     _setAuthLoading(false);
  //   }
  // }

  // // ----------------- LOCATION PERMISSIONS + CURRENT LOCATION old woking code-----------------
  // Future<bool> _getCurrentLocation() async {
  //   bool serviceEnabled;
  //   LocationPermission permission;

  //   // Check service
  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     await Geolocator.openLocationSettings();
  //     return false;
  //   }

  //   // Check permission
  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       return false;
  //     }
  //   }

  //   if (permission == LocationPermission.deniedForever) {
  //     await Geolocator.openLocationSettings();
  //     return false;
  //   }

  //   // Get position
  //   final position = await Geolocator.getCurrentPosition(
  //     desiredAccuracy: LocationAccuracy.high,
  //   );

  //   _latitude = position.latitude;
  //   _longitude = position.longitude;

  //   currentPosition = LatLng(position.latitude, position.longitude);
  //   lastPosition = currentPosition;

  //   notifyListeners();
  //   return true;
  // }

  // ----------------- LOCATION PERMISSIONS + CURRENT LOCATION new woking code-----------------
  Future<bool> _getCurrentLocation(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1️⃣ Check LOCATION SERVICE (GPS)
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackBar(
        context,
        'GPS is disabled. Please enable location services to continue.',
        onTap: () async {
          await Geolocator.openLocationSettings();
        },
      );
      return false;
    }

    // 2️⃣ Check APP PERMISSION
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        _showSnackBar(
          context,
          'Location permission denied.',
          onTap: () async {
            await Geolocator.openAppSettings();
          },
        );
        return false;
      }
    }

    // 3️⃣ Permission permanently denied
    if (permission == LocationPermission.deniedForever) {
      _showSnackBar(
        context,
        'Location permission is denied. Please enable it from app settings to continue.',
        onTap: () async {
          await Geolocator.openAppSettings();
        },
      );
      return false;
    }

    // 4️⃣ Get current location
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    _latitude = position.latitude;
    _longitude = position.longitude;

    currentPosition = LatLng(position.latitude, position.longitude);
    lastPosition = currentPosition;

    notifyListeners();
    return true;
  }

  // ----------------- LIVE LOCATION TRACKING -----------------
  Future<void> _startTracking() async {
    // Avoid multiple subscriptions
    userPositionStream?.cancel();
    // Load previous saved distance first from shared prefence

    await _getTrackingData(); // This must run BEFORE stream listens

    totalDistance = totalDistancePrefData; // Continue from last saved value
    print("STARTING DISTANCE : $totalDistance");

    notifyListeners();
    const LocationSettings settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 1,
    );
    _startSendLocationTimer(); // ✅ START API TIMER
    userPositionStream = Geolocator.getPositionStream(
      locationSettings: settings,
    ).listen((position) async {
      final newLatLng = LatLng(position.latitude, position.longitude);

      // Distance calculation
      if (lastPosition != null) {
        final distance = Geolocator.distanceBetween(
          lastPosition!.latitude,
          lastPosition!.longitude,
          newLatLng.latitude,
          newLatLng.longitude,
        );
        totalDistance += distance;
      }

      lastPosition = newLatLng;
      currentPosition = newLatLng;
      print('123333333333333333');

      // Store values every update
      await _saveTrackingData();
      await _getTrackingData();

      // Update marker
      markers = {
        Marker(
          markerId: const MarkerId("CurrentLocation"),
          position: newLatLng,
          infoWindow: const InfoWindow(title: "You are here"),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
      };

      // Move camera if map is attached
      if (mapController != null) {
        mapController!.animateCamera(CameraUpdate.newLatLng(newLatLng));
      }

      print('123');

      notifyListeners();
    });
  }

  Future<void> stopLocationTracking() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('totalDistance');
    await prefs.remove('currentLatitude');
    await prefs.remove('currentLongitude');

    // reset provider variables
    totalDistance = 0.0;
    currentPosition = null;
    _currentPositionPrefData = null;
    lastPosition = null;

    // stop stream
    await userPositionStream?.cancel();
    _sendLocationTimer?.cancel();
    userPositionStream = null;

    _getTrackingData();

    notifyListeners();
  }

  // ----------------- MAP CONTROLLER -----------------
  void setMapController(GoogleMapController controller) {
    mapController = controller;

    if (currentPosition != null) {
      mapController!.animateCamera(CameraUpdate.newLatLng(currentPosition!));
    }

    notifyListeners();
  }

  // ----------------- CLEANUP -----------------
  @override
  void dispose() async {
    // stop stream
    await userPositionStream?.cancel();
    userPositionStream = null;
    mapController?.dispose();
    super.dispose();
  }

  Future<void> _saveTrackingData() async {
    print("SAVING DISTANCE : $totalDistance");
    print(
      "SAVING CURRENT POSITION : ${currentPosition?.latitude}, ${currentPosition?.longitude}",
    );
    final pref = await SharedPreferences.getInstance();
    await pref.setDouble('totalDistance', totalDistance);

    if (currentPosition != null) {
      await pref.setDouble('currentLatitude', currentPosition!.latitude);
      await pref.setDouble('currentLongitude', currentPosition!.longitude);
    }

    notifyListeners();
  }

  Future<void> _getTrackingData() async {
    final pref = await SharedPreferences.getInstance();
    final prefTotalDistance = await pref.getDouble('totalDistance');
    print('SharedPrefence total distance  : $prefTotalDistance');
    _totalDistancePrefData = prefTotalDistance ?? 0.0;
    notifyListeners();
    if (currentPosition != null) {
      final prefCurrentLatitude = await pref.getDouble('currentLatitude');
      print('SharedPrefence currentLatitude : $prefCurrentLatitude');
      final prefCurrentLongitude = await pref.getDouble('currentLongitude');
      print('SharedPrefence currentLongitude : $prefCurrentLongitude');
      _currentPositionPrefData = LatLng(
        prefCurrentLatitude ?? 0.0,
        prefCurrentLongitude ?? 0.0,
      );
      notifyListeners();
    }
  }

  void _showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSnackBar(
    BuildContext context,
    String message, {
    required VoidCallback onTap,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        elevation: 8,
        backgroundColor: const Color(0xFF1F2937), // Dark slate
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 4),

        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Color(0xFF22C55E), size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),

        action: SnackBarAction(
          label: 'SETTINGS',
          textColor: const Color(0xFF22C55E),
          onPressed: onTap,
        ),
      ),
    );
  }
}
