import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisdeals/core/failure.dart';
import 'package:wisdeals/core/success.dart';
import 'package:wisdeals/data/model/leave_attendance_model/leave_attendance_model.dart';
import 'package:wisdeals/data/model/leave_type_model/leave_type_model.dart';
import 'package:wisdeals/domain/repository/attendance_and_leave_repository.dart';

class LeaveAndAttendanceProvider extends ChangeNotifier {
  final ScrollController dateScrollController = ScrollController();
  final AttendanceAndLeaveRepository attendanceAndLeaveRepository;

  // LeaveAndAttendanceProvider({required this.attendanceAndLeaveRepository});

  bool _isLoading = false;
  bool _isLoadingDelete = false;
  bool _isLoadingAddLeave = false;
  bool _hideAndShowContainerIndex = false;
  int? _hideAndShowContainerIndexEditindex;
  String? _selectedLeaveDateFrom;
  String? _selectedLeaveDateTo;
  String? _selectedTimeTo;
  DateTime _selectedDate = DateTime.now();
  List<DateTime> _monthDays = [];
  List<String> _leaveType = [];
  List<LeaveTypeData> _LeaveTypeList = [];
  String? _selectedLeave;
  File? _selectedFile;
  Failure? _failure;
  Success? _success;

  // leave and attendance
  LeaveAttendanceModel? _leaveData;

  final ImagePicker imagePicker = ImagePicker();

  // getter
  bool get isLoading => _isLoading;
  bool get isLoadingDelete => _isLoadingDelete;
  bool get isLoadingAddLeave => _isLoadingAddLeave;
  DateTime get selectedDate => _selectedDate;
  bool get hideAndShowContainerIndex => _hideAndShowContainerIndex;
  int? get hideAndShowContainerIndexEditindex =>
      _hideAndShowContainerIndexEditindex;
  String? get selectedLeaveDateFrom => _selectedLeaveDateFrom;
  String? get selectedLeaveDateTo => _selectedLeaveDateTo;
  String? get selectedTimeTo => _selectedTimeTo;

  List<DateTime> get monthDays => _monthDays;

  List<String> get leaveType => _leaveType;
  List<LeaveTypeData> get LeaveTypeList => _LeaveTypeList;

  String? get selectedLeave => _selectedLeave;
  File? get selectedFile => _selectedFile;

  Failure? get failure => _failure;
  Success? get success => _success;

  LeaveAttendanceModel? get leaveData => _leaveData;

  LeaveAndAttendanceProvider({required this.attendanceAndLeaveRepository}) {
    _generateMonthDays(_selectedDate);
  }

  void _generateMonthDays(DateTime date) {
    final firstDay = DateTime(date.year, date.month, 1);
    final lastDay = DateTime(date.year, date.month + 1, 0);

    _monthDays = List.generate(
      lastDay.day,
      (index) => DateTime(date.year, date.month, index + 1),
    );

    notifyListeners();
  }

  void clearMeetingDataleave() {
    _selectedLeave = null;
    _selectedLeaveDateFrom = null;
    _selectedLeaveDateTo = null;
    _selectedFile = null;
    notifyListeners();
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    print('selected date in provider: $_selectedDate');
    // If month changes, regenerate that month's days
    _generateMonthDays(date);
    notifyListeners();
  }

  // applay leave

  /// Optional: For displaying the current month and year
  String get currentMonthYear => DateFormat('MMM-yyyy').format(_selectedDate);

  void hideAndShowContainer(bool isEdit, int index) {
    if (isEdit) {
      print("Editing leave for index: $index");

      // Hide main apply section when editing
      _hideAndShowContainerIndex = false;

      // toggle edit section
      if (_hideAndShowContainerIndexEditindex == index) {
        _hideAndShowContainerIndexEditindex = null; // collapse
      } else {
        _hideAndShowContainerIndexEditindex = index; // expand selected
      }

      notifyListeners();
      return;
    }

    // If adding leave, close all edit sections
    _hideAndShowContainerIndexEditindex = null;

    print("Showing Add Leave Form");

    // Toggle add leave section
    _hideAndShowContainerIndex = !_hideAndShowContainerIndex;

    notifyListeners();
  }

  // void hideAndShowContainer(bool ifedit, int index) {
  //   if (ifedit) {
  //     print('if edit true show edit leave : ${ifedit}');
  //     if (_hideAndShowContainerIndexEditindex == index) {
  //       _hideAndShowContainerIndexEditindex = null; // collapse
  //     } else {
  //       _hideAndShowContainerIndexEditindex = index; // expand selected
  //     }
  //     notifyListeners();
  //   } else {
  //     print('if false show add leave : ${ifedit}');
  //     _hideAndShowContainerIndex = !_hideAndShowContainerIndex;
  //   }

  //   print('${_hideAndShowContainerIndex}');
  //   notifyListeners();
  // }
  void clearFailure() {
    _failure = null;
    notifyListeners();
  }

