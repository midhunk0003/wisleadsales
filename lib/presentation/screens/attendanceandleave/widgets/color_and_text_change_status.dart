import 'package:flutter/material.dart';

Color getStatusColor(String status) {
  switch (status) {
    case 'Approved':
      return Colors.blue;
    case 'Pending':
      return Colors.orange;
    case 'Rejected':
      return Colors.red;
    default:
      return Colors.grey;
  }
}

// String getTextColor(String status) {
//   switch (status) {
//     case 'Approved':
//       return Colors.blue;
//     case 'Pending':
//       return Colors.orange;
//     case 'Rejected':
//       return Colors.red;
//     default:
//       return Colors.grey;
//   }
// }
