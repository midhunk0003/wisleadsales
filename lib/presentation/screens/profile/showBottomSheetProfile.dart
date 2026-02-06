import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wisdeals/presentation/provider/profile_provider.dart';
import 'package:wisdeals/presentation/screens/profile/DocumentType.dart';

void showPickerBottomSheetProfile(
  BuildContext context,
  ProfileProvider profileProvider,
  DocumentType type,
) {
  showModalBottomSheet(
    context: context,
    builder: (contex) {
      return SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                profileProvider.pickCameraAndGallery(ImageSource.camera, type);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                profileProvider.pickCameraAndGallery(ImageSource.gallery, type);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file),
              title: const Text('File'),
              onTap: () {
                profileProvider.pickFile(type);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    },
  );
}
