import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

bool validateDateTime(
  BuildContext context,
  String selectedDate,
  String fromTime,
  String toTime,
) {
  final dateFormat = DateFormat('dd-MM-yyyy hh:mm a');

  try {
    final fromDateTime = dateFormat.parse('$selectedDate $fromTime');
    final toDateTime = dateFormat.parse('$selectedDate $toTime');

    if (toDateTime.isBefore(fromDateTime)) {
      showFloatingSnackBar(
        context,
        'End time cannot be before start time!',
        isError: true,
      );
      return false;
    } else {
      // showFloatingSnackBar(context, 'Valid time range!', isError: false);
      return true;
    }
  } catch (e) {
    showFloatingSnackBar(context, 'Error parsing date/time!', isError: true);
    return false;
  }
}

void showFloatingSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message, style: const TextStyle(color: Colors.white)),
      backgroundColor: isError ? Colors.red : Colors.green,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
    ),
  );
}
