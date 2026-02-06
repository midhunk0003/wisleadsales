import 'dart:io';

import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisdeals/core/failure.dart';
import 'package:wisdeals/core/success.dart';
import 'package:wisdeals/data/model/profile_model/profile_model.dart';
import 'package:wisdeals/domain/repository/profile_repository.dart';
import 'package:wisdeals/presentation/screens/profile/DocumentType.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wisdeals/services/auth_services.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository profileRepository;

  ProfileProvider({required this.profileRepository});

  bool _isLoading = false;
  bool _isSaveLoading = false;
  ProfileData? _profileDatas;
  Failure? _failure;
  Success? _success;
  File? _selectedFile;
  File? _resumeFile;
  String? _profileImgg;
  File? _addressProofFile;
  final ImagePicker imagePicker = ImagePicker();
  CameraController? _cameraController;

  // getter

  bool get isLoading => _isLoading;
  bool get isSaveLoading => _isSaveLoading;
  ProfileData? get profileDatas => _profileDatas;
  Failure? get failure => _failure;
  Success? get success => _success;
  File? get selectedFile => _selectedFile;
  String? get profileImgg => _profileImgg;
  File? get resumeFile => _resumeFile;
  File? get addressProofFile => _addressProofFile;
  CameraController? get cameraController => _cameraController;

  // functions

  // get data
  void clearFailure() {
    _selectedFile = null;
    _failure = null;
    notifyListeners();
  }

  void clearSelectedImages() {
    _selectedFile = null;
    _addressProofFile = null;
    _resumeFile = null;
    notifyListeners();
  }

  Future<void> getProfilImgFromShared() async {
    final prefs = await SharedPreferences.getInstance();
    _profileImgg = prefs.getString('profileImage');
    print('get shared image image........................ ${_profileImgg}');
    notifyListeners();
  }

  Future<void> initFrontCamera() async {
    try {
      if (_cameraController != null && _cameraController!.value.isInitialized) {
        return; // ❗ prevent double init
      }

      final cameras = await availableCameras();

      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      notifyListeners();
    } catch (e) {
      debugPrint('Front camera init error: $e');
    }
  }

  Future<void> captureSelfie() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized)
      return;

    final picture = await _cameraController!.takePicture(); // INTERNAL

    _selectedFile = File(picture.path); // Convert immediately
    print('selfi picture : ${_selectedFile}');
    notifyListeners();
  }

  // Camera / Gallery
  Future<void> pickCameraAndGallery(
    ImageSource source,
    DocumentType type,
  ) async {
    final XFile? image = await imagePicker.pickImage(source: source);

    if (image != null) {
      final file = File(image.path);

      if (type == DocumentType.resume) {
        _resumeFile = file;
      } else {
        _addressProofFile = file;
      }
      notifyListeners();
    }
  }

  // Future<void> pickCameraAndGallery(
  //   ImageSource source,
  //   DocumentType type,
  // ) async {
  //   final XFile? image = await imagePicker.pickImage(source: source);

  //   if (image != null) {
  //     File? compressedFile;

  //     // Check if the image is already under 3MB
  //     final fileSize = await File(image.path).length();
  //     final fileSizeInMB = fileSize / (1024 * 1024);

  //     if (fileSizeInMB > 3) {
  //       // Compress the image
  //       final compressedBytes = await FlutterImageCompress.compressWithFile(
  //         image.path,
  //         minWidth: 1024, // Set maximum width
  //         minHeight: 1024, // Set maximum height
  //         quality: 85, // Quality percentage (85% is usually good)
  //         format: CompressFormat.jpeg, // You can also use CompressFormat.png
  //       );

  //       if (compressedBytes != null) {
  //         // Create a temporary file for compressed image
  //         final tempDir = await getTemporaryDirectory();
  //         final targetPath =
  //             '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

  //         compressedFile = await File(targetPath).writeAsBytes(compressedBytes);

  //         // Check if compressed file is under 3MB
  //         final compressedSize = await compressedFile.length();
  //         final compressedSizeInMB = compressedSize / (1024 * 1024);

  //         if (compressedSizeInMB > 3) {
  //           // If still too large, compress more aggressively
  //           final moreCompressedBytes =
  //               await FlutterImageCompress.compressWithFile(
  //                 targetPath,
  //                 minWidth: 800,
  //                 minHeight: 800,
  //                 quality: 70,
  //               );

  //           if (moreCompressedBytes != null) {
  //             compressedFile = await File(
  //               targetPath,
  //             ).writeAsBytes(moreCompressedBytes);
  //           }
  //         }
  //       }
  //     }

  //     final file = compressedFile ?? File(image.path);

  //     if (type == DocumentType.resume) {
  //       _resumeFile = file;
  //     } else {
  //       _addressProofFile = file;
  //     }
  //     notifyListeners();
  //   }
  // }

  // File picker (PDF / DOC / Images)
  Future<void> pickFile(DocumentType type) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);

      if (type == DocumentType.resume) {
        _resumeFile = file;
      } else {
        _addressProofFile = file;
      }
      notifyListeners();
    }
  }

  void disposeCamera() {
    _cameraController?.dispose();
    _cameraController = null;
  }

  Future<void> getProfileData() async {
    _isLoading = true;
    _failure = null;
    notifyListeners();
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('token');
    print('token : ${token}');
    final result = await profileRepository.getProfile(token);
    result.fold(
      (failure) async {
        if (failure is AuthFailure) {
          print('vvvvvvvvvvvvvvvvvvvv...${failure.message}');
          await AuthService.forceLogout();
        }
        _failure = failure;
        _isLoading = false;
        notifyListeners();
      },
      (success) {
        _profileDatas = success;
        print(
          'xxxxxxxxxxxxxxx.......................... xxxxxxxxxxxxxxx${success.isActive}',
        );
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> addProfileVerificationPro(
    String? userId,
    String? profilePhoto,
    String? resume,
    String? addressProff,
    String? accountNumber,
    String? accountName,
    String? ifscCode,
  ) async {
    _isSaveLoading = true;
    _failure = null;
    notifyListeners();
    // 🔹 Print file sizes
    await _printFileSize("Selected File", _selectedFile);
    await _printFileSize("Resume File", _resumeFile);
    await _printFileSize("Address Proof File", _addressProofFile);
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('token');
    print('token : ${token}');
    final result = await profileRepository.uploadProfileVerification(
      token,
      userId,
      profilePhoto,
      resume,
      addressProff,
      accountNumber,
      accountName,
      ifscCode,
    );
    result.fold(
      (failure) async {
        if (failure is AuthFailure) {
          print('vvvvvvvvvvvvvvvvvvvv...${failure.message}');
          await AuthService.forceLogout();
        }
        _failure = failure;
        _isSaveLoading = false;
        notifyListeners();
      },
      (success) {
        _success = success;
        _isSaveLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> _printFileSize(String label, File? file) async {
    if (file == null) {
      debugPrint('$label: No file');
      return;
    }

    final bytes = await file.length();
    final kb = bytes / 1024;
    final mb = kb / 1024;

    debugPrint(
      '$label → '
      '${bytes} bytes | '
      '${kb.toStringAsFixed(2)} KB | '
      '${mb.toStringAsFixed(2)} MB | '
      '${mb <= 3 ? "✓ Under 3MB" : "✗ Over 3MB"}',
    );
  }
}
