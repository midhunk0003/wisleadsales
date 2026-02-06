import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:wisdeals/core/api_end_point.dart';
import 'package:wisdeals/presentation/provider/expanse_provider.dart';
import 'package:wisdeals/presentation/screens/expanse/widgets/showBottomSheet_widget.dart';

class SelectImageFileAndCameraWidget extends StatelessWidget {
  final ExpanseProvider expanseProvider;
  const SelectImageFileAndCameraWidget({
    super.key,
    required this.isTablet,
    required this.expanseProvider,
  });

  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DottedBorder(
        color: Colors.green, // Border color
        strokeWidth: 2, // Border thickness
        dashPattern: [6, 3], // Length of dash and gap
        borderType: BorderType.RRect, // Rectangle or Circle
        radius: const Radius.circular(12),
        child: InkWell(
          onTap: () {
            showPickerBottomSheet(context, expanseProvider);
          },
          child: Container(
            // height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child:
                (expanseProvider.netWorkImage == null ||
                        expanseProvider.netWorkImage!.isEmpty ||
                        expanseProvider.selectedFile != null)
                    ? (expanseProvider.selectedFile == null ||
                            expanseProvider.selectedFile!.path.isEmpty)
                        ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/uploadicon.png',
                              width: 24,
                              height: 24,
                            ),
                            Text(
                              'Upload Receipt',
                              style: TextStyle(
                                fontFamily: "MontrealSerial",
                                color: Colors.white,
                                fontSize: isTablet ? 28 : 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        )
                        : (expanseProvider.selectedFile!.path
                                .toLowerCase()
                                .endsWith('.jpg') ||
                            expanseProvider.selectedFile!.path
                                .toLowerCase()
                                .endsWith('.jpeg') ||
                            expanseProvider.selectedFile!.path
                                .toLowerCase()
                                .endsWith('.png') ||
                            expanseProvider.selectedFile!.path
                                .toLowerCase()
                                .endsWith('.gif') ||
                            expanseProvider.selectedFile!.path
                                .toLowerCase()
                                .endsWith('.bmp'))
                        ? Image(
                          image: FileImage(
                            File('${expanseProvider.selectedFile!.path}'),
                          ),
                          fit: BoxFit.cover,
                        )
                        : (expanseProvider.selectedFile!.path.endsWith('.pdf'))
                        ? Container(
                          // height: 100,
                          width: 120,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.picture_as_pdf,
                                color: Colors.red,
                                size: 40,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                expanseProvider.selectedFile!.path
                                    .split('/')
                                    .last,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ],
                          ),
                        )
                        : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.insert_drive_file,
                                color: Colors.blue,
                                size: 40,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                expanseProvider.selectedFile!.path
                                    .split('/')
                                    .last,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ],
                          ),
                        )
                    : Image(
                      image: NetworkImage(
                        '${ApiEndPoint.photoBaseUrl}${expanseProvider.netWorkImage}',
                      ),
                      fit: BoxFit.cover,
                    ),
          ),
        ),
      ),
    );
  }
}