  Future<void> setSelectedDatefrom(BuildContext context) async {
    final DateTime today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // current date
      firstDate: today, // earliest date
      lastDate: DateTime(2100), // latest date
    );
    if (pickedDate != null) {
      String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
      _selectedLeaveDateFrom = formattedDate;
      notifyListeners();
    }
  }

  Future<void> setSelectedDateTo(BuildContext context) async {
    final DateTime today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // current date
      firstDate: today, // earliest date
      lastDate: DateTime(2100), // latest date
    );
    if (pickedDate != null) {
      String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
      _selectedLeaveDateTo = formattedDate;
      notifyListeners();
    }
  }

  // // get leave
  // void getLeaveType() {
  //   _leaveType = ["Casual Leave", "LOP", "Sick Leave"];
  //   notifyListeners();
  // }

  void setSelectedLeave(String? value) {
    _selectedLeave = value;
    notifyListeners();
  }

  Future<void> pickCameraAndGallery(ImageSource source) async {
    final XFile? image = await imagePicker.pickImage(source: source);
    if (image != null) {
      _selectedFile = File(image.path);
      notifyListeners();
    }
  }

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      _selectedFile = File(result.files.single.path!);
      notifyListeners();
    }
  }

  /*******************crud function start***************** */

  Future<void> addLeaveProvider(
    String? leaveTypeId,
    String? dateFrom,
    String? dateTo,
    String? reason,
    String? file,
  ) async {
    _isLoadingAddLeave = true;
    _success = null;
    _failure = null;
    notifyListeners();
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('token');
    print('token : ${token}');
    final result = await attendanceAndLeaveRepository.addLeave(
      token,
      leaveTypeId,
      dateFrom,
      dateTo,
      reason,
      file,
    );
    result.fold(
      (failure) {
        _failure = failure;
        _isLoadingAddLeave = false;
        notifyListeners();
      },
      (success) {
        _success = success;
        print('success add meeting : ${success.message}');
        _isLoadingAddLeave = false;
        notifyListeners();
      },
    );
  }

  Future<void> updateLeaveProvider(
    String? id,
    String? leaveType,
    String? dateFrom,
    String? dateTo,
    String? reason,
    String? file,
  ) async {
    _isLoadingAddLeave = true;
    _success = null;
    _failure = null;
    notifyListeners();
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('token');
    print('token : ${token}');
    final result = await attendanceAndLeaveRepository.updateLeave(
      token,
      id,
      leaveType,
      dateFrom,
      dateTo,
      reason,
      file,
    );
    result.fold(
      (failure) {
        _failure = failure;
        _isLoadingAddLeave = false;
        notifyListeners();
      },
      (success) {
        _success = success;
        print('success add meeting : ${success.message}');
        _isLoadingAddLeave = false;
        notifyListeners();
      },
    );
  }

  Future<void> getLeaveAndAttendancePro(String? date) async {
    _isLoading = true;
    _success = null;
    _failure = null;
    notifyListeners();
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('token');
    print('token : ${token}');
    final result = await attendanceAndLeaveRepository.getLeaveAndAttendance(
      token,
      date,
    );
    result.fold(
      (failure) {
        _failure = failure;
        _isLoading = false;
        notifyListeners();
      },
      (success) {
        _leaveData = success;
        print('leave data : ${success}');
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> deleteLeavePro(String? leaveId) async {
    _isLoadingDelete = true;
    _success = null;
    _failure = null;
    notifyListeners();
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('token');
    print('token : ${token}');
    final result = await attendanceAndLeaveRepository.deleteLeave(
      token,
      leaveId,
    );

    result.fold(
      (failure) {
        _failure = failure;
        _isLoadingDelete = false;
        notifyListeners();
      },
      (success) {
        _success = success;
        _isLoadingDelete = false;
        notifyListeners();
      },
    );
  }

  // scroll to selected date and current date
  void scrollToSelectedDate() {
    final index = monthDays.indexWhere(
      (d) =>
          d.day == selectedDate.day &&
          d.month == selectedDate.month &&
          d.year == selectedDate.year,
    );
    print('scroll to index : ${index - 5}');

    final indexd = index - 5;
    if (indexd == -1) return;

    double itemWidth = 60;
    double spacing = 10;

    double target = (itemWidth + spacing) * indexd;

    dateScrollController.animateTo(
      target - 150, // center
      duration: Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  Future<void> getLeaveTypePro() async {
    _isLoading = true;
    _success = null;
    _failure = null;
    notifyListeners();
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('token');
    print('token : ${token}');
    final result = await attendanceAndLeaveRepository.getLeaveTypes(token);
    result.fold(
      (failure) {
        _failure = failure;
        _isLoading = false;
        notifyListeners();
      },
      (success) {
        _LeaveTypeList = success;
        print('leave type list : ${success}');
        _isLoading = false;
        notifyListeners();
      },
    );
  }
}
