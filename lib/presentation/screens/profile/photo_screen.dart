import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdeals/presentation/provider/profile_provider.dart';
import 'package:wisdeals/widgets/custom_appbar_widget.dart';
import 'package:wisdeals/widgets/reusable_scafold_and_glowbackground.dart';

class PhotoScreen extends StatefulWidget {
  const PhotoScreen({Key? key}) : super(key: key);

  @override
  State<PhotoScreen> createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {
  @override
  void initState() {
    super.initState();

    /// Initialize ONLY front camera
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProfileProvider>(context, listen: false).clearFailure();
      Provider.of<ProfileProvider>(context, listen: false).initFrontCamera();
    });
  }

  @override
  void dispose() {
    Provider.of<ProfileProvider>(context, listen: false).disposeCamera();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ReusableScafoldAndGlowbackground(
      child: Consumer<ProfileProvider>(
        builder: (context, provider, _) {
          /// Show captured image
          if (provider.selectedFile != null) {
            return Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Image.file(provider.selectedFile!, fit: BoxFit.cover),

                      /// Capture button
                      Positioned(
                        bottom: 70,
                        left: 0,
                        right: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    provider.clearFailure();
                                    provider.initFrontCamera();
                                  },
                                  child: const Text("Retake Selfie"),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text("ok"),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          /// Camera loading state
          if (provider.cameraController == null ||
              !provider.cameraController!.value.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          /// Camera preview
          return Column(
            children: [
              SizedBox(height: 50),
              CustomAppBarWidget(
                title: 'Take Photo',
                notificationIconImage: false,
                drawerIconImage: false,
              ),
              Stack(
                children: [
                  CameraPreview(provider.cameraController!),

                  /// Capture button
                  Positioned(
                    bottom: 30,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: FloatingActionButton(
                        onPressed: provider.captureSelfie,
                        child: const Icon(Icons.camera_alt),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
