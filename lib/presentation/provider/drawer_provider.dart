import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DrawerProvider extends ChangeNotifier {
  bool _isLoading = false;

  List<Map<String, dynamic>>? _listOfData;

  List<Map<String, dynamic>>? get listOfdata => _listOfData;

  String? _userName;
  String? _userImage;
  String? _userEmail;
  String? _role;

  String? get userName => _userName;
  String? get userImage => _userImage;
  String? get userEmail => _userEmail;
  String? get role => _role;

  void drawerListData() {
    _listOfData = [
      {
        'iconImage': "assets/images/drawericons/clints.png",
        'title': "My Clients",
        'route': '/bottomnavbarwidget',
      },
      {
        'iconImage': "assets/images/drawericons/leadmanagment.png",
        'title': "My Leads",
        'route': '/leadlistscreen',
      },
      {
        'iconImage': "assets/images/drawericons/meeting.png",
        'title': "Meetings",
        'route': '/meetinglistscreen',
      },
      {
        'iconImage': "assets/images/drawericons/expanse.png",
        'title': "Expense",
        'route': '/expanselistscreen',
      },
      {
        'iconImage': "assets/images/drawericons/reports.png",
        'title': "Reports & Analysis",
        'route': '/bottomnavbarwidget',
      },
      {
        'iconImage': "assets/images/drawericons/Attendance.png",
        'title': "Attendance & Leave",
        'route': '/attendanceandleavescreen',
      },
      {
        'iconImage': "assets/images/drawericons/Notification.png",
        'title': "Notification",
        'route': '/notificationscreen',
      },
      {
        'iconImage': "assets/images/drawericons/Help.png",
        'title': "Settings",
        'route': '/bottomnavbarwidget',
      },
    ];
    notifyListeners();
  }

  Future<void> getUserDetail() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    _userName = await pref.getString('name') ?? '';
    _userImage = await pref.getString('profileImage') ?? '';
    _userEmail = await pref.getString('email') ?? '';
    _role = await pref.getString('role') ?? '';
    print('${_userName}');
    print('${_userImage}');
    print('${_userEmail}');
    notifyListeners();
  }
}
