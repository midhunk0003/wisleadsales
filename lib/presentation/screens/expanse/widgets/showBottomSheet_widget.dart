import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wisdeals/presentation/provider/expanse_provider.dart';

void showPickerBottomSheet(
  BuildContext context,
  ExpanseProvider expanseProvider,
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
                expanseProvider.pickCameraAndGallery(ImageSource.camera);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                expanseProvider.pickCameraAndGallery(ImageSource.gallery);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file),
              title: const Text('File'),
              onTap: () {
                expanseProvider.pickFile();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    },
  );
}
