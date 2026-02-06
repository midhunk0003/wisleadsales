import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisdeals/core/failure.dart';
import 'package:wisdeals/core/success.dart';
import 'package:wisdeals/data/model/expanse_model/expanse_model.dart';
import 'package:wisdeals/data/model/expanse_model/expense_travel_type_model/expense_travel_type_model.dart';
import 'package:wisdeals/data/model/expanse_model/expenses_payment_mode_model/expenses_payment_mode_model.dart';
import 'package:wisdeals/domain/repository/expanse_repository.dart';

class ExpanseProvider extends ChangeNotifier {
  final ExpanseRepository expanseRepository;

  ExpanseProvider({required this.expanseRepository});

  bool _isLoading = false;
  Success? _success;
  Failure? _failure;
  List<Map<String, dynamic>> _filterExpanseData = [];
  List<String>? _expanseType;
  List<String>? _paymentType;
  String? _expanseSelectedValue;
  String? _paymentSelectedValue;
  File? _selectedFile;
  ExpanseModel? _getExpanse;
  List<ExpanseData>? _expanseList;
  List<ExpanseData>? _expanseSearchList;
  List<ExpenseTravelData>? _expenseTravelTypeList;
  List<ExpensesPaymentModeList>? _expensesPaymentModeList;

  String? _totalClaimed;
  String? _totalApproved;
  String? _totalPending;
  String? _totalRejected;

  String? _selectedStatus;

  String? _netWorkImage;

  // getter
  bool get isLoading => _isLoading;
  Success? get success => _success;
  Failure? get failure => _failure;
  List<Map<String, dynamic>> get filterExpanseData => _filterExpanseData;
  List<String>? get expanseType => _expanseType;
  List<String>? get paymentType => _paymentType;

  String? get expanseSelectedValue => _expanseSelectedValue;
  String? get paymentSelectedValue => _paymentSelectedValue;

  File? get selectedFile => _selectedFile;
  String searchQuery = '';

  final ImagePicker imagePicker = ImagePicker();
  ExpanseModel? get getExpanse => _getExpanse;
  List<ExpanseData>? get expanseList => _expanseList;
  List<ExpanseData>? get expanseSearchList =>
      (searchQuery.isEmpty) ? _expanseList : _expanseSearchList;
  List<ExpenseTravelData>? get expenseTravelTypeList => _expenseTravelTypeList;
  List<ExpensesPaymentModeList>? get expensesPaymentModeList =>
      _expensesPaymentModeList;

  // lead counts
  String? get totalClaimed => _totalClaimed;
  String? get totalApproved => _totalApproved;
  String? get totalPending => _totalPending;
  String? get totalRejected => _totalRejected;

  String? get selectedStatus => _selectedStatus;

  String? get netWorkImage => _netWorkImage;
  // function

