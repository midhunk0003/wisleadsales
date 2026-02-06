import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisdeals/core/failure.dart';
import 'package:wisdeals/core/success.dart';
import 'package:wisdeals/data/model/notification_model/notification_model.dart';
import 'package:wisdeals/domain/repository/notification_repository.dart';
import 'package:wisdeals/services/auth_services.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository notificationRepository;

  NotificationProvider({required this.notificationRepository});

  // ---------------- STATE ----------------
  bool _isLoading = false;
  Failure? _failure;
  Success? _success;

  List<String> _filterData = [];
  String _selectedFilter = "All";
  String? _notifiCount;

  List<NotificationList> _notificationListReal = [];
  List<NotificationList> _todayNotification = [];
  List<NotificationList> _yesterdayNotification = [];

  // ---------------- GETTERS ----------------
  bool get isLoading => _isLoading;
  Failure? get failure => _failure;
  Success? get success => _success;
  List<String> get filterData => _filterData;
  String get selectedFilter => _selectedFilter;

  String? get notifiCount => _notifiCount;

  List<NotificationList> get notificationListReal => _notificationListReal;
  List<NotificationList> get todayNotification => _todayNotification;
  List<NotificationList> get yesterdayNotification => _yesterdayNotification;

  List<NotificationList> _filteredToday = [];
  List<NotificationList> _filteredYesterday = [];

  List<NotificationList> get filteredToday => _filteredToday;
  List<NotificationList> get filteredYesterday => _filteredYesterday;

  // ---------------- FILTER ----------------
  void filterDatas() {
    _filterData = ["All", "Unread", "Expense", "Leave"];
    _selectedFilter = "All";
    notifyListeners();
  }

  void selectFilter(String value) {
    _selectedFilter = value;
    _applyFilter();
    notifyListeners();
  }

  // ---------------- API ----------------
  Future<void> getNotification() async {
    _isLoading = true;
    _failure = null;
    notifyListeners();

    final SharedPreferences pref = await SharedPreferences.getInstance();
    final token = pref.getString('token');

    final result = await notificationRepository.getNotification(token);

    result.fold(
      (failure) async {
        if (failure is AuthFailure) {
          print('vvvvvvvvvvvvvvvvvvvv...${failure.message}');
          await AuthService.forceLogout();
        }
        _failure = failure;
        _isLoading = false;
        notifyListeners();
      },
      (success) {
        _notificationListReal = success;
        final notifiListIsReadFalseCount =
            _notificationListReal.where((e) => e.isRead == false).toList();
        _notifiCount = notifiListIsReadFalseCount.length.toString();
        _separateTodayYesterday();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // ---------------- CLEAR FAILURE ----------------
  void clearFailure() {
    _failure = null;
    notifyListeners();
  }

  // ---------------- DATE SEPARATION ----------------
  // void _separateTodayYesterday() {
  //   _todayNotification.clear();
  //   _yesterdayNotification.clear();

  //   final today = DateFormat('dd/MM/yyyy').format(DateTime.now());

  //   for (final item in _notificationListReal) {
  //     if (item.createdAt == null) continue;
  //     if (item.createdAt == today) {
  //       _todayNotification.add(item);
  //       print('today notification : ${_todayNotification}');
  //       notifyListeners();
  //     } else {
  //       _yesterdayNotification.add(item);
  //       print('yesterday notification : ${_yesterdayNotification}');
  //     }
  //   }
  //   notifyListeners();
  //   _applyFilter(); // 👈 IMPORTANT
  // }

  void _separateTodayYesterday() {
    _todayNotification.clear();
    _yesterdayNotification.clear();

    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    for (final item in _notificationListReal) {
      if (item.createdAt == null) continue;

      final createdDateTime = DateTime.parse(item.createdAt!.toString());
      final createdDate = DateTime(
        createdDateTime.year,
        createdDateTime.month,
        createdDateTime.day,
      );

      if (createdDate == today) {
        _todayNotification.add(item);
        print('today notification ${_todayNotification}');
      } else if (createdDate == yesterday || createdDate.isBefore(yesterday)) {
        _yesterdayNotification.add(item);
        print('yesterday notification ${_todayNotification}');
      }
    }

    notifyListeners();
    _applyFilter(); // 👈 still valid
  }

  // void _applyFilter() {
  //   // default → show all
  //   _filteredToday = List.from(_todayNotification);
  //   _filteredYesterday = List.from(_yesterdayNotification);

  //   if (_selectedFilter == "Meetings") {
  //     _filteredToday =
  //         _filteredToday
  //             .where(
  //               (e) =>
  //                   e.title != null &&
  //                   e.title!.toLowerCase().contains("meeting"),
  //             )
  //             .toList();

  //     _filteredYesterday =
  //         _filteredYesterday
  //             .where(
  //               (e) =>
  //                   e.title != null &&
  //                   e.title!.toLowerCase().contains("meeting"),
  //             )
  //             .toList();
  //   } else if (_selectedFilter == "Unread") {
  //     _filteredToday = _filteredToday.where((e) => e.isRead == false).toList();
  //     _filteredYesterday =
  //         _filteredYesterday.where((e) => e.isRead == false).toList();
  //   } else if (_selectedFilter == "Enxpense") {
  //     print('expense');
  //   }
  // }

  void _applyFilter() {
    // default → show all
    _filteredToday = List.from(_todayNotification);
    _filteredYesterday = List.from(_yesterdayNotification);

    if (_selectedFilter == "Expense") {
      print('Expensecccccccccccc');
      _filteredToday =
          _filteredToday
              .where(
                (e) =>
                    e.title != null &&
                    e.title!.toLowerCase().contains("expense"),
              )
              .toList();

      _filteredYesterday =
          _filteredYesterday
              .where(
                (e) =>
                    e.title != null &&
                    e.title!.toLowerCase().contains("expense"),
              )
              .toList();
    } else if (_selectedFilter == "Unread") {
      _filteredToday = _filteredToday.where((e) => e.isRead == false).toList();
      _filteredYesterday =
          _filteredYesterday.where((e) => e.isRead == false).toList();
    } else if (_selectedFilter == "Leave") {
      print('Leavecccccccccccc');
      _filteredToday =
          _filteredToday
              .where(
                (e) =>
                    e.title != null && e.title!.toLowerCase().contains("leave"),
              )
              .toList();

      _filteredYesterday =
          _filteredYesterday
              .where(
                (e) =>
                    e.title != null && e.title!.toLowerCase().contains("leave"),
              )
              .toList();
    }
  }

  // add lead
  Future<void> readNotificationPro(String? notificationId) async {
    _isLoading = true;
    _success = null;
    _failure = null;
    notifyListeners();
    print('read notification provider.......');
    print('read notification go ${notificationId} .......');
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('token');
    print('token : ${token}');
    final result = await notificationRepository.readNotification(
      token,
      notificationId ?? '',
    );

    result.fold(
      (failure) {
        _failure = failure;
        _isLoading = false;
        notifyListeners();
      },
      (success) {
        _success = success;
        print('success message in provider : ${success.message}');
        _isLoading = false;
        notifyListeners();
      },
    );
  }
}
