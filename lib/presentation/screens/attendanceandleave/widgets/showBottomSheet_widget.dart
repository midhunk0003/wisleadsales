import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wisdeals/presentation/provider/expanse_provider.dart';
import 'package:wisdeals/presentation/provider/leave_and_attendance_provider.dart';

void showPickerBottomSheetLeave(
  BuildContext context,
  LeaveAndAttendanceProvider leaveProvider,
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
                leaveProvider.pickCameraAndGallery(ImageSource.camera);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                leaveProvider.pickCameraAndGallery(ImageSource.gallery);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file),
              title: const Text('File'),
              onTap: () {
                leaveProvider.pickFile();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    },
  );
}
