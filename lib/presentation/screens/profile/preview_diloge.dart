import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

import 'package:wisdeals/core/api_end_point.dart';

/// ================= FILE PREVIEW DIALOG =================
void showFilePreviewDialog(
  BuildContext context,
  String filePath,
  bool isNetwork,
) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) {
      print("sssssssssssssssssss ${filePath}");
      return Dialog(
        insetPadding: const EdgeInsets.all(12),
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            children: [
              /// ---------------- HEADER ----------------
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Preview",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              const Divider(color: Colors.white24, height: 1),

              /// ---------------- CONTENT ----------------
              Expanded(
                child: Builder(
                  builder: (_) {
                    /// ---------- IMAGE ----------
                    if (isImageFile(filePath)) {
                      print("zzzzzzzzzzzzzzzzzzz");
                      return PhotoView(
                        imageProvider:
                            isNetwork
                                ? NetworkImage(
                                  '${ApiEndPoint.photoBaseUrl}${filePath}',
                                )
                                : FileImage(File(filePath)),
                        backgroundDecoration: const BoxDecoration(
                          color: Colors.black,
                        ),
                      );
                    }

                    /// ---------- PDF ----------
                    if (isPdfFile(filePath)) {
                      print("zzzzzzzzzzzzzzzzzzzxxxxxxxxx");
                      return FutureBuilder<String>(
                        future: _preparePdfFile(filePath, isNetwork),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (snapshot.hasError || !snapshot.hasData) {
                            return const Center(
                              child: Text(
                                'Failed to load PDF',
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          }

                          return PDFView(
                            filePath: snapshot.data!,
                            enableSwipe: true,
                            swipeHorizontal: false,
                            autoSpacing: true,
                            pageFling: true,
                            onError: (error) {
                              debugPrint('PDF Error: $error');
                            },
                            onPageError: (page, error) {
                              debugPrint('PDF Page Error: $error');
                            },
                          );
                        },
                      );
                    }

                    /// ---------- OTHER FILES ----------
                    return Center(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final path =
                              isNetwork
                                  ? await _downloadFile(filePath)
                                  : filePath;
                          OpenFilex.open(path.toString());
                        },
                        icon: const Icon(Icons.open_in_new),
                        label: const Text("Open File"),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// ================= PDF PREPARATION =================
/// Converts network PDF to local & returns local path
Future<String> _preparePdfFile(String path, bool isNetwork) async {
  final dir = await getTemporaryDirectory();
  final fileName = path.split('/').last;
  final file = File('${dir.path}/$fileName');

  /// If already downloaded
  if (file.existsSync()) {
    return file.path;
  }

  if (isNetwork) {
    final url = '${ApiEndPoint.photoBaseUrl}$path';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      await file.writeAsBytes(response.bodyBytes);
      return file.path;
    } else {
      throw Exception('PDF download failed');
    }
  } else {
    return path;
  }
}

/// ================= DOWNLOAD & OPEN =================
Future<String> _downloadFile(String path) async {
  final dir = await getTemporaryDirectory();
  final fileName = path.split('/').last;
  final file = File('${dir.path}/$fileName');

  if (file.existsSync()) return file.path;

  final url = '${ApiEndPoint.photoBaseUrl}$path';
  final response = await http.get(Uri.parse(url));
  await file.writeAsBytes(response.bodyBytes);

  return file.path;
}

/// ================= FILE TYPE HELPERS =================
bool isImageFile(String path) {
  final lower = path.toLowerCase();
  return lower.endsWith('.jpg') ||
      lower.endsWith('.jpeg') ||
      lower.endsWith('.png');
}

bool isPdfFile(String path) {
  return path.toLowerCase().endsWith('.pdf');
}
