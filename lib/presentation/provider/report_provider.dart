import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisdeals/core/failure.dart';
import 'package:wisdeals/data/model/profile_model/profile_model.dart';
import 'package:wisdeals/data/model/report_model/report_model.dart';
import 'package:wisdeals/domain/repository/report_repository.dart';
import 'package:wisdeals/services/auth_services.dart';

class ReportProvider extends ChangeNotifier {
  final ReportRepository reportRepository;

  ReportProvider({required this.reportRepository});

  bool _isLoading = false;
  List<Map<String, dynamic>> _range = [];
  List<Map<String, dynamic>> _type = [];
  Failure? _failure;
  ReportModel? _reportModel;
  String? _selectedRange;
  String? _selectedType;

  // getter
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get range => _range;
  List<Map<String, dynamic>> get type => _type;
  Failure? get failure => _failure;
  ReportModel? get reportModel => _reportModel;
  String? get selectedRange => _selectedRange;
  String? get selectedType => _selectedType;

  void getRange() {
    _range = [
      {'title': 'Today', 'range': 'today'},
      {'title': 'This Week', 'range': 'thisWeek'},
      {'title': 'This Month', 'range': 'thisMonth'},
      {'title': 'Custom', 'range': 'custom'},
    ];
    notifyListeners();
  }

  void getType() {
    _type = [
      {'title': 'Attendance', 'type': 'attendance'},
      {'title': 'Expense', 'type': 'expenses'},
      {'title': 'Clients', 'type': 'clients'},
      {'title': 'Leads', 'type': 'leads'},
    ];
    notifyListeners();
  }

  void selectedRangePro(String? value) {
    _selectedRange = value;
    notifyListeners();
  }

  void selectedTypePro(String? value) {
    _selectedType = value;
    notifyListeners();
  }

  void clearFailure() {
    print('clear failure called');
    _failure = null;
    notifyListeners();
  }

  // /// Total amount by report type for Pie Chart
  // Map<String, double> getTotalByType() {
  //   final Map<String, double> totals = {};
  //   for (var item in _reportData) {
  //     final type = item['type'] as String;
  //     final amount = (item['amount'] as num).toDouble();
  //     totals[type] = (totals[type] ?? 0) + amount;
  //   }
  //   return totals;
  // }

  // /// Daily total for Line/Bar Chart
  // Map<String, double> getDailyTotals() {
  //   final Map<String, double> dailyTotals = {};
  //   for (var item in _reportData) {
  //     final date = item['date'];
  //     final amount = (item['amount'] as num).toDouble();
  //     dailyTotals[date] = (dailyTotals[date] ?? 0) + amount;
  //   }
  //   return dailyTotals;
  // }

  Future<void> getReportPro(
    String? type,
    String? range,
    String? startDate,
    String? endDate,
  ) async {
    _isLoading = true;
    _failure = null;
    notifyListeners();
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('token');
    print('token : ${token}');
    final result = await reportRepository.getReport(
      token,
      type,
      range,
      startDate,
      endDate,
    );
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
        _reportModel = success;
        _isLoading = false;
        notifyListeners();
      },
    );
  }
}