  void searchLeadList(String? query) {
    searchQuery = query!.toLowerCase().trim() ?? '';
    print('search query in provider : ${searchQuery}');
    _expanseSearchList =
        _expanseList?.where((expanse) {
          final clientName = expanse.clientName?.toLowerCase() ?? '';
          // final expenseType = expanse.expenseType?.toLowerCase() ?? '';
          final amount = expanse.amount?.toLowerCase() ?? '';
          // final paymentMode = expanse.paymentMode?.toLowerCase() ?? '';
          return clientName.contains(searchQuery) ||
              amount.contains(searchQuery);
        }).toList();
    print('searchdLeadList in provider : ${_expanseSearchList}');
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

  void getFilterExpansePro() {
    _filterExpanseData = [
      {
        'amount': '₹${_totalClaimed ?? '0'}',
        'title': 'Total Claimed',
        'status': '',
      },
      {
        'amount': '₹${_totalApproved ?? '0'}',
        'title': 'Approved',
        'status': 'Approved',
      },
      {
        'amount': '₹${_totalPending ?? '0'}',
        'title': ' Pending',
        'status': 'Pending',
      },
      {
        'amount': '₹${_totalRejected ?? '0'}',
        'title': 'Rejected',
        'status': 'Rejected',
      },
    ];
    notifyListeners();
  }

  void selectFilterStatus(String? status) {
    _selectedStatus = status;
    notifyListeners();
  }

  void dropdownItemsExpanseAndTravel() {
    _expanseType = ["Travel", "Food", "lodging"];
    _paymentType = ["Cash", "Card", "Online Payment"];
    print('${expanseType}');
    print('${paymentType}');
    notifyListeners();
  }

  void expanseSelected(String? value) {
    _expanseSelectedValue = value;
    notifyListeners();
  }

  void paymentSelected(String? value) {
    _paymentSelectedValue = value;
    notifyListeners();
  }

  void uploadedNetWorkImage(String? networkImages) {
    _netWorkImage = networkImages;
    print('network image : ${networkImages}');
    notifyListeners();
  }

  void clearselectedImage() {
    _selectedFile = null;
    notifyListeners();
  }

  void clearNetworkimage() {
    _netWorkImage = null;
    print('net work : ${_netWorkImage}');
    notifyListeners();
  }

  void clearDataExpanse() {
    _expanseSelectedValue = null;
    _paymentSelectedValue = null;
    _selectedFile = null;
    notifyListeners();
    //  = null;
  }

  Color changeStatusColor(String? status) {
    switch (status) {
      case 'Pending':
        return Colors.orange.withOpacity(0.50);
      case 'Approved':
        return Colors.green.withOpacity(0.50);
      case 'Rejected':
        return Colors.red.withOpacity(0.50);
      default:
        return Colors.grey;
    }
  }

  /// insert
  Future<void> addExpanseData(
    String? clientName,
    String? CompanyName,
    String? expanseTypeId,
    String? amount,
    String? paymentTypeId,
    String? file,
    String? note,
  ) async {
    _isLoading = true;
    _success = null;
    _failure = null;
    notifyListeners();
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('token');
    print('token : ${token}');
    final result = await expanseRepository.addExpanse(
      token,
      clientName,
      CompanyName,
      expanseTypeId,
      amount,
      paymentTypeId,
      file,
      note,
    );
    result.fold(
      (failure) {
        _failure = failure;
        _isLoading = false;
        notifyListeners();
      },
      (success) {
        _success = success;
        print('success add meeting : ${success.message}');
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> getExpansePro(String? status) async {
    _isLoading = true;
    _success = null;
    _failure = null;
    notifyListeners();
    print('aaaaaaaaaa : ${status}');
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('token');
    print('token : ${token}');
    final result = await expanseRepository.getExpanse(token, status);
    result.fold(
      (failure) {
        _failure = failure;
        _isLoading = false;
        notifyListeners();
      },
      (success) {
        _getExpanse = success;
        _expanseList = success.data;

        // calculated amount
        _totalClaimed = _getExpanse!.total.toString();
        _totalApproved = _getExpanse!.approved.toString();
        _totalPending = _getExpanse!.pending.toString();
        _totalRejected = _getExpanse!.rejected.toString();
        print('success get expansessss : ${_totalApproved}');
        getFilterExpansePro();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void clearFailure() {
    _failure = null;
    notifyListeners();
  }

  // update
  Future<void> updateExpanseData(
    String? id,
    String? clientName,
    String? CompanyName,
    String? expanseTypeId,
    String? amount,
    String? paymentTypeId,
    String? file,
    String? note,
  ) async {
    _isLoading = true;
    _success = null;
    _failure = null;
    notifyListeners();
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('token');
    print('token : ${token}');
    final result = await expanseRepository.updateExpanse(
      token,
      id,
      clientName,
      CompanyName,
      expanseTypeId,
      amount,
      paymentTypeId,
      file,
      note,
    );
    result.fold(
      (failure) {
        _failure = failure;
        _isLoading = false;
        notifyListeners();
      },
      (success) {
        _success = success;
        print('success add meeting : ${success.message}');
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> getExpanseTravelTypePro() async {
    _isLoading = true;
    _success = null;
    _failure = null;
    notifyListeners();
    // print('aaaaaaaaaa : ${status}');
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('token');
    print('token : ${token}');
    final result = await expanseRepository.getExpenseTravelType(token);
    result.fold(
      (failure) {
        _failure = failure;
        _isLoading = false;
        notifyListeners();
      },
      (success) {
        _expenseTravelTypeList = success;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> getExpansePaymentModePro() async {
    _isLoading = true;
    _success = null;
    _failure = null;
    notifyListeners();
    // print('aaaaaaaaaa : ${status}');
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('token');
    print('token : ${token}');
    final result = await expanseRepository.getExpensePaymentMode(token);
    result.fold(
      (failure) {
        _failure = failure;
        _isLoading = false;
        notifyListeners();
      },
      (success) {
        _expensesPaymentModeList = success;
        _isLoading = false;
        notifyListeners();
      },
    );
  }
}
