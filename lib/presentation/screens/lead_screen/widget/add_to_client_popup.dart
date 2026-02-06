import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdeals/core/colors.dart';

void addToClientPopup<T extends ChangeNotifier>(
  BuildContext context, {
  required Future<void> Function() AddToCLient,
  required String? textMain,
  required T provider,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Delete Confirmation",
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return const SizedBox.shrink();
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final scale = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
      );

      return ScaleTransition(
        scale: scale,
        child: ChangeNotifierProvider<T>.value(
          value: provider,
          child: Consumer<T>(
            builder: (context, provider, _) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                title: Column(
                  children: [
                    Icon(Icons.person_add, size: 48, color: Colors.red),
                    const SizedBox(height: 10),
                    Text(
                      "${textMain}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                content: Text("Are you sure you want to ${textMain}?"),
                actions: [
                  TextButton(
                    onPressed:
                        (provider as dynamic).isLoadingDelete
                            ? null
                            : () {
                              Navigator.of(context).pop();
                            },
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed:
                        (provider as dynamic).isLoadingDelete
                            ? null
                            : () async {
                              await AddToCLient(); // Call the passed function
                              // if (context.mounted) {
                              //   Navigator.of(context).pop();
                              //   // Show success dialog
                              //   if (provider.success != null) {
                              //     showCustomLoginFailedDialog(
                              //       context,
                              //       '${provider.success!.message}',
                              //       'Success',
                              //       Icons.check,
                              //       Colors.green,
                              //     );
                              //   }
                              // }
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kButtonColor2,
                      foregroundColor: Colors.white,
                    ),
                    child:
                        (provider as dynamic).isLoadingDelete
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Text(
                              "Convert to client",
                              style: TextStyle(color: Colors.black),
                            ),
                  ),
                ],
              );
            },
          ),
        ),
      );
    },
  );
}
